*** Settings ***
Documentation   HV-VES 'Sunny Scenario' Robot Framework test - message is sent to the collector and Kafka topic is checked if the message has been published. Content is decoded and checked.
Default Tags    hvves   ete
Test Timeout    5m
Resource    ../resources/global_properties.robot
Resource    ../resources/dcae/hvves.robot
Library    OperatingSystem
Library    ONAPLibrary.Protobuf

*** Test Cases ***
HV-VES test case
    ${status}    ${data}=    Run Keyword And Ignore Error   Variable Should Exist    ${GLOBAL_KAFKA_BOOTSTRAP_SERVICE}
    Send Message    ${GLOBAL_DCAE_HVVES_SERVER_NAME}        ${GLOBAL_DCAE_HVVES_SERVER_PORT}
    Sleep   2s
    ${msg}=  Run Keyword  Decode Last Message From Topic    ${GLOBAL_KAFKA_BOOTSTRAP_SERVICE}   HV_VES_PERF3GPP  ${GLOBAL_KAFKA_USER}
    ${results}=    Compare File To Message    ${EXECDIR}/robot/assets/dcae/hvves_msg.raw    ${msg}
    Should Be True    ${results}
