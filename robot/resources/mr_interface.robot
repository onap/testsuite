*** Settings ***
Documentation     The main interface for interacting with Message router. It handles low level stuff like managing the http request library and message router required fields
Library           RequestsClientCert
Library               RequestsLibrary
Library           UUID

Resource          global_properties.robot

*** Variables ***
${MR_HEALTH_CHECK_PATH}        /topics
${MR_PUB_HEALTH_CHECK_PATH}        /events/TEST_TOPIC
${MR_SUB_HEALTH_CHECK_PATH}        /events/TEST_TOPIC/g1/c4?timeout=5000
${MR_ENDPOINT}     ${GLOBAL_MR_SERVER_PROTOCOL}://${GLOBAL_INJECTED_MR_IP_ADDR}:${GLOBAL_MR_SERVER_PORT}
${MR_PUBLISH_TEMPLATE}     robot/assets/templates/mr_publish.template


*** Keywords ***
Run MR Health Check
     [Documentation]    Runs MR Health check
     ${resp}=    Run MR Get Request    ${MR_HEALTH_CHECK_PATH}
     Should Be Equal As Strings        ${resp.status_code}     200
     Should Contain    ${resp.json()}    topics

Run MR PubSub Health Check
     [Documentation]    Runs MR PubSub Health check
     ${resp}=    Run MR Get Request    ${MR_SUB_HEALTH_CHECK_PATH}
     # topic may not be created which is a 400 error
     ${resp}=    Run MR Post Request    ${MR_PUB_HEALTH_CHECK_PATH}
     Should Be Equal As Strings         ${resp.status_code}     200
     Should Contain    ${resp.json()}    serverTimeMs    Failed to Write Data
     ${resp}=    Run MR Get Request    ${MR_SUB_HEALTH_CHECK_PATH}
     # ${resp} is an array
     Should Be Equal As Strings         ${resp.status_code}     200
     Should Contain    ${resp.json()[0]}    timestamp    Failed to Read Data

Run MR Get Request
     [Documentation]    Runs MR Get request
     [Arguments]    ${data_path}
     ${session}=    Create Session      mr      ${MR_ENDPOINT}
     ${uuid}=    Generate UUID
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json    X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}
     ${resp}=   Get Request     mr      ${data_path}     headers=${headers}
     Log    Received response from message router ${resp.text}
     [Return]    ${resp}

Run MR Post Request
     [Documentation]    Runs MR Post request
     [Arguments]    ${data_path}
     ${session}=    Create Session      mr      ${MR_ENDPOINT}
     ${timestamp}=   Get Current Date
     ${dict}=    Create Dictionary    timestamp=${timestamp}
     ${data}=   Fill JSON Template File    ${MR_PUBLISH_TEMPLATE}    ${dict}
     ${uuid}=    Generate UUID
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json    X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}
     ${resp}=   Post Request    mr      ${data_path}     data=${data}    headers=${headers}
     Log    Received response from message router ${resp.text}
     [Return]    ${resp}

