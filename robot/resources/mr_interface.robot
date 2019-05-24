*** Settings ***
Documentation     The main interface for interacting with Message router. It handles low level stuff like managing the http request library and message router required fields
Library           RequestsLibrary
Library           UUID
Library           DateTime
Library           Process
Library           JSONUtils

Resource          global_properties.robot
Resource          ../resources/json_templater.robot

*** Variables ***
${MR_HEALTH_CHECK_PATH}        /topics
${MR_PUB_HEALTH_CHECK_PATH}        /events/TEST_TOPIC
${MR_SUB_HEALTH_CHECK_PATH}        /events/TEST_TOPIC/g1/c4?timeout=5000
${MR_CREATE_TOPIC_PATH}        /topics/create
${MR_UPDATE_ACL_TOPIC_PATH}        /topics/TEST_TOPIC_ACL/producers
${MR_ENDPOINT}     ${GLOBAL_MR_SERVER_PROTOCOL}://${GLOBAL_INJECTED_MR_IP_ADDR}:${GLOBAL_MR_SERVER_PORT}
${MR_PUBLISH_TEMPLATE}     robot/assets/templates/mr_publish.template
${MR_PUT_ACL_TEMPLATE}    robot/assets/templates/mr_put_acl.template


*** Keywords ***
Run MR Health Check
     [Documentation]    Runs MR Health check
     ${resp}=    Run MR Get Request    ${MR_HEALTH_CHECK_PATH}
     Should Be Equal As Strings        ${resp.status_code}     200
     Should Contain    ${resp.json()}    topics

Run MR PubSub Health Check
     [Documentation]    Runs MR PubSub Health check
     #${resp}=    Run MR Get Request    ${MR_SUB_HEALTH_CHECK_PATH}
     # topic may not be created which is a 400 error

     ${resp}=    Run MR Post Request    ${MR_PUB_HEALTH_CHECK_PATH}
     Should Be Equal As Strings         ${resp.status_code}     200
     Should Contain    ${resp.json()}    serverTimeMs    Failed to Write Data
     ${resp}=    Run MR Get Request    ${MR_SUB_HEALTH_CHECK_PATH}
     # Always Write twice to catch lost first message
     ${resp}=    Run MR Post Request    ${MR_PUB_HEALTH_CHECK_PATH}
     ${resp}=    Run MR Get Request    ${MR_SUB_HEALTH_CHECK_PATH}
     # ${resp} is an array
     Should Be Equal As Strings         ${resp.status_code}     200
     Should Contain    ${resp.json()[0]}    timestamp    Failed to Read Data


Run MR Update Topic Acl
     [Documentation]    Runs MR create topic and update producer credentials
     #
     #   Testing to Delete a Topic:
     #           /opt/kafka/bin/kafka-topics.sh --zookeeper message-router-zookeeper:2181 --delete --topic <topic_name>
     #           /opt/kafka/bin/kafka-topics.sh --zookeeper message-router-zookeeper:2181 --delete --topic TEST_TOPIC_ACL
     #
     #   Appears to not care if topic already exists with the POST / PUT method
     #
     ${dict}=    Create Dictionary    TOPIC_NAME=TEST_TOPIC_ACL
     ${data}=   Fill JSON Template File    ${MR_PUT_ACL_TEMPLATE}    ${dict}
     #Log To Console    ${\n}Create TEST_TOPIC_ACL
     ${resp}=    Run MR Auth Post Request    ${MR_CREATE_TOPIC_PATH}   iPIxkpAMI8qTcQj8  Ehq3WyT4bkif4zwgEbvshGal   ${data}
     #Log To Console    Update Owner for TEST_TOPIC_ACL
     ${resp}=    Run MR Auth Put Request    ${MR_UPDATE_ACL_TOPIC_PATH}/iPIxkpAMI8qTcQj8  iPIxkpAMI8qTcQj8    Ehq3WyT4bkif4zwgEbvshGal    ${data}
     Should Be Equal As Strings         ${resp.status_code}     200

Run MR Auth Post Request
     [Documentation]    Runs MR Authenticated Post Request
     [Arguments]     ${data_path}     ${id_key}   ${secret_key}    ${data}
     ${current_time}=   Get Time
     ${time}=    Evaluate    datetime.datetime.today().replace(tzinfo=pytz.UTC).replace(microsecond=0).isoformat()    modules=datetime,pytz
     ${command}=  Set Variable    /bin/echo -n "${time}" | /usr/bin/openssl sha1 -hmac "${secret_key}" -binary | /usr/bin/openssl base64
     ${result}=    Run Process    ${command}   shell=True
     ${signature}=   Set Variable    ${result.stdout}
     ${xAuth}=    Set Variable    ${id_key}:${signature}
     ${headers}=  Create Dictionary     Content-Type=application/json    X-CambriaAuth=${xAuth}    X-CambriaDate=${time}
     ${session}=    Create Session      mr      ${MR_ENDPOINT}
     ${resp}=   Post Request     mr      ${data_path}     headers=${headers}   data=${data}
     ${status_string}=    Convert To String    ${resp.status_code}
     Should Match Regexp    ${status_string}    ^(204|200)$
     Log    Received response from message router ${resp.text}
     [Return]    ${resp}


Run MR Auth Put Request
     [Documentation]    Runs MR Authenticated Put Request
     [Arguments]     ${data_path}     ${id_key}   ${secret_key}    ${data}
     ${current_time}=   Get Time
     ${time}=    Evaluate    datetime.datetime.today().replace(tzinfo=pytz.UTC).replace(microsecond=0).isoformat()    modules=datetime,pytz
     ${command}=  Set Variable    /bin/echo -n "${time}" | /usr/bin/openssl sha1 -hmac "${secret_key}" -binary | /usr/bin/openssl base64
     ${result}=    Run Process    ${command}   shell=True
     ${signature}=   Set Variable    ${result.stdout}
     ${xAuth}=    Set Variable    ${id_key}:${signature}
     ${headers}=  Create Dictionary     Content-Type=application/json    X-CambriaAuth=${xAuth}    X-CambriaDate=${time}
     ${session}=    Create Session      mr      ${MR_ENDPOINT}
     ${resp}=   Put Request     mr      ${data_path}     headers=${headers}   data=${data}
     Should Be Equal As Strings         ${resp.status_code}     200
     Log    Received response from message router ${resp.text}
     [Return]    ${resp}

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

