*** Settings ***
Documentation     The main interface for interacting with OOF
Library           RequestsLibrary

Resource          global_properties.robot

*** Variables ***
${OOF_HEALTH_CHECK_PATH}        /api/oof/v1/healthcheck
${OOF_ENDPOINT}     ${GLOBAL_OOF_SERVER_PROTOCOL}://${GLOBAL_INJECTED_OOF_IP_ADDR}:${GLOBAL_OOF_SERVER_PORT}


*** Keywords ***
Run OOF Health Check
     [Documentation]    Runs OOF Health check
     ${resp}=    Run OOF Get Request    ${OOF_HEALTH_CHECK_PATH}
     Should Be Equal As Integers   ${resp.status_code}   200

Run OOF Get Request
     [Documentation]    Runs OOF Get request
     [Arguments]    ${data_path}
     ${session}=    Create Session   session   ${OOF_ENDPOINT}
     ${resp}=   Get Request   session   ${data_path}
     Should Be Equal As Integers   ${resp.status_code}   200
     Log    Received response from OOF ${resp.text}
     [Return]    ${resp}
