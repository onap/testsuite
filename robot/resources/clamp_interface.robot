*** Settings ***
Documentation     The main interface for interacting with Microservice Bus.
Library           RequestsLibrary
Library           Collections
Library           String
Library           ONAPLibrary.JSON

Resource          global_properties.robot
Resource          json_templater.robot

*** Variables ***
${CLAMP_HEALTH_CHECK_PATH}        /restservices/clds/v1/healthcheck
${CLAMP_ENDPOINT}     ${GLOBAL_CLAMP_SERVER_PROTOCOL}://${GLOBAL_INJECTED_CLAMP_IP_ADDR}:${GLOBAL_CLAMP_SERVER_PORT}
${CLAMP_BASE_PATH}   /restservices/clds/v1
${CLAMP_CLIENT_KEY}   robot/assets/keys/org.onap.clamp.key.clear.pem
${CLAMP_CLIENT_CERT}   robot/assets/keys/org.onap.clamp.cert.pem

${CLAMP_TEMPLATE_PATH}        robot/assets/templates/clamp


*** Keywords ***
Run CLAMP Create Model
     [Documentation]   Create a new CLAMP Model
     [Arguments]   ${model_name}   ${template_name}
     ${dict}=   Create Dictionary   MODEL_NAME=${model_name}      TEMPLATE_NAME=${template_name}
     ${data}=   Fill JSON Template File    ${CLAMP_TEMPLATE_PATH}/create_model.template    ${dict}
     ${data_path}=   Set Variable   ${CLAMP_BASE_PATH}/clds/model/${model_name}
     ${resp}=   Run CLAMP HTTPS Put Request    ${data_path}    ${data}
     Should Be Equal As Strings  ${resp.status_code}     200
     ${random}=    Generate Random String    4    [LOWER][NUMBERS]
     ${policy_name}=    Catenate    PolicyTest    ${random}
     Run CLAMP Save vLB Model   ${model_name}    ${template_name}   ${policy_name}

Run CLAMP Save vLB Model
     [Documentation]   Save CLAMP Model
     [Arguments]   ${model_name}   ${template_name}   ${policy_name}
     ${dict}=   Create Dictionary   MODEL_NAME=${model_name}      TEMPLATE_NAME=${template_name}   POLICY_NAME=${policy_name}   DOLLAR_SIGN=$
     ${data}=   Fill JSON Template File    ${CLAMP_TEMPLATE_PATH}/save_model_vlb.template    ${dict}
     ${data_path}=   Set Variable   ${CLAMP_BASE_PATH}/clds/model/${model_name}
     ${resp}=   Run CLAMP HTTPS Put Request    ${data_path}    ${data}
     Should Be Equal As Strings  ${resp.status_code}     200
     Run CLAMP Validation Test   ${model_name}   ${data}

Run CLAMP Validation Test
     [Documentation]   Validate CLAMP Control Loop CLAMP Model
     [Arguments]   ${model_name}   ${model_data}
     ${data_path}=   Set Variable   ${CLAMP_BASE_PATH}/clds/action/submit/${model_name}?test=true
     ${resp}=   Run CLAMP HTTPS Put Request    ${data_path}    ${model_data}
     Should Be Equal As Strings  ${resp.status_code}     200


Run CLAMP Get Properties
     [Documentation]   get CLAMP Control Loop properties
     [Arguments]   ${property_id}
     ${data_path}=   Set Variable   ${CLAMP_BASE_PATH}/clds/properties/${property_id}
     ${resp}=   Run Clamp HTTPS Get Request    ${data_path}

Run CLAMP Get Control Loop
     [Documentation]   runs CLAMP Open Control Loop based on model name and returns control_loop_id
     [Arguments]   ${model_name}
     ${data_path}=   Set Variable   ${CLAMP_BASE_PATH}/clds/model/${model_name}
     ${resp}=   Run Clamp HTTPS Get Request    ${data_path}
     # propText value is a string
     # propText': u '{"global":[{"name":"service","value":["5fcdb3b7-5a5b-45da-83f6-14cce29181c8"]}
     Log    ${resp.json()['propText']}
     ${control_loop_id}=    Get Regexp Matches    ${resp.json()['propText']}     \\"service\\",\\"value\\":\\[\\"([0-9a-f\-]{36})\\"     1
     #Set Suite Variable   ${CURRENT_CONTROL_LOOP_ID}   ${control_loop_id[0]}
     [Return]      ${control_loop_id[0]}

Run CLAMP Get Model Names
     [Documentation]   runs CLAMP Get Model Names and returns the model_id
     ${data_path}=   Set Variable   ${CLAMP_BASE_PATH}/clds/model-names
     ${resp}=   Run Clamp HTTPS Get Request    ${data_path}
     #Set Suite Variable   ${CURRENT_MODEL_ID}   ${resp.json()[0]['value']}
     [Return]     ${resp.json()[0]['value']}

Run CLAMP Health Check
     [Documentation]    Runs CLAMP Health check
     ${resp}=    Run CLAMP Get Request    ${CLAMP_HEALTH_CHECK_PATH}
     Should Be Equal As Integers        ${resp.status_code}     200

Run CLAMP HTTPS Put Request
     [Documentation]    Runs CLAMP HTTPS Put request
     [Arguments]    ${data_path}    ${data}
     @{client_certs}=    Create List     ${CLAMP_CLIENT_CERT}   ${CLAMP_CLIENT_KEY}
     ${session}=   Create Client Cert Session  session   ${CLAMP_ENDPOINT}     client_certs=@{client_certs}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Put Request     session   ${data_path}   data=${data}  headers=${headers}
     Should Be Equal As Integers        ${resp.status_code}     200
     Log    ${resp.json()}
     [Return]    ${resp}

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
