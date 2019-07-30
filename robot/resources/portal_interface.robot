*** Settings ***
Documentation	  The main interface for interacting with Portal. It handles low level stuff like managing the http request library and Portal required fields
Library 	RequestsLibrary
Library	          ONAPLibrary.Utilities
Library 	SeleniumLibrary
Library         Collections
Library         String

Resource        global_properties.robot
Resource        browser_setup.robot

*** Variables ***
${PORTAL_HEALTH_CHECK_PATH}        /ONAPPORTAL/portalApi/healthCheck
${PORTAL_ENDPOINT}     ${GLOBAL_PORTAL_SERVER_PROTOCOL}://${GLOBAL_INJECTED_PORTAL_IP_ADDR}:${GLOBAL_PORTAL_SERVER_PORT}
${PORTAL_GUI_ENDPOINT}     ${GLOBAL_PORTAL_SERVER_PROTOCOL}://portal.api.simpledemo.onap.org:${GLOBAL_PORTAL_SERVER_PORT}
${PORTAL_ENV}            /ONAPPORTAL
${PORTAL_LOGIN_URL}                ${PORTAL_GUI_ENDPOINT}${PORTAL_ENV}/login.htm
${PORTAL_HOME_URL}                ${PORTAL_GUI_ENDPOINT}${PORTAL_ENV}/applicationsHome

*** Keywords ***
Run Portal Health Check
     [Documentation]    Runs Portal Health check
     ${resp}=    Run Portal Get Request    ${PORTAL_HEALTH_CHECK_PATH}    
     Should Be Equal As Strings 	${resp.status_code} 	200
     Should Be Equal As Strings 	${resp.json()['statusCode']} 	200
         
Run Portal Get Request
     [Documentation]    Runs Portal Get request
     [Arguments]    ${data_path}
     ${session}=    Create Session 	portal	${PORTAL_ENDPOINT}
     ${uuid}=    Generate UUID4
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json    X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}
     ${resp}= 	Get Request 	portal 	${data_path}     headers=${headers}
     Log    Received response from portal ${resp.text}
     [Return]    ${resp}

Run Portal Login Tests
     [Documentation]    Runs Portal Login Tests
     Close All Browsers
     Login To Portal GUI   demo   demo123456!
     Close All Browsers
     Login To Portal GUI   cs0008  demo123456!
     Close All Browsers
     Login To Portal GUI   jm0007  demo123456!
     Close All Browsers
     Login To Portal GUI   gv0001  demo123456!
     Close All Browsers
     Login To Portal GUI   op0001  demo123456!
     Close All Browsers

Run Portal Application Access Tests
     [Documentation]    Runs Portal Application Access Tests
     Log    Testing SDC,VID,Policy
     Run Portal Application Login Test   cs0008   demo123456!   gridster-SDC-icon-link   tabframe-SDC    Welcome to SDC
     Close All Browsers
     Run Portal Application Login Test   demo    demo123456!  gridster-Virtual-Infrastructure-Deployment-icon-link   tabframe-Virtual-Infrastructure-Deployment    Welcome to VID
     Close All Browsers
     Run Portal Application Login Test   demo    demo123456!  gridster-Policy-icon-link   tabframe-Policy    Policy Editor
     Close All Browsers

Login To Portal GUI And Go Home
    [Documentation]   Logs in to Portal GUI
    [Arguments]     ${loginId}    ${password}
    Login To Portal GUI    ${loginId}    ${password}
    Go To Portal HOME

Login To Portal GUI
    [Documentation]   Logs in to Portal GUI
    [Arguments]     ${loginId}    ${password}
    # Setup Browser Now being managed by test case
    ### revert to local Setup Browser for Login test
    Setup Browser
    Go To    ${PORTAL_LOGIN_URL}
    Set Selenium Speed    ${GLOBAL_SELENIUM_DELAY}
    Set Browser Implicit Wait    ${GLOBAL_SELENIUM_BROWSER_IMPLICIT_WAIT}
    Log    Logging in to ${PORTAL_ENDPOINT}${PORTAL_ENV}
    Handle Proxy Warning
    Title Should Be    Login
    Input Text    xpath=//input[@ng-model='loginId']    ${loginId}
    Input Password    xpath=//input[@ng-model='password']    ${password}
    Click Element    xpath=//a[@id='loginBtn']
    Wait Until Page Contains  Applications   ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT}
    Log    Logged in to ${PORTAL_ENDPOINT}${PORTAL_ENV}
    Log  ${loginId} SUCCESS
    
Logout From Portal GUI
    [Documentation]   Logs out of Portal GUI
    Go To    ${PORTAL_LOGIN_URL}
    Click Element    xpath=//div[@id='header-user-icon']
    Run Keyword And Ignore Error    Click Button    xpath=//button[contains(.,'Log out')]
    Log    Logged out of ${PORTAL_ENDPOINT}${PORTAL_ENV}

Run Portal Application Login Test
    [Documentation]    Login to Portal Application
    [Arguments]   ${loginId}   ${password}   ${click_element}    ${tabframe}   ${match_string}
    # Setup Browser Now being managed by test case
    ### revert to local Setup Browser for Login test
    Setup Browser
    Go To    ${PORTAL_LOGIN_URL}
    #Maximize Browser Window
    Set Selenium Speed    ${GLOBAL_SELENIUM_DELAY}
    Set Browser Implicit Wait    ${GLOBAL_SELENIUM_BROWSER_IMPLICIT_WAIT}
    Log    Logging in to ${PORTAL_ENDPOINT}${PORTAL_ENV}
    Handle Proxy Warning
    Title Should Be    Login
    Input Text    xpath=//input[@ng-model='loginId']    ${loginId}
    Input Password    xpath=//input[@ng-model='password']    ${password}
    Click Element    xpath=//a[@id='loginBtn']
    Wait Until Page Contains  Applications   ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT}
    Log    Logged in to ${PORTAL_ENDPOINT}${PORTAL_ENV}
    Log  ${loginId} SUCCESS
    Sleep  5
    Click Element    id=${click_element}
    Sleep  5
    Select Frame  id=${tabframe}
    Sleep  5
    Page Should Contain  ${match_string}
    Log   Portal Application Access SUCCESS ${click_element}

Go To Portal HOME
    [Documentation]    Naviage to Portal Home
    Go To    ${PORTAL_HOME_URL}
    Wait Until Page Contains  Applications    ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT}

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
    Select From List By Label     xpath=${xpath}    ${value}

Input Text When Enabled
    [Arguments]     ${xpath}    ${value}    ${timeout}=${GLOBAL_VID_UI_TIMEOUT_MEDIUM}
    Wait Until Page Contains Element    xpath=${xpath}    ${timeout}
    Wait Until Element Is Enabled    xpath=${xpath}    ${timeout}
    Input Text    xpath=${xpath}    ${value}

