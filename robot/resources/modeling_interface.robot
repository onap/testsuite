*** Settings ***
Documentation     The main interface for interacting with Modeling
Library           RequestsLibrary
Library            Collections

Resource          global_properties.robot

*** Variables ***
${MODEL_PARSER_HEALTH_CHECK_PATH}        /api/parser/v1/health_check
${MODEL_PARSER_ENDPOINT}     ${GLOBAL_MODEL_PARSER_SERVER_PROTOCOL}://${GLOBAL_INJECTED_MODEL_PARSER_IP_ADDR}:${GLOBAL_MODEL_PARSER_SERVER_PORT}


*** Keywords ***
Run Modeling Parser Health Check
     [Documentation]    Runs Modeling Parser Health check
     ${resp}=    Run Modeling Get Request    ${MODEL_PARSER_HEALTH_CHECK_PATH}
     Should Be Equal As Integers   ${resp.status_code}   200

Run Modeling Get Request
     [Documentation]    Runs Modeling Get request
     [Arguments]    ${data_path}
     ${session}=    Create Session   session   ${UUI_ENDPOINT}
     ${resp}=   Get Request   session   ${data_path}
     Should Be Equal As Integers   ${resp.status_code}   200
     Log    Received response from Modeling ${resp.text}
     [Return]    ${resp}
