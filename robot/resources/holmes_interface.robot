*** Settings ***
Library           RequestsLibrary
Resource          global_properties.robot

*** Variables ***
${HOLMES_RULE_HEALTH_CHECK}    /api/holmes-rule-mgmt/v1/healthcheck
${HOLMES_ENGINE_HEALTH_CHECK}    /api/holmes-engine-mgmt/v1/healthcheck

${HOLMES_RULE_ENDPOINT}     ${GLOBAL_HOLMES_RULE_SERVER_PROTOCOL}://${GLOBAL_INJECTED_HOLMES_RULE_IP_ADDR}:${GLOBAL_HOLMES_RULE_SERVER_PORT}
${HOLMES_ENGINE_ENDPOINT}     ${GLOBAL_HOLMES_ENGINE_SERVER_PROTOCOL}://${GLOBAL_INJECTED_HOLMES_ENGINE_IP_ADDR}:${GLOBAL_HOLMES_ENGINE_SERVER_PORT}

*** Keywords ***
Run Holmes Rule Mgmt Healthcheck
    [Documentation]    Run Holmes Rule Management Health Check
    ${resp}=    Run Holmes Get Request   ${HOLMES_RULE_ENDPOINT}   ${HOLMES_RULE_HEALTH_CHECK}
    Should Be Equal As Integers    ${resp.status_code}    200

Run Holmes Engine Mgmt Healthcheck
    [Documentation]    Run Holmes Engine Management Health Check
    ${resp}=    Run Holmes Get Request   ${HOLMES_ENGINE_ENDPOINT}   ${HOLMES_ENGINE_HEALTH_CHECK}
    Should Be Equal As Integers    ${resp.status_code}    200

Run Holmes Get Request
    [Arguments]   ${endpoint}   ${data_path}
    [Documentation]    Runs Holmes Get request
    ${session}=    Create Session    holmes    ${endpoint}
    ${resp}=    Get On Session    holmes    ${data_path}
    Should Be Equal As Integers    ${resp.status_code}    200
    Log    Received response from server ${resp.text}
    [Return]    ${resp}
