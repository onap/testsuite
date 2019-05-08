*** Settings ***
Documentation   HV-VES 'Sunny Scenario' Robot Framwork test - message is sent to the collector and Kafka topic is checked if the message has been published. 


Library    Rammbock
Library    OperatingSystem
Resource    ${EXECDIR}/robot/resources/global_properties.robot
Resource    ${EXECDIR}/robot/resources/test_templates/hvves_template.robot
Suite Teardown  Reset Rammbock

*** Variables ***

*** Test Cases ***
HV-VES test case
    [Tags]    HVVES   ete
    [Timeout]     10s
    ${msg_number_initial}=  Check Number Of Messages On Topic   ${GLOBAL_DNS_MESSAGE_ROUTER_KAFKA_NAME}  ${GLOBAL_MESSAGE_ROUTER_KAFKA_PORT}  ${hvves_kafka_topic}
    Define WTP Protocol
    Start HV-VES TCP Client And Send Message     ${GLOBAL_DNS_HV_VES_NAME}   ${GLOBAL_HV_VES_SERVER_PORT}
    Wait Until Keyword Succeeds      5s      1s      Check If Topic Exists     ${GLOBAL_DNS_MESSAGE_ROUTER_KAFKA_NAME}      ${GLOBAL_MESSAGE_ROUTER_KAFKA_PORT}      ${hvves_kafka_topic}
    ${msg_number_after}=    Check Number Of Messages On Topic   ${GLOBAL_DNS_MESSAGE_ROUTER_KAFKA_NAME}  ${GLOBAL_MESSAGE_ROUTER_KAFKA_PORT}  ${hvves_kafka_topic}
    Should Not Be Equal As Integers     ${msg_number_initial}   ${msg_number_after}
    Download VesEvent Proto File    ${EXECDIR}
    ${msg_decoded}=     Decode Last Message From Topic   ${GLOBAL_DNS_MESSAGE_ROUTER_KAFKA_NAME}  ${GLOBAL_MESSAGE_ROUTER_KAFKA_PORT}  ${hvves_kafka_topic}    ${EXECDIR}
    ${msg_decoded_template}=    Get File    ${EXECDIR}/robot/assets/templates/hvves/hvves_decoded_msg.template
    Should Be Equal As Strings  ${msg_decoded}  ${msg_decoded_template}
