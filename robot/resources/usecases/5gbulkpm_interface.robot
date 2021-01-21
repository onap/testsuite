*** Settings ***
Documentation	  The main interface for interacting with 5G Bulkpm.
Library 	      RequestsLibrary
Library           OperatingSystem
Library           String
Library           JSONLibrary

*** Variables ***
${INVENTORY_SERVER}                                 ${GLOBAL_INVENTORY_SERVER_PROTOCOL}://${GLOBAL_INVENTORY_SERVER_NAME}:${GLOBAL_INVENTORY_SERVER_PORT}
${DEPLOYMENT_SERVER}                                ${GLOBAL_DEPLOYMENT_HANDLER_SERVER_PROTOCOL}://${GLOBAL_DEPLOYMENT_HANDLER_SERVER_NAME}:${GLOBAL_DEPLOYMENT_HANDLER_SERVER_PORT}
${DR_ENDPOINT}                                      ${GLOBAL_DMAAP_DR_PROV_SERVER_PROTOCOL}://${GLOBAL_INJECTED_DMAAP_DR_PROV_IP_ADDR}:${GLOBAL_DMAAP_DR_PROV_SERVER_PORT}
${DMAAP_BC_SERVER}                                  ${GLOBAL_BC_SERVER_PROTOCOL}://${GLOBAL_INJECTED_BC_IP_ADDR}:${GLOBAL_BC_HTTPS_SERVER_PORT}
${VES_HEALTH_CHECK_PATH}                            ${GLOBAL_DCAE_VES_HTTPS_PROTOCOL}://${GLOBAL_INJECTED_DCAE_VES_HOST}:${GLOBAL_DCAE_VES_HTTPS_SERVER_PORT}
${MR_PUBLISH_TEMPLATE}                              mr/mr_publish.jinja

*** Keywords ***
Undeploy Service
    [Arguments]         ${server}                   ${endpoint}
    ${session}=         Create Session 	            deployment                 ${server}
    ${resp}=            Delete Request              deployment                 ${endpoint}
    [Return]            ${resp}

Deployment Status
    [Arguments]         ${server}                   ${endpoint}            ${deployment}      ${operationId}
    ${session}=         Create Session              deployment-status      ${server}
    ${resp}=            Get Request                 deployment-status      /${endpoint}/${deployment}/operation/${operationId}
    ${status}           Set Variable                ${resp.json().get('status')}
    Should Be Equal As Strings                      ${status}               succeeded


Check Next Event From Topic
    [Documentation]
    ...  This keyword checks if no nomer messages is presnet on MR topic.
    ...  If ther is no more then reports success and finish "Wait Until Keyword Succeeds  2 min  1 s  Check Next Event From Topic" step from "xNF PM File Validate" keyword
    ...  If there are still then it trigger igger "Get Next Event From Topic".
    ...  NOTE: Keyword "Get Next Event From Topic" will always fails in order to not finsh "Wait Until Keyword Succeeds  2 min  1 s  Check Next Event From Topic" step from "xNF PM File Validate" keyword
    ${resp}=  Run MR Auth Get Request     ${MR_TOPIC_URL_PATH}     ${GLOBAL_DCAE_USERNAME}      ${GLOBAL_DCAE_PASSWORD}
    Run keyword If  ${resp.text} == @{EMPTY}  Log  Event is empty! There is no more events on topic!
    ...     ELSE   Get Next Event From Topic  ${resp}

Get Next Event From Topic
    [Documentation]
    ...  This keyword adds new events from MR topic to ${all_event_json_list} in a recursive way and sets ${all_event_json_list} as suite variable in order to be able add new items/evnts in next iteration
    ...  NOTE: Keyword "Get Next Event From Topic" will always fails in order to not finish "Wait Until Keyword Succeeds  2 min  1 s  Check Next Event From Topic" step from "xNF PM File Validate" keyword
    ${resp_list}=  Set Variable   ${resp.json()}
    Log  ${resp_list}
    ${combained_list}=  Combine Lists  ${all_event_json_list}  ${resp_list}
    ${all_event_json_list}=  Set Variable  ${combained_list}
    Set Suite Variable 	${all_event_json_list}
    Fail

xNF PM File Validate
    [Documentation]
    ...  This keyword gather all events from message router topic and validates if in recived data is present expexted string: "${expected_pm_str}" .
    ...  In custom mode it saves also response as a json file "${PM_FILE}-${timestamp}.json" in location  "${expected_event_json_path}"
    [Arguments]  ${bulk_pm_mode}  ${expected_pm_str}  ${expected_event_json_path}
    Run Keyword If  '${bulk_pm_mode}' == 'custom'  Set Log Level  ${PM_LOG_LEVEL}
    ${timestamp}=  Get Time  epoch
    ${resp}=  Run MR Auth Get Request     ${MR_TOPIC_URL_PATH}     ${GLOBAL_DCAE_USERNAME}      ${GLOBAL_DCAE_PASSWORD}
    Run keyword If  ${resp.text} == @{EMPTY}  Fail  msg=Event is empty!
    ${all_event_json_list}=  Set Variable  ${resp.json()}
    Set Suite Variable 	${all_event_json_list}
    Wait Until Keyword Succeeds  2 min  5 sec  Check Next Event From Topic
    ${all_event_json_string}=   Convert To String    ${all_event_json_list}
    Should Contain   ${all_event_json_string}   ${expected_pm_str}
    Run Keyword If  '${bulk_pm_mode}' == 'custom'   Print Evnets From Topic to JSON file  ${expected_event_json_path}  ${all_event_json_string}
    Run Keyword If  '${bulk_pm_mode}' == 'custom'  Set Log Level  TRACE


Print Evnets From Topic to JSON file
    [Arguments]   ${expected_event_json_path}  ${all_event_json_string}
     ${str}=  Replace String   ${all_event_json_string}   u'{  {
     ${all_event_json_string}=  Replace String   ${str}   }'  }
     ${json}=  To Json  ${all_event_json_string}   pretty_print=True
     ${timestamp}=  Get Time  epoch
     Create File  ${expected_event_json_path}/${PM_FILE}-${timestamp}.json  ${json}


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


Usecase Teardown
    Undeploy Service                    ${DEPLOYMENT_SERVER}                 /${DEPLOYMENT_ENDPOINT}/pmmapper
    Undeploy Service                    ${DEPLOYMENT_SERVER}                 /${DEPLOYMENT_ENDPOINT}/sftpserver
    Undeploy Service                    ${INVENTORY_SERVER}                  ${INVENTORY_ENDPOINT}/${serviceTypeId-Sftp}
    Undeploy Service                    ${DEPLOYMENT_SERVER}                  /${DEPLOYMENT_ENDPOINT}/datafile


Send File Ready Event to VES Collector
    [Arguments]                         ${pm_file}                          ${file_format_type}             ${file_format_version}
    ${headers}=                         Create Dictionary                   content-type=application/json
    ${fileready}=                       OperatingSystem.Get File            ${JSON_DATA_FILE}
    ${auth}=                            Create List                         ${GLOBAL_DCAE_VES_USERNAME}     ${GLOBAL_DCAE_VES_PASSWORD}
    ${session}=                         Create Session                      ves                             ${VES_HEALTH_CHECK_PATH}      auth=${auth}
    ${resp}=                            Post Request                        ves                             ${VES_LISTENER_PATH}          data=${fileready}   headers=${headers}
    Should Be Equal As Strings          ${resp.status_code}                 202
    ${VES_FILE_READY_NOTIFICATION}      Set Variable                        {"event":{"commonEventHeader":{"version":"4.0.1","vesEventListenerVersion":"7.0.1","domain":"notification","eventName":"Noti_RnNode-Ericsson_FileReady","eventId":"FileReady_1797490e-10ae-4d48-9ea7-3d7d790b25e1","lastEpochMicrosec":8745745764578,"priority":"Normal","reportingEntityName":"otenb5309","sequence":0,"sourceName":"oteNB5309","startEpochMicrosec":8745745764578,"timeZoneOffset":"UTC+05.30"},"notificationFields":{"changeIdentifier":"PM_MEAS_FILES","changeType":"FileReady","notificationFieldsVersion":"2.0","arrayOfNamedHashMap":[{"name":"${pm_file}","hashMap":{"location":"sftp://bulkpm:bulkpm@sftpserver:22/upload/${pm_file}","compression":"gzip","fileFormatType":"${file_format_type}","fileFormatVersion":"${file_format_version}"}}]}}}
    ${resp}=                            Post Request                        ves                             ${VES_LISTENER_PATH}          data=${VES_FILE_READY_NOTIFICATION}   headers=${headers}
    Should Be Equal As Strings          ${resp.status_code}                 202

Upload PM Files to xNF SFTP Server
    [Arguments]                         ${pm_file_path}                   ${bulk_pm_mode}
    Open Connection                     sftpserver
    Login                               bulkpm                             bulkpm
    ${epoch}=                           Get Current Date                   result_format=epoch
    ${pm_file} =  Run Keyword If        "${bulk_pm_mode}" == "custom"      Fetch From Right                   ${pm_file_path}               marker=/
    ...                     ELSE                                           Set Variable                        A${epoch}.xml.gz
    Put File                            ${pm_file_path}                    upload/${pm_file}
    [Return]  ${pm_file}

Check Given Print In DFC Log
    [Arguments]  ${check_dfc_logs}
    ${dfc_logs}=                     Run Given Command On DFC Container      ${CHECK_DFC_LOGS}
    Should Contain                   ${dfc_logs}                             HostKey has been changed

Run Given Command On DFC Container
    [Arguments]  ${user_command}
    ${run_command} =   Run And Return Rc And Output  ${user_command}
    ${command_output} =  Set Variable  ${run_command[1]}
    ${regexp_matches} =  Get Regexp Matches  ${command_output}  .*(\\s|\\[)+(.+-datafile-collector).*  2
    ${dfc_container_name} =  Set Variable  ${regexp_matches[0]}
    ${new_command} =  Set Variable  ${user_command} ${dfc_container_name}
    ${command_output} =  Run And Return Rc And Output  ${new_command}
    Should Be Equal As Integers  ${command_output[0]}  0
    ${log} =  Set Variable  ${command_output[1]}
    [Return]  ${log}

Check Known Hosts In Env
    [Arguments]    ${CHECK_KNOWN_HOSTS}
    ${check} =  Run And Return Rc And Output  ${CHECK_KNOWN_HOSTS}
    Should Be Equal As Integers  ${check[0]}  0
    ${env} =  Set Variable  ${check[1]}
    ${string_matches} =  Get Lines Containing String  ${env}  KNOWN_HOSTS_FILE_PATH=/home/datafile/.ssh/known_host  case_insensitive=True
    ${output} =  Should Not Be Empty  ${string_matches}
    [Return]    ${output}

