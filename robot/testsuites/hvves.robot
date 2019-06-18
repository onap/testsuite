*** Settings ***
Documentation   HV-VES 'Sunny Scenario' Robot Framework test - message is sent to the collector and Kafka topic is checked if the message has been published. Content is decoded and checked.
Default Tags    hvves   ete
Test Timeout    3m
Resource    ../resources/global_properties.robot
Resource    ../resources/dcae/hvves.robot
Library    OperatingSystem
Library    ONAPLibrary.Protobuf    

*** Variable ***
${HVVES_KAFKA_TOPIC}    HV_VES_PERF3GPP

*** Test Cases ***
HV-VES test case
    Check Message Router Api    ${GLOBAL_DMAAP_MESSAGE_ROUTER_SERVER_NAME}    ${GLOBAL_DMAAP_MESSAGE_ROUTER_SERVER_PORT}    ${HVVES_KAFKA_TOPIC}
    Start HV-VES TCP Client And Send Message     ${GLOBAL_DCAE_HVVES_SERVER_NAME}   ${GLOBAL_DCAE_HVVES_SERVER_PORT}
    Wait Until Keyword Succeeds      30s      5s      Check If Topic Exists     ${GLOBAL_DMAAP_MESSAGE_ROUTER_SERVER_NAME}      ${GLOBAL_DMAAP_MESSAGE_ROUTER_SERVER_PORT}      ${HVVES_KAFKA_TOPIC}
    Check Message Router Api    ${GLOBAL_DMAAP_MESSAGE_ROUTER_SERVER_NAME}    ${GLOBAL_DMAAP_MESSAGE_ROUTER_SERVER_PORT}    ${HVVES_KAFKA_TOPIC}
    ${msg}=    Decode Last Message From Topic    ${GLOBAL_DMAAP_KAFKA_SERVER_NAME}    ${GLOBAL_DMAAP_KAFKA_SERVER_PORT}    ${HVVES_KAFKA_TOPIC}    ${GLOBAL_DMAAP_KAFKA_JAAS_USERNAME}    ${GLOBAL_DMAAP_KAFKA_JAAS_PASSWORD}
    ${results}=     Compare File To Message    ${EXECDIR}/robot/assets/dcae/hvves_msg.raw    ${msg}
    Should Be True    ${results}