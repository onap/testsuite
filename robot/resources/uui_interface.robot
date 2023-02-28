*** Settings ***
Documentation     The main interface for interacting with Usecase UI
Library           RequestsLibrary
Library            Collections

Resource          global_properties.robot

*** Variables ***
${UUI_HEALTH_CHECK_PATH}        /api/usecaseui-server/v1/
${UUI_ENDPOINT}     ${GLOBAL_UUI_SERVER_PROTOCOL}://${GLOBAL_INJECTED_UUI_IP_ADDR}:${GLOBAL_UUI_SERVER_PORT}


*** Keywords ***
Run UUI Health Check
     [Documentation]    Runs UUI Health check
     ${resp}=    Run UUI Get Request    ${UUI_HEALTH_CHECK_PATH}
     Should Be Equal As Integers   ${resp.status_code}   200

Run UUI Get Request
     [Documentation]    Runs UUI Get request
     [Arguments]    ${data_path}
     ${session}=    Create Session   session   ${UUI_ENDPOINT}
     ${resp}=   Get Request   session   ${data_path}
     Should Be Equal As Integers   ${resp.status_code}   200
     Log    Received response from UUI ${resp.text}
     [Return]    ${resp}
