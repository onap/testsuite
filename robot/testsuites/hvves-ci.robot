*** Settings ***
Documentation   HV-VES 'Sunny Scenario' Robot Framework test - message is sent to the collector and Kafka topic is checked if the message has been published. Content is decoded and checked.
Default Tags    hvves   ete
Test Timeout    5m
Resource    ../resources/global_properties.robot
Resource    ../resources/dcae/hvves.robot
Library    OperatingSystem
Library    ONAPLibrary.Protobuf

*** Variable ***
${HVVES_KAFKA_TOPIC}    HV_VES_PERF3GPP

*** Test Cases ***
HV-VES test case
    [Setup]    Run Process    /app/setup-hvves.sh    shell=yes
    ${status}    ${data}=    Run Keyword And Ignore Error   Variable Should Exist    ${GLOBAL_KAFKA_BOOTSTRAP_SERVICE}
    Run Keyword  Set Test Config   ${GLOBAL_KAFKA_BOOTSTRAP_SERVICE}
    Send Message    ${GLOBAL_DCAE_HVVES_SERVER_NAME}    ${GLOBAL_DCAE_HVVES_SERVER_PORT}
    Sleep   10s
    ${msg}=  Run Keyword  Decode Last Message From Topic STRIMZI User    ${GLOBAL_KAFKA_BOOTSTRAP_SERVICE}   ${HVVES_KAFKA_TOPIC}  ${GLOBAL_KAFKA_USER}
    ${results}=    Compare File To Message    ${EXECDIR}/robot/assets/dcae/hvves_msg.raw    ${msg}
    Should Be True    ${results}
    [Teardown]      Set Old Config
