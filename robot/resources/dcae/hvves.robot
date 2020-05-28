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
Resource    ../consul_interface.robot

*** Variables ***
${HVVES_MESSAGE}    \xaa\x01\x00\x00\x00\x00\x00\x01\x00\x00\x01'\n\x94\x02\n\x0esample-version\x12\x08perf3gpp\x18\x01 \x01*\nperf3GPP222\x11sample-event-name:\x11sample-event-type@\xf1\x9a\xfd\xdd\x05H\xf1\x9a\xfd\xdd\x05R\x15sample-nf-naming-codeZ\x16sample-nfc-naming-codeb\x15sample-nf-vendor-namej\x1asample-reporting-entity-idr\x1csample-reporting-entity-namez\x10sample-source-id\x82\x01\x0fsample-xnf-name\x8a\x01\tUTC+02:00\x92\x01\x057.0.2\x12\x0etest test test
${HVVES_CONFIG_SSL}    {"security.sslDisable": false, "logLevel": "INFO", "security.keys.trustStoreFile": "/tmp/ca.p12", "server.listenPort": 6061, "server.idleTimeoutSec": 300, "cbs.requestIntervalSec": 5, "streams_publishes": {"perf3gpp": {"type": "kafka", "aaf_credentials": {"username": "admin", "password": "admin_secret"}, "kafka_info": {"bootstrap_servers": "message-router-kafka:9092", "topic_name": "HV_VES_PERF3GPP_SSL"}}}, "security.keys.keyStoreFile": "/tmp/server.p12", "security.keys.trustStorePasswordFile": "/dev/null", "security.keys.keyStorePasswordFile": "/dev/null"}
${HVVES_CONFIG}     {"security.sslDisable": false, "logLevel": "INFO", "security.keys.trustStoreFile": "/tmp/ca.p12", "server.listenPort": 6061, "server.idleTimeoutSec": 300, "cbs.requestIntervalSec": 5, "streams_publishes": {"perf3gpp": {"type": "kafka", "aaf_credentials": {"username": "admin", "password": "admin_secret"}, "kafka_info": {"bootstrap_servers": "message-router-kafka:9092", "topic_name": "HV_VES_PERF3GPP"}}}, "security.keys.keyStoreFile": "/tmp/server.p12", "security.keys.trustStorePasswordFile": "/dev/null", "security.keys.keyStorePasswordFile": "/dev/null"}
${CA_CERT}    /tmp/ca.pem
${CLIENT_CERT}    /tmp/client.pem
${CLIENT_KEY}    /tmp/client.key

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

Mode
    [Documentation]     Changes HV-VES config.
    [Arguments]     ${config}
    ${resp}=    Run Consul Put Request      /v1/kv/dcae-hv-ves-collector?dc=dc1     ${config}
    Should Be Equal As Strings      ${resp.status_code}     200
    Sleep   10s
