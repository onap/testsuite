*** Settings ***
Documentation         CPS Core - Admin REST API to cover CPS admin functionalities

Library               Collections
Library               OperatingSystem
Library               RequestsLibrary

*** Variables ***

${CPS_HEALTH_URL}       ${GLOBAL_CPS_SERVER_PROTOCOL}://${GLOBAL_INJECTED_CPS_IP_ADDR}:${GLOBAL_CPS_HEALTH_PORT}


*** Keywords ***
Run CPS Healthcheck
    [Documentation]     Runs CPS Health Check
    ${uri}=             Set Variable        ${CPS_HEALTH_URL}/manage/health
    ${response}=  Run CPS Get On Session  ${uri}
    Should Be Equal As Strings              ${response.status_code}   200
    ${res_body}=    Convert to string    ${response.text}
    Should Contain    ${res_body}    UP
    Should Not Contain    ${res_body}    DOWN
