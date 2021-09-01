*** Settings ***
Documentation    Template contains stuff for HV-VES use case.
Library    OperatingSystem
Library    RequestsLibrary
Library    BuiltIn
Library    Collections
Library    ONAPLibrary.Utilities
Library    String
Library    ONAPLibrary.Kafka
Resource    ../mr_interface.robot

*** Variables ***
${HVVES_MESSAGE}    \xaa\x01\x00\x00\x00\x00\x00\x01\x00\x00\x01'\n\x94\x02\n\x0esample-version\x12\x08perf3gpp\x18\x01 \x01*\nperf3GPP222\x11sample-event-name:\x11sample-event-type@\xf1\x9a\xfd\xdd\x05H\xf1\x9a\xfd\xdd\x05R\x15sample-nf-naming-codeZ\x16sample-nfc-naming-codeb\x15sample-nf-vendor-namej\x1asample-reporting-entity-idr\x1csample-reporting-entity-namez\x10sample-source-id\x82\x01\x0fsample-xnf-name\x8a\x01\tUTC+02:00\x92\x01\x057.0.2\x12\x0etest test test
${CA_CERT}    /tmp/ca.pem
${CLIENT_CERT}    /tmp/client.pem
${CLIENT_KEY}    /tmp/client.key

${PREV_CM_FILE}                   /tmp/prevCm.json
${CURRENT_CONFIG_FILE}            /tmp/currentConfig.yaml
${CM_NAME}                        dev-dcae-hv-ves-collector-application-config-configmap
${GET_PREV_CM}                    kubectl -n onap get cm ${CM_NAME} -o json

${TEST_TRUSTSTORE_PASS_PATH}      security.keys.trustStorePasswordFile: /dev/null

${COPY_CURRENT_CONFIG}            kubectl -n onap cp $(kubectl get pods -n onap | grep hv-ves | awk '{print $1}' | grep -v NAME):/app-config-input/..data/application_config.yaml ${CURRENT_CONFIG_FILE}
${GET_TRUSTSTORE_PASS_PATH}       cat ${CURRENT_CONFIG_FILE} | grep security.keys.trustStorePasswordFile

${GET_CONFIG_FROM_CM}             kubectl -n onap get cm ${CM_NAME} -o jsonpath="{.data.application_config\\.yaml}"

${TEST_CONFIG}        SEPARATOR=\n
...                         data:
...                           ${SPACE*2}application_config.yaml: |
...                              ${SPACE*4}security.sslDisable: false
...                              ${SPACE*4}logLevel: INFO
...                              ${SPACE*4}security.keys.trustStoreFile: /tmp/ca.p12
...                              ${SPACE*4}server.listenPort: 6061
...                              ${SPACE*4}server.idleTimeoutSec: 300
...                              ${SPACE*4}cbs.requestIntervalSec: 5
...                              ${SPACE*4}streams_publishes:
...                                ${SPACE*6}perf3gpp:
...                                  ${SPACE*8}type: kafka
...                                  ${SPACE*8}aaf_credentials:
...                                    ${SPACE*10}username: admin
...                                    ${SPACE*10}password: admin_secret
...                                  ${SPACE*8}kafka_info:
...                                    ${SPACE*10}bootstrap_servers: message-router-kafka:9092
...                                    ${SPACE*10}topic_name: HV_VES_PERF3GPP_SSL
...                              ${SPACE*4}security.keys.keyStoreFile: /tmp/server.p12
...                              ${SPACE*4}${TEST_TRUSTSTORE_PASS_PATH}
...                              ${SPACE*4}security.keys.keyStorePasswordFile: /dev/null

*** Keywords ***
Check Message Router Api
    [Documentation]    Checks message via message router API.
    [Arguments]    ${message_router}    ${message_router_port}    ${topic}
    ${session}=    Create Session   session   http://${message_router}:${message_router_port}/events
    ${resp}=   Get Request   session   /${topic}/1/1
    Run Keyword If    400 <= ${resp.status_code} < 500    Log    Topic ${topic} does not exist.
    Run Keyword If    200 <= ${resp.status_code} < 300    Log    Topic ${topic} exists.

Check If Topic Exists
    [Documentation]      Checks if specific topic exists on kafka.
    [Arguments]      ${message_router}      ${message_router_port}      ${topic}
    ${session}=    Create Session   session   http://${message_router}:${message_router_port}/topics
    ${resp}=   Get Request   session   /
    ${value}=    Catenate    ${resp.json()['topics']}
    Should Contain    ${value}    ${topic}

Send Message
    [Documentation]     Sends message to HV-VES over TCP.
    [Arguments]     ${hvves_server_ip}     ${hvves_server_port}
    ${msg}=    Convert To Bytes     ${HVVES_MESSAGE}
    Send Binary Data    ${hvves_server_ip}    ${hvves_server_port}    ${msg}

Send Message Over Ssl
    [Documentation]     Sends message to HV-VES over TCP wih SSL enabled.
    [Arguments]     ${hvves_server_ip}     ${hvves_server_port}
    ${msg}=    Convert To Bytes     ${HVVES_MESSAGE}
    Send Binary Data    ${hvves_server_ip}    ${hvves_server_port}    ${msg}    ${TRUE}    ${TRUE}    ${CA_CERT}    ${CLIENT_CERT}    ${CLIENT_KEY}

Decode Last Message From Topic
    [Documentation]     Decode last message from Kafka topic.
    [Arguments]     ${kafka_server}     ${kafka_port}     ${kafka_topic}    ${username}    ${password}
    Connect    kafka    ${kafka_server}:${kafka_port}    ${username}    ${password}
    ${msg}=     Consume    kafka    ${kafka_topic}
    [Return]    ${msg}

Set Test Config
    [Documentation]     Changes HV-VES config.

    ${rc}    ${prev_conf} =                    Run and Return RC and Output                   ${GET_PREV_CM}
    Should Be Equal As Integers                ${rc}                                          0
    Create File                                ${PREV_CM_FILE}                                ${prev_conf}

    ${rc}    ${prev_conf_yaml} =               Run and Return RC and Output                   ${GET_CONFIG_FROM_CM}
    Should Be Equal As Integers                ${rc}                                          0
    Set Environment Variable                   OLD_CONFIG_YAML                                ${prev_conf_yaml}

    Set Environment Variable                   TEST_CONFIG                                    ${TEST_CONFIG}

    ${rc} =                                    Run and Return RC                              kubectl -n onap patch cm ${CM_NAME} --type strategic -p "%{TEST_CONFIG}"
    Should Be Equal As Integers                ${rc}                                          0

    Wait Until Keyword Succeeds                2 min                5 sec                    Check If Config Is Applied    ${TEST_TRUSTSTORE_PASS_PATH}
    Sleep                                      5s


Check If Config Is Applied
    [Documentation]    Checks if the config is applied.
    [Arguments]        ${truststore_pass_path}

    ${rc} =                                    Run and Return RC                              ${COPY_CURRENT_CONFIG}
    Should Be Equal As Integers                ${rc}                                          0

    ${rc}      ${current_trust_pass_path} =    Run and Return RC and Output                   ${GET_TRUSTSTORE_PASS_PATH}
    Should Be Equal As Integers                ${rc}                                          0

    Should Be Equal As Strings                 ${truststore_pass_path}                        ${current_trust_pass_path}

Set Old Config
    [Documentation]     Changes HV-VES config back to normal mode.

    ${rc} =                                    Run and Return RC                              kubectl -n onap replace --force -f ${PREV_CM_FILE}
    Should Be Equal As Integers                ${rc}                                          0

    ${rc}    ${old_trust_pass_path} =          Run and Return RC and Output                   echo "%{OLD_CONFIG_YAML}" | grep security.keys.trustStorePasswordFile
    Should Be Equal As Integers                ${rc}                                          0

    Remove File                                ${PREV_CM_FILE}
    Remove File                                ${CURRENT_CONFIG_FILE}

    Wait Until Keyword Succeeds                2 min                5 sec                    Check If Config Is Applied    ${old_trust_pass_path}

    Sleep                                      10s
