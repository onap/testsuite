*** Settings ***
Documentation     The main interface for interacting with APP-C. It handles low level stuff like managing the http request library and APP-C required fields
Library 	      RequestsLibrary
Library	          ONAPLibrary.Utilities
Library	          ONAPLibrary.Templating
Library           SeleniumLibrary
Resource          browser_setup.robot

*** Variables ***
${APPC_INDEX_PATH}    /restconf
${APPC_HEALTHCHECK_OPERATION_PATH}  /operations/SLI-API:healthcheck
${APPC_CREATE_MOUNTPOINT_PATH}  /config/network-topology:network-topology/topology/topology-netconf/node/
${APPC_MOUNT_XML}    appc/vnf_mount.jinja
${APPC_ENDPOINT}    ${GLOBAL_APPC_SERVER_PROTOCOL}://${GLOBAL_INJECTED_APPC_IP_ADDR}:${GLOBAL_APPC_SERVER_PORT}
${APPC_CDT_Config_Scaleout}    ${EXECDIR}/robot/assets/templates/appc/template_ConfigScaleOut_vLoadBalancer_vLoadBalancer-test0_0.0.1V_vLB.xml
${APPC_CDT_Config_Scaleout_PD}    ${EXECDIR}/robot/assets/templates/appc/pd_ConfigScaleOut_vLoadBalancer_vLoadBalancer-test0_0.0.1V_vLB.yaml
${APPC_CDT_Config_Scaleout_REF}    ${EXECDIR}/robot/assets/templates/appc/reference_AllAction_vLoadBalancer_vLoadBalancer-test0_0.0.1V.json
${APPC_CDT_Config_Scaleout_REF_name}    reference_AllAction_vLoadBalancer_vLoadBalancer-test0_0.0.1V.json
${APPC_CDT_ENDPOINT}    ${GLOBAL_APPC_CDT_SERVER_PROTOCOL}://${GLOBAL_INJECTED_APPC_CDT_IP_ADDR}:${GLOBAL_APPC_CDT_SERVER_PORT}
${APPC_CDT_LOGIN_URL}                ${APPC_CDT_ENDPOINT}/index.html


*** Keywords ***
Run APPC Health Check
    [Documentation]    Runs an APPC healthcheck
	${resp}=    Run APPC Post Request     ${APPC_INDEX PATH}${APPC_HEALTHCHECK_OPERATION_PATH}     ${None}
    Should Be Equal As Strings 	${resp.status_code} 	200
    Should Be Equal As Strings 	${resp.json()['output']['response-code']} 	200

Run APPC Post Request
    [Documentation]    Runs an APPC post request
    [Arguments]    ${data_path}    ${data}    ${content}=json
    ${auth}=  Create List  ${GLOBAL_APPC_USERNAME}    ${GLOBAL_APPC_PASSWORD}
    Log    Creating session ${APPC_ENDPOINT}
    ${session}=    Create Session 	appc 	${APPC_ENDPOINT}    auth=${auth}
    ${uuid}=    Generate UUID4
    ${headers}=  Create Dictionary     Accept=application/${content}    Content-Type=application/${content}    X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}
    ${resp}= 	Post Request 	appc 	${data_path}     data=${data}    headers=${headers}
    Log    Received response from appc ${resp.text}
    [Return]    ${resp}

Run APPC Put Request
    [Documentation]    Runs an APPC post request
    [Arguments]    ${data_path}    ${data}    ${content}=xml
    ${auth}=  Create List  ${GLOBAL_APPC_USERNAME}    ${GLOBAL_APPC_PASSWORD}
    Log    Creating session ${APPC_ENDPOINT}
    ${session}=    Create Session 	appc 	${APPC_ENDPOINT}    auth=${auth}
    ${uuid}=    Generate UUID4
    ${headers}=  Create Dictionary     Accept=application/${content}    Content-Type=application/${content}    X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}
    ${resp}= 	Put Request 	appc 	${data_path}     data=${data}    headers=${headers}
    Log    Received response from appc ${resp.text}
    [Return]    ${resp}

Create Mount Point In APPC
    [Documentation]     Go tell APPC about the PGN we just spun up...
    [Arguments]    ${nodeid}    ${host}    ${port}=${GLOBAL_PGN_PORT}    ${username}=admin    ${password}=admin
    ${dict}=    Create Dictionary    nodeid=${nodeid}    host=${host}    port=${port}    username=${username}    password=${password}
    Create Environment    appc    ${GLOBAL_TEMPLATE_FOLDER}
    ${data}=   Apply Template    appc   ${APPC_MOUNT_XML}    ${dict}
    ${resp}=    Run APPC Put Request     ${APPC_INDEX PATH}${APPC_CREATE_MOUNTPOINT_PATH}${nodeid}     ${data}
    Should Be True	200    <= ${resp.status_code} < 300
    [Return]     ${resp}

Preload APPC CDT GUI
    [Documentation]   APPC CDT GUI Preload
    [Arguments]    ${username}=${GLOBAL_APPC_CDT_USERNAME}   ${reference_file_name}=${APPC_CDT_Config_Scaleout_REF_name}   ${reference_file}=${APPC_CDT_Config_Scaleout_REF}   ${template_file}=${APPC_CDT_Config_Scaleout}   ${parameterdefinition_file}=${APPC_CDT_Config_Scaleout_PD}
    # Setup Browser Now being managed by test case
    ##Setup Browser
    Go To   ${APPC_CDT_LOGIN_URL}#/home
    Set Selenium Speed   ${GLOBAL_SELENIUM_DELAY}
    Set Browser Implicit Wait    ${GLOBAL_SELENIUM_BROWSER_IMPLICIT_WAIT}
    Log   Logging in to ${APPC_CDT_ENDPOINT}
    Handle Proxy Warning
    Wait Until Page Contains   WELCOME   ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT}
    Go To    ${APPC_CDT_LOGIN_URL}#/vnfs
    Wait Until Element Is Visible   id=userId   ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT}
    Input Text   id=userId   ${username}
    Click Button   Submit
    Page Should Contain   ${username}
    Wait Until Page Contains Element   xpath=(//*[@class='mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect mdl-button--primary'])   ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT}
    Click Button   Create New VNF Type or VNFC Type
    Page Should Contain   Enter VNF type and VNFC to proceed
    Click Button   Proceed anyway
    Click Button   Upload Reference File
    Choose File   id=inputFile   ${reference_file}
    Select From List By Value   name=templateIdentifier   vLB
    Sleep   ${GLOBAL_SELENIUM_BROWSER_IMPLICIT_WAIT}
    Click Link   Template
    Click Button   Upload Template File
    Choose File   id=inputFile   ${template_file}
    Sleep   ${GLOBAL_SELENIUM_BROWSER_IMPLICIT_WAIT}
    Click Link   Parameter Definition
    Click Button   UPLOAD PD FILE
    Choose File   id=inputFile1   ${parameterdefinition_file}
    Sleep   ${GLOBAL_SELENIUM_BROWSER_IMPLICIT_WAIT}
    Click Link   Reference Data
    Select From List By Value   name=templateIdentifier   vLB
    Click Button   saveToAppc
    Go To    ${APPC_CDT_LOGIN_URL}#/vnfs
    Wait Until Page Contains   ${reference_file_name}   ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT}
    Log   Logged in to ${APPC_CDT_ENDPOINT}
