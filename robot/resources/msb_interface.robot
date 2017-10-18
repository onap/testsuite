*** Settings ***
Documentation     The main interface for interacting with Microservice Bus.
Library           RequestsLibrary

Resource          global_properties.robot

*** Variables ***
${MSB_HEALTH_CHECK_PATH}        /iui/microservices/default.html
${MSB_ENDPOINT}     ${GLOBAL_MSB_SERVER_PROTOCOL}://${GLOBAL_INJECTED_OPENO_IP_ADDR}:${GLOBAL_MSB_SERVER_PORT}


*** Keywords ***
Run MSB Health Check
     [Documentation]    Runs MSB Health check
     ${resp}=    Run MSB Get Request    ${MSB_HEALTH_CHECK_PATH}
     Should Be Equal As Integers 	${resp.status_code} 	200

Run MSB Get Request
     [Documentation]    Runs MSB Get request
     [Arguments]    ${data_path}
     ${session}=    Create Session 	msb	${MSB_ENDPOINT}
     ${resp}= 	Get Request 	msb 	${data_path}
     Should Be Equal As Integers 	${resp.status_code} 	200
     Log    Received response from MSB ${resp.text}
     [Return]    ${resp}
