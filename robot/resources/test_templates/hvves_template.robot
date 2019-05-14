*** Settings ***
Documentation   Template contains stuff for HV-VES use case.
Library     OperatingSystem
Library     RequestsLibrary
Library     Rammbock
Library     BuiltIn
Library     Collections

*** Variables ***
${hvves_message}    0x0a94020a0e73616d706c652d76657273696f6e12087065726633677070180120012a0a70657266334750503232321173616d706c652d6576656e742d6e616d653a1173616d706c652d6576656e742d7479706540f19afddd0548f19afddd05521573616d706c652d6e662d6e616d696e672d636f64655a1673616d706c652d6e66632d6e616d696e672d636f6465621573616d706c652d6e662d76656e646f722d6e616d656a1a73616d706c652d7265706f7274696e672d656e746974792d6964721c73616d706c652d7265706f7274696e672d656e746974792d6e616d657a1073616d706c652d736f757263652d696482010f73616d706c652d786e662d6e616d658a01095554432b30323a3030920105372e302e32120e7465737420746573742074657374
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

Define WTP Protocol
    [Documentation]     Defines Wire Transfer Protocol.
    New Protocol    WireTransferProtocol
    u8    magic     0xAA
    u8    versionMajor  0x01
    u8    versionMinor  0x00
    u24     reserved     0x000000
    u16     payloadId    0x0001
    u32     payloadLength   0x00000127
    uint    295     payload  ${hvves_message}
    End Protocol

Start HV-VES TCP Client And Send Message
    [Documentation]     Starts HV-VES TCP client sends message to the collector.
    [Arguments]     ${hvves_server_ip}     ${hvves_server_port}
    Start Tcp Client    timeout=5   protocol=WireTransferProtocol
    Connect     ${hvves_server_ip}  ${hvves_server_port}
    New Message     HvVesMessage    protocol=WireTransferProtocol
    Client Sends Message

Decode Last Message From Topic
    [Documentation]     Decode last message from Kafka topic.
    [Arguments]     ${kafka_server}     ${kafka_port}     ${kafka_topic}    ${sec_protocol}    ${mechanisms}    ${username}    ${password}
    ${msg}=     Run     kafkacat -C -b ${kafka_server}:${kafka_port} -t ${kafka_topic} -X security.protocol=${sec_protocol} -X sasl.mechanisms=${mechanisms} -X sasl.username=${username} -X sasl.password=${password} -D "" -o -1 -c 1 | protoc --decode_raw
    [Return]    ${msg}

