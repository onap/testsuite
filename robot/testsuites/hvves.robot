*** Settings ***
Documentation   HV-VES 'Sunny Scenario' Robot Framwork test - message is sent to the collector and Kafka topic is checked if the message has been published.
Default Tags    hvves   ete
Test Timeout    3m
Resource    ${EXECDIR}/robot/resources/global_properties.robot
Resource    ${EXECDIR}/robot/resources/test_templates/hvves_template.robot
Suite Teardown  Reset Rammbock

*** Variables ***

*** Test Cases ***
HV-VES test case
    Check Message Via Message Router Api    ${GLOBAL_DNS_MESSAGE_ROUTER_NAME}    ${GLOBAL_MESSAGE_ROUTER_PORT}    ${hvves_kafka_topic}    before
    Define WTP Protocol
    Start HV-VES TCP Client And Send Message     ${GLOBAL_DNS_HV_VES_NAME}   ${GLOBAL_HV_VES_SERVER_PORT}
    Wait Until Keyword Succeeds      30s      5s      Check If Topic Exists     ${GLOBAL_DNS_MESSAGE_ROUTER_NAME}      ${GLOBAL_MESSAGE_ROUTER_PORT}      ${hvves_kafka_topic}
    Check Message Via Message Router Api    ${GLOBAL_DNS_MESSAGE_ROUTER_NAME}    ${GLOBAL_MESSAGE_ROUTER_PORT}    ${hvves_kafka_topic}    after
    ${msg_decoded}=    Decode Last Message From Topic    ${GLOBAL_DNS_MESSAGE_ROUTER_KAFKA_NAME}    ${GLOBAL_MESSAGE_ROUTER_KAFKA_PORT}    ${hvves_kafka_topic}    ${security_protocol}    ${sasl_mechanisms}    ${sasl_username}    ${sasl_password}
    ${msg_decoded_template}=    Get File    ${EXECDIR}/robot/assets/templates/hvves/hvves_decoded_msg.template
    Should Be Equal As Strings  ${msg_decoded}  ${msg_decoded_template}
