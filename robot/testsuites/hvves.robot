*** Settings ***
Documentation   HV-VES 'Sunny Scenario' Robot Framework test - message is sent to the collector and Kafka topic is checked if the message has been published. Content is decoded and checked.
Default Tags    hvves   ete
Test Timeout    3m
Resource    ../resources/global_properties.robot
Resource    ../resources/dcae/hvves.robot
Library    OperatingSystem

*** Test Cases ***
HV-VES test case
    Check Message Router Api    ${GLOBAL_DMAAP_MESSAGE_ROUTER_SERVER_NAME}    ${GLOBAL_DMAAP_MESSAGE_ROUTER_SERVER_PORT}    ${hvves_kafka_topic}
    Start HV-VES TCP Client And Send Message     ${GLOBAL_DCAE_HVVES_SERVER_NAME}   ${GLOBAL_DCAE_HVVES_SERVER_PORT}
    Wait Until Keyword Succeeds      30s      5s      Check If Topic Exists     ${GLOBAL_DMAAP_MESSAGE_ROUTER_SERVER_NAME}      ${GLOBAL_DMAAP_MESSAGE_ROUTER_SERVER_PORT}      ${hvves_kafka_topic}
    Check Message Router Api    ${GLOBAL_DMAAP_MESSAGE_ROUTER_SERVER_NAME}    ${GLOBAL_DMAAP_MESSAGE_ROUTER_SERVER_PORT}    ${hvves_kafka_topic}
    ${msg_decoded}=    Decode Last Message From Topic    ${GLOBAL_DMAAP_KAFKA_SERVER_NAME}    ${GLOBAL_DMAAP_KAFKA_SERVER_PORT}    ${hvves_kafka_topic}    ${security_protocol}    ${sasl_mechanisms}    ${GLOBAL_DMAAP_KAFKA_JAAS_USERNAME}    ${GLOBAL_DMAAP_KAFKA_JAAS_PASSWORD}
    ${msg_decoded_template}=    Get File    ${EXECDIR}/robot/assets/templates/hvves/hvves_decoded_msg.template
    Should Be Equal As Strings  ${msg_decoded}  ${msg_decoded_template}