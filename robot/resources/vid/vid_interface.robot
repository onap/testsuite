*** Settings ***
Documentation     The main interface for interacting with VID. It handles low level stuff like managing the selenium request library and VID required steps
Library 	    SeleniumLibrary
Library    Collections
Library         String
Library 	      RequestsLibrary
Library	          ONAPLibrary.Utilities
Resource        ../global_properties.robot
Resource        ../browser_setup.robot

*** Variables ***
${VID_ENV}            /vid
${VID_ENDPOINT}    ${GLOBAL_VID_SERVER_PROTOCOL}://${GLOBAL_INJECTED_VID_IP_ADDR}:${GLOBAL_VID_SERVER_PORT}
${VID_LOGIN_URL}                ${VID_ENDPOINT}${VID_ENV}/login.htm
${VID_HEALTHCHECK_PATH}    ${VID_ENV}/healthCheck
${VID_HOME_URL}                ${VID_ENDPOINT}${VID_ENV}/welcome.htm
${VID_SERVICE_MODELS_URL}                ${VID_ENDPOINT}${VID_ENV}/serviceModels.htm#/models/services

*** Keywords ***
Run VID Health Check
    [Documentation]   Logs in to VID GUI
    ${resp}=    Run VID Get Request    ${VID_HEALTHCHECK_PATH}
    Should Be Equal As Strings 	${resp.status_code} 	200
    Should Be String    ${resp.json()['detailedMsg']}

Run VID Get Request
    [Documentation]    Runs an VID get request
    [Arguments]    ${data_path}
    ${auth}=  Create List  ${GLOBAL_VID_HEALTH_USERNAME}    ${GLOBAL_VID_HEALTH_PASSWORD}
    Log    Creating session ${VID_ENDPOINT}
    ${session}=    Create Session 	vid 	${VID_ENDPOINT}    auth=${auth}
    ${uuid}=    Generate UUID4
    ${headers}=  Create Dictionary     username=${GLOBAL_VID_HEALTH_USERNAME}    password=${GLOBAL_VID_HEALTH_PASSWORD}    Accept=application/json    Content-Type=application/json    X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}
    ${resp}= 	Get Request 	vid 	${data_path}     headers=${headers}
    Log    Received response from vid ${resp.text}
    [Return]    ${resp}

Login To VID GUI
    [Documentation]   Logs in to VID GUI
    # Setup Browser Now being managed by test case
    ##Setup Browser
    Go To    ${VID_LOGIN_URL}
    #Maximize Browser Window
    Set Selenium Speed    ${GLOBAL_SELENIUM_DELAY}
    Set Browser Implicit Wait    ${GLOBAL_SELENIUM_BROWSER_IMPLICIT_WAIT}
    Log    Logging in to ${VID_ENDPOINT}${VID_ENV}
    Handle Proxy Warning
    Title Should Be    Login
    Input Text    xpath=//input[@id='loginId']    ${GLOBAL_VID_USERNAME}
    Input Password    xpath=//input[@id='password']    ${GLOBAL_VID_PASSWORD}
    Click Button    xpath=//input[@id='loginBtn']
    Wait Until Page Contains  Welcome to VID    ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT}
    Select From List By Label    //select[@id='selectTestApi']    VNF_API (old)
    Log    Logged in to ${VID_ENDPOINT}${VID_ENV}

Go To VID HOME
    [Documentation]    Naviage to VID Home
    Go To    ${VID_HOME_URL}
    Wait Until Page Contains  Welcome to VID    ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT}

Go To VID Browse Service Models
    [Documentation]    Naviage to VID Browse Service Models
    Go To    ${VID_SERVICE_MODELS_URL}
    Wait Until Page Contains   Browse SDC Service Models   ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT}

Click On Button When Enabled
    [Arguments]     ${xpath}    ${timeout}=${GLOBAL_VID_UI_TIMEOUT_MEDIUM}
    Wait Until Page Contains Element    xpath=${xpath}    ${timeout}
    Wait Until Element Is Enabled    xpath=${xpath}    ${timeout}
    Click Button      xpath=${xpath}

Click On Element When Visible
    [Arguments]     ${xpath}    ${timeout}=${GLOBAL_VID_UI_TIMEOUT_MEDIUM}
    Wait Until Page Contains Element    xpath=${xpath}    ${timeout}
    Wait Until Element Is Visible    xpath=${xpath}    ${timeout}
    Click Element      xpath=${xpath}

Select From List When Enabled
    [Arguments]     ${xpath}    ${value}    ${timeout}=${GLOBAL_VID_UI_TIMEOUT_MEDIUM}
    Wait Until Page Contains Element    xpath=${xpath}    ${timeout}
    Wait Until Element Is Enabled    xpath=${xpath}    ${timeout}
    Select From List By Value     xpath=${xpath}    ${value}

Input Text When Enabled
    [Arguments]     ${xpath}    ${value}    ${timeout}=${GLOBAL_VID_UI_TIMEOUT_MEDIUM}
    Wait Until Page Contains Element    xpath=${xpath}    ${timeout}
    Wait Until Element Is Enabled    xpath=${xpath}    ${timeout}
    Input Text    xpath=${xpath}    ${value}

Parse Request Id
    [Arguments]    ${so_response_text}
	${request_list}=     Split String    ${so_response_text}    202)\n    1
	${clean_string}=    Replace String    ${request_list[1]}    \n    ${empty}
    ${json}=    To Json    ${clean_string}
    ${request_id}=    Catenate    ${json['requestReferences']['requestId']}
    [Return]    ${request_id}

Parse Instance Id
    [Arguments]    ${so_response_text}
	${request_list}=     Split String    ${so_response_text}    202)\n    1
    ${json}=    To Json    ${request_list[1]}
    ${request_id}=    Catenate    ${json['requestReferences']['instanceId']}
    [Return]    ${request_id}

Get Model UUID from VID
    [Documentation]    Must use UI since rest call get redirect to portal and get DNS error
    ...    Search all services and match on the invariantUUID
    [Arguments]   ${invariantUUID}
    Go To     ${VID_ENDPOINT}${VID_ENV}/rest/models/services
    ${resp}=   Get Text   xpath=//body/pre
    ${json}=   To Json    ${resp}
    ${services}=   Get From Dictionary    ${json}   services
    :FOR   ${dict}  IN  @{services}
    \    ${uuid}=   Get From DIctionary   ${dict}   uuid
    \    ${inv}=   Get From DIctionary   ${dict}    invariantUUID
    \    Return From Keyword If   "${invariantUUID}" == "${inv}"   ${uuid}
    [Return]    ""


Get Module Names from VID
    [Documentation]    Must use UI since rest call get redirect to portal and get DNS error
    ...    Given the invariantUUID of the model, mock up the vf_modules list passed to Preload VNF
    [Arguments]   ${invariantUUID}
    ${id}=   Get Model UUID from VID    ${invariantUUID}
    Go To     ${VID_ENDPOINT}${VID_ENV}/rest/models/services/${id}
    ${resp}=   Get Text   xpath=//body/pre
    ${json}=   To Json    ${resp}
    ${modules}=   Create List
    ${vnfs}=   Get From Dictionary    ${json}   vnfs
    ${keys}=   Get Dictionary Keys    ${vnfs}
    :FOR   ${key}  IN  @{keys}
    \    Add VFModule   ${vnfs['${key}']}   ${modules}
    [Return]    ${modules}

Add VFModule
    [Documentation]   Dig the vf module names from the VID service model
    [Arguments]   ${vnf}   ${modules}
    ${vfModules}=   Get From Dictionary    ${vnf}   vfModules
    ${keys}=   Get Dictionary Keys    ${vfModules}
    :FOR   ${key}  IN  @{keys}
    \    ${module}=   Get From Dictionary    ${vfModules}   ${key}
    \    ${dict}=    Create Dictionary   name=${module['name']}
    \    Append to List   ${modules}   ${dict}
