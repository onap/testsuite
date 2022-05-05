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
${CURRENT_CONFIG_FILE}            /tmp/xz.yaml
${COPY_CURRENT_CONFIG}            kubectl -n onap cp $(kubectl -n onap get --no-headers pods -l app.kubernetes.io/name=dcae-hv-ves-collector --field-selector status.phase=Running -o custom-columns=NAME:.metadata.name):/app-config-input/..data/application_config.yaml ${CURRENT_CONFIG_FILE}
${GET_TRUSTSTORE_PASS_PATH}       cat ${CURRENT_CONFIG_FILE} | grep security.keys.trustStorePasswordFile
${TEST_TRUSTSTORE_PASS_PATH}      security.keys.trustStorePasswordFile: /dev/null
${TEST_CONFIG_YAML_PATH}          ${EXECDIR}/robot/assets/dcae/hvves_test_config.yaml
${GET_CM_NAME}                    kubectl -n onap get --no-headers cm -l app.kubernetes.io/name=dcae-hv-ves-collector -o custom-columns=NAME:.metadata.name | grep application-config-configmap
${KAFKA_GET_PASSWORD}             kubectl -n onap get secret strimzi-kafka-admin -o jsonpath="{.data.password}" | base64 --decode

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
    Wait Until Keyword Succeeds         300 sec          15 sec    Send Binary Data    ${hvves_server_ip}    ${hvves_server_port}    ${msg}

Send Message Over Ssl
    [Documentation]     Sends message to HV-VES over TCP wih SSL enabled.
    [Arguments]     ${hvves_server_ip}     ${hvves_server_port}
    ${msg}=    Convert To Bytes     ${HVVES_MESSAGE}
    Wait Until Keyword Succeeds          300 sec             15 sec              Send Binary Data    ${hvves_server_ip}    ${hvves_server_port}    ${msg}    ${TRUE}    ${TRUE}    ${CA_CERT}    ${CLIENT_CERT}    ${CLIENT_KEY}

Decode Last Message From Topic
    [Documentation]     Decode last message from Kafka topic.
    [Arguments]     ${kafka_server}     ${kafka_port}     ${kafka_topic}    ${username}    ${password}
    Connect    kafka    ${kafka_server}:${kafka_port}    ${username}    ${password}
    ${msg}=     Consume    kafka    ${kafka_topic}
    [Return]    ${msg}

Decode Last Message From Topic STRIMZI User
    [Documentation]     Decode last message from Kafka topic using STRIMZI User.
    [Arguments]     ${kafka_server}   ${kafka_topic}    ${username}
    ${command_output} =                 Run And Return Rc And Output        ${KAFKA_GET_PASSWORD}
    Should Be Equal As Integers         ${command_output[0]}                0
    ${password}   Set Variable  ${command_output[1]}
    Connect    kafka    ${kafka_server}    ${username}    ${password}   SCRAM-SHA-512
    ${msg}=     Consume    kafka    ${kafka_topic}
    [Return]    ${msg}

Set Test Config
    [Documentation]     Changes HV-VES config.

    ${TEST_CONFIG}=                            Get File                                       ${TEST_CONFIG_YAML_PATH}    encoding=UTF-8

    Save Configuration From Config Map
    Set Environment Variable                   TEST_CONFIG                                    ${TEST_CONFIG}

    ${cm_name} =                               Get Config Map Name
    ${rc} =                                    Run and Return RC                              kubectl -n onap patch cm ${cm_name} --type strategic -p "%{TEST_CONFIG}"
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

Save Configuration From Config Map
    [Documentation]    Saves current configuration from hv-ves config map in OLD_CONFIG_YAML env

    ${cm_name} =                               Get Config Map Name
    ${rc}    ${prev_conf} =                    Run and Return RC and Output                   kubectl -n onap get cm ${cm_name} -o json
    Should Be Equal As Integers                ${rc}                                          0
    Create File                                ${PREV_CM_FILE}                                ${prev_conf}
    ${rc}    ${prev_conf_yaml} =               Run and Return RC and Output                   kubectl -n onap get cm ${cm_name} -o jsonpath="{.data.application_config\\.yaml}"
    Should Be Equal As Integers                ${rc}                                          0
    Set Environment Variable                   OLD_CONFIG_YAML                                ${prev_conf_yaml}

Get Config Map Name
    [Documentation]    Retrieves HV-VES Config Map name

    ${rc}    ${cm_name} =                      Run and Return RC and Output                   ${GET_CM_NAME}
    Should Be Equal As Integers                ${rc}                                          0
    [Return]           ${cm_name}

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
