*** Settings ***
Documentation     5G SON Usecase functionality

Library           RequestsLibrary
Library           OperatingSystem
Library           Collections
Library           String
Library           DateTime
Library           SSHLibrary
Library           JSONLibrary
Library           Process
Library           ONAPLibrary.JSON
Library           ONAPLibrary.Utilities
Resource          ../../resources/policy_interface.robot
Resource          ../../resources/mr_interface.robot
Resource          ../../resources/dcae/ves_interface.robot
Resource          ../../resources/usecases/5gbulkpm_interface.robot
Suite Teardown    SON Usecase Teardown

*** Variables ***

${POLICY_TYPE_PATH}                 /policy/api/v1/policytypes
${CL_DATA_PATH}                     ${POLICY_TYPE_PATH}/onap.policies.controlloop.operational.common.Drools/versions/1.0.0/policies
${MONITORING_DATA_PATH}             ${POLICY_TYPE_PATH}/onap.policies.monitoring.docker.sonhandler.app/versions/1.0.0/policies
@{TOPICS}                           PCI-NOTIF-TOPIC-NGHBR-LIST-CHANGE-INFO   unauthenticated.SEC_FAULT_OUTPUT   unauthenticated.VES_MEASUREMENT_OUTPUT   unauthenticated.DCAE_CL_OUTPUT   DCAE_CL_RSP   SDNR-CL
${DMAAP_MR_URL}                     ${GLOBAL_MR_SERVER_PROTOCOL}://${GLOBAL_INJECTED_MR_IP_ADDR}:${GLOBAL_MR_SERVER_PORT}
${INVENTORY_SERVER}                 ${GLOBAL_INVENTORY_SERVER_PROTOCOL}://${GLOBAL_INVENTORY_SERVER_NAME}:${GLOBAL_INVENTORY_SERVER_PORT}
${DEPLOYMENT_SERVER}                ${GLOBAL_DEPLOYMENT_HANDLER_SERVER_PROTOCOL}://${GLOBAL_DEPLOYMENT_HANDLER_SERVER_NAME}:${GLOBAL_DEPLOYMENT_HANDLER_SERVER_PORT}
${INVENTORY_ENDPOINT}               /dcae-service-types
${DEPLOYMENT_ENDPOINT}              dcae-deployments
${DEPLOY_DATA_PATH}                 /policy/pap/v1/pdps/policies
${5GSON_RESOURCES_PATH}             ${EXECDIR}/robot/assets/usecases/5gson
${CONFIGDB_BLUEPRINT_PATH}          ${5GSON_RESOURCES_PATH}/k8s-configdb.yaml
${BLUEPRINT_TEMPLATE_PATH}          ${EXECDIR}/robot/assets/usecases/5gbulkpm/blueprintTemplate.json
${CONFIGDB_INSERT_PATH}             /api/sdnc-config-db/v3/insertData
${CONFIGDB_CREATENBR_PATH}          /api/sdnc-config-db/v3/createNbr
@{NEW_NBRS}                         Chn0012   Chn0116   Chn0071

*** Test Cases ***

Creating Policy Types
    [Tags]                              5gson
    ${monitoring_policy_type}=          Get Binary File                    ${5GSON_RESOURCES_PATH}/monitoring_policy_type.json
    ${resp}=                            Run Policy Api Post Request        data_path=${POLICY_TYPE_PATH}    data=${monitoring_policy_type}
    Should Be Equal As Strings          ${resp.status_code}                200

Creating SON Policies
    [Tags]                              5gson
    ${pci_policy}=                      Get Binary File                    ${5GSON_RESOURCES_PATH}/pci.json
    ${resp}=                            Run Policy Api Post Request        data_path=${CL_DATA_PATH}        data=${pci_policy}
    Should Be Equal As Strings          ${resp.status_code}                200
    ${anr_policy}=                      Get Binary File                    ${5GSON_RESOURCES_PATH}/anr.json
    ${resp}=                            Run Policy Api Post Request        data_path=${CL_DATA_PATH}        data=${anr_policy}
    Should Be Equal As Strings          ${resp.status_code}                200
    ${son_policy}=                      Get Binary File                    ${5GSON_RESOURCES_PATH}/son_monitoring.json
    ${resp}=                            Run Policy Api Post Request        data_path=${MONITORING_DATA_PATH}    data=${son_policy}
    Should Be Equal As Strings          ${resp.status_code}                200

Deploying SON Polciies
    [Tags]                              5gson
    ${pci_deploy}=                      Get Binary File                    ${5GSON_RESOURCES_PATH}/pci_deploy.json
    ${resp}=                            Run Policy Pap Post Request        data_path=${DEPLOY_DATA_PATH}    data=${pci_deploy}
    Should Be Equal As Strings          ${resp.status_code}                200
    ${anr_deploy}=                      Get Binary File                    ${5GSON_RESOURCES_PATH}/anr_deploy.json
    ${resp}=                            Run Policy Pap Post Request        data_path=${DEPLOY_DATA_PATH}    data=${anr_deploy}
    Should Be Equal As Strings          ${resp.status_code}                200
    ${son_deploy}=                      Get Binary File                    ${5GSON_RESOURCES_PATH}/son_deploy.json
    ${resp}=                            Run Policy Pap Post Request        data_path=${DEPLOY_DATA_PATH}    data=${son_deploy}
    Should Be Equal As Strings          ${resp.status_code}                200

Create dmaap topics
    [Tags]                              5gson
    :FOR   ${topic}   IN   @{TOPICS}
    \   ${data_path}=                   Set Variable                       /events/${topic}
    \   ${resp}=                        Run MR Post Request                data_path=${data_path}
    \   Should Be Equal As Strings      ${resp.status_code}                200

Deploy SON Handler
    [Tags]                              5gson
    ${headers}=                         Create Dictionary                  content-type=application/json
    ${session}=                         Create Session                     inv                              ${INVENTORY_SERVER}
    ${resp}=                            Get Request                        inv                              ${INVENTORY_ENDPOINT}?typeName=k8s-sonhms
    ${json}=                            Set Variable                       ${resp.json()}
    ${serviceTypeId-sonhms}             Set Variable                       ${json['items'][0]['typeId']}
    ${sonhms_inputs}=                   Get Binary File                    ${5GSON_RESOURCES_PATH}/sonhms_inputs.json
    ${deployment_data}=                 Set Variable                       {"serviceTypeId": "${serviceTypeId-sonhms}", "inputs": ${sonhms_inputs}}
    ${session}=                         Create Session                     deployment-son                   ${DEPLOYMENT_SERVER}
    ${resp}=                            Put Request                        deployment-son                   /${DEPLOYMENT_ENDPOINT}/sonhms         data=${deployment_data}     headers=${headers}
    ${operationLink}                    Set Variable                       ${resp.json().get('links').get('status')}
    ${operationId}                      Fetch From Right                   ${operationLink}                 /
    Wait Until Keyword Succeeds         5 minute                           20 sec                           Deployment Status       ${DEPLOYMENT_SERVER}     ${DEPLOYMENT_ENDPOINT}     sonhms     ${operationId}

Deploy Config DB
    [Tags]                              5gson
    ${configdb_blueprint_path}          Set Variable                       ${5GSON_RESOURCES_PATH}/k8s-configdb.yaml
    ${blueprint}=                       OperatingSystem.Get File           ${configdb_blueprint_path}
    ${templatejson}=                    Load JSON From File                ${BLUEPRINT_TEMPLATE_PATH}
    ${templatejson}=                    Update Value To Json               ${templatejson}                  blueprintTemplate             ${blueprint}
    ${templatejson}=                    Update Value To Json               ${templatejson}                  typeName                      configdb
    ${json_data}                        Convert JSON To String             ${templatejson}
    ${headers}=                         Create Dictionary                  content-type=application/json
    ${session}=                         Create Session                     sftp                             ${INVENTORY_SERVER}
    ${resp}=                            Post Request                       sftp                             ${INVENTORY_ENDPOINT}          data=${json_data}             headers=${headers}
    ${serviceTypeId-configdb}=          Set Variable                       ${resp.json().get('typeId')}
    Set Global Variable                 ${serviceTypeId-configdb}
    ${deployment_data}=                 Set Variable                       {"serviceTypeId": "${serviceTypeId-configdb}" }
    ${session}=                         Create Session                     deployment-configdb              ${DEPLOYMENT_SERVER}
    ${resp}=                            Put Request                        deployment-configdb              /${DEPLOYMENT_ENDPOINT}/configdb         data=${deployment_data}     headers=${headers}
    ${operationLink}=                   Set Variable                       ${resp.json().get('links').get('status')}
    ${operationId}                      Fetch From Right                   ${operationLink}                 /
    Wait Until Keyword Succeeds         2 minute                           5 sec                            Deployment Status       ${DEPLOYMENT_SERVER}     ${DEPLOYMENT_ENDPOINT}     configdb     ${operationId}

Load Data to Config DB
    [Tags]                              5gson
    Sleep                               30 seconds
    ${initial_dump}                     Get Binary File                    ${5GSON_RESOURCES_PATH}/dump_file.json
    ${headers}=                         Create Dictionary                  content-type=application/json
    ${session}=                         Create Session                     configdb                         http://configdb.onap:8080
    ${resp}=                            Put Request                        configdb                         ${CONFIGDB_INSERT_PATH}    data=${initial_dump}    headers=${headers}
    Should Be Equal As Strings          ${resp.status_code}                201

Post Fault Message to VES Collector
    [Tags]                              5gson
    ${session}=                         Create Session                     configdb                         http://configdb.onap:8080
    ${headers}=                         Create Dictionary                  content-type=application/json
    :FOR   ${NBR}   IN   @{NEW_NBRS}
    \   ${nbr_obj}                      Set Variable                       {"targetCellId": "${NBR}", "ho": true}
    \   ${resp}                         Put Request                        configdb                         ${CONFIGDB_CREATENBR_PATH}/Chn0005    headers=${headers}    data=${nbr_obj}
    \   Should Be Equal As Strings      ${resp.status_code}                201
    ${fault_event}=                     Set Variable                       ${5GSON_RESOURCES_PATH}/son_fault.json
    Send Event to VES Collector         event=${fault_event}

Verifying Modify Config message from SDNR-CL
    [Tags]                              5gson
    ${no_of_msgs}                       Set Variable                       ${0}
    Set Global Variable                 ${no_of_msgs}
    Wait Until Keyword Succeeds         4 minutes                          30 seconds                       Verify SDNC Dmaap Message

*** Keywords ***

SON Usecase Teardown
    Undeploy Service                    ${DEPLOYMENT_SERVER}               /${DEPLOYMENT_ENDPOINT}/sonhms
    Undeploy Service                    ${DEPLOYMENT_SERVER}               /${DEPLOYMENT_ENDPOINT}/configdb
    Undeploy Service                    ${INVENTORY_SERVER}                ${INVENTORY_ENDPOINT}/${serviceTypeId-configdb}

Verify SDNC Dmaap Message
    ${resp}=                            Run MR Get Request                 /events/SDNR-CL/robot-cg/robot-cid
    @{messages}=                        Set Variable                       ${resp.json()}
    Should Not Be Empty                 ${messages}
    :FOR   ${msg}   IN   @{messages}
    \   ${msg_json}=                    Convert String to JSON             ${msg}
    \   ${rpc_name}=                    Set Variable                       ${msg_json.get("rpc-name")}
    \   ${no_of_msgs}=                  Set Variable If                    "${rpc_name}" == "modifyconfig"    ${no_of_msgs + 1}
    Should Be Equal As Numbers          ${no_of_msgs}                      4
