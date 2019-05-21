*** Settings ***
Documentation   Template contains stuff for HV-VES use case.
Library     OperatingSystem
Library     RequestsLibrary
Library     BuiltIn
Library     Collections
Library     SocketUtils
Library    String
Resource    ../mr_interface.robot

*** Variables ***
${hvves_message}    \xaa\x01\x00\x00\x00\x00\x00\x01\x00\x00\x01'\n\x94\x02\n\x0esample-version\x12\x08perf3gpp\x18\x01 \x01*\nperf3GPP222\x11sample-event-name:\x11sample-event-type@\xf1\x9a\xfd\xdd\x05H\xf1\x9a\xfd\xdd\x05R\x15sample-nf-naming-codeZ\x16sample-nfc-naming-codeb\x15sample-nf-vendor-namej\x1asample-reporting-entity-idr\x1csample-reporting-entity-namez\x10sample-source-id\x82\x01\x0fsample-xnf-name\x8a\x01\tUTC+02:00\x92\x01\x057.0.2\x12\x0etest test test
${hvves_kafka_topic}    HV_VES_PERF3GPP
${security_protocol}    SASL_PLAINTEXT
${sasl_mechanisms}    PLAIN

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

Start HV-VES TCP Client And Send Message
    [Documentation]     Starts HV-VES TCP client sends message to the collector.
    [Arguments]     ${hvves_server_ip}     ${hvves_server_port}
    ${msg}=    Convert To Bytes     ${hvves_message}
    Send Binary Data    ${hvves_server_ip}    ${hvves_server_port}    ${msg}

Decode Last Message From Topic
    [Documentation]     Decode last message from Kafka topic.
    [Arguments]     ${kafka_server}     ${kafka_port}     ${kafka_topic}    ${sec_protocol}    ${mechanisms}    ${username}    ${password}
    #Catenate    http://message-router.onap:3904/events/${kafka_topic}/group1/C1?timeout=5000?limit=1
    ${msg}=     Run     kafkacat -C -b ${kafka_server}:${kafka_port} -t ${kafka_topic} -X security.protocol=${sec_protocol} -X sasl.mechanisms=${mechanisms} -X sasl.username=${username} -X sasl.password=${password} -D "" -o -1 -c 1 | protoc --decode_raw
    [Return]    ${msg}

