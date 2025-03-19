*** Settings ***
Documentation    Template contains stuff for HV-VES use case.
Library    OperatingSystem
Library    RequestsLibrary
Library    BuiltIn
Library    Collections
Library    ONAPLibrary.Utilities
Library    String
Library    ONAPLibrary.Kafka

*** Variables ***
${HVVES_MESSAGE}    \xaa\x01\x00\x00\x00\x00\x00\x01\x00\x00\x01'\n\x94\x02\n\x0esample-version\x12\x08perf3gpp\x18\x01 \x01*\nperf3GPP222\x11sample-event-name:\x11sample-event-type@\xf1\x9a\xfd\xdd\x05H\xf1\x9a\xfd\xdd\x05R\x15sample-nf-naming-codeZ\x16sample-nfc-naming-codeb\x15sample-nf-vendor-namej\x1asample-reporting-entity-idr\x1csample-reporting-entity-namez\x10sample-source-id\x82\x01\x0fsample-xnf-name\x8a\x01\tUTC+02:00\x92\x01\x057.0.2\x12\x0etest test test

${KAFKA_GET_PASSWORD}      kubectl -n onap get secret strimzi-kafka-admin -o jsonpath="{.data.password}" | base64 -d

*** Keywords ***
Send Message
    [Documentation]     Sends message to HV-VES over TCP.
    [Arguments]     ${hvves_server_ip}     ${hvves_server_port}
    ${msg}=    Convert To Bytes     ${HVVES_MESSAGE}
    Wait Until Keyword Succeeds         300 sec          15 sec    Send Binary Data    ${hvves_server_ip}    ${hvves_server_port}    ${msg}

Decode Last Message From Topic
    [Documentation]     Decode last message from Kafka topic.
    [Arguments]     ${kafka_server}   ${kafka_topic}    ${username}
    ${command_output} =                 Run And Return Rc And Output        ${KAFKA_GET_PASSWORD}
    Should Be Equal As Integers         ${command_output[0]}                0
    ${password}   Set Variable  ${command_output[1]}
    Connect    kafka    ${kafka_server}    ${username}    ${password}   SCRAM-SHA-512
    ${msg}=     Consume    kafka    ${kafka_topic}
    [Return]    ${msg}
