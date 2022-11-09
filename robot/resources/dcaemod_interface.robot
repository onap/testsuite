*** Settings ***
Library          ONAPLibrary.Templating    WITH NAME    Templating
Library          ONAPLibrary.Utilities
Library          RequestsLibrary
Library          Collections
Library          String
Library          OperatingSystem
Resource         ../resources/global_properties.robot
Resource         chart_museum.robot


*** Variables ***

${CLIENT_ID}                                  robot123
${SESSION_NAME}                               nifi-api
${DCAEMOD_SERVER}                             http://dcaemod.simpledemo.onap.org
${IS_PROCESS_GROUP_SET}                       False
${IS_FLOW_DISTRIBUTED}                        False
${IS_SERVICE_DEPLOYED}                        False
${PROCESS_GROUP_ID}                           ${EMPTY}
${TYPE_ID}                                    ${EMPTY}
${BLUEPRINT_NAME}                             ${EMPTY}
${DISTRIBUTION_TARGET_ID}                     ${EMPTY}
${REGISTRY_CLIENT_ID}                         ${EMPTY}
${DCAEMOD_ONBOARDING_API_SERVER}              ${GLOBAL_DCAEMOD_ONBOARDING_API_SERVER_PROTOCOL}://${GLOBAL_DCAEMOD_ONBOARDING_API_SERVER_NAME}:${GLOBAL_DCAEMOD_ONBOARDING_API_SERVER_PORT}
${DCAEMOD_DESIGNTOOL_SERVER}                  ${GLOBAL_DCAEMOD_DESIGNTOOL_SERVER_PROTOCOL}://${GLOBAL_DCAEMOD_DESIGNTOOL_SERVER_NAME}:${GLOBAL_DCAEMOD_DESIGNTOOL_SERVER_PORT}
${DCAEMOD_DISTRIBUTOR_API_SERVER}             ${GLOBAL_DCAEMOD_DISTRIBUTOR_API_SERVER_PROTOCOL}://${GLOBAL_DCAEMOD_DISTRIBUTOR_API_SERVER_NAME}:${GLOBAL_DCAEMOD_DISTRIBUTOR_API_SERVER_PORT}
${HELM_RELEASE}                               kubectl --namespace onap get pods | sed 's/ .*//' | grep robot | sed 's/-.*//'


*** Keywords ***

Deploy DCAE Application
    [Arguments]  ${componentSpec}  ${dict_values}  ${compSpecName}  ${processGroupName}

    Onboard Component Spec  ${componentSpec}  ${dict_values}  ${compSpecName}
    ${processGroupId} =  Create Process Group  ${processGroupName}
    Set Test Variable  ${IS_PROCESS_GROUP_SET}  True
    Set Test Variable  ${PROCESS_GROUP_ID}  ${processGroupId}

    Create Processor  ${PROCESS_GROUP_ID}  ${compSpecName}
    Save Flow By Version Controlling  ${processGroupName}  ${PROCESS_GROUP_ID}
    Distribute The Flow  ${PROCESS_GROUP_ID}
    Set Test Variable  ${IS_FLOW_DISTRIBUTED}  True

    Deploy Applictaion  ${processGroupName}  ${compSpecName}
    Set Test Variable  ${CHART_NAME}  ${compSpecName}



Delete Config Map With Mounted Config File
    ${configMapStatus} =  Run Keyword And Return Status  Config Map Exists  ${CONFIG_MAP_NAME}
    Run Keyword If  ${configMapStatus}  Delete Config Map  ${CONFIG_MAP_NAME}
    Remove File  ${CONFIG_MAP_FILE}

Delete Config Map
    [Arguments]  ${configMapName}
    ${configMapDelete} =  Run And Return Rc  kubectl -n onap delete configmap ${configMapName}
    Should Be Equal As Integers  ${configMapDelete}  0

Create Config Map From File
    [Arguments]  ${configMapName}  ${configMapFilePath}

    ${createConfigMapRC} =  Run And Return Rc  kubectl -n onap create configmap ${configMapName} --from-file=${configMapFilePath}
    Should Be Equal As Integers  ${createConfigMapRC}  0
    Wait Until Keyword Succeeds  1 min  5s  Config Map Exists  ${configMapName}

Config Map Exists
    [Arguments]  ${configMapName}
    ${configMapExists} =  Run And Return Rc  kubectl -n onap get configmap | grep ${configMapName}
    Should Be Equal As Integers  ${configMapExists}  0

Get Pod Yaml
    [Arguments]  ${compSpecName}
    ${podYaml} =  Run And Return Rc And Output  kubectl -n onap get pod $(kubectl get pod -n onap | grep ${compSpecName} | awk '{print $1}') -o yaml
    Should Be Equal As Integers  ${podYaml[0]}  0
    ${podYaml} =  Set Variable  ${podYaml[1]}

    [Return]  ${podYaml}

Get Content Of Mounted Folder Inside Container
    [Arguments]  ${compSpecName}  ${volumeMountPath}
    ${mountedFolderContent} =  Run And Return Rc And Output  kubectl -n onap exec $(kubectl get pod -n onap | grep ${compSpecName} | awk '{print $1}') -c ${compSpecName} -- ls ${volumeMountPath}
    Should Be Equal As Integers  ${mountedFolderContent[0]}  0
    ${mountedFolderContent} =  Set Variable  ${mountedFolderContent[1]}

    [Return]  ${mountedFolderContent}

Verify If Volume Is Mounted
    [Arguments]  ${podYaml}  ${volumeMountPath}
    Should Contain  ${podYaml}  ${volumeMountPath}

Verify If Config Map Is Mounted As Volume
    [Arguments]  ${podYaml}  ${configMapName}
    Should Contain  ${podYaml}  ${configMapName}

Verify If Mounted Folder Is Empty
    [Arguments]  ${mountedFolderContent}
    Should Be Empty  ${mountedFolderContent}

Verify If Mounted Folder Contains File
    [Arguments]  ${compSpecName}  ${fileName}  ${configMapDir}

    ${dirContent} =  Run And Return Rc And Output  kubectl -n onap exec $(kubectl get pod -n onap | grep ${compSpecName} | awk '{print $1}') -c ${compSpecName} -- ls ${configMapDir}
    Should Be Equal As Integers  ${dirContent[0]}  0
    Should Contain  ${dirContent[1]}  ${fileName}

Verify File Content
    [Arguments]  ${compSpecName}  ${configMapFilePath}  ${content}

    ${fileContent} =  Run And Return Rc And Output  kubectl -n onap exec $(kubectl get pod -n onap | grep ${compSpecName} | awk '{print $1}') -c ${compSpecName} -- cat ${configMapFilePath}
    Should Be Equal As Integers  ${fileContent[0]}  0
    Should Contain  ${fileContent[1]}  ${content}

Verify If Component Is Onboarded
    [Arguments]  ${compSpecName}
    ${session}=  Create Session   ${SESSION_NAME}  ${DCAEMOD_ONBOARDING_API_SERVER}
    ${headers}=  Create Dictionary  content-type=application/json
    ${resp} =  Get Request  ${SESSION_NAME}  /onboarding/components?name=${compSpecName}  headers=${headers}
    Log  ${resp.json()}
    Should Not Be Empty  ${resp.json().get('components')}


Onboard Component Spec
    [Arguments]  ${componentSpec}  ${dict_values}  ${compSpecName}
    ${session}=  Create Session   ${SESSION_NAME}  ${DCAEMOD_ONBOARDING_API_SERVER}
    ${headers}=  Create Dictionary  content-type=application/json
    Templating.Create Environment  dcaemod  ${GLOBAL_TEMPLATE_FOLDER}
    ${componentSpec}=  Templating.Apply Template  dcaemod   ${componentSpec}  ${dict_values}
    ${resp} =  Post Request   ${SESSION_NAME}  /onboarding/components  data=${componentSpec}  headers=${headers}
    Should Be True  ${resp.status_code} < 300

    Wait Until Keyword Succeeds  2 min  5s  Verify If Component Is Onboarded  ${compSpecName}

    Log  ${resp.json()}

Add Registry Client

    ${session}=  Create Session   ${SESSION_NAME}  ${DCAEMOD_DESIGNTOOL_SERVER}
    ${headers}=  Create Dictionary  content-type=application/json
    ${data} =  Set Variable  {"revision": {"version": 0}, "component": {"name": "registry_test", "uri": "http://dcaemod-nifi-registry:18080"}}
    ${resp} =  Post Request  ${SESSION_NAME}  /nifi-api/controller/registry-clients  data=${data}  headers=${headers}
    Should Be True  ${resp.status_code} < 300

    Set Global Variable  ${REGISTRY_CLIENT_ID}  ${resp.json().get('id')}
    Set Global Variable  ${REGISTRY_CLIENT_VERSION}  ${resp.json().get('revision').get('version')}

Add Distribution Target

    ${session}=  Create Session   distributor  ${DCAEMOD_DISTRIBUTOR_API_SERVER}
    ${headers}=  Create Dictionary  content-type=application/json
    ${data} =  Set Variable  {"name": "runtime_test", "runtimeApiUrl": "http://dcaemod-runtime-api:9090"}
    ${resp} =  Post Request  distributor  /distributor/distribution-targets  data=${data}  headers=${headers}
    Should Be True  ${resp.status_code} < 300
    Set Global Variable  ${DISTRIBUTION_TARGET_ID}  ${resp.json().get('id')}

Create Process Group
    [Arguments]  ${name}
    ${session}=  Create Session   ${SESSION_NAME}  ${DCAEMOD_DESIGNTOOL_SERVER}
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


Verify If NIFI Processor Is Created
    [Arguments]  ${typeName}
    ${session}=  Create Session   ${SESSION_NAME}  ${DCAEMOD_DESIGNTOOL_SERVER}
    ${headers}=  Create Dictionary  content-type=application/json
    ${resp} =  Get Request  ${SESSION_NAME}  /nifi-api/flow/processor-types?type=org.onap.dcae.${typeName}  headers=${headers}
    Log  ${resp.json()}
    Should Not Be Empty  ${resp.json().get('processorTypes')}

Create Processor
    [Arguments]  ${processGroupId}  ${compSpecName}
    ${session}=  Create Session   ${SESSION_NAME}  ${DCAEMOD_DESIGNTOOL_SERVER}
    ${headers}=  Create Dictionary  content-type=application/json
    ${typeName} =  Evaluate  $compSpecName.title()
    ${typeName} =  Remove String  ${typeName}  -
    ${data} =  Set Variable  {"revision": {"clientId": "${CLIENT_ID}", "version": 0},"component": {"parentGroupId": "${processGroupId}", "name": "${compSpecName}", "type": "org.onap.dcae.${typeName}"}}
    Wait Until Keyword Succeeds  60s  5s  Verify If NIFI Processor Is Created  ${typeName}
    ${resp} =  Post Request  ${SESSION_NAME}  /nifi-api/process-groups/${processGroupId}/processors  data=${data}  headers=${headers}
    Should Be True  ${resp.status_code} < 300


Save Flow By Version Controlling
    [Arguments]  ${flowName}  ${processGroupId}

    ${session}=  Create Session   ${SESSION_NAME}  ${DCAEMOD_DESIGNTOOL_SERVER}
    ${headers}=  Create Dictionary  content-type=application/json

    ${resp} =  Get Request  ${SESSION_NAME}  /nifi-api/flow/registries/${REGISTRY_CLIENT_ID}/buckets  headers=${headers}
    Should Be True  ${resp.status_code} < 300
    Log  ${resp.json()}
    ${bucketId} =  Set Variable  ${resp.json().get('buckets')[0].get('id')}

    ${processGrVersion}  ${_}=  Get Process Group Revision  ${processGroupId}

    ${data} =  Set Variable  {"versionedFlow": {"flowName": "${flowName}", "bucketId": "${bucketId}", "registryId": "${REGISTRY_CLIENT_ID}"}, "processGroupRevision": {"clientId": "${CLIENT_ID}", "version": ${processGrVersion}}}
    ${resp} =  Post Request  ${SESSION_NAME}  /nifi-api/versions/process-groups/${processGroupId}  data=${data}  headers=${headers}
    Should Be True  ${resp.status_code} < 300

Distribute The Flow
    [Arguments]  ${processGroupId}
    ${session}=  Create Session   ${SESSION_NAME}  ${DCAEMOD_DESIGNTOOL_SERVER}
    ${session}=  Create Session   distributor  ${DCAEMOD_DISTRIBUTOR_API_SERVER}
    ${headers}=  Create Dictionary  content-type=application/json
    ${resp} =  Get Request  ${SESSION_NAME}  /nifi-api/process-groups/${processGroupId}  headers=${headers}
    Should Be True  ${resp.status_code} < 300
    Log  ${resp.json()}
    ${flowId} =  Set Variable  ${resp.json().get('component').get('versionControlInformation').get('flowId')}
    ${data} =  Set Variable  {"processGroupId": "${flowId}"}
    ${resp} =  Post Request  distributor  /distributor/distribution-targets/${DISTRIBUTION_TARGET_ID}/process-groups  data=${data}  headers=${headers}
    Should Be True  ${resp.status_code} < 300

Deploy Applictaion
     [Arguments]  ${processGroupName}  ${compSpecName}
     ${command_output} =                     Run And Return Rc And Output            helm repo update
     Should Be Equal As Integers             ${command_output[0]}                    0
     ${helm_install}=                        Set Variable                            helm install ${ONAP_HELM_RELEASE}-${compSpecName} chart-museum/${compSpecName} --set global.repository=${registry_ovveride}
     ${helm_install_command_output} =        Run And Return Rc And Output            ${helm_install}
     Log                                     ${helm_install_command_output[1]}
     Should Be Equal As Integers             ${helm_install_command_output[0]}       0
     Set Test Variable  ${IS_SERVICE_DEPLOYED}  True
     ${kubectl_patch}=                       Set Variable                            kubectl patch deployment ${ONAP_HELM_RELEASE}-${compSpecName} -p '{"spec":{"template":{"spec":{"containers":[{"name": "${compSpecName}","image":"docker.io/nginx:latest"}]}}}}'
     ${kubectl_patch_command_output}=        Run And Return Rc And Output            ${kubectl_patch}
     Log                                     ${kubectl_patch_command_output[1]}
     Should Be Equal As Integers             ${kubectl_patch_command_output[0]}       0
     Wait Until Keyword Succeeds             4 min                                    15s           Check NGINX Applictaion    ${compSpecName}

Check NGINX Applictaion
     [Arguments]    ${compSpecName}
      ${check_command}=                       Set Variable                             kubectl get deployment -n onap | grep ${compSpecName} | grep 1/1
      ${check_command_command_output}=        Run And Return Rc And Output             ${check_command}
      Log                                     ${check_command_command_output[1]}
      Should Be Equal As Integers             ${check_command_command_output[0]}       0

Undeploy Application
     [Arguments]  ${CHART_NAME}
     Uninstall helm charts               ${ONAP_HELM_RELEASE}-${CHART_NAME}

Get Process Group Revision
     [Arguments]  ${processGroupId}
     ${session}=  Create Session   ${SESSION_NAME}  ${DCAEMOD_DESIGNTOOL_SERVER}
     ${headers}=  Create Dictionary  content-type=application/json
     ${resp} =  Get Request  ${SESSION_NAME}  /nifi-api/versions/process-groups/${processGroupId}  headers=${headers}
     Should Be True  ${resp.status_code} < 300
     ${currentProcessGrVersion} =  Set Variable  ${resp.json().get('processGroupRevision').get('version')}
     ${clientId} =  Set Variable  ${resp.json().get('processGroupRevision').get('clientId')}

     [Return]  ${currentProcessGrVersion}  ${clientId}

Delete Distribution Target
    ${session}=  Create Session   distributor  ${DCAEMOD_DISTRIBUTOR_API_SERVER}
    ${resp} =  Delete Request  distributor  /distributor/distribution-targets/${DISTRIBUTION_TARGET_ID}
    Should Be True  ${resp.status_code} < 300

Delete Process Group
    [Arguments]  ${processGroupId}
    ${session}=  Create Session   ${SESSION_NAME}  ${DCAEMOD_DESIGNTOOL_SERVER}
    ${processGrVersion}  ${clientId}=  Get Process Group Revision  ${processGroupId}
    ${resp} =  Delete Request  ${SESSION_NAME}  /nifi-api/process-groups/${processGroupId}?version=${processGrVersion}&clientId=${clientId}
    Should Be True  ${resp.status_code} < 300

Delete Registry Client
    ${session}=  Create Session   ${SESSION_NAME}  ${DCAEMOD_DESIGNTOOL_SERVER}
    ${resp} =  Delete Request  ${SESSION_NAME}  /nifi-api/controller/registry-clients/${REGISTRY_CLIENT_ID}?version=${REGISTRY_CLIENT_VERSION}
    Should Be True  ${resp.status_code} < 300

Configure Nifi Registry And Distribution Target
     Restart Runtime API
     Add Registry Client
     Add Distribution Target
     Add chart repository                        chart-museum                  http://chart-museum:80      onapinitializer      demo123456!
     ${command_output} =                 Run And Return Rc And Output        ${HELM_RELEASE}
     Should Be Equal As Integers         ${command_output[0]}                0
     Set Global Variable   ${ONAP_HELM_RELEASE}   ${command_output[1]}

Restart Runtime API
      ${restart_command}=                       Set Variable                             kubectl delete pod $(kubectl get pods -n onap | grep dcaemod-runtime-api | awk '{print $1}') -n onap
      ${restart_command_command_output}=        Run And Return Rc And Output             ${restart_command}
      Log                                       ${restart_command_command_output[1]}
      Should Be Equal As Integers               ${restart_command_command_output[0]}       0
      Wait Until Keyword Succeeds  2 min  5s    Check Runtime API

Check Runtime API
      ${check_command}=                       Set Variable                             kubectl get pods -n onap | grep dcaemod-runtime-api | grep Running | grep 1/1
      ${check_command_command_output}=        Run And Return Rc And Output             ${check_command}
      Log                                     ${check_command_command_output[1]}
      Should Be Equal As Integers             ${check_command_command_output[0]}       0

Delete Nifi Registry And Distribution Target
    Run Keyword If  '${DISTRIBUTION_TARGET_ID}' != '${EMPTY}'  Wait Until Keyword Succeeds  2 min  5s  Delete Distribution Target
    Run Keyword If  '${REGISTRY_CLIENT_ID}' != '${EMPTY}'      Wait Until Keyword Succeeds  2 min  5s  Delete Registry Client

Delete Process Group And Deployment
    Run Keyword If  ${IS_PROCESS_GROUP_SET}  Run Keywords  Delete Process Group  ${PROCESS_GROUP_ID}
    ...                                               AND  Set Suite Variable  ${IS_PROCESS_GROUP_SET}  False
    Run Keyword If  ${IS_SERVICE_DEPLOYED}   Run Keywords  Undeploy Application   ${CHART_NAME}
    ...                                               AND  Set Suite Variable  ${IS_SERVICE_DEPLOYED}  False
