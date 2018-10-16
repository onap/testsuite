*** Settings ***
Library           RequestsLibrary
Resource          global_properties.robot

*** Variables ***
${MSB_ENDPOINT}    ${GLOBAL_MSB_SERVER_PROTOCOL}://${GLOBAL_INJECTED_MSB_IP_ADDR}:${GLOBAL_MSB_SERVER_PORT}
${HOLMES_RULE_HEALTH_CHECK}    /api/holmes-rule-mgmt/v1/healthcheck
${HOLMES_ENGINE_HEALTH_CHECK}    /api/holmes-engine-mgmt/v1/healthcheck

*** Keywords ***
Run Holmes Rule Mgmt Healthcheck
    [Documentation]    Run Holmes Rule Management Health Check
    ${resp}=    Run Holmes Get Request    ${HOLMES_RULE_HEALTH_CHECK}
    Should Be Equal As Integers    ${resp.status_code}    200

Run Holmes Engine Mgmt Healthcheck
    [Documentation]    Run Holmes Engine Management Health Check
    ${resp}=    Run Holmes Get Request    ${HOLMES_ENGINE_HEALTH_CHECK}
    Should Be Equal As Integers    ${resp.status_code}    200

Run Holmes Get Request
    [Arguments]    ${data_path}
    [Documentation]    Runs Holmes Get request
    ${session}=    Create Session    holmes    ${MSB_ENDPOINT}
    ${resp}=    Get Request    holmes    ${data_path}
    Should Be Equal As Integers    ${resp.status_code}    200
    Log    Received response from server ${resp.text}
    [Return]    ${resp}
