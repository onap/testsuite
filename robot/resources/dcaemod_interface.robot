*** Settings ***
Library          ONAPLibrary.Templating    WITH NAME    Templating
Library          ONAPLibrary.Utilities
Library          RequestsLibrary
Library          Collections
Resource         ../resources/global_properties.robot
Resource         ../resources/dcae/inventory.robot
Resource         ../resources/dcae/deployment.robot

*** Variables ***

${CLIENTID}                    robot123
${COMPONENT_SPEC}              dcaemod/dcaemod.jinja
${COMPONENT_NAME}              Kasia
${SESSION_NAME}                nifi-api
${DCAEMOD_SERVER}              http://dcaemod.simpledemo.onap.org

*** Keywords ***

Is Component Onborded

    ${session}=  Create Session   ${SESSION_NAME}  ${DCAEMOD_SERVER}
    ${headers}=  Create Dictionary  content-type=application/json
    ${resp} =  Get Request  ${SESSION_NAME}  /nifi-jars/  ${headers}
    Should Be True  ${resp.status_code} < 300
    Log  ${resp.json()}

    FOR  ${component}  IN  @{resp.json()}
         ${compFound}=  Get From Dictionary  ${component}  name
         ${compName}=  Fetch From Left  ${compFound}  marker=-
         ${onboardStatus}=  Set Variable If  '${COMPONENT_NAME}' == '${compName}'  True  False
         Exit For Loop If  '${COMPONENT_NAME}' == '${compName}'
    END

    Should Be Equal  ${onboardStatus}  True

Onboard Component Spec

    ${session}=  Create Session   ${SESSION_NAME}  ${DCAEMOD_SERVER}
    ${headers}=  Create Dictionary  content-type=application/json
    ${dict_values} =  Create Dictionary  name=${COMPONENT_NAME}
    Templating.Create Environment  dcaemod  ${GLOBAL_TEMPLATE_FOLDER}
    ${componentSpec}=  Templating.Apply Template  dcaemod   ${COMPONENT_SPEC}  ${dict_values}
    ${resp} =  Post Request   ${SESSION_NAME}  /onboarding/components  data=${componentSpec}  headers=${headers}
    Should Be True  ${resp.status_code} < 300

    Wait Until Keyword Succeeds  5 min  20s  Is Component Onborded  ${SESSION_NAME}  ${headers}
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

    ${session}=  Create Session   ${SESSION_NAME}  ${DCAEMOD_SERVER}
    ${headers}=  Create Dictionary  content-type=application/json
    ${resp} =  Get Request  ${SESSION_NAME}  /nifi-api/flow/process-groups/root/  headers=${headers}
    Should Be True  ${resp.status_code} < 300
    Log  ${resp.json()}
    ${parentGroupId} =  Set Variable  ${resp.json().get('processGroupFlow').get('id')}

    ${data} =  Set Variable  {"revision": {"clientId": "${CLIENTID}", "version": 0}, "component" : {"parentGroupId" : "${parentGroupId}", "name" : "${name}"}}
    ${resp} =  Post Request  ${SESSION_NAME}  /nifi-api/process-groups/${parentGroupId}/process-groups  data=${data}  headers=${headers}
    Should Be True  ${resp.status_code} < 300
    Log  ${resp.json()}

    ${processGroupId} =  Set Variable  ${resp.json().get('id')}

    Set Global Variable  ${PROCESS_GROUP_ID}  ${processGroupId}

Create Processor

    ${session}=  Create Session   ${SESSION_NAME}  ${DCAEMOD_SERVER}
    ${headers}=  Create Dictionary  content-type=application/json
    ${data} =  Set Variable  {"revision": {"clientId": "${CLIENTID}", "version": 0},"component": {"parentGroupId": "${PROCESS_GROUP_ID}", "name": "${COMPONENT_NAME}", "type": "org.onap.dcae.${COMPONENT_NAME}"}}
    ${resp} =  Post Request  ${SESSION_NAME}  /nifi-api/process-groups/${PROCESS_GROUP_ID}/processors  data=${data}  headers=${headers}
    Should Be True  ${resp.status_code} < 300


Save Flow By Version Controlling
    [Arguments]  ${name}

    ${session}=  Create Session   ${SESSION_NAME}  ${DCAEMOD_SERVER}
    ${headers}=  Create Dictionary  content-type=application/json

    ${registryId}  ${_} =  Get Registries
    ${resp} =  Get Request  ${SESSION_NAME}  /nifi-api/flow/registries/${registryId}/buckets  headers=${headers}
    Should Be True  ${resp.status_code} < 300
    Log  ${resp.json()}
    ${bucketId} =  Set Variable  ${resp.json().get('buckets')[0].get('id')}
    ${currentProcessGrVersion}  ${_}=  Get Process Group Revision

    ${data} =  Set Variable  {"versionedFlow": {"flowName": "${name}", "bucketId": "${bucketId}", "registryId": "${registryId}"}, "processGroupRevision": {"clientId": "${CLIENTID}", "version": ${currentProcessGrVersion}}}
    ${versionControl_resp} =  Post Request  ${SESSION_NAME}  /nifi-api/versions/process-groups/${PROCESS_GROUP_ID}  data=${data}  headers=${headers}
    Should Be True  ${resp.status_code} < 300

    [Return]  ${distributionId}  ${currentProcessGrVersion}  ${registryId}

Distribute The Flow

    ${session}=  Create Session   ${SESSION_NAME}  ${DCAEMOD_SERVER}
    ${headers}=  Create Dictionary  content-type=application/json
    ${resp} =  Get Request  ${SESSION_NAME}  /nifi-api/process-groups/${PROCESS_GROUP_ID}  headers=${headers}
    Should Be True  ${resp.status_code} < 300
    Log  ${resp.json()}
    ${flowId} =  Set Variable  ${resp.json().get('component').get('versionControlInformation').get('flowId')}

    ${distributionId} =  Get Distribution Target ID

    ${data} =  Set Variable  {"processGroupId": "${flowId}"}
    ${distribute_resp} =  Post Request  ${SESSION_NAME}  /distributor/distribution-targets/${distributionId}/process-groups  data=${data}  headers=${headers}
    Should Be True  ${resp.status_code} < 300

Deploy Blueprint From Inventory
    [Arguments]  ${typeName}

    ${resp} =  Wait Until Keyword Succeeds  7 min  20s  Get Blueprint From Inventory  ${typeName}
    ${typeId} =  Set Variable  ${resp.json().get('items')[0].get('typeId')}
    Set Global Variable  ${SERVICE_TYPE_ID}  ${typeId}
    ${data} =  Set Variable  {"serviceTypeId": "${typeId}"}
    Deploy Service  ${data}  ${typeName}

Get Distribution Target ID

    ${session}=  Create Session   ${SESSION_NAME}  ${DCAEMOD_SERVER}
    ${headers}=  Create Dictionary  content-type=application/json
    ${resp} =  Get Request  ${SESSION_NAME}  /distributor/distribution-targets  headers=${headers}
    Should Be True  ${resp.status_code} < 300
    Log  ${resp.json()}
    ${distributionId} =  Set Variable  ${resp.json().get('distributionTargets')[0].get('id')}

    [Return]  ${distributionId}

Get Process Group Revision

     ${session}=  Create Session   ${SESSION_NAME}  ${DCAEMOD_SERVER}
     ${headers}=  Create Dictionary  content-type=application/json
     ${resp} =  Get Request  ${SESSION_NAME}  /nifi-api/versions/process-groups/${PROCESS_GROUP_ID}  headers=${headers}
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

Delete Process Group

    ${session}=  Create Session   ${SESSION_NAME}  ${DCAEMOD_SERVER}
    ${currentProcessGrVersion}  ${clientId}=  Get Process Group Revision
    ${resp} =  Delete Request  ${SESSION_NAME}  /nifi-api/versions/process-groups/${PROCESS_GROUP_ID}?version=${currentProcessGrVersion}&clientId=${clientId}

Delete Registry Client
    [Arguments]  ${registryId}

    ${session}=  Create Session   ${SESSION_NAME}  ${DCAEMOD_SERVER}
    ${registryId}  ${version} =  Get Registries
    ${resp} =  Delete Request  ${SESSION_NAME}  /nifi-api/controller/registry-clients/${registryId}?version=${version}


Usecase Teardown
    Delete Distribution Target
    Delete Registry Client
    Delete Process Group
    Delete Blueprint From Inventory  ${SERVICE_TYPE_ID}
    #Undeploy Service