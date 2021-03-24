*** Settings ***
Documentation	  The main interface for interacting with 5G Bulkpm.
Library 	      RequestsLibrary
Library           OperatingSystem
Library           String
Library           JSONLibrary
Resource          ../dcae/deployment.robot
Resource          ../dcae/inventory.robot
Resource          ../mr_interface.robot
Resource          ../dr_interface.robot
Resource          ../consul_interface.robot

*** Variables ***
${INVENTORY_SERVER}                                 ${GLOBAL_INVENTORY_SERVER_PROTOCOL}://${GLOBAL_INVENTORY_SERVER_NAME}:${GLOBAL_INVENTORY_SERVER_PORT}
${DEPLOYMENT_SERVER}                                ${GLOBAL_DEPLOYMENT_HANDLER_SERVER_PROTOCOL}://${GLOBAL_DEPLOYMENT_HANDLER_SERVER_NAME}:${GLOBAL_DEPLOYMENT_HANDLER_SERVER_PORT}
${DR_ENDPOINT}                                      ${GLOBAL_DMAAP_DR_PROV_SERVER_PROTOCOL}://${GLOBAL_INJECTED_DMAAP_DR_PROV_IP_ADDR}:${GLOBAL_DMAAP_DR_PROV_SERVER_PORT}
${DMAAP_BC_SERVER}                                  ${GLOBAL_BC_SERVER_PROTOCOL}://${GLOBAL_INJECTED_BC_IP_ADDR}:${GLOBAL_BC_HTTPS_SERVER_PORT}
${VES_HEALTH_CHECK_PATH}                            ${GLOBAL_DCAE_VES_HTTPS_PROTOCOL}://${GLOBAL_INJECTED_DCAE_VES_HOST}:${GLOBAL_DCAE_VES_HTTPS_SERVER_PORT}
${MR_PUBLISH_TEMPLATE}                              mr/mr_publish.jinja
${INVENTORY_ENDPOINT}                               /dcae-service-types
${XNF_SFTP_BLUEPRINT_PATH}                          ${EXECDIR}/robot/assets/usecases/5gbulkpm/k8s-sftp.yaml
${XNF_HTTPS_BLUEPRINT_PATH}                          ${EXECDIR}/robot/assets/usecases/5gbulkpm/k8s-https.yaml
${BLUEPRINT_TEMPLATE_PATH}                          ${EXECDIR}/robot/assets/usecases/5gbulkpm/blueprintTemplate.json
${DEPLOYMENT_ENDPOINT}                              dcae-deployments
${MR_TOPIC_CHECK_PATH}                              /topics
${DR_SUB_CHECK_PATH}                                /internal/prov
${MR_TOPIC_URL_PATH}                                /events/org.onap.dmaap.mr.PERFORMANCE_MEASUREMENTS/CG1/C1
${MR_TOPIC_URL_PATH_FOR_POST}                       /events/org.onap.dmaap.mr.PERFORMANCE_MEASUREMENTS
${DMAAP_BC_MR_CLIENT_PATH}                          /webapi/mr_clients
${DMAAP_BC_MR_CLUSTER_PATH}                         /webapi/mr_clusters
${PMMAPPER_HEALTH_CHECK_PATH}                       /healthcheck
${JSON_DATA_FILE}                                   ${EXECDIR}/robot/assets/usecases/5gbulkpm/Notification.json
${VES_LISTENER_PATH}                                /eventListener/v7
${PMMAPPER_SUB_ROLE_DATA}                           ${EXECDIR}/robot/assets/usecases/5gbulkpm/sub.json
${PMMAPPER_MR_CLUSTER_DATA}                         ${EXECDIR}/robot/assets/usecases/5gbulkpm/mr_clusters.json
${NEXUS3}                                           ${GLOBAL_INJECTED_NEXUS_DOCKER_REPO}
${SET_KNOWN_HOSTS_FILE_PATH}                        kubectl set env deployment/$(kubectl get deployment -n onap | grep datafile | awk '{print $1}') KNOWN_HOSTS_FILE_PATH=/home/datafile/.ssh/known_hosts -n onap
${CHECK_ENV_SET}                                    kubectl set env pod/$(kubectl get pod -n onap | grep datafile | awk '{print $1}') --list -n onap
${GET_RSA_KEY}                                      kubectl exec $(kubectl get pod -n onap | grep sftpserver | awk '{print $1}') -n onap -- ssh-keyscan -t rsa sftpserver > /tmp/known_hosts
${COPY_RSA_KEY}                                     kubectl cp /tmp/known_hosts $(kubectl get pod -n onap | grep datafile | awk '{print $1}'):/home/datafile/.ssh/known_hosts -n onap
${CHECK_DFC_LOGS}                                   kubectl logs $(kubectl get pod -n onap | grep datafile | awk '{print $1}') -n onap --tail=4
${EXPECTED_PRINT}                                   StrictHostKeyChecking is enabled but environment variable KNOWN_HOSTS_FILE_PATH is not set or points to not existing file
${MONGO_BLUEPRINT_PATH}                             ${EXECDIR}/robot/assets/cmpv2/k8s-mongo.yaml
${PNF_SIMULATOR_BLUEPRINT_PATH}                     ${EXECDIR}/robot/assets/cmpv2/k8s-pnf-simulator.yaml
${VES_INPUTS}                                       deployment/VesTlsCmpv2Inputs.jinja
${pm_notification_event}                            dfc/notification.jinja
${consul_change_event}                              dfc/consul.jinja
${ves_client_single_event}=                         ves/pnf_simulator_single_event.jinja




*** Keywords ***


Check Next Event From Topic
    [Documentation]
    ...  This keyword checks if on MR topic there is no existing messageses.
    ...  If there is no more messageses then it reports success and finish "Wait Until Keyword Succeeds  2 min  1 s  Check Next Event From Topic" step from "xNF PM File Validate" keyword
    ...  In other case it triggers "Get Next Event From Topic".
    ...  NOTE: Keyword "Get Next Event From Topic" will always fails in order to not finsh "Wait Until Keyword Succeeds  2 min  1 s  Check Next Event From Topic" step from "xNF PM File Validate" keyword
    ${resp}=        Run MR Auth Get Request         ${MR_TOPIC_URL_PATH}     ${GLOBAL_DCAE_USERNAME}      ${GLOBAL_DCAE_PASSWORD}
    Run keyword If  ${resp.text} == @{EMPTY}        Log                         Event is empty! There is no more events on topic!
    ...     ELSE    Get Next Event From Topic       ${resp}

Get Next Event From Topic
    [Documentation]
    ...  This keyword adds new events from MR topic to list ${all_event_json_list} in a recursive way and sets ${all_event_json_list} as a suite variable in order to be able to add new items/evnts in a next iteration
    ...  NOTE: Keyword "Get Next Event From Topic" will always fails in order to not finish "Wait Until Keyword Succeeds  2 min  1 s  Check Next Event From Topic" step from "xNF PM File Validate" keyword
    [Arguments]                 ${resp}
    ${resp_list}=               Set Variable        ${resp.json()}
    Log                         ${resp_list}
    ${combained_list}=          Combine Lists       ${all_event_json_list}      ${resp_list}
    ${all_event_json_list}=     Set Variable        ${combained_list}
    Set Suite Variable 	        ${all_event_json_list}
    Fail

xNF PM File Validate
    [Documentation]
    ...  This keyword gathers all events from message router topic and validates if in recived data is present an expected string: "${expected_pm_str}" .
    ...  Only in custom mode it saves a response as a json file "${PM_FILE}-${timestamp}.json" located in "${expected_event_json_path}"
    [Arguments]                 ${bulk_pm_mode}                 ${expected_pm_str}              ${expected_event_json_path}
    Run Keyword If              '${bulk_pm_mode}' == 'custom'   Set Log Level                   ${PM_LOG_LEVEL}
    ${timestamp}=               Get Time                        epoch
    ${resp}=                    Run MR Auth Get Request         ${MR_TOPIC_URL_PATH}            ${GLOBAL_DCAE_USERNAME}         ${GLOBAL_DCAE_PASSWORD}
    Run keyword If              ${resp.text} == @{EMPTY}        Fail                            msg=Event is empty!
    ${all_event_json_list}=     Set Variable                    ${resp.json()}
    Set Suite Variable 	        ${all_event_json_list}
    Wait Until Keyword Succeeds  2 min                          5 sec                           Check Next Event From Topic
    ${all_event_json_string}=   Convert To String               ${all_event_json_list}
    Should Contain              ${all_event_json_string}        ${expected_pm_str}
    Run Keyword If              '${bulk_pm_mode}' == 'custom'   Print Evnets From Topic to JSON file        ${expected_event_json_path}     ${all_event_json_string}
    Run Keyword If              '${bulk_pm_mode}' == 'custom'   Set Log Level                               TRACE

Print Evnets From Topic to JSON file
     [Arguments]                ${expected_event_json_path}         ${all_event_json_string}
     ${str}=                    Replace String                      ${all_event_json_string}                '{          {
     ${str2}=                   Replace String                      ${str}                                  }'          }
     ${all_event_json_string}=  Replace String                      ${str2}                                 u{          {
     ${json}=                   To Json                             ${all_event_json_string}                pretty_print=True
     ${timestamp}=              Get Time                            epoch
     Create File                ${expected_event_json_path}/${PM_FILE}-${timestamp}.json                    ${json}

Topic Validate
    [Arguments]                         ${value}
    ${timestamp}=                       Get Current Date
    ${dict}=                            Create Dictionary                           timestamp=${timestamp}
    Templating.Create Environment       mr                                          ${GLOBAL_TEMPLATE_FOLDER}
    ${data}=                            Templating.Apply Template                   mr                                  ${MR_PUBLISH_TEMPLATE}              ${dict}
    ${resp}=                            Run MR Auth Post Request (User And Pass)    ${MR_TOPIC_URL_PATH_FOR_POST}       ${GLOBAL_DCAE_USERNAME}             ${GLOBAL_DCAE_PASSWORD}       ${data}
    Should Be Equal As Strings          ${resp.status_code}                         200
    ${resp}=                            Run MR Auth Get Request                     ${MR_TOPIC_URL_PATH}                ${GLOBAL_DCAE_USERNAME}             ${GLOBAL_DCAE_PASSWORD}
    Should Contain                      ${resp.text}                                ${value}

Send File Ready Event to VES Collector and Deploy all DCAE Applications
    [Arguments]                                 ${pm_file}              ${file_format_type}             ${file_format_version}
    Disable Warnings
    Send File Ready Event to VES Collector      ${pm_file}              ${file_format_type}             ${file_format_version}
    Setting Global Variables
    Log To Console                              Deploying Data File Collector
    Deploying Data File Collector
    Log To Console                              Deploying 3GPP PM Mapper
    Deploying 3GPP PM Mapper
    Log To Console                              Deploying SFTP Server As xNF
    Deploying SFTP Server As xNF
    Checking PERFORMANCE_MEASUREMENTS Topic In Message Router
    DR Bulk PM Feed Check
    DR PM Mapper Subscriber Check
    Log To Console                              Deploying VES collector with CMPv2 for bulkpm over https
    Deploying VES collector with CMPv2 for bulkpm over https
    Log To Console                              Deploying HTTPS server with correct CMPv2 certificates
    Deploying HTTPS server with correct certificates
    Log To Console                              Deploying HTTPS server with wrong CMPv2 certificates - wrong SAN-s
    Deploying HTTPS server with wrong certificates - wrong SAN-s
    Log To Console                              Deploying VES Client with CMPv2 certificates
    Deploying VES Client with correct certificates
    Log To Console                              Checking status of deployed applictions
    Wait Until Keyword Succeeds                 5 min                                           20 sec                             Checking Status Of Deployed Applictions

Usecase Teardown
    Disable Warnings
    Undeploy Service                    sftpserver
    Undeploy Service                    ${serviceTypeId-Sftp}
    Undeploy Service                    datafile
    Undeploy Service                    pmmapper
    Undeploy Service                    mongo-dep-5gbulkpm
    Undeploy Service                    ves-rest-client-dep
    Undeploy Service                    ves-collector-for-bulkpm-over-https
    Delete Blueprint From Inventory     ${serviceTypeIdMongo}
    Delete Blueprint From Inventory     ${serviceTypeIdVesClient}
    Undeploy Service                    https-server-dep
    Delete Blueprint From Inventory     ${serviceTypeId-Https}
    Undeploy Service                    https-server-wrong-sans-dep
    Delete Blueprint From Inventory     ${serviceTypeId-Https-wrong-sans}

Setting Global Variables
    [Documentation]
    ...  This test case checks suite if it is working in default or custom mode and sets proper variables depended on used mode.
    ...  Default mode is based on a previous version of 5gbulkpm test case which it test PM file available in robot image.
    ...  Custom mode is used only in xtesing. Can be executed only as k8s job described in https://gerrit.onap.org/r/gitweb?p=integration/xtesting.git;a=blob_plain;f=smoke-usecases-robot/README.md;hb=refs/heads/master
    ...  Custom mode is used to validate custom PM files. All details how to provide custom PM files are described in documentation above.
    ...  By default in custom mode all PM details are not logged to robot log files, so they are not send to community name: TEST_DB_URL http://testresults.opnfv.org/onap/api/v1/results
    ${env_variables} =  Get Environment Variables
    ${bulk_pm_mode}=   Get Variable Value  ${env_variables["BULK_PM_MODE"]}  default
    ${pm_log_level}=   Get Variable Value  ${env_variables["PM_LOG_LEVEL"]}  NONE
    ${test_variables} =  Create Dictionary
    Run Keyword If   "${bulk_pm_mode}" == "custom"  Set To Dictionary  ${test_variables}   FILE_FORMAT_TYPE=${env_variables["FILE_FORMAT_TYPE"]}
    ...                                                                                    FILE_FORMAT_VERSION=${env_variables["FILE_FORMAT_VERSION"]}
    ...                                                                                    PM_FILE_PATH=${env_variables["PM_FILE_PATH"]}
    ...                                                                                    EXPECTED_PM_STR=${env_variables["EXPECTED_PM_STR"]}
    ...                                                                                    EXPECTED_EVENT_JSON_PATH=${env_variables["EXPECTED_EVENT_JSON_PATH"]}
    ...        ELSE                                 Set To Dictionary  ${test_variables}   FILE_FORMAT_TYPE=org.3GPP.32.435#measCollec
    ...                                                                                    FILE_FORMAT_VERSION=V10
    ...                                                                                    PM_FILE_PATH=${EXECDIR}/robot/assets/usecases/5gbulkpm/pmfiles/A20181002.0000-1000-0015-1000_5G.xml.gz
    ...                                                                                    EXPECTED_PM_STR=perf3gpp_RnNode-Ericsson_pmMeasResult
    ...                                                                                    EXPECTED_EVENT_JSON_PATH=none
    Set Global Variable   ${GLOBAL_TEST_VARIABLES}  ${test_variables}
    Set Global Variable  ${BULK_PM_MODE}  ${bulk_pm_mode}
    Set Global Variable  ${PM_LOG_LEVEL}  ${pm_log_level}


Send File Ready Event to VES Collector
    [Arguments]                         ${pm_file}                          ${file_format_type}             ${file_format_version}
    Disable Warnings
    ${headers}=                         Create Dictionary                   content-type=application/json
    ${fileready}=                       OperatingSystem.Get File            ${JSON_DATA_FILE}
    ${auth}=                            Create List                         ${GLOBAL_DCAE_VES_USERNAME}     ${GLOBAL_DCAE_VES_PASSWORD}
    ${session}=                         Create Session                      ves                             ${VES_HEALTH_CHECK_PATH}      auth=${auth}
    ${resp}=                            Post Request                        ves                             ${VES_LISTENER_PATH}          data=${fileready}   headers=${headers}
    Should Be Equal As Strings          ${resp.status_code}                 202
    ${VES_FILE_READY_NOTIFICATION}      Set Variable                        {"event":{"commonEventHeader":{"version":"4.0.1","vesEventListenerVersion":"7.0.1","domain":"notification","eventName":"Noti_RnNode-Ericsson_FileReady","eventId":"FileReady_1797490e-10ae-4d48-9ea7-3d7d790b25e1","lastEpochMicrosec":8745745764578,"priority":"Normal","reportingEntityName":"otenb5309","sequence":0,"sourceName":"oteNB5309","startEpochMicrosec":8745745764578,"timeZoneOffset":"UTC+05.30"},"notificationFields":{"changeIdentifier":"PM_MEAS_FILES","changeType":"FileReady","notificationFieldsVersion":"2.0","arrayOfNamedHashMap":[{"name":"${pm_file}","hashMap":{"location":"sftp://bulkpm:bulkpm@sftpserver:22/upload/${pm_file}","compression":"gzip","fileFormatType":"${file_format_type}","fileFormatVersion":"${file_format_version}"}}]}}}
    ${resp}=                            Post Request                        ves                             ${VES_LISTENER_PATH}          data=${VES_FILE_READY_NOTIFICATION}   headers=${headers}
    Should Be Equal As Strings          ${resp.status_code}                 202

Send File Ready Event to VES Collector Over VES Client
    [Arguments]                     ${pm_file}                  ${file_format_type}             ${file_format_version}    ${https_server_host}   ${http_reposnse_code}
    Disable Warnings
    ${pm_event}                     Create Dictionary           https_server_host=${https_server_host}  pm_file=${pm_file}   fileFormatType=${file_format_type}   fileFormatVersion=${file_format_version}
    Templating.Create Environment   pm                          ${GLOBAL_TEMPLATE_FOLDER}
    ${event}=                       Templating.Apply Template   pm                              ${pm_notification_event}   ${pm_event}
    ${ves_client_endpoint}=         Set Variable                http://ves-client:5000
    ${ves_url}=                     Set Variable                ${GLOBAL_DCAE_VES_HTTPS_PROTOCOL}://dcae-ves-collector-for-bulkpm-over-https:${GLOBAL_DCAE_VES_HTTPS_SERVER_PORT}/eventListener/v7
    ${single_event}=                Create Dictionary           event=${event}                  ves_url=${ves_url}
    Templating.Create Environment   ves                         ${GLOBAL_TEMPLATE_FOLDER}
    ${data}=                        Templating.Apply Template   ves                             ${ves_client_single_event}   ${single_event}
    ${session}=                     Create Session              ves_client                      ${ves_client_endpoint}
    ${headers}=                     Create Dictionary           Accept=application/json         Content-Type=application/json
    ${post_resp}=                   Post Request                ves_client                      /simulator/event      data=${data}        headers=${headers}
    Log                             PM notification ${data}
    Should Be Equal As Strings      ${post_resp.status_code}    ${http_reposnse_code}

Upload PM Files to xNF SFTP Server
    [Arguments]                         ${pm_file_path}                   ${bulk_pm_mode}
    Open Connection                     sftpserver
    Login                               bulkpm                             bulkpm
    ${epoch}=                           Get Current Date                   result_format=epoch
    ${pm_file} =  Run Keyword If        "${bulk_pm_mode}" == "custom"      Fetch From Right                   ${pm_file_path}               marker=/
    ...                     ELSE                                           Set Variable                        A${epoch}.xml.gz
    Put File                            ${pm_file_path}                    upload/${pm_file}
    [Return]  ${pm_file}

Upload PM Files to xNF HTTPS Server
    [Arguments]                         ${pm_file_path}                     ${bulk_pm_mode}                     ${https_server}
    ${epoch}=                           Get Current Date                    result_format=epoch
    ${pm_file} =  Run Keyword If        "${bulk_pm_mode}" == "custom"       Fetch From Right                   ${pm_file_path}               marker=/
    ...                     ELSE                                            Set Variable                       A${epoch}.xml.gz
    Copy File                           ${pm_file_path}                     tmp/${pm_file}
    ${fileData}=                        Get Binary File                     tmp/${pm_file}
    ${file_part}=                       Create List                         ${pm_file}                         ${fileData}                   application/octet-stream
    ${fileParts}=                       Create Dictionary
    Set to Dictionary                   ${fileParts}                        uploaded_file=${file_part}
    ${auth}=                            Create List                         demo                                demo123456!
    ${session}=                         Create Session                      https                               http://${https_server}:80   auth=${auth}
    ${resp}=                            Post Request                        https                               /upload.php                 files=${fileParts}
    Should Be Equal As Strings          ${resp.status_code}                 200
    [Return]                            ${pm_file}

Check Given Print In DFC Log
    [Arguments]                         ${check_dfc_logs}
    ${dfc_logs}=                        Run Given Command On DFC Container                                      ${CHECK_DFC_LOGS}
    Should Contain                      ${dfc_logs}                                                             HostKey has been changed

Run Given Command On DFC Container
    [Arguments]                         ${user_command}
    ${run_command} =                    Run And Return Rc And Output        ${user_command}
    ${command_output} =                 Set Variable                        ${run_command[1]}
    ${regexp_matches} =                 Get Regexp Matches                  ${command_output}                   .*(\\s|\\[)+(.+-datafile-collector).*  2
    ${dfc_container_name} =             Set Variable                        ${regexp_matches[0]}
    ${new_command} =                    Set Variable                        ${user_command} ${dfc_container_name}
    ${command_output} =                 Run And Return Rc And Output        ${new_command}
    Should Be Equal As Integers         ${command_output[0]}                0
    ${log} =                            Set Variable                        ${command_output[1]}
    [Return]                            ${log}

Check Known Hosts In Env
    [Arguments]                         ${CHECK_KNOWN_HOSTS}
    ${check} =                          Run And Return Rc And Output        ${CHECK_KNOWN_HOSTS}
    Should Be Equal As Integers         ${check[0]}                         0
    ${env} =                            Set Variable                        ${check[1]}
    ${string_matches} =                 Get Lines Containing String         ${env}                              KNOWN_HOSTS_FILE_PATH=/home/datafile/.ssh/known_host  case_insensitive=True
    ${output} =                         Should Not Be Empty                 ${string_matches}
    [Return]                            ${output}

Deploying Data File Collector
    ${resp}=                            Get Blueprint From Inventory       k8s-datafile
    ${json}=                            Set Variable                       ${resp.json()}
    ${serviceTypeId-Dfc}                Set Variable                       ${json['items'][0]['typeId']}
    ${image}                            Get Regexp Matches                 ${json['items'][0]['blueprintTemplate']}             nexus3(.)*?(?=\\")
    ${image}                            Replace String                     ${image}[0]      nexus3.onap.org:10001               ${NEXUS3}
    ${deployment_data}=                 Set Variable                       {"serviceTypeId": "${serviceTypeId-Dfc}", "inputs": {"tag_version": "${image}", "external_cert_use_external_tls": true}}
    Deploy Service                      ${deployment_data}                 datafile                                            4 minutes

Deploying 3GPP PM Mapper
    ${clusterdata}=                     OperatingSystem.Get File           ${PMMAPPER_MR_CLUSTER_DATA}
    ${headers}=                         Create Dictionary                  content-type=application/json
    ${session}=                         Create Session                     dmaapbc                          ${DMAAP_BC_SERVER}
    ${resp}=                            Post Request                       dmaapbc                          ${DMAAP_BC_MR_CLUSTER_PATH}          data=${clusterdata}   headers=${headers}
    ${resp}=                            Get Blueprint From Inventory       k8s-pm-mapper
    ${json}=                            Set Variable                       ${resp.json()}
    ${serviceTypeId-Pmmapper}           Set Variable                       ${json['items'][0]['typeId']}
    ${image}                            Get Regexp Matches                 ${json['items'][0]['blueprintTemplate']}             nexus3(.)*?(?=\')
    ${image}                            Replace String                     ${image}[0]      nexus3.onap.org:10001               ${NEXUS3}
    ${deployment_data}=                 Set Variable                       {"inputs":{"client_password": "${GLOBAL_DCAE_PASSWORD}", "tag_version": "${image}"},"serviceTypeId": "${serviceTypeId-Pmmapper}"}
    ${pmMapperOperationId}=             Deploy Service                      ${deployment_data}                 pmmapper                        check_deployment_status=false
    Set Global Variable                 ${pmMapperOperationId}

Deploying SFTP Server As xNF
    ${serviceTypeId-Sftp}               Load Blueprint To Inventory        ${XNF_SFTP_BLUEPRINT_PATH}              sftp
    Set Global Variable                 ${serviceTypeId-Sftp}
    ${deployment_data}=                 Set Variable                       {"serviceTypeId": "${serviceTypeId-Sftp}"}
    ${sftpServerOperationId}=           Deploy Service                      ${deployment_data}                 sftpserver                        check_deployment_status=false
    Set Global Variable                 ${sftpServerOperationId}

Deploying HTTPS server with correct certificates
    ${serviceTypeId-Https}              Load Blueprint To Inventory        ${XNF_HTTPS_BLUEPRINT_PATH}              https
    Set Global Variable                 ${serviceTypeId-Https}
    ${deployment_data}=                 Set Variable                       {"serviceTypeId": "${serviceTypeId-Https}"}
    ${resp}=                            Get Blueprint From Inventory       https
    ${json}=                            Set Variable                       ${resp.json()}
    ${image}                            Get Regexp Matches                 ${json['items'][0]['blueprintTemplate']}               nexus3(.)*?(?=\')
    ${image}                            Replace String                     ${image}[0]      nexus3.onap.org:10001                 ${NEXUS3}
    ${deployment_data}=                 Set Variable                       {"serviceTypeId": "${serviceTypeId-Https}", "inputs": {"tag_version": "${image}", "service_component_type": "https-server", "service_component_name_override": "https-server", "external_cert_sans": "https-server"}}
    ${httpsServerOperationId}=          Deploy Service                      ${deployment_data}                 https-server-dep                  check_deployment_status=false
    Set Global Variable                 ${httpsServerOperationId}

Deploying HTTPS server with wrong certificates - wrong SAN-s
    ${serviceTypeId-Https-wrong-sans}              Load Blueprint To Inventory        ${XNF_HTTPS_BLUEPRINT_PATH}              https-wrong-sans
    Set Global Variable                 ${serviceTypeId-Https-wrong-sans}
    ${deployment_data}=                 Set Variable                       {"serviceTypeId": "${serviceTypeId-Https-wrong-sans}"}
    ${resp}=                            Get Blueprint From Inventory       https-wrong-sans
    ${json}=                            Set Variable                       ${resp.json()}
    ${image}                            Get Regexp Matches                 ${json['items'][0]['blueprintTemplate']}               nexus3(.)*?(?=\')
    ${image}                            Replace String                     ${image}[0]      nexus3.onap.org:10001                 ${NEXUS3}
    ${deployment_data}=                 Set Variable                       {"serviceTypeId": "${serviceTypeId-Https-wrong-sans}", "inputs": {"tag_version": "${image}", "service_component_type": "https-server-wrong-sans", "service_component_name_override": "https-server-wrong-sans", "external_cert_sans": "wrong-cert"}}
    ${httpsServerWrongSansOperationId}=        Deploy Service                      ${deployment_data}                 https-server-wrong-sans-dep                   check_deployment_status=false
    Set Global Variable                 ${httpsServerWrongSansOperationId}

Deploying VES Client with correct certificates
    ${serviceTypeIdMongo}               Load Blueprint To Inventory        ${MONGO_BLUEPRINT_PATH}              mongo-5g-bulk-pm
    ${serviceTypeIdVesClient}           Load Blueprint To Inventory        ${PNF_SIMULATOR_BLUEPRINT_PATH}      ves-rest-client
    Set Suite Variable                  ${serviceTypeIdMongo}
    Set Suite Variable                  ${serviceTypeIdVesClient}
    ${deployment_data}=                 Set Variable                       {"serviceTypeId": "${serviceTypeIdMongo}"}
    Deploy Service                      ${deployment_data}                 mongo-dep-5gbulkpm                             2 minutes
    ${resp}=                            Get Blueprint From Inventory       ves-rest-client
    ${json}=                            Set Variable                       ${resp.json()}
    ${image}                            Get Regexp Matches                 ${json['items'][0]['blueprintTemplate']}               nexus3(.)*?(?=\')
    ${image}                            Replace String                     ${image}[0]      nexus3.onap.org:10001                 ${NEXUS3}
    ${deployment_data}=                 Set Variable                       {"serviceTypeId": "${serviceTypeIdVesClient}", "inputs": {"tag_version": "${image}", "service_component_type": "ves-client", "service_component_name_override": "ves-client"}}
    ${vesRestClientOperationId}=        Deploy Service                      ${deployment_data}                 ves-rest-client-dep                   check_deployment_status=false
    Set Global Variable                 ${vesRestClientOperationId}

Deploying VES collector with CMPv2 for bulkpm over https
    ${resp}=                            Get Blueprint From Inventory       k8s-ves
    ${json}=                            Set Variable                       ${resp.json()}
    ${serviceTypeIdVes}                 Set Variable                       ${json['items'][0]['typeId']}
    ${image}                            Get Regexp Matches                 ${json['items'][0]['blueprintTemplate']}             nexus3(.)*?(?=\")
    ${image}                            Replace String                     ${image}[0]      nexus3.onap.org:10001               ${NEXUS3}
    ${arguments}=                       Create Dictionary                  serviceTypeId=${serviceTypeIdVes}
    Set To Dictionary                   ${arguments}                       image                                                ${image}
    Set To Dictionary                   ${arguments}                       external_port_tls                                    32419
    Set To Dictionary                   ${arguments}                       service_component_name_override                      dcae-ves-collector-for-bulkpm-over-https
    Set To Dictionary                   ${arguments}                       external_cert_sans                                   dcae-ves-collector-for-bulkpm-over-https,ves-collector-cmpv2-cert,ves-cmpv2-cert
    Templating.Create Environment       deployment                         ${GLOBAL_TEMPLATE_FOLDER}
    ${deployment_data}=                 Templating.Apply Template          deployment                                           ${VES_INPUTS}            ${arguments}
    ${vesCollectorForBulkpmOverHttpsOperationId}=  Deploy Service                      ${deployment_data}                 ves-collector-for-bulkpm-over-https                  check_deployment_status=false
    Set Global Variable                 ${vesCollectorForBulkpmOverHttpsOperationId}


Checking Status Of Deployed Applictions
    ${statusDict}=                          Create Dictionary
    ${status} 	                            ${value} =          Run Keyword And Ignore Error 	        Deployment Status                   pmmapper                                            ${pmMapperOperationId}
    Set To Dictionary                       ${statusDict}       pmmapper                                ${status}
    ${status} 	                            ${value} =          Run Keyword And Ignore Error 	        Deployment Status                   ves-rest-client-dep                                 ${vesRestClientOperationId}
    Set To Dictionary                       ${statusDict}       ves-rest-client-dep                     ${status}
    ${status} 	                            ${value} =          Run Keyword And Ignore Error 	        Deployment Status                   ves-collector-for-bulkpm-over-https                 ${vesCollectorForBulkpmOverHttpsOperationId}
    Set To Dictionary                       ${statusDict}       ves-collector-for-bulkpm-over-https     ${status}
    ${status} 	                            ${value} =          Run Keyword And Ignore Error 	        Deployment Status                   https-server-dep                                    ${httpsServerOperationId}
    Set To Dictionary                       ${statusDict}       https-server-dep                        ${status}
    ${status} 	                            ${value} =          Run Keyword And Ignore Error 	        Deployment Status                   https-server-wrong-sans-dep                         ${httpsServerWrongSansOperationId}
    Set To Dictionary                       ${statusDict}       https-server-wrong-sans-dep             ${status}
    Dictionary Should Not Contain Value     ${statusDict}       FAIL

Checking PERFORMANCE_MEASUREMENTS Topic In Message Router
    ${headers}=                         Create Dictionary                  content-type=application/json
    ${subdata}=                         OperatingSystem.Get File           ${PMMAPPER_SUB_ROLE_DATA}
    ${session}=                         Create Session                     dmaapbc                          ${DMAAP_BC_SERVER}
    ${resp}=                            Post Request                       dmaapbc                          ${DMAAP_BC_MR_CLIENT_PATH}      data=${subdata}        headers=${headers}
    Wait Until Keyword Succeeds         5 minute                           5 sec                            Topic Validate                  success
    ${resp}=                            Run MR Get Request                 ${MR_TOPIC_CHECK_PATH}
    Should Be Equal As Strings          ${resp.status_code}                200
    ${topics}=                          Set Variable                       ${resp.json().get('topics')}
    List Should Contain Value           ${topics}                          org.onap.dmaap.mr.PERFORMANCE_MEASUREMENTS
    ${resp}=                            Run MR Auth Get Request            ${MR_TOPIC_URL_PATH}            ${GLOBAL_DCAE_USERNAME}         ${GLOBAL_DCAE_PASSWORD}
    Should Be Equal As Strings          ${resp.status_code}                200

DR Bulk PM Feed Check
    ${resp}=                            Run DR Get Request                  ${DR_SUB_CHECK_PATH}
    Should Contain                      ${resp.text}                        bulk_pm_feed

DR PM Mapper Subscriber Check
    ${resp}=                            Run DR Get Request                  ${DR_SUB_CHECK_PATH}
    Should Contain                      ${resp.text}                        https://dcae-pm-mapper:8443/delivery

Setting KNOWN_HOSTS_FILE_PATH Environment Variable in DFC
    ${rc}=                             Run and Return RC                   ${SET_KNOWN_HOSTS_FILE_PATH}
    Should Be Equal As Integers        ${rc}                               0
    Wait Until Keyword Succeeds        5 min                               10s               Check Known Hosts In Env             ${CHECK_ENV_SET}
    ${rc}=                             Run and Return RC                   ${GET_RSA_KEY}
    Should Be Equal As Integers        ${rc}                               0
    ${rc}=                             Run and Return RC                   ${COPY_RSA_KEY}
    Should Be Equal As Integers        ${rc}                               0

Uploading PM Files to xNF SFTP Server
    ${pm_file}=                         Upload PM Files to xNF SFTP Server      ${GLOBAL_TEST_VARIABLES["PM_FILE_PATH"]}    ${BULK_PM_MODE}
    Set Global Variable                 ${PM_FILE}                              ${pm_file}

Uploading PM Files to xNF HTTPS Server
    [Arguments]                         ${https-server_host}
    ${pm_file}=                         Upload PM Files to xNF HTTPS Server     ${GLOBAL_TEST_VARIABLES["PM_FILE_PATH"]}    ${BULK_PM_MODE}     ${https-server_host}
    Set Global Variable                 ${PM_FILE}                              ${pm_file}

Sending File Ready Event to VES Collector
    Send File Ready Event to VES Collector  ${PM_FILE}  ${GLOBAL_TEST_VARIABLES["FILE_FORMAT_TYPE"]}  ${GLOBAL_TEST_VARIABLES["FILE_FORMAT_VERSION"]}

Sending File Ready Event to VES Collector Over VES Client
    [Arguments]  ${https-server_host}
    Send File Ready Event to VES Collector Over VES Client  ${PM_FILE}  ${GLOBAL_TEST_VARIABLES["FILE_FORMAT_TYPE"]}  ${GLOBAL_TEST_VARIABLES["FILE_FORMAT_VERSION"]}    ${https-server_host}   202

Verifying 3GPP Perf VES Content On PERFORMANCE_MEASUREMENTS Topic
    Wait Until Keyword Succeeds         2 min                            5 sec            xNF PM File Validate   ${BULK_PM_MODE}   ${GLOBAL_TEST_VARIABLES["EXPECTED_PM_STR"]}  ${GLOBAL_TEST_VARIABLES["EXPECTED_EVENT_JSON_PATH"]}

Changing SFTP Server RSA Key in DFC
    ${get_known_hosts_file}=          OperatingSystem.Get File  /tmp/known_hosts
    ${change_rsa_key}=                Replace String            ${get_known_hosts_file}        A  a
    Create File                       /tmp/known_hosts          ${change_rsa_key}
    ${rc}=                            Run and Return RC         ${COPY_RSA_KEY}
    Should Be Equal As Integers       ${rc}                     0

Checking DFC Logs After KNOWN_HOSTS_FILE_PATH Env Variable Added
    ${dfc_logs}=                     Run Given Command On DFC Container      ${CHECK_DFC_LOGS}
    Should Not Contain               ${dfc_logs}                             ${EXPECTED_PRINT}

Checking DFC Logs After SFTP Server RSA Key Changed
    Wait Until Keyword Succeeds         5 min  30 sec            Check Given Print In DFC LOG  ${CHECK_DFC_LOGS}

Check DFC logs
    [Arguments]  ${DFC_LOG_CHECK}
    ${rc} =                                    Run and Return RC                   ${DFC_LOG_CHECK}
    Should Be Equal As Integers                ${rc}                               0

Change DFC httpsHostnameVerify configuration in Consul
    [Documentation]     Changes DFC httpsHostnameVerify config.
    [Arguments]                     ${httpsHostnameVerify}
    ${httpsHostnameVerify_conf}     Create Dictionary               httpsHostnameVerify=${httpsHostnameVerify}
    Templating.Create Environment   pm                              ${GLOBAL_TEMPLATE_FOLDER}
    ${event}=                       Templating.Apply Template       pm                              ${consul_change_event}      ${httpsHostnameVerify_conf}
    ${rc} 	${container_name} = 	Run and Return RC and Output 	kubectl get pods -n onap | grep datafile-collector | awk '{print $1}' | grep -v NAME | awk -F'-' '{print $2}'
    Should Be Equal As Integers 	${rc} 	                        0
    ${resp}=                        Run Consul Put Request          /v1/kv/${container_name}-datafile-collector?dc=dc1          ${event}
    Should Be Equal As Strings      ${resp.status_code}             200
    ${rc} = 	                    Run and Return RC 	            kubectl delete pods -n onap $(kubectl get pods -n onap | grep datafile-collector | awk '{print $1}' | grep -v NAME)
    Should Be Equal As Integers 	${rc} 	                        0
    Wait Until Keyword Succeeds         60 sec          5 sec       Check DFC logs                  kubectl logs -n onap $(kubectl get pods -n onap | grep datafile-collector | awk '{print $1}' | grep -v NAME) ${container_name}-datafile-collector


