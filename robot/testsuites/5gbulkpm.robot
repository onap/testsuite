*** Settings ***
Documentation     5G Bulk PM Usecase functionality
Test Timeout      60 seconds

Library           RequestsLibrary
Library           String
Library           DateTime
Library           SSHLibrary
Library           Process
Library           ONAPLibrary.JSON
Library	          ONAPLibrary.Utilities
Library	          ONAPLibrary.Templating    WITH NAME    Templating
Resource          ../resources/dcae_interface.robot
Resource          ../resources/mr_interface.robot

*** Variables ***
${INVENTORY_SERVER}                 https://inventory:8080
${INVENTORY_ENDPOINT}               /dcae-service-types
${DFC_BLUEPRINT_URL}                https://git.onap.org/dcaegen2/collectors/datafile/plain/datafile-app-server/dpo/blueprints/k8s-datafile.yaml
${PMMAPPER_BLUEPRINT_URL}           https://git.onap.org/dcaegen2/services/pm-mapper/plain/dpo/blueprints/k8s-pm-mapper.yaml
${XNF_SFTP_BLUEPRINT_PATH}          /var/opt/ONAP/robot/assets/5gbulkpm/k8s-sftp.yaml
${BLUEPRINT_TEMPLATE_PATH}          /var/opt/ONAP/robot/assets/5gbulkpm/blueprintTemplate.json
${DEPLOYMENT_SERVER}                https://deployment-handler:8443
${DEPLOYMENT_ENDPOINT}              dcae-deployments
${MR_TOPIC_CHECK_PATH}              /topics
${DR_SUB_CHECK_PATH}                /internal/prov
${DR_ENDPOINT}                      http://dmaap-dr-prov:80
${VES_HEALTH_CHECK_PATH}            http://dcae-ves-collector:8080
${PMMAPPER_ENDPOINT}                https://dcae-pm-mapper:8443
${MR_ENDPOINT}                      http://message-router:3904
${MR_TOPIC_UR_PATH}                 /events/org.onap.dmaap.mr.PERFORMANCE_MEASUREMENTS/CG1/C1
${DMAAP_BC_ENDPOINT}                http://dmaap-bc:8080
${DMAAP_BC_MR_CLIENT_PATH}          /webapi/mr_clients
${DMAAP_BC_MR_CLUSTER_PATH}         /webapi/mr_clusters
${PMMAPPER_HEALTH_CHECK_PATH}       /healthcheck
${FILE_READY_JSON_DATA_FILE}        /var/opt/ONAP/robot/assets/5gbulkpm/FileExistNotification.json
${JSON_DATA_FILE}                   /var/opt/ONAP/robot/assets/5gbulkpm/Notification.json
${VES_LISTENER_PATH}                /eventListener/v7
${PMMAPPER_SUB_ROLE_DATA}           /var/opt/ONAP/robot/assets/5gbulkpm/sub.json
${PMMAPPER_MR_CLUSTER_DATA}         /var/opt/ONAP/robot/assets/5gbulkpm/mr_cluster.json

*** Test Cases ***

Deploying Data File Collector
    [Tags]                              5gbulkpm
    ${blueprint-file}=                  GetCall                            ${DFC_BLUEPRINT_URL}
    ${templatejson}=                    Get Json Data From File            ${BLUEPRINT_TEMPLATE_PATH}
    ${json}=                            evaluate                           json.loads('''${templatejson}''')   json
    set to dictionary                   ${json}                            blueprintTemplate=${blueprint-file}
    set to dictionary                   ${json}                            typeName=datafile
    ${json_data}=                       evaluate                           json.dumps(${json})                 json
    ${headers}=                         Create Dictionary                  content-type=application/json
    ${resp}=                            PostCall  ${INVENTORY_SERVER}      ${INVENTORY_ENDPOINT}    ${headers}    ${json_data}
    Should Be Equal As Strings          ${resp.status_code}                200
    ${serviceTypeId-Dfc}                Evaluate                           $resp.json().get('typeId')
    Set Global Variable                 ${serviceTypeId-Dfc}
    ${deployment_data}=                 Set Variable                       '{"serviceTypeId": "${serviceTypeId-Dfc}"}'
    ${resp}=                            PutCall                            ${DEPLOYMENT_SERVER}/${DEPLOYMENT_ENDPOINT}/datafile     ${deployment_data}

Deploying 3GPP PM Mapper
    [Tags]                              5gbulkpm
    ${headers}=                         Create Dictionary                  content-type=application/json
    ${clusterdata}=                     Get Event Data From File           ${PMMAPPER_MR_CLUSTER_DATA}
    Post 5G Bulk PM Configuration       ${DMAAP_BC_ENDPOINT}               ${DMAAP_BC_MR_CLUSTER_PATH}         ${headers}      ${clusterdata}
    ${blueprint-file}=                  GetCall                            ${PMMAPPER_BLUEPRINT_URL}
    ${templatejson}=                    Get Json Data From File            ${BLUEPRINT_TEMPLATE_PATH}
    ${json}=                            evaluate                           json.loads('''${templatejson}''')   json
    set to dictionary                   ${json}                            blueprintTemplate=${blueprint-file}
    set to dictionary                   ${json}                            typeName=pmmapper
    ${json_data}=                       evaluate                           json.dumps(${json})                 json
    ${resp}=                            PostCall  ${INVENTORY_SERVER}      ${INVENTORY_ENDPOINT}    ${headers}    ${json_data}
    Should Be Equal As Strings          ${resp.status_code}                200
    ${serviceTypeId-Pmmapper}           Evaluate                           $resp.json().get('typeId')
    Set Global Variable                 ${serviceTypeId-Pmmapper}
    ${deployment_data}=                 Set Variable                       '{"inputs":{"client_password": "demo123456!"},"serviceTypeId": "${serviceTypeId-Pmmapper}"}'
    ${resp}=                            PutCall                            ${DEPLOYMENT_SERVER}/${DEPLOYMENT_ENDPOINT}/pmmapper     ${deployment_data}
    Log                                 ${resp.text}
    ${subdata}=                         Get Event Data From File           ${PMMAPPER_SUB_ROLE_DATA}
    Post 5G Bulk PM Configuration       ${DMAAP_BC_ENDPOINT}               ${DMAAP_BC_MR_CLIENT_PATH}          ${headers}      ${subdata}

Checking PERFORMANCE_MEASUREMENTS Topic In Message Router
    [Tags]                              5gbulkpm
    ${resp}=                            Run MR Get Request                 ${MR_TOPIC_CHECK_PATH}
    Should Be Equal As Strings          ${resp.status_code}                200
    ${topics}=                          Evaluate                           $resp.json().get('topics')
    List Should Contain Value           ${topics}                          org.onap.dmaap.mr.PERFORMANCE_MEASUREMENTS
    ${resp}=                            Get Message Router Topic Data
    Should Be Equal As Strings 	        ${resp.status_code} 	           200

Deploying SFTP Server As xNF
    [Tags]                              5gbulkpm
    ${blueprint-file}=                  Get Json Data From File            ${XNF_SFTP_BLUEPRINT_PATH}
    ${templatejson}=                    Get Json Data From File            ${BLUEPRINT_TEMPLATE_PATH}
    ${json}=                            evaluate                           json.loads('''${templatejson}''')   json
    set to dictionary                   ${json}                            blueprintTemplate=${blueprint-file}
    set to dictionary                   ${json}                            typeName=sftpserver
    ${json_data}=                       evaluate                           json.dumps(${json})                 json
    ${headers}=                         Create Dictionary                  content-type=application/json
    ${resp}=                            PostCall  ${INVENTORY_SERVER}      ${INVENTORY_ENDPOINT}    ${headers}    ${json_data}
    Should Be Equal As Strings          ${resp.status_code}                200
    ${serviceTypeId-Sftp}               Evaluate                           $resp.json().get('typeId')
    Set Global Variable                 ${serviceTypeId-Sftp}
    ${deployment_data}=                 Set Variable                       '{"serviceTypeId": "${serviceTypeId-Sftp}"}'
    ${resp}=                            PutCall                            ${DEPLOYMENT_SERVER}/${DEPLOYMENT_ENDPOINT}/sftpserver     ${deployment_data}
    Log                                 ${resp.text}

Upload PM Files to xNF SFTP Server
    [Tags]                              5gbulkpm
    sleep                               20
    Open Connection                     sftpserver
    Login                               bulkpm                             bulkpm
    Put File                            /var/opt/ONAP/robot/assets/5gbulkpm/pmfiles/A20181002.0000-1000-0015-1000_5G.xml.gz     upload

VES Collector Health Check
    [Tags]                              5gbulkpm
    ${resp}=                            Run VES Get Request
    Should Be Equal As Strings          ${resp.status_code}                 200

PM Mapper Health Check
    [Tags]                              5gbulkpm
    ${resp}=                            Run PM Mapper Get Request           ${PMMAPPER_HEALTH_CHECK_PATH}
    Should Be Equal As Strings          ${resp.status_code}                 200

Message Router Health Check
    [Tags]                              5gbulkpm
    Run MR Health Check

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
    ${evtdata}=                         Get Event Data From File            ${JSON_DATA_FILE}
    ${headers}=                         Create Dictionary                   content-type=application/json
    ${resp}=                            Publish Event To VES Collector      ${VES_HEALTH_CHECK_PATH}  ${VES_LISTENER_PATH}     ${headers}    ${evtdata}
    Should Be Equal As Strings 	        ${resp.status_code} 	            202
    Sleep                               2s
    ${fileready}=                       Get Event Data From File            ${FILE_READY_JSON_DATA_FILE}
    ${resp}=                            Publish Event To VES Collector      ${VES_HEALTH_CHECK_PATH}  ${VES_LISTENER_PATH}     ${headers}    ${fileready}
    Should Be Equal As Strings 	        ${resp.status_code} 	            202

Checking VES_NOTIFICATION_OUTPUT Topic In Message Router
    [Tags]                              5gbulkpm
    ${resp}=                            Run MR Get Request                  ${MR_TOPIC_CHECK_PATH}
    Should Be Equal As Strings          ${resp.status_code}                 200
    ${topics}=                          Evaluate                            $resp.json().get('topics')
    List Should Contain Value           ${topics}                           unauthenticated.VES_NOTIFICATION_OUTPUT

Verifying 3GPP Perf VES Content On PERFORMANCE_MEASUREMENTS Topic
    [Tags]                              5gbulkpm
    Sleep                               10s
    ${resp}=                            Get Message Router Topic Data
    Should Contain                      ${resp.text}                        perf3gpp_RnNode-Ericsson_pmMeasResult

Cleaning Up The Env
    [Tags]                              5gbulkpm
    DeleteCall                          ${DEPLOYMENT_SERVER}/${DEPLOYMENT_ENDPOINT}/datafile
    DeleteCall                          ${DEPLOYMENT_SERVER}/${DEPLOYMENT_ENDPOINT}/pmmapper
    DeleteCall                          ${DEPLOYMENT_SERVER}/${DEPLOYMENT_ENDPOINT}/sftpserver
    DeleteCall                          ${INVENTORY_SERVER}${INVENTORY_ENDPOINT}/${serviceTypeId-Dfc}
    DeleteCall                          ${INVENTORY_SERVER}${INVENTORY_ENDPOINT}/${serviceTypeId-Pmmapper}
    DeleteCall                          ${INVENTORY_SERVER}${INVENTORY_ENDPOINT}/${serviceTypeId-Sftp}

*** Keywords ***

Run DR Get Request
    [Arguments]        ${data_path}
    ${session}=        Create Session    session    ${DR_ENDPOINT}
    ${resp}=           Get Request       session    ${data_path}
    [Return]           ${resp}

Run VES Get Request
    ${session}=        Create Session    session    ${VES_HEALTH_CHECK_PATH}
    ${resp}=           Get Request       session    /
    [Return]           ${resp}

Run PM Mapper Get Request
    [Arguments]        ${data_path}
    ${session}=        Create Session    session    ${PMMAPPER_ENDPOINT}
    ${resp}=           Get Request       session    ${data_path}
    [Return]           ${resp}

Get Event Data From File
    [Arguments]         ${jsonfile}
    ${data}=            OperatingSystem.Get File    ${jsonfile}
    [return]            ${data}

Publish Event To VES Collector
    [Arguments]         ${url}     ${evtpath}   ${httpheaders}    ${evtdata}
    ${session}=         Create Session 	        ves 	${url}
    ${resp}=            Post Request 	        ves 	${evtpath}     data=${evtdata}   headers=${httpheaders}
    [return]            ${resp}

Post 5G Bulk PM Configuration
    [Arguments]         ${url}     ${evtpath}   ${httpheaders}    ${evtdata}
    ${session}=         Create Session 	        dmaapbc 	${url}
    ${resp}=            Post Request 	        dmaapbc 	${evtpath}     data=${evtdata}   headers=${httpheaders}
    [return]            ${resp}

Get Message Router Topic Data
    ${session}=        Create Session           mr          ${MR_ENDPOINT}
    ${headers}=        Create Dictionary        Authorization=Basic ZGNhZUBkY2FlLm9uYXAub3JnOmRlbW8xMjM0NTYh
    ${resp}=           Get Request              mr          ${MR_TOPIC_UR_PATH}     ${headers}
    [Return]           ${resp}

GetCall
    [Arguments]     ${url}
    ${resp}=    	Evaluate    requests.get('${url}')    requests
    [Return]    	${resp.text}

Get Json Data From File
    [Arguments]         ${jsonfile}
    ${data}=            OperatingSystem.Get File    ${jsonfile}
    [return]            ${data}

PostCall
    [Arguments]         ${url}     ${evtpath}   ${headers}    ${evtdata}
    ${session}=         Create Session 	        ves 	${url}
    ${resp}=            Post Request 	        ves 	${evtpath}     data=${evtdata}   headers=${headers}
    [return]            ${resp}

PutCall
    [Arguments]                     ${url}                           ${data}
    ${headers}=                     Create Dictionary                Content-Type=application/json
    ${resp}=                        Evaluate                         requests.put('${url}', data=${data}, headers=${headers}, verify=False, allow_redirects=False)    requests
    [Return]                        ${resp}

DeleteCall
    [Arguments]      ${url}
    ${resp}=         Evaluate            requests.delete('${url}', verify=False)    requests
    [Return]         ${resp}