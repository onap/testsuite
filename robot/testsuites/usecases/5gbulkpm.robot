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
Resource          ../../resources/usecases/5gbulkpm_interface.robot
Resource          ../../resources/mr_interface.robot
Resource          ../../resources/dr_interface.robot
Suite Setup       Send File Ready Event to VES Collector   test  org.3GPP.32.435#measCollec  V10
Suite Teardown    Usecase Teardown

*** Variables ***
${INVENTORY_ENDPOINT}               /dcae-service-types
${XNF_SFTP_BLUEPRINT_PATH}          ${EXECDIR}/robot/assets/usecases/5gbulkpm/k8s-sftp.yaml
${BLUEPRINT_TEMPLATE_PATH}          ${EXECDIR}/robot/assets/usecases/5gbulkpm/blueprintTemplate.json
${DEPLOYMENT_ENDPOINT}              dcae-deployments
${MR_TOPIC_CHECK_PATH}              /topics
${DR_SUB_CHECK_PATH}                /internal/prov
${MR_TOPIC_URL_PATH}                /events/org.onap.dmaap.mr.PERFORMANCE_MEASUREMENTS/CG1/C1
${MR_TOPIC_URL_PATH_FOR_POST}       /events/org.onap.dmaap.mr.PERFORMANCE_MEASUREMENTS
${DMAAP_BC_MR_CLIENT_PATH}          /webapi/mr_clients
${DMAAP_BC_MR_CLUSTER_PATH}         /webapi/mr_clusters
${PMMAPPER_HEALTH_CHECK_PATH}       /healthcheck
${JSON_DATA_FILE}                   ${EXECDIR}/robot/assets/usecases/5gbulkpm/Notification.json
${VES_LISTENER_PATH}                /eventListener/v7
${PMMAPPER_SUB_ROLE_DATA}           ${EXECDIR}/robot/assets/usecases/5gbulkpm/sub.json
${PMMAPPER_MR_CLUSTER_DATA}         ${EXECDIR}/robot/assets/usecases/5gbulkpm/mr_clusters.json
${NEXUS3}                           ${GLOBAL_INJECTED_NEXUS_DOCKER_REPO}
${SET_KNOWN_HOSTS_FILE_PATH}        kubectl set env deployment/$(kubectl get deployment -n onap | grep datafile | awk '{print $1}') KNOWN_HOSTS_FILE_PATH=/home/datafile/.ssh/known_hosts -n onap
${CHECK_ENV_SET}                    kubectl set env pod/$(kubectl get pod -n onap | grep datafile | awk '{print $1}') --list -n onap
${GET_RSA_KEY}                      kubectl exec $(kubectl get pod -n onap | grep sftpserver | awk '{print $1}') -n onap -- ssh-keyscan -t rsa sftpserver > /tmp/known_hosts
${COPY_RSA_KEY}                     kubectl cp /tmp/known_hosts $(kubectl get pod -n onap | grep datafile | awk '{print $1}'):/home/datafile/.ssh/known_hosts -n onap
${CHECK_DFC_LOGS}                   kubectl logs $(kubectl get pod -n onap | grep datafile | awk '{print $1}') -n onap --tail=4
${EXPECTED_PRINT}                   StrictHostKeyChecking is enabled but environment variable KNOWN_HOSTS_FILE_PATH is not set or points to not existing file

*** Test Cases ***

Setting Global Variables
    [Documentation]
    ...  This test case chck if suite works in default or custom mode.
    ...  Default mode ius old 5gbulkpm test case executed with PM's presnet in robot image.
    ...  Custom mode is used only in xtesing. Can be executed only as k8s job described in https://gerrit.onap.org/r/gitweb?p=integration/xtesting.git;a=blob_plain;f=smoke-usecases-robot/README.md;hb=refs/heads/master
    ...  Custom mode is used to validate custom PM files. All details how to provide custom PM files is described in documentation above.
    ...  By default in custom mode all PM details are not logged to robot log files, so they are not send to community name: TEST_DB_URL http://testresults.opnfv.org/onap/api/v1/results
    [Tags]                              5gbulkpm                           5gbulkpm_checking_sftp_rsa_key
    ${env_variables} =  Get Environment Variables
    ${bulk_pm_mode}=   Get Variable Value  ${env_variables["BULK_PM_MODE"]}  default
    ${pm_log_level}=   Get Variable Value  ${env_variables["PM_LOG_LEVEL"]}  NONE
    ${test_variables} =  Create Dictionary
    Run Keyword If   "${bulk_pm_mode}" == "custom"  Set To Dictionary  ${test_variables}   FILE_FORMAT_TYPE=${env_variables["FILE_FORMAT_TYPE"]}
                                                     ...                                   FILE_FORMAT_VERSION=${env_variables["FILE_FORMAT_VERSION"]}
                                                     ...                                   PM_FILE_PATH=${env_variables["PM_FILE_PATH"]}
                                                     ...                                   EXPECTED_PM_STR=${env_variables["EXPECTED_PM_STR"]}
                                                     ...                                   EXPECTED_EVENT_JSON_PATH=${env_variables["EXPECTED_EVENT_JSON_PATH"]}
    ...  ELSE   Set To Dictionary  ${test_variables}  FILE_FORMAT_TYPE=org.3GPP.32.435#measCollec
                ...                                   FILE_FORMAT_VERSION=V10
                ...                                   PM_FILE_PATH=${EXECDIR}/robot/assets/usecases/5gbulkpm/pmfiles/A20181002.0000-1000-0015-1000_5G.xml.gz
                ...                                   EXPECTED_PM_STR=perf3gpp_RnNode-Ericsson_pmMeasResult
                ...                                   EXPECTED_EVENT_JSON_PATH=none
    Set Global Variable   ${GLOBAL_TEST_VARIABLES}  ${test_variables}
    Set Global Variable  ${BULK_PM_MODE}  ${bulk_pm_mode}
    Set Global Variable  ${PM_LOG_LEVEL}  ${pm_log_level}


Deploying Data File Collector
    [Tags]                              5gbulkpm                           5gbulkpm_checking_sftp_rsa_key
    ${headers}=                         Create Dictionary                  content-type=application/json
    ${session}=                         Create Session                     dfc                 ${INVENTORY_SERVER}
    ${resp}=                            Get Request                        dfc                 ${INVENTORY_ENDPOINT}?typeName=k8s-datafile                      headers=${headers}
    ${json}=                            Set Variable                       ${resp.json()}
    ${serviceTypeId-Dfc}                Set Variable                       ${json['items'][0]['typeId']}
    ${image}                            Get Regexp Matches                 ${json['items'][0]['blueprintTemplate']}            nexus3(.)*?(?=\\")
    ${image}                            Replace String                     ${image}[0]      nexus3.onap.org:10001                 ${NEXUS3}
    Set Global Variable                 ${serviceTypeId-Dfc}
    ${deployment_data}=                 Set Variable                       {"serviceTypeId": "${serviceTypeId-Dfc}", "inputs": {"tag_version": "${image}"}}
    ${session}=                         Create Session                     deployment-dfc                 ${DEPLOYMENT_SERVER}
    ${resp}=                            Put Request                        deployment-dfc                 /${DEPLOYMENT_ENDPOINT}/datafile         data=${deployment_data}     headers=${headers}
    ${operationLink}                    Set Variable                       ${resp.json().get('links').get('status')}
    ${operationId}                      Fetch From Right                   ${operationLink}                /
    Wait Until Keyword Succeeds         5 minute                           20 sec            Deployment Status       ${DEPLOYMENT_SERVER}     ${DEPLOYMENT_ENDPOINT}     datafile     ${operationId}

Deploying 3GPP PM Mapper
    [Tags]                              5gbulkpm                           5gbulkpm_checking_sftp_rsa_key
    ${clusterdata}=                     OperatingSystem.Get File           ${PMMAPPER_MR_CLUSTER_DATA}
    ${headers}=                         Create Dictionary                  content-type=application/json
    ${session}=                         Create Session                     dmaapbc                          ${DMAAP_BC_SERVER}
    ${resp}=                            Post Request                       dmaapbc                          ${DMAAP_BC_MR_CLUSTER_PATH}          data=${clusterdata}   headers=${headers}
    ${session}=                         Create Session                     pmmapper                 ${INVENTORY_SERVER}
    ${resp}=                            Get Request                        pmmapper                 ${INVENTORY_ENDPOINT}?typeName=k8s-pm-mapper                     headers=${headers}
    ${json}=                            Set Variable                       ${resp.json()}
    ${serviceTypeId-Pmmapper}           Set Variable                       ${json['items'][0]['typeId']}
    ${image}                            Get Regexp Matches                 ${json['items'][0]['blueprintTemplate']}            nexus3(.)*?(?=\')
    ${image}                            Replace String                     ${image}[0]      nexus3.onap.org:10001                 ${NEXUS3}
    Set Global Variable                 ${serviceTypeId-Pmmapper}
    ${deployment_data}=                 Set Variable                       {"inputs":{"client_password": "${GLOBAL_DCAE_PASSWORD}", "tag_version": "${image}"},"serviceTypeId": "${serviceTypeId-Pmmapper}"}
    ${session}=                         Create Session                     deployment-pmmapper                 ${DEPLOYMENT_SERVER}
    ${resp}=                            Put Request                        deployment-pmmapper                 /${DEPLOYMENT_ENDPOINT}/pmmapper         data=${deployment_data}     headers=${headers}
    ${operationLink}                    Set Variable                       ${resp.json().get('links').get('status')}
    ${operationId}                      Fetch From Right                   ${operationLink}                /
    Wait Until Keyword Succeeds         6 minute                           10 sec            Deployment Status       ${DEPLOYMENT_SERVER}     ${DEPLOYMENT_ENDPOINT}     pmmapper     ${operationId}

Deploying SFTP Server As xNF
    [Tags]                              5gbulkpm                           5gbulkpm_checking_sftp_rsa_key
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
    ${deployment_data}=                 Set Variable                       {"serviceTypeId": "${serviceTypeId-Sftp}" }
    ${session}=                         Create Session                     deployment-sftpserver                 ${DEPLOYMENT_SERVER}
    ${resp}=                            Put Request                        deployment-sftpserver                 /${DEPLOYMENT_ENDPOINT}/sftpserver         data=${deployment_data}     headers=${headers}
    ${operationLink}=                   Set Variable                       ${resp.json().get('links').get('status')}
    ${operationId}                      Fetch From Right                   ${operationLink}                /
    Wait Until Keyword Succeeds         2 minute                           5 sec            Deployment Status       ${DEPLOYMENT_SERVER}     ${DEPLOYMENT_ENDPOINT}     sftpserver     ${operationId}


Checking PERFORMANCE_MEASUREMENTS Topic In Message Router
    [Tags]                              5gbulkpm                           5gbulkpm_checking_sftp_rsa_key
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

Uploading PM Files to xNF SFTP Server After Services Deployed
    [Tags]                              5gbulkpm                           5gbulkpm_checking_sftp_rsa_key
    ${pm_file}=  Upload PM Files to xNF SFTP Server  ${GLOBAL_TEST_VARIABLES["PM_FILE_PATH"]}  ${BULK_PM_MODE}
    Set Global Variable  ${PM_FILE}  ${pm_file}

DR Bulk PM Feed Check
    [Tags]                              5gbulkpm                            5gbulkpm_checking_sftp_rsa_key
    ${resp}=                            Run DR Get Request                  ${DR_SUB_CHECK_PATH}
    Should Contain                      ${resp.text}                        bulk_pm_feed

DR PM Mapper Subscriber Check
    [Tags]                              5gbulkpm                            5gbulkpm_checking_sftp_rsa_key
    ${resp}=                            Run DR Get Request                  ${DR_SUB_CHECK_PATH}
    Should Contain                      ${resp.text}                        https://dcae-pm-mapper:8443/delivery

Sending File Ready Event to VES Collector After Services Deployed
    [Tags]                              5gbulkpm                 5gbulkpm_checking_sftp_rsa_key
    Send File Ready Event to VES Collector  ${PM_FILE}  ${GLOBAL_TEST_VARIABLES["FILE_FORMAT_TYPE"]}  ${GLOBAL_TEST_VARIABLES["FILE_FORMAT_VERSION"]}

Verifying 3GPP Perf VES Content On PERFORMANCE_MEASUREMENTS Topic After Services Deployed
    [Tags]                              5gbulkpm                            5gbulkpm_checking_sftp_rsa_key
    Wait Until Keyword Succeeds         2 min                            5 sec            xNF PM File Validate   ${BULK_PM_MODE}   ${GLOBAL_TEST_VARIABLES["EXPECTED_PM_STR"]}  ${GLOBAL_TEST_VARIABLES["EXPECTED_EVENT_JSON_PATH"]}


Setting KNOWN_HOSTS_FILE_PATH Environment Variable
    [Tags]                             5gbulkpm_checking_sftp_rsa_key
    Run Keyword If  '${bulk_pm_mode}' == 'custom'  Set Log Level  TRACE
    ${rc}=                             Run and Return RC                   ${SET_KNOWN_HOSTS_FILE_PATH}
    Should Be Equal As Integers        ${rc}                               0
    Wait Until Keyword Succeeds        5 min                               10s               Check Known Hosts In Env             ${CHECK_ENV_SET}
    ${rc}=                             Run and Return RC                   ${GET_RSA_KEY}
    Should Be Equal As Integers        ${rc}                               0
    ${rc}=                             Run and Return RC                   ${COPY_RSA_KEY}
    Should Be Equal As Integers        ${rc}                               0

Uploading PM Files to xNF SFTP Server After KNOWN_HOSTS_FILE_PATH Env Variable Added
    [Tags]                              5gbulkpm_checking_sftp_rsa_key
    ${pm_file}=  Upload PM Files to xNF SFTP Server  ${GLOBAL_TEST_VARIABLES["PM_FILE_PATH"]}  ${BULK_PM_MODE}
    Set Global Variable  ${PM_FILE}  ${pm_file}

Sending File Ready Event to VES Collector After KNOWN_HOSTS_FILE_PATH Env Variable Added
    [Tags]                              5gbulkpm_checking_sftp_rsa_key
    Send File Ready Event to VES Collector  ${PM_FILE}  ${GLOBAL_TEST_VARIABLES["FILE_FORMAT_TYPE"]}  ${GLOBAL_TEST_VARIABLES["FILE_FORMAT_VERSION"]}

Verifying 3GPP Perf VES Content On PERFORMANCE_MEASUREMENTS Topic After KNOWN_HOSTS_FILE_PATH Env Variable Added
    [Tags]                              5gbulkpm_checking_sftp_rsa_key
    Wait Until Keyword Succeeds         2 min                            5 sec             xNF PM File Validate   ${BULK_PM_MODE}   ${GLOBAL_TEST_VARIABLES["EXPECTED_PM_STR"]}  ${GLOBAL_TEST_VARIABLES["EXPECTED_EVENT_JSON_PATH"]}

Checking DFC Logs After KNOWN_HOSTS_FILE_PATH Env Variable Added
    [Tags]                           5gbulkpm_checking_sftp_rsa_key
    ${dfc_logs}=                     Run Given Command On DFC Container      ${CHECK_DFC_LOGS}
    Should Not Contain               ${dfc_logs}                             ${EXPECTED_PRINT}

Changing SFTP Server RSA Key
    [Tags]                            5gbulkpm_checking_sftp_rsa_key
    ${get_known_hosts_file}=          OperatingSystem.Get File  /tmp/known_hosts
    ${change_rsa_key}=                Replace String            ${get_known_hosts_file}        A  a
    Create File                       /tmp/known_hosts          ${change_rsa_key}
    ${rc}=                            Run and Return RC         ${COPY_RSA_KEY}
    Should Be Equal As Integers       ${rc}                     0

Uploading PM Files to xNF SFTP Server After SFTP Server RSA Key Changed
    [Tags]                              5gbulkpm_checking_sftp_rsa_key
    ${pm_file}=  Upload PM Files to xNF SFTP Server  ${GLOBAL_TEST_VARIABLES["PM_FILE_PATH"]}  ${BULK_PM_MODE}
    Set Global Variable  ${PM_FILE}  ${pm_file}

Sending File Ready Event to VES Collector After SFTP Server RSA Key Changed
    [Tags]                              5gbulkpm_checking_sftp_rsa_key
    Send File Ready Event to VES Collector  ${PM_FILE}  ${GLOBAL_TEST_VARIABLES["FILE_FORMAT_TYPE"]}  ${GLOBAL_TEST_VARIABLES["FILE_FORMAT_VERSION"]}

Checking DFC Logs After SFTP Server RSA Key Changed
    [Tags]                              5gbulkpm_checking_sftp_rsa_key
    Wait Until Keyword Succeeds         5 min  30 sec            Check Given Print In DFC LOG  ${CHECK_DFC_LOGS}
