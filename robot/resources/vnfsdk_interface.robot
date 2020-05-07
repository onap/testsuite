*** Settings ***
Documentation      The main interface for interacting with VNFSDK.
Library           RequestsLibrary

Resource          global_properties.robot

*** Variables ***
${VNFSDK_HEALTH_CHECK_PATH}        /onapapi/vnfsdk-marketplace/v1/PackageResource/healthcheck
${VNFSDK_ENDPOINT}     ${GLOBAL_VNFSDK_SERVER_PROTOCOL}://${GLOBAL_INJECTED_VNFSDK_IP_ADDR}:${GLOBAL_VNFSDK_SERVER_PORT}

*** Keywords ***
Run VNFSDK Health Check
     [Documentation]    Runs VNFSDK Health check
     ${resp}=    Run VNFSDK Get Request    ${VNFSDK_HEALTH_CHECK_PATH}
     Should Be Equal As Strings     ${resp.status_code}     200

Run VNFSDK Get Request
     [Documentation]    Runs VNFSDK Get request
     [Arguments]    ${data_path}
     ${session}=    Create Session    vnfsdk    ${VNFSDK_ENDPOINT}
     ${resp}=     Get Request     vnfsdk     ${data_path}
     Log    Received response from VNFSDK ${resp.text}
     [Return]    ${resp}

Run VNFSDK Post Request
     [Documentation]    Runs VNFSDK Get request
     [Arguments]    ${data_path}     ${files}
     ${session}=    Create Session    vnfsdk    ${VNFSDK_ENDPOINT}
     ${resp}=     Post Request     vnfsdk     ${data_path}   files=${files}
     Log    Received response from VNFSDK ${resp}
     [Return]    ${resp}
