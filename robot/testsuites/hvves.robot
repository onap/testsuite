*** Settings ***
Documentation   HV-VES 'Sunny Scenario' Robot Framework test - message is sent to the collector and Kafka topic is checked if the message has been published. Content is decoded and checked.
Default Tags    hvves   ete
Test Timeout    1m
Resource    ../resources/global_properties.robot
Resource    ../resources/dcae/hvves.robot
Library    OperatingSystem
Library    ONAPLibrary.Protobuf

*** Variable ***
${HVVES_KAFKA_TOPIC}    HV_VES_PERF3GPP
${HVVES_KAFKA_TOPIC_SSL}    HV_VES_PERF3GPP_SSL

*** Test Cases ***
HV-VES SSL test case
    Mode    ${HVVES_CONFIG_SSL}
    Send Message Over Ssl    ${GLOBAL_DCAE_HVVES_SERVER_NAME}    ${GLOBAL_DCAE_HVVES_SERVER_PORT}
    Wait Until Keyword Succeeds    10s    2s    Check If Topic Exists    ${GLOBAL_DMAAP_MESSAGE_ROUTER_SERVER_NAME}    ${GLOBAL_DMAAP_MESSAGE_ROUTER_SERVER_PORT}    ${HVVES_KAFKA_TOPIC_SSL}
    Check Message Router Api    ${GLOBAL_DMAAP_MESSAGE_ROUTER_SERVER_NAME}    ${GLOBAL_DMAAP_MESSAGE_ROUTER_SERVER_PORT}    ${HVVES_KAFKA_TOPIC_SSL}
    ${msg}=    Decode Last Message From Topic    ${GLOBAL_DMAAP_KAFKA_SERVER_NAME}    ${GLOBAL_DMAAP_KAFKA_SERVER_PORT}    ${HVVES_KAFKA_TOPIC_SSL}    ${GLOBAL_DMAAP_KAFKA_JAAS_USERNAME}    ${GLOBAL_DMAAP_KAFKA_JAAS_PASSWORD}
    ${results}=    Compare File To Message    ${EXECDIR}/robot/assets/dcae/hvves_msg.raw    ${msg}
    Should Be True    ${results}
    [Teardown]      Mode    ${HVVES_CONFIG}
