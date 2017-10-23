*** Settings ***
Documentation     The main interface for interacting with Microservice Bus.
Library           RequestsLibrary

Resource          global_properties.robot

*** Variables ***
${CLAMP_HEALTH_CHECK_PATH}        /restservices/clds/v1/clds/healthcheck
${CLAMP_ENDPOINT}     ${GLOBAL_CLAMP_SERVER_PROTOCOL}://${GLOBAL_INJECTED_CLAMP_IP_ADDR}:${GLOBAL_CLAMP_SERVER_PORT}


*** Keywords ***
Run CLAMP Health Check
     [Documentation]    Runs CLAMP Health check
     ${resp}=    Run CLAMP Get Request    ${CLAMP_HEALTH_CHECK_PATH}
     Should Be Equal As Integers 	${resp.status_code} 	200

Run CLAMP Get Request
     [Documentation]    Runs CLAMP Get request
     [Arguments]    ${data_path}
     ${session}=    Create Session 	session 	${CLAMP_ENDPOINT}
     ${resp}= 	Get Request 	session 	${data_path}
     Should Be Equal As Integers 	${resp.status_code} 	200
     Log    Received response from CLAMP ${resp.text}
     [Return]    ${resp}
