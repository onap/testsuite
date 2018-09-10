*** Settings ***
Documentation     The main interface for interacting with Data-Router.
Library           RequestsLibrary

Resource          global_properties.robot

*** Variables ***
${DR_HEALTH_CHECK_PATH}    /internal/fetchProv
${DR_ENDPOINT}             ${GLOBAL_DMAAP_DR_NODE_SERVER_PROTOCOL}://${GLOBAL_INJECTED_DMAAP_DR_NODE_IP_ADDR}:${GLOBAL_DMAAP_DR_NODE_SERVER_PORT}


*** Keywords ***
Run DR Health Check
    [Documentation]    Runs DR Health check
    ${resp}=    Run DR Get Request    ${DR_HEALTH_CHECK_PATH}
    Should Be Equal As Strings    ${resp.status_code}    204

Run DR Get Request
    [Documentation]    Runs DR Get request
    [Arguments]        ${data_path}
    ${session}=        Create Session    session    ${DR_ENDPOINT}
    ${resp}=           Get Request       session    ${data_path}
    [Return]           ${resp}
