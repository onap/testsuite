*** Settings ***
Documentation     The main interface for interacting with Microservice Bus.
Library           RequestsLibrary

Resource          global_properties.robot

*** Variables ***
${CLAMP_HEALTH_CHECK_PATH}        /restservices/clds/v1/healthcheck
${CLAMP_ENDPOINT}     ${GLOBAL_CLAMP_SERVER_PROTOCOL}://${GLOBAL_INJECTED_CLAMP_IP_ADDR}:${GLOBAL_CLAMP_SERVER_PORT}
${CLAMP_BASE_PATH}   /restservices/clds/v1
${CLAMP_CLIENT_KEY}   robot/assets/keys/org.onap.clamp.key.clear.pem
${CLAMP_CLIENT_CERT}   robot/assets/keys/org.onap.clamp.cert.pem


*** Keywords ***
Run CLAMP Get Properties
     [Documentation]   get CLAMP Control Loop properties
     [Arguments]   ${property_id}
     ${data_path}=   Set Variable   ${CLAMP_BASE_PATH}/clds/properties/${property_id}
     ${resp}=   Run Clamp HTTPS Get Request    ${data_path}

Run CLAMP Get Control Loop
     [Documentation]   runs CLAMP Open Control Loop based on model name
     [Arguments]   ${model_name}
     ${data_path}=   Set Variable   ${CLAMP_BASE_PATH}/clds/model/${model_name}
     ${resp}=   Run Clamp HTTPS Get Request    ${data_path}

Run CLAMP Get Model Names
     [Documentation]   runs CLAMP Get Model Names
     ${data_path}=   Set Variable   ${CLAMP_BASE_PATH}/clds/model-names
     ${resp}=   Run Clamp HTTPS Get Request    ${data_path}

Run CLAMP Health Check
     [Documentation]    Runs CLAMP Health check
     ${resp}=    Run CLAMP Get Request    ${CLAMP_HEALTH_CHECK_PATH}
     Should Be Equal As Integers        ${resp.status_code}     200

Run CLAMP HTTPS Get Request
     [Documentation]    Runs CLAMP HTTPS Get request
     [Arguments]    ${data_path}
     @{client_certs}=    Create List     ${CLAMP_CLIENT_CERT}   ${CLAMP_CLIENT_KEY}
     ${session}=   Create Client Cert Session  session   ${CLAMP_ENDPOINT}     client_certs=@{client_certs}
     ${resp}=   Get Request     session         ${data_path}
     Should Be Equal As Integers        ${resp.status_code}     200
     Log    ${resp.json()}
     [Return]    ${resp}

Run CLAMP Get Request
     [Documentation]    Runs CLAMP Get request
     [Arguments]    ${data_path}
     ${session}=    Create Session      session         ${CLAMP_ENDPOINT}
     ${resp}=   Get Request     session         ${data_path}
     Should Be Equal As Integers        ${resp.status_code}     200
     Log    Received response from CLAMP ${resp.text}
     [Return]    ${resp}
