*** Settings ***
Documentation     The main interface for interacting with Bus Controller.
Library           RequestsLibrary

Resource          global_properties.robot

*** Variables ***
${BC_HEALTH_CHECK_PATH}        /webapi/dmaap
${BC_HTTPS_ENDPOINT}     https://${GLOBAL_INJECTED_BC_IP_ADDR}:${GLOBAL_BC_HTTPS_SERVER_PORT}


*** Keywords ***
Run BC Health Check With Basic Auth
     [Documentation]    Runs dmmap details check
     ${resp}=    Return dmaap details with basic auth    ${BC_HEALTH_CHECK_PATH}
     Should Be Equal As Strings        ${resp.status_code}     200


Return dmaap details with basic auth
     [Documentation]    Runs Bus Controler get details request with basic authentication
     [Arguments]    ${data_path}
     ${auth}=  Create List     ${GLOBAL_BC_USERNAME}   ${GLOBAL_BC_PASSWORD}
     ${session}=    Create Session      bs      ${BC_HTTPS_ENDPOINT}    auth=${auth}
     ${resp}=   Get Request     bs      ${data_path}
     Log    Received response from bus controller ${resp.text}
     [Return]    ${resp}

