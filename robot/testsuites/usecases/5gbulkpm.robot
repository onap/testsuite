*** Settings ***
Documentation     5G Bulk PM Usecase functionality

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
Resource          ../resources/usecases/5gbulkpm_interface.robot
Resource          ../resources/mr_interface.robot
Resource          ../resources/dr_interface.robot
Suite Teardown    Usecase Teardown

*** Variables ***
${INVENTORY_ENDPOINT}               /dcae-service-types
${DFC_BLUEPRINT_PATH}               ${EXECDIR}/robot/assets/usecases/5gbulkpm//k8s-datafile.yaml
${PMMAPPER_BLUEPRINT_PATH}          ${EXECDIR}/robot/assets/usecases/5gbulkpm//k8s-pm-mapper.yaml
${XNF_SFTP_BLUEPRINT_PATH}          ${EXECDIR}/robot/assets/usecases/5gbulkpm/k8s-sftp.yaml
${BLUEPRINT_TEMPLATE_PATH}          ${EXECDIR}/robot/assets/usecases/5gbulkpm/blueprintTemplate.json
${FTP_FILE_PATH}                    ${EXECDIR}/robot/assets/usecases/5gbulkpm/pmfiles/A20181002.0000-1000-0015-1000_5G.xml.gz
${DEPLOYMENT_ENDPOINT}              dcae-deployments
${MR_TOPIC_CHECK_PATH}              /topics
${DR_SUB_CHECK_PATH}                /internal/prov
${MR_TOPIC_URL_PATH}                /events/org.onap.dmaap.mr.PERFORMANCE_MEASUREMENTS/CG1/C1
${DMAAP_BC_MR_CLIENT_PATH}          /webapi/mr_clients
${DMAAP_BC_MR_CLUSTER_PATH}         /webapi/mr_clusters
${PMMAPPER_HEALTH_CHECK_PATH}       /healthcheck
${JSON_DATA_FILE}                   ${EXECDIR}/robot/assets/usecases/5gbulkpm/Notification.json
${VES_LISTENER_PATH}                /eventListener/v7
${PMMAPPER_SUB_ROLE_DATA}           ${EXECDIR}/robot/assets/usecases/5gbulkpm/sub.json
${PMMAPPER_MR_CLUSTER_DATA}         ${EXECDIR}/robot/assets/usecases/5gbulkpm/mr_clusters.json

*** Test Cases ***

Deploying Data File Collector
    [Tags]                              5gbulkpm
    ${blueprint}=                       OperatingSystem.Get File           ${DFC_BLUEPRINT_PATH}
    ${templatejson}=                    Load JSON From File                ${BLUEPRINT_TEMPLATE_PATH}
    ${templatejson}=                    Update Value To Json               ${templatejson}                            blueprintTemplate             ${blueprint}
    ${templatejson}=                    Update Value To Json               ${templatejson}                            typeName                      datafile
    ${json_data}                        Convert JSON To String             ${templatejson}
    ${headers}=                         Create Dictionary                  content-type=application/json
    ${session}=                         Create Session                     dfc                 ${INVENTORY_SERVER}
    ${resp}=                            Post Request                       dfc                 ${INVENTORY_ENDPOINT}          data=${json_data}             headers=${headers}
    ${serviceTypeId-Dfc}                Set Variable                       ${resp.json().get('typeId')}
    Set Global Variable                 ${serviceTypeId-Dfc}
    ${deployment_data}=                 Set Variable                       {"serviceTypeId": "${serviceTypeId-Dfc}"}
    ${session}=                         Create Session                     deployment-dfc                 ${DEPLOYMENT_SERVER}
    ${resp}=                            Put Request                        deployment-dfc                 /${DEPLOYMENT_ENDPOINT}/datafile         data=${deployment_data}     headers=${headers}
    ${operationLink}                    Set Variable                       ${resp.json().get('links').get('status')}
    ${operationId}                      Fetch From Right                   ${operationLink}                /
    Wait Until Keyword Succeeds         3 minute                           20 sec            Deployment Status       ${DEPLOYMENT_SERVER}     ${DEPLOYMENT_ENDPOINT}     datafile     ${operationId}

Deploying 3GPP PM Mapper
    [Tags]                              5gbulkpm
    ${clusterdata}=                     OperatingSystem.Get File           ${PMMAPPER_MR_CLUSTER_DATA}
    ${headers}=                         Create Dictionary                  content-type=application/json
    ${session}=                         Create Session                     dmaapbc                 ${DMAAP_BC_SERVER}
    ${resp}=                            Post Request                       dmaapbc                 ${DMAAP_BC_MR_CLUSTER_PATH}          data=${clusterdata}   headers=${headers}
    ${blueprint}=                       OperatingSystem.Get File           ${PMMAPPER_BLUEPRINT_PATH}
    ${templatejson}=                    Load JSON From File                ${BLUEPRINT_TEMPLATE_PATH}
    ${templatejson}=                    Update Value To Json               ${templatejson}                            blueprintTemplate             ${blueprint}
    ${templatejson}=                    Update Value To Json               ${templatejson}                            typeName                      pmmapper
    ${json_data}                        Convert JSON To String             ${templatejson}
    ${session}=                         Create Session                     pmmapper                 ${INVENTORY_SERVER}
    ${resp}=                            Post Request                       pmmapper                 ${INVENTORY_ENDPOINT}          data=${json_data}             headers=${headers}
    ${serviceTypeId-Pmmapper}           Set Variable                       ${resp.json().get('typeId')}
    Set Global Variable                 ${serviceTypeId-Pmmapper}
    ${deployment_data}=                 Set Variable                       {"inputs":{"client_password": "${GLOBAL_DCAE_PASSWORD}"},"serviceTypeId": "${serviceTypeId-Pmmapper}"}
    ${session}=                         Create Session                     deployment-pmmapper                 ${DEPLOYMENT_SERVER}
    ${resp}=                            Put Request                        deployment-pmmapper                 /${DEPLOYMENT_ENDPOINT}/pmmapper         data=${deployment_data}     headers=${headers}
    ${operationLink}                    Set Variable                       ${resp.json().get('links').get('status')}
    ${operationId}                      Fetch From Right                   ${operationLink}                /
    Wait Until Keyword Succeeds         2 minute                           10 sec            Deployment Status       ${DEPLOYMENT_SERVER}     ${DEPLOYMENT_ENDPOINT}     pmmapper     ${operationId}

Deploying SFTP Server As xNF
    [Tags]                              5gbulkpm
    ${blueprint}=                       OperatingSystem.Get File           ${XNF_SFTP_BLUEPRINT_PATH}
    ${templatejson}=                    Load JSON From File                ${BLUEPRINT_TEMPLATE_PATH}
    ${templatejson}=                    Update Value To Json               ${templatejson}                            blueprintTemplate             ${blueprint}
    ${templatejson}=                    Update Value To Json               ${templatejson}                            typeName                      sftpserver
    ${json_data}                        Convert JSON To String             ${templatejson}
    ${headers}=                         Create Dictionary                  content-type=application/json
    ${session}=                         Create Session                     sftp                 ${INVENTORY_SERVER}
    ${resp}=                            Post Request                       sftp                 ${INVENTORY_ENDPOINT}          data=${json_data}             headers=${headers}
    ${serviceTypeId-Sftp}=              Set Variable                       ${resp.json().get('typeId')}
    Set Global Variable                 ${serviceTypeId-Sftp}
    ${deployment_data}=                 Set Variable                       {"serviceTypeId": "${serviceTypeId-Sftp}"}
    ${session}=                         Create Session                     deployment-sftpserver                 ${DEPLOYMENT_SERVER}
    ${resp}=                            Put Request                        deployment-sftpserver                 /${DEPLOYMENT_ENDPOINT}/sftpserver         data=${deployment_data}     headers=${headers}
    ${operationLink}=                   Set Variable                       ${resp.json().get('links').get('status')}
    ${operationId}                      Fetch From Right                   ${operationLink}                /
    Wait Until Keyword Succeeds         1 minute                           5 sec            Deployment Status       ${DEPLOYMENT_SERVER}     ${DEPLOYMENT_ENDPOINT}     sftpserver     ${operationId}


Checking PERFORMANCE_MEASUREMENTS Topic In Message Router
    [Tags]                              5gbulkpm
    ${headers}=                         Create Dictionary                  content-type=application/json
    ${subdata}=                         OperatingSystem.Get File           ${PMMAPPER_SUB_ROLE_DATA}
    ${session}=                         Create Session                     dmaapbc                 ${DMAAP_BC_SERVER}
    ${resp}=                            Post Request                       dmaapbc                 ${DMAAP_BC_MR_CLIENT_PATH}          data=${subdata}   headers=${headers}
    ${resp}=                            Run MR Get Request                 ${MR_TOPIC_CHECK_PATH}
    Should Be Equal As Strings          ${resp.status_code}                200
    ${topics}=                          Set Variable                       ${resp.json().get('topics')}
    List Should Contain Value           ${topics}                          org.onap.dmaap.mr.PERFORMANCE_MEASUREMENTS
    ${resp}=                            Run MR Auth Get Request            ${MR_TOPIC_URL_PATH}     ${GLOBAL_DCAE_USERNAME}      ${GLOBAL_DCAE_PASSWORD}
    Should Be Equal As Strings          ${resp.status_code}                200

Upload PM Files to xNF SFTP Server
    [Tags]                              5gbulkpm
    Open Connection                     sftpserver
    Login                               bulkpm                             bulkpm
    ${epoch}=                           Get Current Date                   result_format=epoch
    Set Global Variable                 ${epoch}
    Put File                            ${FTP_FILE_PATH}                   upload/A${epoch}.xml.gz

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
    ${headers}=                         Create Dictionary                   content-type=application/json
    ${fileready}=                       OperatingSystem.Get File            ${JSON_DATA_FILE}
    ${session}=                         Create Session                      ves                         ${VES_HEALTH_CHECK_PATH}
    ${resp}=                            Post Request                        ves                         ${VES_LISTENER_PATH}          data=${fileready}   headers=${headers}
    Should Be Equal As Strings          ${resp.status_code}                 202
    ${VES_FILE_READY_NOTIFICATION}      Set Variable                        {"event":{"commonEventHeader":{"version":"4.0.1","vesEventListenerVersion":"7.0.1","domain":"notification","eventName":"Noti_RnNode-Ericsson_FileReady","eventId":"FileReady_1797490e-10ae-4d48-9ea7-3d7d790b25e1","lastEpochMicrosec":8745745764578,"priority":"Normal","reportingEntityName":"otenb5309","sequence":0,"sourceName":"oteNB5309","startEpochMicrosec":8745745764578,"timeZoneOffset":"UTC+05.30"},"notificationFields":{"changeIdentifier":"PM_MEAS_FILES","changeType":"FileReady","notificationFieldsVersion":"2.0","arrayOfNamedHashMap":[{"name":"A${epoch}.xml.gz","hashMap":{"location":"sftp://bulkpm:bulkpm@sftpserver:22/upload/A${epoch}.xml.gz","compression":"gzip","fileFormatType":"org.3GPP.32.435#measCollec","fileFormatVersion":"V10"}}]}}}
    ${resp}=                            Post Request                        ves                         ${VES_LISTENER_PATH}          data=${VES_FILE_READY_NOTIFICATION}   headers=${headers}
    Should Be Equal As Strings          ${resp.status_code}                 202

Verifying 3GPP Perf VES Content On PERFORMANCE_MEASUREMENTS Topic
    [Tags]                              5gbulkpm
    Wait Until Keyword Succeeds         1 minute                            5 sec            xNF PM File Validate      perf3gpp_RnNode-Ericsson_pmMeasResult

*** Keywords ***

Usecase Teardown
    Undeploy Service                    ${DEPLOYMENT_SERVER}                 /${DEPLOYMENT_ENDPOINT}/pmmapper
    Undeploy Service                    ${INVENTORY_SERVER}                  ${INVENTORY_ENDPOINT}/${serviceTypeId-Pmmapper}
    Undeploy Service                    ${DEPLOYMENT_SERVER}                 /${DEPLOYMENT_ENDPOINT}/sftpserver
    Undeploy Service                    ${INVENTORY_SERVER}                  ${INVENTORY_ENDPOINT}/${serviceTypeId-Sftp}
    Undeploy Service                    ${DEPLOYMENT_SERVER}                  /${DEPLOYMENT_ENDPOINT}/datafile
    Undeploy Service                    ${INVENTORY_SERVER}                   ${INVENTORY_ENDPOINT}/${serviceTypeId-Dfc}