*** Settings ***
Documentation      The main interface for interacting with CLI.
Library           RequestsLibrary

Resource          global_properties.robot

*** Variables ***
${CLI_HEALTH_CHECK_PATH}        /
${CLI_ENDPOINT}     ${GLOBAL_CLI_SERVER_PROTOCOL}://${GLOBAL_INJECTED_CLI_IP_ADDR}:${GLOBAL_CLI_SERVER_PORT}

*** Keywords ***
Run CLI Health Check
     [Documentation]    Runs CLI Health check
     ${resp}=    Run CLI Get Request    ${CLI_HEALTH_CHECK_PATH}
     Should Be Equal As Strings     ${resp.status_code}     200

Run CLI Get Request
     [Documentation]    Runs CLI Get request
     [Arguments]    ${data_path}
     ${session}=    Create Session    cli    ${CLI_ENDPOINT}
     ${resp}=     Get Request     cli     ${data_path}
     Log    Received response from CLI ${resp.text}
     [Return]    ${resp}

