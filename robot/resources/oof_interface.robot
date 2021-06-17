*** Settings ***
Documentation     The main interface for interacting with OOF: OSDF and Homing Service
Library           RequestsLibrary
Library	          ONAPLibrary.Utilities
Library           OperatingSystem
Library	          String
Library           DateTime
Library           Collections
Library           ONAPLibrary.JSON
Library           ONAPLibrary.OOF    WITH NAME    OOF
Library           ONAPLibrary.Templating    WITH NAME    Templating
Resource          global_properties.robot

*** Variables ***
${OOF_HOMING_HEALTH_CHECK_PATH}       /v1/plans/healthcheck
${OOF_OSDF_HEALTH_CHECK_PATH}        /api/oof/v1/healthcheck

${OOF_HOMING_PLAN_FOLDER}    robot/assets/oof/optf-has
${OOF_OSDF_TEMPLATE_FOLDER}   robot/assets/oof/optf-osdf

${OOF_HOMING_ENDPOINT}    ${GLOBAL_OOF_SERVER_PROTOCOL}://${GLOBAL_INJECTED_OOF_HOMING_IP_ADDR}:${GLOBAL_OOF_HOMING_SERVER_PORT}
${OOF_OSDF_ENDPOINT}     ${GLOBAL_OOF_SERVER_PROTOCOL}://${GLOBAL_INJECTED_OOF_SNIRO_IP_ADDR}:${GLOBAL_OOF_SNIRO_SERVER_PORT}
${OOF_OSDF_ENDPOINT}      ${GLOBAL_OOF_SERVER_PROTOCOL}://${GLOBAL_INJECTED_OOF_HOMING_IP_ADDR}:${GLOBAL_OOF_HOMING_SERVER_PORT}


*** Keywords ***
Run OOF-Homing Health Check
	[Documentation]    Runs OOF-Homing Health check
	${resp}=    Run OOF-Homing Get Request    ${OOF_HOMING_HEALTH_CHECK_PATH}
	Should Be Equal As Integers   ${resp.status_code}   200

Run OOF-Homing Get Request
	[Documentation]    Runs OOF-Homing Get request
	[Arguments]    ${data_path}
	${session}=    Create Session   session   ${OOF_HOMING_ENDPOINT}
	${resp}=   Get Request   session   ${data_path}
	Should Be Equal As Integers   ${resp.status_code}   200
	Log    Received response from OOF-Homing ${resp.text}
	[Return]    ${resp}

RUN OOF-Homing SendPlanWithWrongVersion
	[Documentation]    It sends a POST request to conductor
    ${session}=    Create Session   optf-cond      ${OOF_HOMING_ENDPOINT}
    ${data}=         Get Binary File     ${OOF_HOMING_PLAN_FOLDER}${/}plan_with_wrong_version.json
    ${auth}=  Create List  ${GLOBAL_OOF_HOMING_USERNAME}    ${GLOBAL_OOF_HOMING_PASSWORD}
    ${session}=    Create Session   session   ${OOF_HOMING_ENDPOINT}   auth=${auth}
    &{headers}=      Create Dictionary    Content-Type=application/json  Accept=application/json
    ${resp}=         Post Request        optf-cond   /v1/plans     data=${data}     headers=${headers}
    Log               *********************
    Log               response = ${resp}
    Log               body = ${resp.text}
    ${generatedPlanId}=    Convert To String      ${resp.json()['id']}
    Set Global Variable     ${generatedPlanId}
    Log              generatedPlanId = ${generatedPlanId}
    Should Be Equal As Integers    ${resp.status_code}    201
    Sleep    10s    Wait Plan Resolution

Run OOF-OSDF Health Check
    [Documentation]    Runs OOF-OSDF Health check
    ${resp}=    Run OOF-OSDF Get Request    ${OOF_OSDF_HEALTH_CHECK_PATH}
    Should Be Equal As Integers   ${resp.status_code}   200

Run OOF-OSDF Get Request
    [Documentation]    Runs OOF-OSDF Get request
    [Arguments]    ${data_path}
    ${session}=    Create Session   session   ${OOF_OSDF_ENDPOINT}
    ${resp}=   Get Request   session   ${data_path}
    Should Be Equal As Integers   ${resp.status_code}   200
    Log    Received response from OOF-OSDF ${resp.text}
    [Return]    ${resp}

Run OOF-OSDF Post Request
    [Documentation]    Runs a scheduler POST request
    [Arguments]   ${data_path}   ${auth}    ${data}={}

    ${session}=    Create Session   session   ${OOF_OSDF_ENDPOINT}   auth=${auth}
    ${headers}=  Create Dictionary   Accept=application/json    Content-Type=application/json
    ${resp}= 	Post Request 	session 	${data_path}     headers=${headers}   data=${data}
    Log    Received response from osdf ${resp.text}
    [Return]    ${resp}

Run OOF-OSDF Post Homing
   [Documentation]    Runs a osdf homing request
    ${auth}=  Create List  ${GLOBAL_OOF_OSDF_USERNAME}    ${GLOBAL_OOF_OSDF_PASSWORD}
    ${data}=         Get Binary File     ${OOF_OSDF_TEMPLATE_FOLDER}${/}placement_request.json
    ${resp}=   Run OOF-OSDF Post Request  /api/oof/placement/v1       auth=${auth}    data=${data}
    Should Be Equal As Strings    ${resp.status_code}   204

Run OOF-OSDF Post PCI-OPT
    [Documentation]    Runs a osdf PCI-OPT request
    ${auth}=  Create List  ${GLOBAL_OOF_PCI_USERNAME}    ${GLOBAL_OOF_PCI_PASSWORD}
    ${data}=         Get Binary File     ${OOF_OSDF_TEMPLATE_FOLDER}${/}pci-opt-request.json
    ${resp}=   Run OOF-OSDF Post Request  /api/oof/pci/v1   auth=${auth}    data=${data}
    Should Be Equal As Strings    ${resp.status_code}   204
