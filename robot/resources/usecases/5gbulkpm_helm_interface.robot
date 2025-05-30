*** Settings ***
Documentation	  The main interface for interacting with 5G Bulkpm.
Library 	      RequestsLibrary
Library           OperatingSystem
Library           String
Library           JSONLibrary
Resource          ../dmaap/dr_interface.robot
Resource          ../consul_interface.robot
Resource          ../chart_museum.robot
Resource          ../strimzi_kafka.robot

*** Variables ***
${DR_ENDPOINT}                                      ${GLOBAL_DMAAP_DR_PROV_SERVER_PROTOCOL}://${GLOBAL_INJECTED_DMAAP_DR_PROV_IP_ADDR}:${GLOBAL_DMAAP_DR_PROV_SERVER_PORT}
${VES_HEALTH_CHECK_PATH}                            ${GLOBAL_DCAE_VES_HTTPS_PROTOCOL}://${GLOBAL_INJECTED_DCAE_VES_HOST}:${GLOBAL_DCAE_VES_HTTPS_SERVER_PORT}
${DR_SUB_CHECK_PATH}                                /internal/prov
${JSON_DATA_FILE}                                   ${EXECDIR}/robot/assets/usecases/5gbulkpm/Notification.json
${VES_LISTENER_PATH}                                /eventListener/v7
${SET_KNOWN_HOSTS_FILE_PATH}                        kubectl set env deployment/$(kubectl get deployment -n onap | grep datafile | awk '{print $1}') KNOWN_HOSTS_FILE_PATH=/home/datafile/.ssh/known_hosts -n onap
${DR_NODE_FECTH_PROV}                               kubectl exec $(kubectl get pods -n onap | grep dmaap-dr-node | awk '{print $1}' | grep -v NAME) -n onap -- curl http://localhost:8080/internal/fetchProv
${CHECK_ENV_SET}                                    kubectl set env pod/$(kubectl get pod -n onap | grep datafile | awk '{print $1}') -c dcae-datafile-collector --list -n onap
${COPY_RSA_KEY}                                     kubectl cp /tmp/known_hosts $(kubectl get pod -n onap | grep datafile | awk '{print $1}'):/home/datafile/.ssh/known_hosts -c dcae-datafile-collector -n onap
${CHECK_DFC_LOGS}                                   kubectl logs $(kubectl get pod -n onap | grep datafile | awk '{print $1}') -c dcae-datafile-collector -n onap --tail=10
${CHECK_ALL_DFC_LOGS}                               kubectl logs $(kubectl get pod -n onap | grep datafile | awk '{print $1}') -n onap --all-containers
${CHECK_ALL_PMMAPPER_LOGS}                          kubectl logs $(kubectl get pod -n onap | grep pm-mapper | awk '{print $1}') -n onap --all-containers
${EXPECTED_PRINT}                                   StrictHostKeyChecking is enabled but environment variable KNOWN_HOSTS_FILE_PATH is not set or points to not existing file
${pm_notification_event}                            dfc/notification.jinja
${consul_change_event}                              dfc/consul.jinja
${SFTP_HELM_CHARTS}                                 ${EXECDIR}/robot/assets/helm/sftp
${HTTPS_SERVER_HELM_CHARTS}                         ${EXECDIR}/robot/assets/helm/pm-https-server
${HELM_RELEASE}                                     kubectl --namespace onap get pods | sed 's/ .*//' | grep robot | sed 's/-.*//'

*** Keywords ***
xNF PM File Validate
    [Documentation]
    ...  This keyword gets the last event from the PM topic and validates if the expected string is present: "${expected_pm_str}" .
    [Arguments]                 ${expected_pm_str}
    ${bytes} =	Encode String To Bytes	         ${expected_pm_str}	     UTF-8
    ${msg}=  Run Keyword        Get Last Message From Topic    unauthenticated.PERFORMANCE_MEASUREMENTS
    Should Contain              ${msg}                    ${bytes}


Send File Ready Event to VES Collector and Deploy all DCAE Applications
    [Arguments]                                 ${pm_file}              ${file_format_type}             ${file_format_version}
    Disable Warnings
    Setting Global Variables
    DR Node Fetch Prov
    Sleep     10s
    Send File Ready Event to VES Collector      ${pm_file}              ${file_format_type}             ${file_format_version}
    Add OOM test chart repository               onap-testing                  https://nexus3.onap.org/repository/onap-helm-testing/
    Add chart repository                        chart-museum                  http://chart-museum:80      onapinitializer      demo123456!
    Log To Console                              Deploying SFTP Server As xNF
    Deploying SFTP Server As xNF
#    Log To Console                              Deploying HTTPS Server with correct CMPv2 certificates as xNF
#    Deploying HTTPS server with correct certificates
    DR PM Mapper Subscriber Check

Usecase Teardown
    Disable Warnings
    Get all logs from PM Mapper
    Get all logs from Data File Collector
    Uninstall helm charts               ${ONAP_HELM_RELEASE}-sftp
#    Uninstall helm charts               ${ONAP_HELM_RELEASE}-pm-https-server-correct-sans

Setting Global Variables
    ${test_variables} =  Create Dictionary
    Set To Dictionary  ${test_variables}   FILE_FORMAT_TYPE=org.3GPP.32.435#measCollec
    ...                                    FILE_FORMAT_VERSION=V10
    ...                                    PM_FILE_PATH=${EXECDIR}/robot/assets/usecases/5gbulkpm/pmfiles/A20181002.0000-1000-0015-1000_5G.xml.gz
    ...                                    EXPECTED_PM_STR=perf3gpp_RnNode-Ericsson_pmMeasResult
    Set Global Variable   ${GLOBAL_TEST_VARIABLES}  ${test_variables}
    ${command_output} =                 Run And Return Rc And Output        ${HELM_RELEASE}
    Should Be Equal As Integers         ${command_output[0]}                0
    Set Global Variable   ${ONAP_HELM_RELEASE}   ${command_output[1]}

Send File Ready Event to VES Collector
    [Arguments]                         ${pm_file}                          ${file_format_type}             ${file_format_version}
    Disable Warnings
    ${headers}=                         Create Dictionary                   content-type=application/json
    ${fileready}=                       OperatingSystem.Get File            ${JSON_DATA_FILE}
    ${auth}=                            Create List                         ${GLOBAL_DCAE_VES_USERNAME}     ${GLOBAL_DCAE_VES_PASSWORD}
    ${session}=                         Create Session                      ves                             ${VES_HEALTH_CHECK_PATH}      auth=${auth}
    ${resp}=                            Post Request                        ves                             ${VES_LISTENER_PATH}          data=${fileready}   headers=${headers}
    Should Be Equal As Strings          ${resp.status_code}                 202
    ${VES_FILE_READY_NOTIFICATION}      Set Variable                        {"event":{"commonEventHeader":{"version":"4.0.1","vesEventListenerVersion":"7.0.1","domain":"notification","eventName":"Noti_RnNode-Ericsson_FileReady","eventId":"FileReady_1797490e-10ae-4d48-9ea7-3d7d790b25e1","lastEpochMicrosec":8745745764578,"priority":"Normal","reportingEntityName":"otenb5309","sequence":0,"sourceName":"oteNB5309","startEpochMicrosec":8745745764578,"timeZoneOffset":"UTC+05.30"},"notificationFields":{"changeIdentifier":"PM_MEAS_FILES","changeType":"FileReady","notificationFieldsVersion":"2.0","arrayOfNamedHashMap":[{"name":"${pm_file}","hashMap":{"location":"sftp://bulkpm:bulkpm@${ONAP_HELM_RELEASE}-sftp:22/upload/${pm_file}","compression":"gzip","fileFormatType":"${file_format_type}","fileFormatVersion":"${file_format_version}"}}]}}}
    ${resp}=                            Post Request                        ves                             ${VES_LISTENER_PATH}          data=${VES_FILE_READY_NOTIFICATION}   headers=${headers}
    Should Be Equal As Strings          ${resp.status_code}                 202

Upload PM Files to xNF SFTP Server
    [Arguments]                         ${pm_file_path}
    Open Connection                     ${ONAP_HELM_RELEASE}-sftp
    Login                               bulkpm                             bulkpm
    ${epoch}=                           Get Current Date                   result_format=epoch
    ${pm_file}=                         Set Variable                        A${epoch}.xml.gz
    Put File                            ${pm_file_path}                    upload/${pm_file}
    [Return]  ${pm_file}

Check Given Print In DFC Log
    [Arguments]                         ${check_dfc_logs}
    ${dfc_logs}=                        Run Given Command On DFC Container                                      ${CHECK_DFC_LOGS}
    Should Contain                      ${dfc_logs}                                                             HostKey has been changed

Run Given Command On DFC Container
    [Arguments]                         ${user_command}
    ${run_command} =                    Run And Return Rc And Output        ${user_command}
    Should Be Equal As Integers         ${run_command[0]}                   0
    ${command_output} =                 Set Variable                        ${run_command[1]}
    ${regexp_matches} =                 Get Regexp Matches                  ${command_output}                   .*(\\s|\\[)+(.+-datafile-collector).*  2
    ${matches_length} =                 Get length                          ${regexp_matches}
    ${log} =                            Run Keyword If   "${matches_length}"!='0'  Get DFC log by container name   ${command_output}  ${regexp_matches}
                                        ...  ELSE   Set Variable   ${command_output}
    [Return]                            ${log}

Get DFC log by container name
    [Arguments]                         ${command_output}                   ${regexp_matches}
    ${dfc_container_name} =             Set Variable                        ${regexp_matches[0]}
    ${new_command} =                    Set Variable                        ${user_command} ${dfc_container_name}
    ${command_output} =                 Run And Return Rc And Output        ${new_command}
    Should Be Equal As Integers         ${run_command[0]}                   0
    ${log} =                            Set Variable                        ${run_command[1]}
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
    Install helm charts                 chart-museum                       dcae-datafile-collector         ${ONAP_HELM_RELEASE}-dcae-datafile-collector           6m      --set useCmpv2Certificates=true --set global.cmpv2Enabled=true --set masterPasswordOverride=test --set global.centralizedLoggingEnabled=false --debug

Deploying 3GPP PM Mapper
    ${override} =                       Set Variable                       --set global.centralizedLoggingEnabled=false --debug
    Install helm charts                 chart-museum                       dcae-pm-mapper         ${ONAP_HELM_RELEASE}-dcae-pm-mapper             6m   set_values_override=${override}

Deploying SFTP Server As xNF
    ${override} =                       Set Variable                       --set fullnameOverride=${ONAP_HELM_RELEASE}-sftp --debug
    Install helm charts from folder     ${SFTP_HELM_CHARTS}                ${ONAP_HELM_RELEASE}-sftp                 6m  set_values_override=${override}

Deploying HTTPS server with correct certificates
    ${name} =                           Set Variable                       ${ONAP_HELM_RELEASE}-pm-https-server-correct-sans
    ${override} =                       Set Variable                       --set fullnameOverride=${name} --set nameOverride=${name} --set certificates.name=${name} --set certificates.commonName=${name} --set certificates.dnsNames={${name}} --debug
    Install helm charts from folder     ${HTTPS_SERVER_HELM_CHARTS}        ${name}                 set_values_override=${override}

Deploying HTTPS server with wrong certificates - wrong SAN-s
    ${name} =                           Set Variable                       ${ONAP_HELM_RELEASE}-pm-https-server-wrong-sans
    ${override} =                       Set Variable                       --set fullnameOverride=${name} --set nameOverride=${name} --set certificates.name=${name} --set certificates.commonName=wrong-sans-1 --set certificates.dnsNames={wrong-sans-2} --debug
    Install helm charts from folder     ${HTTPS_SERVER_HELM_CHARTS}        ${name}                 set_values_override=${override}

DR Node Fetch Prov
    ${rc}=                              Run and Return RC                   ${DR_NODE_FECTH_PROV}
    Should Be Equal As Integers         ${rc}                               0


DR PM Mapper Subscriber Check
    ${resp}=                            Run DR Get Request                  ${DR_SUB_CHECK_PATH}
    Should Contain                      ${resp.text}                        http://dcae-pm-mapper:8081/delivery

Setting KNOWN_HOSTS_FILE_PATH Environment Variable in DFC
    ${rc}=                             Run and Return RC                   ${SET_KNOWN_HOSTS_FILE_PATH}
    Should Be Equal As Integers        ${rc}                               0
    Wait Until Keyword Succeeds        7 min                               10s               Check Known Hosts In Env             ${CHECK_ENV_SET}
    ${GET_RSA_KEY}=                    Set Variable                        kubectl exec $(kubectl get pod -n onap | grep ${ONAP_HELM_RELEASE}-sftp | awk '{print $1}') -n onap -- ssh-keyscan -t rsa ${ONAP_HELM_RELEASE}-sftp > /tmp/known_hosts
    ${rc}=                             Run and Return RC                   ${GET_RSA_KEY}
    Should Be Equal As Integers        ${rc}                               0
    ${rc}=                             Run and Return RC                   ${COPY_RSA_KEY}
    Should Be Equal As Integers        ${rc}                               0

Uploading PM Files to xNF SFTP Server
    ${pm_file}=                         Upload PM Files to xNF SFTP Server      ${GLOBAL_TEST_VARIABLES["PM_FILE_PATH"]}
    Set Global Variable                 ${PM_FILE}                              ${pm_file}

Sending File Ready Event to VES Collector
    Send File Ready Event to VES Collector  ${PM_FILE}  ${GLOBAL_TEST_VARIABLES["FILE_FORMAT_TYPE"]}  ${GLOBAL_TEST_VARIABLES["FILE_FORMAT_VERSION"]}

Verifying 3GPP Perf VES Content On PERFORMANCE_MEASUREMENTS Topic
    Wait Until Keyword Succeeds         2 min                            5 sec            xNF PM File Validate   ${GLOBAL_TEST_VARIABLES["EXPECTED_PM_STR"]}

Changing SFTP Server RSA Key in DFC
    ${get_known_hosts_file}=          OperatingSystem.Get File  /tmp/known_hosts
    ${change_rsa_key}=                Replace String            ${get_known_hosts_file}        A  a
    Create File                       /tmp/known_hosts          ${change_rsa_key}
    ${rc}=                            Run and Return RC         ${COPY_RSA_KEY}
    Should Be Equal As Integers       ${rc}                     0

Checking DFC Logs After KNOWN_HOSTS_FILE_PATH Env Variable Added
    ${dfc_logs}=                     Run Given Command On DFC Container      ${CHECK_DFC_LOGS}
    Should Not Contain               ${dfc_logs}                             ${EXPECTED_PRINT}

Get all logs from PM Mapper
    ${pmmapper_logs}=                Check logs      ${CHECK_ALL_PMMAPPER_LOGS}
    Log                              ${pmmapper_logs}

Get all logs from Data File Collector
    ${pmmapper_logs}=                Check logs      ${CHECK_ALL_DFC_LOGS}
    Log                              ${pmmapper_logs}

Checking DFC Logs After SFTP Server RSA Key Changed
    Wait Until Keyword Succeeds         5 min  30 sec            Check Given Print In DFC LOG  ${CHECK_DFC_LOGS}

Check logs
    [Arguments]  ${LOG_CHECK}
    ${rc} =                                    Run And Return Rc And Output                    ${LOG_CHECK}
    Should Be Equal As Integers                ${rc[0]}                               0
    [Return]                                   ${rc[1]}

Change DFC httpsHostnameVerify configuration in Consul
    [Documentation]     Changes DFC httpsHostnameVerify config.
    [Arguments]                     ${httpsHostnameVerify}
    ${httpsHostnameVerify_conf}     Create Dictionary               httpsHostnameVerify=${httpsHostnameVerify}
    Templating.Create Environment   pm                              ${GLOBAL_TEMPLATE_FOLDER}
    ${event}=                       Templating.Apply Template       pm                              ${consul_change_event}      ${httpsHostnameVerify_conf}
    ${rc}   ${container_name} =   Run and Return RC and Output  kubectl get pods -n onap | grep datafile-collector | awk '{print $1}' | grep -v NAME | awk -F'-' '{print $2}'
    Should Be Equal As Integers   ${rc}                           0
    ${resp}=                        Run Consul Put Request          /v1/kv/${container_name}-datafile-collector?raw=1          ${event}
    Should Be Equal As Strings      ${resp.status_code}             200
    ${rc} =                       Run and Return RC               kubectl delete pods -n onap $(kubectl get pods -n onap | grep datafile-collector | awk '{print $1}' | grep -v NAME)
    Should Be Equal As Integers   ${rc}                           0
    Wait Until Keyword Succeeds         360 sec          15 sec       Check logs                  kubectl logs -n onap $(kubectl get pods -n onap | grep datafile-collector | awk '{print $1}' | grep -v NAME) ${container_name}-datafile-collector

Sending File Ready Event to VES Collector for HTTPS Server
    [Arguments]  ${https-server_host}
    Send File Ready Event to VES Collector for HTTPS Server  ${PM_FILE}  ${GLOBAL_TEST_VARIABLES["FILE_FORMAT_TYPE"]}  ${GLOBAL_TEST_VARIABLES["FILE_FORMAT_VERSION"]}    ${https-server_host}

Send File Ready Event to VES Collector for HTTPS Server
    [Arguments]                         ${pm_file}                          ${file_format_type}             ${file_format_version}     ${https_server_host}
    Disable Warnings
    ${pm_event}                         Create Dictionary                   https_server_host=${https_server_host}  pm_file=${pm_file}   fileFormatType=${file_format_type}   fileFormatVersion=${file_format_version}
    Templating.Create Environment       pm                                  ${GLOBAL_TEMPLATE_FOLDER}
    ${VES_FILE_READY_NOTIFICATION}=     Templating.Apply Template           pm                              ${pm_notification_event}   ${pm_event}
    ${headers}=                         Create Dictionary                   content-type=application/json
    ${auth}=                            Create List                         ${GLOBAL_DCAE_VES_USERNAME}     ${GLOBAL_DCAE_VES_PASSWORD}
    ${session}=                         Create Session                      ves                             ${VES_HEALTH_CHECK_PATH}      auth=${auth}
    ${resp}=                            Post Request                        ves                             ${VES_LISTENER_PATH}          data=${VES_FILE_READY_NOTIFICATION}   headers=${headers}
    Should Be Equal As Strings          ${resp.status_code}                 202


Uploading PM Files to xNF HTTPS Server
    [Arguments]                         ${https-server_host}
    ${pm_file}=                         Upload PM Files to xNF HTTPS Server     ${GLOBAL_TEST_VARIABLES["PM_FILE_PATH"]}    ${https-server_host}
    Set Global Variable                 ${PM_FILE}                              ${pm_file}

Upload PM Files to xNF HTTPS Server
    [Arguments]                         ${pm_file_path}                     ${https_server}
    ${epoch}=                           Get Current Date                    result_format=epoch
    ${pm_file} =                        Set Variable                        A${epoch}.xml.gz
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
