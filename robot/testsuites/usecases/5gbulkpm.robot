*** Settings ***
Documentation     5G Bulk PM Usecase functionality

Library           RequestsLibrary
Library           OperatingSystem
Library           Collections
Library           String
Library           DateTime
Library           SSHLibrary
Library           Process
Library           ONAPLibrary.JSON
Library           ONAPLibrary.Utilities
Resource          ../resources/usecases/5gbulkpm_interface.robot
Resource          ../resources/mr_interface.robot
Resource          ../resources/dr_interface.robot

*** Variables ***
${INVENTORY_ENDPOINT}               /dcae-service-types
${ONAP_GIT}                         https://git.onap.org
${DFC_BLUEPRINT_PATH}               /dcaegen2/collectors/datafile/plain/datafile-app-server/dpo/blueprints/k8s-datafile.yaml
${PMMAPPER_BLUEPRINT_PATH}          /dcaegen2/services/pm-mapper/plain/dpo/blueprints/k8s-pm-mapper.yaml
${XNF_SFTP_BLUEPRINT_PATH}          /var/opt/ONAP/robot/assets/usecases/5gbulkpm/k8s-sftp.yaml
${BLUEPRINT_TEMPLATE_PATH}          /var/opt/ONAP/robot/assets/usecases/5gbulkpm/blueprintTemplate.json
${DEPLOYMENT_ENDPOINT}              dcae-deployments
${MR_TOPIC_CHECK_PATH}              /topics
${DR_SUB_CHECK_PATH}                /internal/prov
${MR_TOPIC_UR_PATH}                 /events/org.onap.dmaap.mr.PERFORMANCE_MEASUREMENTS/CG1/C1
${DMAAP_BC_MR_CLIENT_PATH}          /webapi/mr_clients
${DMAAP_BC_MR_CLUSTER_PATH}         /webapi/mr_clusters
${PMMAPPER_HEALTH_CHECK_PATH}       /healthcheck
${FILE_READY_JSON_DATA_FILE}        /var/opt/ONAP/robot/assets/usecases/5gbulkpm/FileReadyNotification.json
${JSON_DATA_FILE}                   /var/opt/ONAP/robot/assets/usecases/5gbulkpm/Notification.json
${VES_LISTENER_PATH}                /eventListener/v7
${PMMAPPER_SUB_ROLE_DATA}           /var/opt/ONAP/robot/assets/usecases/5gbulkpm/sub.json
${PMMAPPER_MR_CLUSTER_DATA}         /var/opt/ONAP/robot/assets/usecases/5gbulkpm/mr_cluster.json

*** Test Cases ***

Deploying Data File Collector
    [Tags]                              5gbulkpm
    ${blueprint}=                       GetCall                            ${ONAP_GIT}           ${DFC_BLUEPRINT_PATH}
    ${templatejson}=                    OperatingSystem.Get File           ${BLUEPRINT_TEMPLATE_PATH}
    ${json}=                            Evaluate                           json.loads('''${templatejson}''')   json
    set to dictionary                   ${json}                            blueprintTemplate=${blueprint.text}
    set to dictionary                   ${json}                            typeName=datafile
    ${json_data}=                       Evaluate                           json.dumps(${json})                 json
    ${headers}=                         Create Dictionary                  content-type=application/json
    ${resp}=                            PostCall  ${INVENTORY_SERVER}      ${INVENTORY_ENDPOINT}    ${headers}    ${json_data}
    Should Be Equal As Strings          ${resp.status_code}                200
    ${serviceTypeId-Dfc}                Evaluate                           $resp.json().get('typeId')
    Set Global Variable                 ${serviceTypeId-Dfc}
    ${deployment_data}=                 Set Variable                       {"serviceTypeId": "${serviceTypeId-Dfc}"}
    ${resp}=                            PutCall                            ${DEPLOYMENT_SERVER}     /${DEPLOYMENT_ENDPOINT}/datafile     ${deployment_data}
    Log                                 ${resp.text}
    ${operationLink}                    Evaluate                           $resp.json().get('links').get('status')
    ${operationId}                      Fetch From Right                   ${operationLink}                /
    Wait Until Keyword Succeeds         3 minute                           20 sec            Deployment Status       ${DEPLOYMENT_SERVER}     ${DEPLOYMENT_ENDPOINT}     datafile     ${operationId}

Deploying 3GPP PM Mapper
    [Tags]                              5gbulkpm
    ${headers}=                         Create Dictionary                  content-type=application/json
    ${clusterdata}=                     OperatingSystem.Get File           ${PMMAPPER_MR_CLUSTER_DATA}
    Post 5G Bulk PM Configuration       ${DMAAP_BC_ENDPOINT}               ${DMAAP_BC_MR_CLUSTER_PATH}         ${headers}      ${clusterdata}
    ${blueprint}=                       GetCall                            ${ONAP_GIT}           ${PMMAPPER_BLUEPRINT_PATH}
    ${templatejson}=                    OperatingSystem.Get File           ${BLUEPRINT_TEMPLATE_PATH}
    ${json}=                            Evaluate                           json.loads('''${templatejson}''')   json
    set to dictionary                   ${json}                            blueprintTemplate=${blueprint.text}
    set to dictionary                   ${json}                            typeName=pmmapper
    ${json_data}=                       Evaluate                           json.dumps(${json})                 json
    ${resp}=                            PostCall                           ${INVENTORY_SERVER}      ${INVENTORY_ENDPOINT}    ${headers}    ${json_data}
    Should Be Equal As Strings          ${resp.status_code}                200
    ${serviceTypeId-Pmmapper}           Evaluate                           $resp.json().get('typeId')
    Set Global Variable                 ${serviceTypeId-Pmmapper}
    ${deployment_data}=                 Set Variable                       {"inputs":{"client_password": "demo123456!"},"serviceTypeId": "${serviceTypeId-Pmmapper}"}
    ${resp}=                            PutCall                            ${DEPLOYMENT_SERVER}    /${DEPLOYMENT_ENDPOINT}/pmmapper     ${deployment_data}
    Log                                 ${resp.text}
    ${operationLink}                    Evaluate                           $resp.json().get('links').get('status')
    ${operationId}                      Fetch From Right                   ${operationLink}                /
    Wait Until Keyword Succeeds         3 minute                           10 sec            Deployment Status       ${DEPLOYMENT_SERVER}     ${DEPLOYMENT_ENDPOINT}     pmmapper     ${operationId}

Deploying SFTP Server As xNF
    [Tags]                              5gbulkpm
    ${blueprint}=                       OperatingSystem.Get File           ${XNF_SFTP_BLUEPRINT_PATH}
    ${templatejson}=                    OperatingSystem.Get File           ${BLUEPRINT_TEMPLATE_PATH}
    ${json}=                            Evaluate                           json.loads('''${templatejson}''')   json
    set to dictionary                   ${json}                            blueprintTemplate=${blueprint}
    set to dictionary                   ${json}                            typeName=sftpserver
    ${json_data}=                       Evaluate                           json.dumps(${json})                 json
    ${headers}=                         Create Dictionary                  content-type=application/json
    ${resp}=                            PostCall                           ${INVENTORY_SERVER}      ${INVENTORY_ENDPOINT}    ${headers}    ${json_data}
    Should Be Equal As Strings          ${resp.status_code}                200
    ${serviceTypeId-Sftp}               Evaluate                           $resp.json().get('typeId')
    Set Global Variable                 ${serviceTypeId-Sftp}
    ${deployment_data}=                 Set Variable                       {"serviceTypeId": "${serviceTypeId-Sftp}"}
    ${resp}=                            PutCall                            ${DEPLOYMENT_SERVER}     /${DEPLOYMENT_ENDPOINT}/sftpserver     ${deployment_data}
    Log                                 ${resp.text}
    ${operationLink}                    Evaluate                           $resp.json().get('links').get('status')
    ${operationId}                      Fetch From Right                   ${operationLink}                /
    Wait Until Keyword Succeeds         3 minute                           5 sec            Deployment Status       ${DEPLOYMENT_SERVER}     ${DEPLOYMENT_ENDPOINT}     sftpserver     ${operationId}

Checking PERFORMANCE_MEASUREMENTS Topic In Message Router
    [Tags]                              5gbulkpm
    ${headers}=                         Create Dictionary                  content-type=application/json
    ${subdata}=                         OperatingSystem.Get File           ${PMMAPPER_SUB_ROLE_DATA}
    Post 5G Bulk PM Configuration       ${DMAAP_BC_ENDPOINT}               ${DMAAP_BC_MR_CLIENT_PATH}          ${headers}      ${subdata}
    ${resp}=                            Run MR Get Request                 ${MR_TOPIC_CHECK_PATH}
    Should Be Equal As Strings          ${resp.status_code}                200
    ${topics}=                          Evaluate                           $resp.json().get('topics')
    List Should Contain Value           ${topics}                          org.onap.dmaap.mr.PERFORMANCE_MEASUREMENTS
    ${resp}=                            Get Message Router Topic Data
    Should Be Equal As Strings          ${resp.status_code}                 200

Upload PM Files to xNF SFTP Server
    [Tags]                              5gbulkpm
    Open Connection                     sftpserver
    Login                               bulkpm                             bulkpm
    ${epoch}=                           Get Current Date                   result_format=epoch
    Set Global Variable                 ${epoch}
    Put File                            /var/opt/ONAP/robot/assets/usecases/5gbulkpm/pmfiles/A20181002.0000-1000-0015-1000_5G.xml.gz     upload/A${epoch}.xml.gz

DR Bulk PM Feed Check
    [Tags]                              5gbulkpm
    ${resp}=                            Run DR Get Request                  ${DR_SUB_CHECK_PATH}
    Should Contain                      ${resp.text}                        bulk_pm_feed

DR PM Mapper Subscriber Check
    [Tags]                              5gbulkpm
    ${resp}=                            Run DR Get Request                  ${DR_SUB_CHECK_PATH}
    Should Contain                      ${resp.text}                        https://dcae-pm-mapper:8443/delivery

Sending File Ready Event to VES Collector
    [Tags]                              5gbulkpm
    ${VES_FILE_READY_NOTIFICATION}      Set Variable                        {"event":{"commonEventHeader":{"version":"4.0.1","vesEventListenerVersion":"7.0.1","domain":"notification","eventName":"Noti_RnNode-Ericsson_FileReady","eventId":"FileReady_1797490e-10ae-4d48-9ea7-3d7d790b25e1","lastEpochMicrosec":8745745764578,"priority":"Normal","reportingEntityName":"otenb5309","sequence":0,"sourceName":"oteNB5309","startEpochMicrosec":8745745764578,"timeZoneOffset":"UTC+05.30"},"notificationFields":{"changeIdentifier":"PM_MEAS_FILES","changeType":"FileReady","notificationFieldsVersion":"2.0","arrayOfNamedHashMap":[{"name":"A${epoch}.xml.gz","hashMap":{"location":"sftp://bulkpm:bulkpm@sftpserver:22/upload/A${epoch}.xml.gz","compression":"gzip","fileFormatType":"org.3GPP.32.435#measCollec","fileFormatVersion":"V10"}}]}}}
    #${evtdata}=                         OperatingSystem.Get File            ${JSON_DATA_FILE}
    ${headers}=                         Create Dictionary                   content-type=application/json
    ${resp}=                            Publish Event To VES Collector      ${VES_HEALTH_CHECK_PATH}  ${VES_LISTENER_PATH}     ${headers}    ${VES_FILE_READY_NOTIFICATION}
    Should Be Equal As Strings          ${resp.status_code}                 202
    ${fileready}=                       OperatingSystem.Get File            ${FILE_READY_JSON_DATA_FILE}
    ${resp}=                            Publish Event To VES Collector      ${VES_HEALTH_CHECK_PATH}  ${VES_LISTENER_PATH}     ${headers}    ${fileready}
    Should Be Equal As Strings          ${resp.status_code}                 202

Verifying 3GPP Perf VES Content On PERFORMANCE_MEASUREMENTS Topic
    [Tags]                              5gbulkpm
    Wait Until Keyword Succeeds         1 minute                            5 sec            xNF PM File Validate      perf3gpp_RnNode-Ericsson_pmMeasResult

Undeploying PM Mapper
    [Tags]                              5gbulkpm
    Undeploy                            ${DEPLOYMENT_SERVER}                 /${DEPLOYMENT_ENDPOINT}/pmmapper
    Undeploy                            ${INVENTORY_SERVER}                  ${INVENTORY_ENDPOINT}/${serviceTypeId-Pmmapper}

Undeploying SFTP Server
    [Tags]                              5gbulkpm
    Undeploy                            ${DEPLOYMENT_SERVER}                 /${DEPLOYMENT_ENDPOINT}/sftpserver
    Undeploy                            ${INVENTORY_SERVER}                  ${INVENTORY_ENDPOINT}/${serviceTypeId-Sftp}

Undeploying Data File Collector
    [Tags]                              5gbulkpm
    Undeploy                            ${DEPLOYMENT_SERVER}                  /${DEPLOYMENT_ENDPOINT}/datafile
    Undeploy                            ${INVENTORY_SERVER}                   ${INVENTORY_ENDPOINT}/${serviceTypeId-Dfc}