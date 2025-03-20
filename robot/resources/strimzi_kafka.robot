*** Settings ***
Documentation    Template for interfacing with strimzi kafka.
Library    OperatingSystem
Library    RequestsLibrary
Library    BuiltIn
Library    Collections
Library    ONAPLibrary.Utilities
Library    String
Library    ONAPLibrary.Kafka

*** Variables ***
${KAFKA_GET_PASSWORD}      kubectl -n onap get secret strimzi-kafka-admin -o jsonpath="{.data.password}" | base64 -d

*** Keywords ***
Get Last Message From Topic
    [Documentation]     Decode last message from Kafka topic.
    [Arguments]     ${kafka_topic}
    ${command_output} =                 Run And Return Rc And Output        ${KAFKA_GET_PASSWORD}
    Should Be Equal As Integers         ${command_output[0]}                0
    ${password}   Set Variable  ${command_output[1]}
    Connect    kafka    ${GLOBAL_KAFKA_BOOTSTRAP_SERVICE}   ${GLOBAL_KAFKA_USER}    ${password}   SCRAM-SHA-512
    ${msg}=     Consume    kafka    ${kafka_topic}
    [Return]    ${msg}

