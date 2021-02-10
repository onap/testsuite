*** Settings ***
Library          ONAPLibrary.Templating    WITH NAME    Templating
Library          ONAPLibrary.Utilities
Library          RequestsLibrary
Library          Collections
Library          String
Library          OperatingSystem
Resource         ../resources/global_properties.robot
Resource         ../resources/dcae/inventory.robot
Resource         ../resources/dcae/deployment.robot


*** Variables ***

${CLIENT_ID}                   robot123
${SESSION_NAME}                nifi-api
${DCAEMOD_SERVER}              http://dcaemod.simpledemo.onap.org

*** Keywords ***

Get Pod Yaml
    [Arguments]  ${compSpecName}
    ${podYaml} =  Run And Return Rc And Output  kubectl -n onap get pod $(kubectl get pod -n onap | grep ${compSpecName} | awk '{print $1}') -o yaml
    Should Be Equal As Integers  ${podYaml[0]}  0
    ${podYaml} =  Set Variable  ${podYaml[1]}

    [Return]  ${podYaml}

Get Content Of Mounted Folder Inside Container
    [Arguments]  ${compSpecName}  ${volumeMountPath}
    ${mountedFolderContent} =  Run And Return Rc And Output  kubectl -n onap exec $(kubectl get pod -n onap | grep ${compSpecName} | awk '{print $1}') -- ls ${volumeMountPath}
    Should Be Equal As Integers  ${mountedFolderContent[0]}  0
    ${mountedFolderContent} =  Set Variable  ${mountedFolderContent[1]}

    [Return]  ${mountedFolderContent}

Verify If Volume Is Mounted
    [Arguments]  ${podYaml}  ${volumeMountPath}
    Should Contain  ${podYaml}  ${volumeMountPath}

Verify If Config Map Is Mounted As Volume
    [Arguments]  ${podYaml}  ${volumeName}
    Should Contain  ${podYaml}  ${volumeName}

Verify If Mounted Folder Is Empty
    [Arguments]  ${mountedFolderContent}
    Should Be Empty  ${mountedFolderContent}


Is Component Onborded
    [Arguments]  ${compSpecName}
    ${session}=  Create Session   ${SESSION_NAME}  ${DCAEMOD_SERVER}
    ${headers}=  Create Dictionary  content-type=application/json
    ${resp} =  Get Request  ${SESSION_NAME}  /nifi-jars/  ${headers}
    Should Be True  ${resp.status_code} < 300
    Log  ${resp.json()}

    FOR  ${component}  IN  @{resp.json()}
         ${compFound}=  Get From Dictionary  ${component}  name
         ${compName}=  Fetch From Left  ${compFound}  marker=-
         ${onboardStatus}=  Set Variable If  '${compSpecName}' == '${compName}'  True  False
         Exit For Loop If  '${compSpecName}' == '${compName}'
    END

    Should Be Equal  ${onboardStatus}  True

Onboard Component Spec
    [Arguments]  ${componentSpec}  ${dict_values}  ${compSpecName}
    ${session}=  Create Session   ${SESSION_NAME}  ${DCAEMOD_SERVER}
    ${headers}=  Create Dictionary  content-type=application/json
    Templating.Create Environment  dcaemod  ${GLOBAL_TEMPLATE_FOLDER}
    ${componentSpec}=  Templating.Apply Template  dcaemod   ${componentSpec}  ${dict_values}
    ${resp} =  Post Request   ${SESSION_NAME}  /onboarding/components  data=${componentSpec}  headers=${headers}
    Should Be True  ${resp.status_code} < 300

    Wait Until Keyword Succeeds  5 min  20s  Is Component Onborded  ${compSpecName}
    Log  ${resp.json()}

Add Registry Client

    ${session}=  Create Session   ${SESSION_NAME}  ${DCAEMOD_SERVER}
    ${headers}=  Create Dictionary  content-type=application/json
    ${data} =  Set Variable  {"revision": {"version": 0}, "component": {"name": "registry", "uri": "http://dcaemod-nifi-registry:18080"}}
    ${resp} =  Post Request  ${SESSION_NAME}  /nifi-api/controller/registry-clients  data=${data}  headers=${headers}
    Should Be True  ${resp.status_code} < 300

Add Distribution Target

    ${session}=  Create Session   ${SESSION_NAME}  ${DCAEMOD_SERVER}
    ${headers}=  Create Dictionary  content-type=application/json
    ${data} =  Set Variable  {"name": "runtime", "runtimeApiUrl": "http://dcaemod-runtime-api:9090"}
    ${resp} =  Post Request  ${SESSION_NAME}  /distributor/distribution-targets  data=${data}  headers=${headers}
    Should Be True  ${resp.status_code} < 300

Create Process Group
    [Arguments]  ${name}
    ${session}=  Create Session   ${SESSION_NAME}  ${DCAEMOD_SERVER}
    ${headers}=  Create Dictionary  content-type=application/json
    ${resp} =  Get Request  ${SESSION_NAME}  /nifi-api/flow/process-groups/root/  headers=${headers}
    Should Be True  ${resp.status_code} < 300
    Log  ${resp.json()}
    ${parentGroupId} =  Set Variable  ${resp.json().get('processGroupFlow').get('id')}

    ${data} =  Set Variable  {"revision": {"clientId": "${CLIENT_ID}", "version": 0}, "component" : {"parentGroupId" : "${parentGroupId}", "name" : "${name}"}}
    ${resp} =  Post Request  ${SESSION_NAME}  /nifi-api/process-groups/${parentGroupId}/process-groups  data=${data}  headers=${headers}
    Should Be True  ${resp.status_code} < 300
    Log  ${resp.json()}

    ${processGroupId} =  Set Variable  ${resp.json().get('id')}

    [Return]  ${processGroupId}

Create Processor
    [Arguments]  ${processGroupId}  ${compSpecName}
    ${session}=  Create Session   ${SESSION_NAME}  ${DCAEMOD_SERVER}
    ${headers}=  Create Dictionary  content-type=application/json
    ${typeName} =  Evaluate  $compSpecName.title()
    ${data} =  Set Variable  {"revision": {"clientId": "${CLIENT_ID}", "version": 0},"component": {"parentGroupId": "${processGroupId}", "name": "${compSpecName}", "type": "org.onap.dcae.${typeName}"}}
    ${resp} =  Post Request  ${SESSION_NAME}  /nifi-api/process-groups/${processGroupId}/processors  data=${data}  headers=${headers}
    Should Be True  ${resp.status_code} < 300


Save Flow By Version Controlling
    [Arguments]  ${flowName}  ${processGroupId}

    ${session}=  Create Session   ${SESSION_NAME}  ${DCAEMOD_SERVER}
    ${headers}=  Create Dictionary  content-type=application/json

    ${registryId}  ${_} =  Get Registries
    ${resp} =  Get Request  ${SESSION_NAME}  /nifi-api/flow/registries/${registryId}/buckets  headers=${headers}
    Should Be True  ${resp.status_code} < 300
    Log  ${resp.json()}
    ${bucketId} =  Set Variable  ${resp.json().get('buckets')[0].get('id')}
    ${currentProcessGrVersion}  ${_}=  Get Process Group Revision  ${processGroupId}

    ${data} =  Set Variable  {"versionedFlow": {"flowName": "${flowName}", "bucketId": "${bucketId}", "registryId": "${registryId}"}, "processGroupRevision": {"clientId": "${CLIENT_ID}", "version": ${currentProcessGrVersion}}}
    ${versionControl_resp} =  Post Request  ${SESSION_NAME}  /nifi-api/versions/process-groups/${processGroupId}  data=${data}  headers=${headers}
    Should Be True  ${resp.status_code} < 300

Distribute The Flow
    [Arguments]  ${processGroupId}

    ${session}=  Create Session   ${SESSION_NAME}  ${DCAEMOD_SERVER}
    ${headers}=  Create Dictionary  content-type=application/json
    ${resp} =  Get Request  ${SESSION_NAME}  /nifi-api/process-groups/${processGroupId}  headers=${headers}
    Should Be True  ${resp.status_code} < 300
    Log  ${resp.json()}
    ${flowId} =  Set Variable  ${resp.json().get('component').get('versionControlInformation').get('flowId')}

    ${distributionId} =  Get Distribution Target ID

    ${data} =  Set Variable  {"processGroupId": "${flowId}"}
    ${distribute_resp} =  Post Request  ${SESSION_NAME}  /distributor/distribution-targets/${distributionId}/process-groups  data=${data}  headers=${headers}
    Should Be True  ${resp.status_code} < 300

Deploy Blueprint From Inventory
    [Arguments]  ${processGroupName}  ${compSpecName}
    ${blueprintName} =  Set Variable  ${processGroupName}_${compSpecName}
    ${resp} =  Wait Until Keyword Succeeds  7 min  20s  Get Blueprint From Inventory  ${blueprintName}
    ${typeId} =  Set Variable  ${resp.json().get('items')[0].get('typeId')}
    ${data} =  Set Variable  {"serviceTypeId": "${typeId}"}
    Deploy Service  ${data}  ${blueprintName}

    [Return]  ${typeId}  ${blueprintName}

Get Distribution Target ID

    ${session}=  Create Session   ${SESSION_NAME}  ${DCAEMOD_SERVER}
    ${headers}=  Create Dictionary  content-type=application/json
    ${resp} =  Get Request  ${SESSION_NAME}  /distributor/distribution-targets  headers=${headers}
    Should Be True  ${resp.status_code} < 300
    Log  ${resp.json()}
    ${distributionId} =  Set Variable  ${resp.json().get('distributionTargets')[0].get('id')}

    [Return]  ${distributionId}

Get Process Group Revision
     [Arguments]  ${processGroupId}
     ${session}=  Create Session   ${SESSION_NAME}  ${DCAEMOD_SERVER}
     ${headers}=  Create Dictionary  content-type=application/json
     ${resp} =  Get Request  ${SESSION_NAME}  /nifi-api/versions/process-groups/${processGroupId}  headers=${headers}
     Should Be True  ${resp.status_code} < 300
     ${currentProcessGrVersion} =  Set Variable  ${resp.json().get('processGroupRevision').get('version')}
     ${clientId} =  Set Variable  ${resp.json().get('processGroupRevision').get('clientId')}

     [Return]  ${currentProcessGrVersion}  ${clientId}

Get Registries

    ${session}=  Create Session   ${SESSION_NAME}  ${DCAEMOD_SERVER}
    ${headers}=  Create Dictionary  content-type=application/json
    ${resp} =  Get Request  ${SESSION_NAME}  /nifi-api/controller/registry-clients  headers=${headers}
    Should Be True  ${resp.status_code} < 300
    Log  ${resp.json()}
    ${registryId} =  Set Variable  ${resp.json().get('registries')[0].get('id')}
    ${version} =  Set Variable  ${resp.json().get('registries')[0].get('revision').get('version')}

    [Return]  ${registryId}  ${version}

Delete Distribution Target
    ${session}=  Create Session   ${SESSION_NAME}  ${DCAEMOD_SERVER}
    ${distributionId} =  Get Distribution Target ID
    ${resp} =  Delete Request  ${SESSION_NAME}  /distributor/distribution-targets/${distributionId}
    Should Be True  ${resp.status_code} < 300

Delete Process Group
    [Arguments]  ${processGroupId}
    ${session}=  Create Session   ${SESSION_NAME}  ${DCAEMOD_SERVER}
    ${currentProcessGrVersion}  ${clientId}=  Get Process Group Revision  ${processGroupId}
    ${resp} =  Delete Request  ${SESSION_NAME}  /nifi-api/process-groups/${processGroupId}?version=${currentProcessGrVersion}&clientId=${clientId}
    Should Be True  ${resp.status_code} < 300

Delete Registry Client
    ${session}=  Create Session   ${SESSION_NAME}  ${DCAEMOD_SERVER}
    ${registryId}  ${version} =  Get Registries
    ${resp} =  Delete Request  ${SESSION_NAME}  /nifi-api/controller/registry-clients/${registryId}?version=${version}
    Should Be True  ${resp.status_code} < 300

Usecase Setup
     Add Registry Client
     Add Distribution Target


Usecase Teardown

    Wait Until Keyword Succeeds  2 min  5s  Delete Distribution Target
    Wait Until Keyword Succeeds  2 min  5s  Delete Registry Client


Specific Teardown
    Run Keyword If  ${IS_PROCESS_GROUP_SET}  Run Keywords  Delete Process Group  ${PROCESS_GROUP_ID}
    ...                                               AND  Set Suite Variable  ${IS_PROCESS_GROUP_SET}  False
    Run Keyword If  ${IS_FLOW_DISTRIBUTED}   Run Keywords  Delete Blueprint From Inventory  ${TYPE_ID}
    ...                                               AND  Set Suite Variable  ${IS_FLOW_DISTRIBUTED}  False
    Run Keyword If  ${IS_SERVICE_DEPLOYED}    Run Keyword  Undeploy Service  ${BLUEPRINT_NAME}
    ...                                               AND  Set Suite Variable  ${IS_SERVICE_DEPLOYED}  False