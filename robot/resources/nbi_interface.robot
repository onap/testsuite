*** Settings ***
Documentation     The main interface for interacting with External API/NBI
Library           RequestsLibrary
Library            Collections

Resource          global_properties.robot

*** Variables ***
${NBI_HEALTH_CHECK_PATH}        /nbi/api/v4/status?fullStatus=true
${NBI_ENDPOINT}     ${GLOBAL_NBI_SERVER_PROTOCOL}://${GLOBAL_INJECTED_NBI_IP_ADDR}:${GLOBAL_NBI_SERVER_PORT}


*** Keywords ***
Run NBI Health Check
     [Documentation]    Runs NBI Health check
     ${resp}=    Run NBI Get Request    ${NBI_HEALTH_CHECK_PATH}
     Should Be Equal As Integers   ${resp.status_code}   200

Run NBI Get Request
     [Documentation]    Runs NBI Get request
     [Arguments]    ${data_path}
     ${session}=    Create Session   session   ${NBI_ENDPOINT}
     ${resp}=   Get Request   session   ${data_path}
     Should Be Equal As Integers   ${resp.status_code}   200
     Log    Received response from NBI ${resp.text}
     ${json}=    Set Variable    ${resp.json()}
     ${status}=    Get From Dictionary    ${json}   status
     Should Be Equal  ${status}    ok
     [Return]    ${resp}
