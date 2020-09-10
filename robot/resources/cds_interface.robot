*** Settings ***
Documentation     The main interface for interacting with CDS. It handles low level stuff like managing the http request library and CDS required fields
Library               RequestsLibrary
Resource          global_properties.robot
Library           SSHLibrary
Library           OperatingSystem
Library           String

*** Variables ***
${CDS_HEALTH_CHECK_PATH}    /api/v1/execution-service/health-check
${CDS_HEALTH_ENDPOINT}     ${GLOBAL_CCSDK_CDS_SERVER_PROTOCOL}://${GLOBAL_INJECTED_CCSDK_CDS_BLUEPRINT_PROCESSOR_IP_ADDR}:${GLOBAL_CCSDK_CDS_HEALTH_SERVER_PORT}
${CDS_CREATE_DATA_DICTIONARY_ENDPOINT}               /api/v1/dictionary/definition
${CDS_RETRIEVE_DATA_DICTIONARY_ENDPOINT}             /api/v1/dictionary/search/
${CDS_BOOTSTRAP_ENDPOINT}                            /api/v1/blueprint-model/bootstrap
${CDS_CBA_ENRICH_ENDPOINT}                           /api/v1/blueprint-model/enrich
${CDS_CBA_PUBLISH_ENDPOINT}                          /api/v1/blueprint-model/publish
${CDS_CBA_PROCESS_API_ENDPOINT}                      /api/v1/execution-service/process
${CDS_CBA_DELETE_ENDPOINT}                           /api/v1/blueprint-model/
${CREATE_DICTIONARY_JSON_PATH}                       ${CURDIR}${/}../assets/cds/create_dictionary.json
${BOOTSTRAP_JSON_PATH}                               ${CURDIR}${/}../assets/cds/bootstrap.json
${CDS_CBA_PROCESS_FILE_PATH}                         ${CURDIR}${/}../assets/cds/cba_process.json
${CDS_CBA_PACKAGE_FILE}                              ${CURDIR}${/}../assets/cds/cba.zip
${CDS_CBA_ENRICHED_FILE}                             ${CURDIR}${/}../assets/cds/enriched-cba.zip
${CDS_CD_TAG}				             restmock
${SUCCESS}                                           EVENT_COMPONENT_EXECUTED

*** Keywords ***
Run CDS Basic Health Check
    [Documentation]    Runs a CDS health check
    ${auth}=  Create List  ${GLOBAL_CCSDK_CDS_USERNAME}    ${GLOBAL_CCSDK_CDS_PASSWORD}
    ${session}=    Create Session       cds    ${CDS_HEALTH_ENDPOINT}    auth=${auth}
    ${headers}=  Create Dictionary    Accept=application/json    Content-Type=application/json
    ${resp}=    Get Request     cds    ${CDS_HEALTH_CHECK_PATH}     headers=${headers}
    Log    Received response code from cds ${resp}
    Log    Received content from cds ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200

Run CDS Create Data Dictionary Health Check
    [Documentation]    Runs CDS Create Data Dictionary Health Check
    ${auth}=  Create List  ${GLOBAL_CCSDK_CDS_USERNAME}    ${GLOBAL_CCSDK_CDS_PASSWORD}
    ${session}=    Create Session       cds    ${CDS_HEALTH_ENDPOINT}    auth=${auth}
    ${headers}=  Create Dictionary    Accept=application/json    Content-Type=application/json
    ${json}      Get Binary File          ${CREATE_DICTIONARY_JSON_PATH}
    ${resp}=    Post Request     cds    ${CDS_CREATE_DATA_DICTIONARY_ENDPOINT}        data=${json}              headers=${headers}
    Log    Received response code from cds ${resp}
    Log    Received content from cds ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200

Run CDS GET Data Dictionary Health Check
    [Documentation]    Runs CDS Get Data Dictionary health check
    ${auth}=  Create List  ${GLOBAL_CCSDK_CDS_USERNAME}    ${GLOBAL_CCSDK_CDS_PASSWORD}
    ${session}=    Create Session       cds    ${CDS_HEALTH_ENDPOINT}    auth=${auth}
    ${headers}=  Create Dictionary    Accept=application/json    Content-Type=application/json
    ${resp}=    Get Request     cds    ${CDS_RETRIEVE_DATA_DICTIONARY_ENDPOINT}${CDS_CD_TAG}     headers=${headers}
    Log    Received response code from cds ${resp}
    Log    Received content from cds ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
    ${res_body}=   Convert to string     ${resp.content}
    Should Contain   ${res_body}     ${CDS_CD_TAG}

Run CDS Bootstrap Health Check
    [Documentation]    Run CDS Bootstrap Health Check
    ${auth}=  Create List  ${GLOBAL_CCSDK_CDS_USERNAME}    ${GLOBAL_CCSDK_CDS_PASSWORD}
    ${session}=    Create Session       cds    ${CDS_HEALTH_ENDPOINT}    auth=${auth}
    ${headers}=  Create Dictionary    Accept=application/json    Content-Type=application/json
    ${json_bootstrap}      Get Binary File          ${BOOTSTRAP_JSON_PATH}
    ${resp}=    Post Request     cds    ${CDS_BOOTSTRAP_ENDPOINT}        data=${json_bootstrap}              headers=${headers}
    Log    Received response code from cds ${resp}
    Log    Received content from cds ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200

Run CDS Enrich CBA Health Check
    [Documentation]    Runs a successful CDS enrich Post requests
    ${auth}=  Create List  ${GLOBAL_CCSDK_CDS_USERNAME}         ${GLOBAL_CCSDK_CDS_PASSWORD}
    ${session}=    Create Session       cds    ${CDS_HEALTH_ENDPOINT}    auth=${auth}
    ${file}=    Evaluate    {'file': open('${CDS_CBA_PACKAGE_FILE}', 'rb')}
    ${resp}=    Post Request   cds    ${CDS_CBA_ENRICH_ENDPOINT}    files=${file}
    Should Be Equal As Strings  ${resp.status_code}    200
    Create File    ${CDS_CBA_ENRICHED_FILE}    ${resp.text}    encoding=ISO-8859-1

Run CDS Publish CBA Health Check
    [Documentation]    Runs a publish CDS upload enriched Post requests API
    ${auth}=  Create List  ${GLOBAL_CCSDK_CDS_USERNAME}       ${GLOBAL_CCSDK_CDS_PASSWORD}
    ${session}=    Create Session       cds    ${CDS_HEALTH_ENDPOINT}    auth=${auth}
    ${file}=    Evaluate    {'file': open('${CDS_CBA_ENRICHED_FILE}', 'rb')}
    ${resp}=    Post Request   cds    ${CDS_CBA_PUBLISH_ENDPOINT}    files=${file}
    Should Be Equal As Strings  ${resp.status_code}    200      And    ${resp.json()['blueprintModel']['id']}!= ${NONE}
    Set Global Variable    ${blueprintModel}    ${resp.json()['blueprintModel']['id']}

Run CDS Process CBA Health Check
    [Documentation]    Runs a process CDS enriched CBA Post requests API
    ${auth}=  Create List  ${GLOBAL_CCSDK_CDS_USERNAME}       ${GLOBAL_CCSDK_CDS_PASSWORD}
    ${session}=    Create Session       cds    ${CDS_HEALTH_ENDPOINT}    auth=${auth}
    ${headers}=  Create Dictionary    Accept=*/*        Content-Type=application/json
    ${file}    Get Binary File                  ${CDS_CBA_PROCESS_FILE_PATH}
    ${resp}=    Post Request   cds    ${CDS_CBA_PROCESS_API_ENDPOINT}    data=${file}   headers=${headers}
    Should Be Equal As Strings  ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['status']['eventType']}   ${SUCCESS}

Run CDS Delete CBA Health Check
    [Documentation]    Runs a CDS Delete CBA Delete requests API
    ${auth}=  Create List  ${GLOBAL_CCSDK_CDS_USERNAME}       ${GLOBAL_CCSDK_CDS_PASSWORD}
    ${session}=    Create Session       cds    ${CDS_HEALTH_ENDPOINT}    auth=${auth}
    ${headers}=    Create Dictionary    Accept=*/*    Content-Type=application/json
    ${resp}=    Delete Request   cds    ${CDS_CBA_DELETE_ENDPOINT}${blueprintModel}       headers=${headers}
    Should Be Equal As Strings  ${resp.status_code}    200
