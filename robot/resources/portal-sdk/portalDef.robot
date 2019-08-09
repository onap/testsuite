*** Settings ***
Documentation    Keywords for ONAP Portal SDK management operations
Library         SeleniumLibrary
Library         OperatingSystem
Library         RequestsLibrary
Library         DateTime
Library         Collections
Library         String
Library         ONAPLibrary.Templating    WITH NAME    Templating

Resource        ../browser_setup.robot

*** Variables ***
#${PORTAL_URL}      http://portal.api.simpledemo.onap.org:8989
${PORTAL_URL}       ${GLOBAL_PORTAL_SERVER_PROTOCOL}://${GLOBAL_INJECTED_PORTAL_IP_ADDR}:${GLOBAL_PORTAL_SERVER_PORT}
${PORTAL_ENV}       /ONAPPORTAL
${PORTAL_LOGIN_URL}                ${PORTAL_URL}${PORTAL_ENV}/login.htm
${PORTAL_HOME_PAGE}        ${PORTAL_URL}${PORTAL_ENV}/applicationsHome
${PORTAL_MICRO_ENDPOINT}    ${PORTAL_URL}${PORTAL_ENV}/commonWidgets
${PORTAL_HOME_URL}                ${PORTAL_URL}${PORTAL_ENV}/applicationsHome
${PORTAL_HEALTH_CHECK_PATH}        ${PORTAL_ENV}/portalApi/healthCheck
${PORTAL_XDEMPAPP_REST_URL}        ${PORTAL_URL}/ONAPPORTALSDK/api/v2
${PORTAL_ASSETS_DIRECTORY}    ../../assets/widgets/
${GLOBAL_PORTAL_ADMIN_USER}		demo
${GLOBAL_PORTAL_ADMIN_PWD}		demo123456!
${RESOURCE_PATH}    ${PORTAL_URL}/auxapi/ticketevent
${portal_Template}    portal/portal.jinja


*** Keywords ***
Generate Random User
    [Arguments]    ${prefix}
    ${RAND}    Generate Random String    4    [NUMBERS]
    ${login_id}=     Set Variable    ${prefix}${RAND}
    ${email_address}=    Set Variable    ${prefix}${RAND}@onap.com
    [Return]   ${login_id}    ${email_address}

Portal admin Login To Portal GUI
    [Documentation]   Logs into Portal GUI
    Set Selenium Speed    ${GLOBAL_SELENIUM_DELAY}
    Setup Browser
    Go To    ${PORTAL_LOGIN_URL}
    Set Browser Implicit Wait    ${GLOBAL_SELENIUM_BROWSER_IMPLICIT_WAIT}
    Log    Logging in to ${PORTAL_URL}${PORTAL_ENV}
    Title Should Be    Login
    Input Text    xpath=//input[@ng-model='loginId']    ${GLOBAL_PORTAL_ADMIN_USER}
    Input Password    xpath=//input[@ng-model='password']    ${GLOBAL_PORTAL_ADMIN_PWD}
    Click Link    xpath=//a[@id='loginBtn']
    Sleep    5s
    Go To    ${PORTAL_HOME_URL}
    Wait Until Page Contains Element    xpath=//img[@alt='Onap Logo']    ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT}
	Log    Logged in to ${PORTAL_URL}${PORTAL_ENV}

Portal admin Go To Portal HOME
    [Documentation]    Navigate to Portal Home
    Go To    ${PORTAL_HOME_URL}
    Wait Until Page Contains Element    xpath=//div[@class='applicationWindow']    ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT}

Portal admin User Notifications
    [Documentation]    Navigate to User notification tab
    Click Link    xpath=//a[@id='parent-item-User-Notifications']
    Wait Until Element Is Visible    xpath=//h1[@class='heading-page']    ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT}
    Click Button    xpath=//button[@id='button-openAddNewApp']
    Click Button    xpath=(//button[@id='undefined'])[1]

Portal admin Add Application Admin Existing User
    [Documentation]    Navigate to Admins tab and add new application admin rights to existing user
    [Arguments]    ${login_id}
    Wait Until Element Is Visible    xpath=//a[@title='Admins']    ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT}
    Click Link    xpath=//a[@title='Admins']
    Wait Until Element Is Visible    xpath=//h1[contains(.,'Admins')]    ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT}
    Page Should Contain      Admins
    Click Button	xpath=//button[@ng-click='toggleSidebar()']
    Click Button    xpath=//button[@ng-click='admins.openAddNewAdminModal()']
    Input Text    xpath=//input[@id='input-user-search']    ${login_id}
    Click Button    xpath=//button[@id='button-search-users']
    Click Element    xpath=//span[@id='result-uuid-0']
    Click Button    xpath=//button[@id='search-users-button-next']
    Click Button    xpath=//input[@value='Select application']
    Scroll Element Into View    xpath=(//input[@value='Select application']/following::*[contains(text(),'xDemo App' )])[1]
    Click Element    xpath=(//li[contains(.,'xDemo App' )])[2]
    Click Button    xpath=//button[@id='div-updateAdminAppsRoles']
    Click Element    xpath=//button[@id='admin-div-ok-button']
    Click Element    xpath=//button[@id='div-confirm-ok-button']
    Get Selenium Implicit Wait
    Click Link    xpath=//a[@aria-label='Admins']
    Click Element    xpath=//input[@id='dropdown1']
    Click Element    xpath=//li[contains(.,'xDemo App' )]
    Input Text    xpath=//input[@id='input-table-search']    ${login_id}
    Table Column Should Contain    xpath=//*[@table-data='admins.adminsTableData']    1    ${login_id}

Portal admin Delete Application Admin Existing User
    [Documentation]    Navigate to Admins tab
    [Arguments]    ${login_id}
    Wait Until Element Is Visible    xpath=//a[@title='Admins']    ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT}
    Click Link    xpath=//a[@title='Admins']
    Wait Until Element Is Visible    xpath=//h1[contains(.,'Admins')]    ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT}
    Page Should Contain      Admins
    Click Button	xpath=//button[@ng-click='toggleSidebar()']
    Input Text    xpath=//input[@id='input-table-search']    ${login_id}
    Click Element    xpath=(//span[contains(.,'portal')] )[1]
    Click Element    xpath=//*[@id='select-app-xDemo-App']/following::i[@id='i-delete-application']
    Click Element    xpath=//button[@id='div-confirm-ok-button']
    Click Button    xpath=//button[@id='div-updateAdminAppsRoles']
    Click Element    xpath=//button[@id='admin-div-ok-button']
    Element Should Not Contain     xpath=//*[@table-data='admins.adminsTableData']    portal
    Click Image     xpath=//img[@alt='Onap Logo']
    Set Selenium Implicit Wait    3000

Portal admin Add Application admin User New user
    [Documentation]    Navigate to Users tab
    [Arguments]    ${login_id}    ${email_address}
    Click Link    xpath=//a[@title='Users']
    Page Should Contain      Users
    Click Button	xpath=//button[@ng-click='toggleSidebar()']
    Click Button    xpath=//button[@id='users-button-add']
    Click Button    xpath=//button[@id='Create-New-User-button']
    Input Text    xpath=//input[@ng-model='searchUsers.newUser.firstName']    ${login_id}
    Input Text    xpath=//input[@ng-model='searchUsers.newUser.lastName']    ${GLOBAL_PORTAL_ADMIN_USER}
    Input Text    xpath=//input[@ng-model='searchUsers.newUser.emailAddress']    ${email_address}
    Input Text    xpath=//input[@ng-model='searchUsers.newUser.loginId']    ${login_id}
    Input Text    xpath=//input[@ng-model='searchUsers.newUser.loginPwd']    ${GLOBAL_PORTAL_ADMIN_PWD}
    Input Text    xpath=//input[@ng-model='searchUsers.newUser.loginPwdCheck']    ${GLOBAL_PORTAL_ADMIN_PWD}
    Click Button    xpath=//button[@ng-click='searchUsers.addNewUserFun()']
    ${Result}=    Get Element Count     xpath=//*[contains(text(),'User with same loginId already exists')]

    Run Keyword if     '${Result}'== 0     AdminUser does not exist already    ${login_id}
    ...    ELSE     Goto Home Image
    Set Selenium Implicit Wait    3000

Goto Home Image
    Click Image    xpath=//img[@alt='Onap Logo']

AdminUser does not exist already
    [Arguments]    ${login_id}
    Click Button    xpath=//button[@id='next-button']
    Click Element    xpath=//*[@id='div-app-name-dropdown-xDemo-App']
    Click Element    xpath=//*[@id='div-app-name-xDemo-App']/following::input[@id='Standard-User-checkbox']
    Set Selenium Implicit Wait    3000
    Click Button    xpath=//button[@id='new-user-save-button']
    Set Selenium Implicit Wait    3000
    Go To    ${PORTAL_HOME_PAGE}
    Click Link    xpath=//a[@title='Users']
    Click Element    xpath=//input[@id='dropdown1']
    Click Element    xpath=//li[contains(.,'xDemo App')]
    Table Column Should Contain    xpath=//*[@table-data='users.accountUsers']    1    ${login_id}
    Click Image     xpath=//img[@alt='Onap Logo']
    Set Selenium Implicit Wait    3000

Portal admin Add Standard User New user
    [Documentation]    Navigate to Users tab
    [Arguments]    ${login_id}    ${email_address}
    Click Link    xpath=//a[@title='Users']
    Page Should Contain      Users
    Click Button	xpath=//button[@ng-click='toggleSidebar()']
    Click Button    xpath=//button[@id='users-button-add']
    Click Button    xpath=//button[@id='Create-New-User-button']
    Input Text    xpath=//input[@ng-model='searchUsers.newUser.firstName']    ${login_id}
    Input Text    xpath=//input[@ng-model='searchUsers.newUser.lastName']    ${GLOBAL_PORTAL_ADMIN_USER}
    Input Text    xpath=//input[@ng-model='searchUsers.newUser.emailAddress']    ${email_address}
    Input Text    xpath=//input[@ng-model='searchUsers.newUser.loginId']    ${login_id}
    Input Text    xpath=//input[@ng-model='searchUsers.newUser.loginPwd']    ${GLOBAL_PORTAL_ADMIN_PWD}
    Input Text    xpath=//input[@ng-model='searchUsers.newUser.loginPwdCheck']    ${GLOBAL_PORTAL_ADMIN_PWD}
    Click Button    xpath=//button[@ng-click='searchUsers.addNewUserFun()']

    ${Result}=    Get Element Count     xpath=//*[contains(text(),'User with same loginId already exists')]

    Run Keyword if     '${Result}'== 0     StaUser does not exist already    ${login_id}
    ...    ELSE     Goto Home Image
    Set Selenium Implicit Wait    3000

StaUser does not exist already
    [Arguments]    ${login_id}
    Click Button    xpath=//button[@id='next-button']
    Click Element    xpath=//*[@id='div-app-name-dropdown-xDemo-App']
    Click Element    xpath=//*[@id='div-app-name-xDemo-App']/following::input[@id='Standard-User-checkbox']
    Set Selenium Implicit Wait    3000
    Click Button    xpath=//button[@id='new-user-save-button']
    Set Selenium Implicit Wait    3000
    Go To    ${PORTAL_HOME_PAGE}
    Click Link    xpath=//a[@title='Users']
    Click Element    xpath=//input[@id='dropdown1']
    Click Element    xpath=//li[contains(.,'xDemo App')]
    Table Column Should Contain    xpath=//*[@table-data='users.accountUsers']    1    ${login_id}
    Click Image     xpath=//img[@alt='Onap Logo']
    Set Selenium Implicit Wait    3000

Portal admin Add Application admin User New user -Test
    [Documentation]    Navigate to Users tab
    [Arguments]    ${login_id}    ${email_address}
    Click Link    xpath=//a[@title='Users']
    Page Should Contain      Users
    Click Button	xpath=//button[@ng-click='toggleSidebar()']
    Click Button    xpath=//button[@id='users-button-add']
    Click Button    xpath=//button[@id='Create-New-User-button']
    Input Text    xpath=//input[@ng-model='searchUsers.newUser.firstName']    ${login_id}
    Input Text    xpath=//input[@ng-model='searchUsers.newUser.lastName']    ${GLOBAL_PORTAL_ADMIN_USER}
    Input Text    xpath=//input[@ng-model='searchUsers.newUser.emailAddress']    ${email_address}
    Input Text    xpath=//input[@ng-model='searchUsers.newUser.loginId']    ${login_id}
    Input Text    xpath=//input[@ng-model='searchUsers.newUser.loginPwd']    ${GLOBAL_PORTAL_ADMIN_PWD}
    Input Text    xpath=//input[@ng-model='searchUsers.newUser.loginPwdCheck']    ${GLOBAL_PORTAL_ADMIN_PWD}
    Click Button    xpath=//button[@ng-click='searchUsers.addNewUserFun()']
    Click Button	xpath=//button[@id='search-users-button-cancel']
    Click Image     xpath=//img[@alt='Onap Logo']
    Set Selenium Implicit Wait    3000


Portal admin Add Application Admin Existing User -APPDEMO
    [Documentation]    Navigate to Admins tab
    [Arguments]    ${login_id}
    Wait Until Element Is Visible    xpath=//a[@title='Admins']    ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT}
    Click Link    xpath=//a[@title='Admins']
    Wait Until Element Is Visible    xpath=//h1[contains(.,'Admins')]    ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT}
    Page Should Contain      Admins
    Click Button	xpath=//button[@ng-click='toggleSidebar()']
    Click Button    xpath=//button[@ng-click='admins.openAddNewAdminModal()']
    Input Text    xpath=//input[@id='input-user-search']    ${login_id}
    Click Button    xpath=//button[@id='button-search-users']
    Click Element    xpath=//span[@id='result-uuid-0']
    Click Button    xpath=//button[@id='search-users-button-next']
    Click Button    xpath=//input[@value='Select application']
    Scroll Element Into View    xpath=(//input[@value='Select application']/following::*[contains(text(),'xDemo App' )])[1]
    Click Element    xpath=(//li[contains(.,'xDemo App' )])[2]
    Click Button    xpath=//button[@id='div-updateAdminAppsRoles']
    Click Element    xpath=//button[@id='admin-div-ok-button']
    Click Element    xpath=//button[@id='div-confirm-ok-button']
    Get Selenium Implicit Wait
    Click Link    xpath=//a[@aria-label='Admins']
    Click Element    xpath=//input[@id='dropdown1']
    Click Element    xpath=//li[contains(.,'xDemo App' )]
    Input Text    xpath=//input[@id='input-table-search']    ${login_id}
    Table Column Should Contain    xpath=//*[@table-data='admins.adminsTableData']    1    ${login_id}
    Click Image     xpath=//img[@alt='Onap Logo']
    Set Selenium Implicit Wait    3000	
          
Portal admin Add Standard User Existing user
    [Documentation]    Navigate to Users tab
    [Arguments]    ${login_id}
    Click Link    xpath=//a[@title='Users']
    Page Should Contain      Users
    Click Button	xpath=//button[@ng-click='toggleSidebar()']
    Click Button    xpath=//button[@ng-click='users.openAddNewUserModal()']
    Input Text    xpath=//input[@id='input-user-search']    ${login_id}
    Click Button    xpath=//button[@id='button-search-users']
    Click Element    xpath=//span[@id='result-uuid-0']
    Click Button    xpath=//button[@id='next-button']
    Click Element    xpath=//div[@id='app-select-Select roles1']
    Click Element    xpath=//div[@id='app-select-Select roles1']/following::input[@id='Standard-User-checkbox']
    Set Selenium Implicit Wait    3000
    Click Button    xpath=//button[@id='new-user-save-button']
    Set Selenium Implicit Wait    3000
    Go To    ${PORTAL_HOME_PAGE}

Portal admin Edit Standard User Existing user
    [Documentation]    Navigate to Users tab
    [Arguments]    ${login_id}
    Click Link    xpath=//a[@title='Users']
    Click Element    xpath=//input[@id='dropdown1']
    Click Element    xpath=//li[contains(.,'xDemo App')]
    Input Text    xpath=//input[@id='input-table-search']    ${login_id}
    Element Text Should Be      xpath=(.//*[@id='rowheader_t1_0'])[2]   Standard User
    Click Element    xpath=(.//*[@id='rowheader_t1_0'])[2]
    Click Element    xpath=//*[@id='app-select-Standard User1']
    Click Element    xpath=//*[@id='app-select-Standard User1']/following::input[@id='Standard-User-checkbox']
    Set Selenium Implicit Wait    3000
    Click Button    xpath=//button[@id='new-user-save-button']
    Set Selenium Implicit Wait    3000

    Page Should Contain      Users
    Click Button	xpath=//button[@ng-click='toggleSidebar()']
    Click Button    xpath=//button[@ng-click='users.openAddNewUserModal()']
    Input Text    xpath=//input[@id='input-user-search']    ${login_id}
    Click Button    xpath=//button[@id='button-search-users']
    Click Element    xpath=//span[@id='result-uuid-0']
    Click Button    xpath=//button[@id='next-button']
    Click Element    xpath=//div[@id='app-select-Select roles1']
    Click Element    xpath=//div[@id='app-select-Select roles1']/following::input[@id='System-Administrator-checkbox']
    Set Selenium Implicit Wait    3000
    Set Selenium Implicit Wait    3000
    Click Button    xpath=//button[@id='new-user-save-button']
    Set Selenium Implicit Wait    3000
    Page Should Contain      Users
    Input Text    xpath=//input[@id='input-table-search']    ${login_id}
    Element Text Should Be      xpath=(.//*[@id='rowheader_t1_0'])[2]   System Administrator
    Set Selenium Implicit Wait    3000

Portal admin Delete Standard User Existing user
    [Documentation]    Naviage to Users tab
    Click Element    xpath=(.//*[@id='rowheader_t1_0'])[2]
    Set Selenium Implicit Wait    9000
    Scroll Element Into View    xpath=//*[@id='div-app-name-xDemo-App']/following::*[@id='app-item-delete'][1]
    Click Element    xpath=//*[@id='div-app-name-xDemo-App']/following::*[@id='app-item-delete'][1]
    Click Element    xpath=//button[@id='div-confirm-ok-button']
    Click Button    xpath=//button[@id='new-user-save-button']
    Element Should Not Contain     xpath=//*[@table-data='users.accountUsers']    Portal
    Set Selenium Implicit Wait    3000

Functional Top Menu Get Access
    [Documentation]    Navigate to Support tab
	Go To    ${PORTAL_HOME_URL}
    Click Link    xpath=//a[contains(.,'Support')]
    Mouse Over    xpath=//*[contains(text(),'Get Access')]
    Click Link    xpath=//a[contains(.,'Get Access')]
    Element Text Should Be    xpath=//h1[contains(.,'Get Access')]    Get Access
    Set Selenium Implicit Wait    3000

Functional Top Menu Contact Us
    [Documentation]    Navigate to Support tab
    Click Link    xpath=//a[contains(.,'Support')]
    Mouse Over    xpath=//*[contains(text(),'Contact Us')]
    Click Link    xpath=//a[contains(.,'Contact Us')]
    Element Text Should Be    xpath=//h1[contains(.,'Contact Us')]    Contact Us
    Click Image    xpath=//img[@alt='Onap Logo']
    Set Selenium Implicit Wait    3000

Portal admin Edit Functional menu
    [Documentation]    Navigate to Edit Functional menu tab
    Click Link    xpath=//a[@title='Edit Functional Menu']
    Click Link    xpath=.//*[@id='Manage']/div/a
    Click Link    xpath=.//*[@id='Design']/div/a
    Click Link    xpath=.//*[@id='Product_Design']/div/a
    Open Context Menu    xpath=//*[@id='Product_Design']/div/span
    Click Link    xpath=//a[@href='#add']
    Input Text    xpath=//input[@id='input-title']    ONAP Test
    Click Element     xpath=//input[@id='select-app']
    Scroll Element Into View    xpath=//li[contains(.,'xDemo App')]
    Click Element    xpath=//li[contains(.,'xDemo App')]
    Input Text    xpath=//input[@id='input-url']    http://google.com
    Click Button    xpath=//button[@id='button-save-continue']
    Click Element    xpath=//*[@id='app-select-Select Roles']
    Click Element    xpath=//input[@id='Standard-User-checkbox']
    Click Element    xpath=//button[@id='button-save-add']
    Click Image     xpath=//img[@alt='Onap Logo']
    Set Selenium Implicit Wait    3000
    Click Link    xpath=//a[contains(.,'Manage')]
    Mouse Over    xpath=//*[contains(text(),'Design')]
    Set Selenium Implicit Wait    3000
    Element Text Should Be    xpath=//a[contains(.,'ONAP Test')]      ONAP Test
    Set Selenium Implicit Wait    3000
    Click Image	xpath=//img[@alt='Onap Logo']
    Click Link    xpath=//a[@title='Edit Functional Menu']
    Click Link    xpath=.//*[@id='Manage']/div/a
    Click Link    xpath=.//*[@id='Design']/div/a
    Click Link    xpath=.//*[@id='Product_Design']/div/a
    Open Context Menu    xpath=//*[@id='ONAP_Test']
    Click Link    xpath=//a[@href='#delete']
    Set Selenium Implicit Wait    3000
    Click Element    xpath=//button[@id='div-confirm-ok-button']
    Click Image     xpath=//img[@alt='Onap Logo']
    Set Selenium Implicit Wait    3000
    Click Link    xpath=//a[contains(.,'Manage')]
    Mouse Over    xpath=//*[contains(text(),'Design')]
    Set Selenium Implicit Wait    3000
    Element Should Not Contain    xpath=(.//*[contains(.,'Design')]/following::ul[1])[1]      ONAP Test
    Set Selenium Implicit Wait    3000
    Click Image     xpath=//img[@alt='Onap Logo']
    Set Selenium Implicit Wait    3000

Portal admin Microservice Onboarding
    [Documentation]    Navigate to Edit Functional menu tab
    Click Link    xpath=//a[@title='Microservice Onboarding']
    Click Button    xpath=//button[@id='microservice-onboarding-button-add']
    Input Text    xpath=//input[@name='name']    Test Microservice
    Input Text    xpath=//*[@name='desc']    Test
    Click Element    xpath=//input[@id='microservice-details-input-app']
    Scroll Element Into View    xpath=//li[contains(.,'xDemo App')]
    Click Element    xpath=//li[contains(.,'xDemo App')]
    Click Element     xpath=//*[@name='desc']
    Input Text    xpath=//input[@name='url']    ${PORTAL_MICRO_ENDPOINT}
    Click Element    xpath=//input[@id='microservice-details-input-security-type']
    Scroll Element Into View    xpath=//li[contains(.,'Basic Authentication')]
    Click Element    xpath=//li[contains(.,'Basic Authentication')]
    Input Text    xpath=//input[@name='username']    ${GLOBAL_PORTAL_ADMIN_USER}
    Input Text    xpath=//input[@name='password']    ${GLOBAL_PORTAL_ADMIN_PWD}
    Click Button    xpath=//button[@id='microservice-details-save-button']
    Table Column Should Contain    xpath=//*[@table-data='serviceList']    1    Test Microservice
    Set Selenium Implicit Wait    3000

Portal admin Microservice Delete
    [Documentation]    Navigate to Edit Functional menu tab
    Click Link    xpath=//a[@title='Microservice Onboarding']
    Click Button    xpath=//button[@id='microservice-onboarding-button-add']
    Input Text    xpath=//input[@name='name']    TestMS
    Input Text    xpath=//*[@name='desc']    TestMS
    Click Element    xpath=//input[@id='microservice-details-input-app']
    Scroll Element Into View    xpath=//li[contains(.,'xDemo App')]
    Click Element    xpath=//li[contains(.,'xDemo App')]
    Click Element     xpath=//*[@name='desc']
    Input Text    xpath=//input[@name='url']    ${PORTAL_MICRO_ENDPOINT}
    Click Element    xpath=//input[@id='microservice-details-input-security-type']
    Scroll Element Into View    xpath=//li[contains(.,'Basic Authentication')]
    Click Element    xpath=//li[contains(.,'Basic Authentication')]
    Input Text    xpath=//input[@name='username']    ${GLOBAL_PORTAL_ADMIN_USER}
    Input Text    xpath=//input[@name='password']    ${GLOBAL_PORTAL_ADMIN_PWD}
    Click Button    xpath=//button[@id='microservice-details-save-button']
    Execute Javascript	    window.scrollTo(0,document.body.scrollHeight);
    Click Element    xpath=(.//*[contains(text(),'TestMS')]/following::*[@ng-click='microserviceOnboarding.deleteService(rowData)'])[1]
    Click Button    xpath=//button[@id="div-confirm-ok-button"]
    Set Selenium Implicit Wait    3000

Portal Admin Create Widget for All users
    [Documentation]    Navigate to Create Widget menu tab
    ${WidgetAttachment}=    Catenate    ${PORTAL_ASSETS_DIRECTORY}news_widget.zip
    Wait until page contains Element    xpath=//a[@title='Widget Onboarding']     ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT}
    Click Link    xpath=//a[@title='Widget Onboarding']
    Click Button	xpath=//button[@ng-click='toggleSidebar()']
    Click Button    xpath=//button[@id='widget-onboarding-button-add']
    Input Text    xpath=//*[@name='name']    ONAP-xDemo
    Input Text    xpath=//*[@name='desc']    ONAP xDemo
    Click Element    xpath=//*[@id='widgets-details-input-endpoint-url']
    Scroll Element Into View    xpath=//li[contains(.,'News Microservice')]
    Click Element    xpath=//li[contains(.,'News Microservice')]
    Click Element    xpath=//*[contains(text(),'Allow all user access')]/preceding::input[@ng-model='widgetOnboardingDetails.widget.allUser'][1]
    Choose File    xpath=//input[@id='widget-onboarding-details-upload-file']    ${WidgetAttachment}
    Click Button    xpath=//button[@id='widgets-details-save-button']
    Wait Until Page Contains      ONAP-xDemo    ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT}
    Page Should Contain    ONAP-xDemo
    Set Selenium Implicit Wait    3000
    GO TO    ${PORTAL_HOME_PAGE}

Portal Admin Delete Widget for All users
    [Documentation]    Navigate to delete Widget menu tab
    Click Link    xpath=//a[@title='Widget Onboarding']
    Click Element    xpath=//input[@id='dropdown1']
    Click Element    xpath=//li[contains(.,'xDemo App')]
    Click Button	xpath=//button[@ng-click='toggleSidebar()']
    Click Element    xpath=(.//*[contains(text(),'ONAP-xDemo')]/following::*[@ng-click='widgetOnboarding.deleteWidget(rowData)'])[1]
    Click Element    xpath=//button[@id='div-confirm-ok-button']
    Set Selenium Implicit Wait    3000
    Element Should Not Contain     xpath=//*[@table-data='portalAdmin.portalAdminsTableData']    ONAP-xDemo

Portal Admin Create Widget for Application Roles
    [Documentation]    Navigate to Create Widget menu tab
    ${WidgetAttachment}=    Catenate    ${PORTAL_ASSETS_DIRECTORY}news_widget.zip
    Click Link    xpath=//a[@title='Widget Onboarding']
    Click Button	xpath=//button[@ng-click='toggleSidebar()']
    Click Button    xpath=//button[@id='widget-onboarding-button-add']
    Input Text    xpath=//*[@name='name']    ONAP-xDemo
    Input Text    xpath=//*[@name='desc']    ONAP xDemo
    Click Element    xpath=//*[@id='widgets-details-input-endpoint-url']
    Scroll Element Into View    xpath=//li[contains(.,'News Microservice')]
    Click Element    xpath=//li[contains(.,'News Microservice')]
    Click element    xpath=//*[@id="app-select-Select Applications"]
    Click element    xpath=//*[@id="xDemo-App-checkbox"]
    Click element    xpath=//*[@name='desc']
    Click element    xpath=//*[@id="app-select-Select Roles0"]
    Click element    xpath=//*[@id="Standard-User-checkbox"]
    Click element    xpath=//*[@name='desc']
    Scroll Element Into View    xpath=//input[@id='widget-onboarding-details-upload-file']
    Choose File    xpath=//input[@id='widget-onboarding-details-upload-file']    ${WidgetAttachment}
    Click Button    xpath=//button[@id='widgets-details-save-button']
    Click Image     xpath=//img[@alt='Onap Logo']
    Set Selenium Implicit Wait    3000
    Click Link    xpath=//a[@title='Widget Onboarding']
    Click Element    xpath=//input[@id='dropdown1']
    Click Element    xpath=//li[contains(.,'xDemo App')]
    Page Should Contain    ONAP-xDemo
    Set Selenium Implicit Wait    3000
    GO TO    ${PORTAL_HOME_PAGE}

Portal Admin Delete Widget for Application Roles
    Click Link    xpath=//a[@title='Widget Onboarding']
    Click Element    xpath=//input[@id='dropdown1']
    Click Element    xpath=//li[contains(.,'xDemo App')]
    Click Button	xpath=//button[@ng-click='toggleSidebar()']
    Scroll Element Into View	xpath=//*[contains(text(),'ONAP-xDemo')]/following::td[3]/div
    Click Element    xpath=//*[contains(text(),'ONAP-xDemo')]/following::td[3]/div
    Click Element    xpath=//button[@id='div-confirm-ok-button']
    Set Selenium Implicit Wait    3000
    Element Should Not Contain     xpath=//*[@table-data='portalAdmin.portalAdminsTableData']    ONAP-xDemo
    Set Selenium Implicit Wait    3000

Portal Admin Edit Widget
    [Documentation]    Navigate to Home tab
    Click Element    xpath=(//h3[contains(text(),'News')]/following::span[1])[1]
    Set Browser Implicit Wait    8000
    Mouse Over    xpath=(//h3[contains(text(),'News')]/following::span[1]/following::a[contains(text(),'Edit')])[1]
    Click Link    xpath=(//h3[contains(text(),'News')]/following::span[1]/following::a[contains(text(),'Edit')])[1]
    Input Text    xpath=//input[@name='title']    ONAP_VID
    Input Text    xpath=//input[@name='url']    http://about.att.com/news/international.html
    Input Text    xpath=//input[@id='widget-input-add-order']    5
    Click Link    xpath=//a[contains(.,'Add New')]
    Click Element    xpath=//div[@id='close-button']
    Element Should Contain    xpath=//*[@table-data='ignoredTableData']    ONAP_VID
    Click Element    xpath=.//div[contains(text(),'ONAP_VID')]/following::*[contains(text(),'5')][1]/following::div[@ng-click='remove($index);'][1]
    Click Element    xpath=//div[@id='confirmation-button-next']
    Element Should Not Contain    xpath=//*[@table-data='ignoredTableData']    ONAP_VID
    Click Link    xpath=//a[@id='close-button']
    Set Selenium Implicit Wait    3000

Portal Admin Broadcast Notifications
    [Documentation]   Portal Test Admin Broadcast Notifications
    ${CurrentDay}=    Get Current Date    increment=24:00:00    result_format=%m/%d/%Y
    ${NextDay}=    Get Current Date    increment=48:00:00    result_format=%m/%d/%Y
    ${CurrentDate}=    Get Current Date    increment=24:00:00    result_format=%m%d%y%H%M
    ${AdminBroadCastMsg}=    catenate    ONAP VID Broadcast Automation${CurrentDate}
    Go To    ${PORTAL_HOME_URL}
    Click Image     xpath=//img[@alt='Onap Logo']
    Set Selenium Implicit Wait    3000
    Click Link    xpath=//*[@id="parent-item-User-Notifications"]
    Wait until Element is visible    xpath=//*[@id="button-openAddNewApp"]    timeout=10
    Click button    xpath=//*[@id="button-openAddNewApp"]
    Input Text    xpath=//input[@id='datepicker-start']     ${CurrentDay}
    Input Text    xpath=//input[@id='datepicker-end']     ${NextDay}
    Input Text    xpath=//*[@id="add-notification-input-title"]    ONAP VID Broadcast Automation
    Input Text    xpath=//*[@id="user-notif-input-message"]    ${AdminBroadCastMsg}
    Click element    xpath=//*[@id="button-notification-save"]
    Wait until Element is visible    xpath=//*[@id="button-openAddNewApp"]    timeout=10
    Click element    xpath=//*[@id="megamenu-notification-button"]
    Click element    xpath=//*[@id="notification-history-link"]
    Wait until Element is visible    xpath=//*[@id="notification-history-table"]    timeout=10
    Table Column Should Contain    xpath=//*[@id="notification-history-table"]    2    ${AdminBroadCastMsg}
    Set Selenium Implicit Wait    3000
    log    ${AdminBroadCastMsg}
    [Return]     ${AdminBroadCastMsg}

Portal Admin Category Notifications
    [Documentation]   Portal Admin Broadcast Notifications
    ${CurrentDay}=    Get Current Date    increment=24:00:00    result_format=%m/%d/%Y
    ${NextDay}=    Get Current Date    increment=48:00:00    result_format=%m/%d/%Y
    ${CurrentDate}=    Get Current Date    increment=24:00:00    result_format=%m%d%y%H%M
    ${AdminCategoryMsg}=    catenate    ONAP VID Category Automation${CurrentDate}
    Click Link    xpath=//a[@id='parent-item-Home']
    Click Link    xpath=//*[@id="parent-item-User-Notifications"]
    Wait until Element is visible    xpath=//*[@id="button-openAddNewApp"]    timeout=10
    Click button    xpath=//*[@id="button-openAddNewApp"]
    Click Element    //*[contains(text(),'Broadcast to All Categories')]/following::*[contains(text(),'No')][1]
    Click Element    xpath=//*[contains(text(),'Categories')]/following::*[contains(text(),'Application Roles')][1]
    Click Element    xpath=//*[contains(text(),'xDemo App')]/preceding::input[@ng-model='member.isSelected'][1]
    Input Text    xpath=//input[@id='datepicker-start']     ${CurrentDay}
    Input Text    xpath=//input[@id='datepicker-end']     ${NextDay}
    Input Text    xpath=//*[@id="add-notification-input-title"]    ONAP VID Category Automation
    Input Text    xpath=//*[@id='user-notif-input-message']    ${AdminCategoryMsg}
    Click element    xpath=//*[@id="button-notification-save"]
    Wait until Element is visible    xpath=//*[@id="button-openAddNewApp"]    timeout=10
    Click element    xpath=//*[@id="megamenu-notification-button"]
    Click element    xpath=//*[@id="notification-history-link"]
    Wait until Element is visible    xpath=//*[@id="notification-history-table"]    timeout=10
    Table Column Should Contain    xpath=//*[@id="notification-history-table"]    2    ${AdminCategoryMsg}
    Set Selenium Implicit Wait    3000
    log    ${AdminCategoryMsg}
    [Return]     ${AdminCategoryMsg}

Portal admin Logout from Portal GUI
    [Documentation]   Logout from Portal GUI
    Click Element    xpath=//div[@id='header-user-icon']
    Run Keyword And Ignore Error    Click Button    xpath=//button[contains(.,'Log out')]
    # TODO: Rework Logout tests to deal with intermittent "document unloaded while waiting for result" errors

Application admin Login To Portal GUI
    [Documentation]   Logs into Portal GUI
    [Arguments]    ${login_id}
    Go To    ${PORTAL_LOGIN_URL}
    Title Should Be    Login
    Input Text    xpath=//input[@ng-model='loginId']    ${login_id}
    Input Password    xpath=//input[@ng-model='password']    ${GLOBAL_PORTAL_ADMIN_PWD}
    Click Link    xpath=//a[@id='loginBtn']
    Sleep    5s
    Go To    ${PORTAL_HOME_URL}
    Wait Until Page Contains Element    xpath=//img[@alt='Onap Logo']    ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT}
    Log    Logged in to ${PORTAL_URL}${PORTAL_ENV}

Application Admin Navigation Application Link Tab
    [Documentation]   Logs into Portal GUI as application admin
    Click Link    xpath=//a[@id='parent-item-Home']
    Click Element    xpath=.//h3[contains(text(),'xDemo App')]/following::div[1]
    Page Should Contain    ONAP Portal
	Scroll Element Into View	xpath=//i[@class='ion-close-round']
    Click Element    xpath=//i[@class='ion-close-round']
    Set Selenium Implicit Wait    3000

Application Admin Navigation Functional Menu
    [Documentation]   Logs into Portal GUI as application admin
    Click Link    xpath=//a[contains(.,'Manage')]
    Mouse Over    xpath=//*[contains(text(),'Technology Insertion')]
    Click Link    xpath= //*[contains(text(),'Infrastructure VNF Provisioning')]
    Page Should Contain    ONAP Portal
    Click Element    xpath=//i[@class='ion-close-round']
    Click Element    xpath=(.//span[@id='tab-Home'])[1]

Application admin Add Standard User Existing user
    [Documentation]    Navigate to Users tab
    [Arguments]    ${login_id}
    Click Link    xpath=//a[@title='Users']
    Page Should Contain      Users
    Click Button	xpath=//button[@ng-click='toggleSidebar()']
    Click Button    xpath=//button[@ng-click='users.openAddNewUserModal()']
    Input Text    xpath=//input[@id='input-user-search']    ${login_id}
    Click Button    xpath=//button[@id='button-search-users']
    Click Element    xpath=//span[@id='result-uuid-0']
    Click Button    xpath=//button[@id='next-button']
    Click Element    xpath=//*[@id='div-app-name-dropdown-xDemo-App']
    Click Element    xpath=//*[@id='div-app-name-xDemo-App']/following::input[@id='Standard-User-checkbox']
    Click Button    xpath=//button[@id='new-user-save-button']
    Set Selenium Implicit Wait    3000
    Go To    ${PORTAL_HOME_PAGE}
    Set Selenium Implicit Wait    3000
    Click Link    xpath=//a[@title='Users']
    Click Element    xpath=//input[@id='dropdown1']
    Click Element    xpath=//li[contains(.,'xDemo App')]
    Input Text    xpath=//input[@id='input-table-search']    ${login_id}
    Element Text Should Be      xpath=(.//*[@id='rowheader_t1_0'])[2]   Standard User

Application admin Edit Standard User Existing user
    [Documentation]    Navigate to Users tab
    [Arguments]    ${login_id}
    Click Element    xpath=(.//*[@id='rowheader_t1_0'])[2]
    Click Element    xpath=//*[@id='div-app-name-dropdown-xDemo-App']
    Click Element    xpath=//*[@id='div-app-name-xDemo-App']/following::input[@id='Standard-User-checkbox']
    Click Element    xpath=//*[@id='div-app-name-xDemo-App']/following::input[@id='System-Administrator-checkbox']
    Set Selenium Implicit Wait    3000
    Click Button    xpath=//button[@id='new-user-save-button']
    Set Selenium Implicit Wait    3000
    Page Should Contain      Users
    Input Text    xpath=//input[@id='input-table-search']    ${login_id}
    Element Text Should Be      xpath=(.//*[@id='rowheader_t1_0'])[2]   System Administrator

Application admin Delete Standard User Existing user
    [Documentation]    Naviage to Users tab
    Click Element    xpath=(.//*[@id='rowheader_t1_0'])[2]
    Scroll Element Into View    xpath=//*[@id='div-app-name-xDemo-App']/following::*[@id='app-item-delete'][1]
    Click Element    xpath=//*[@id='div-app-name-xDemo-App']/following::*[@id='app-item-delete'][1]
    Click Element    xpath=//button[@id='div-confirm-ok-button']
    Click Button    xpath=//button[@id='new-user-save-button']
    Element Should Not Contain     xpath=//*[@table-data='users.accountUsers']    Portal
    Set Selenium Implicit Wait    3000

Application admin Logout from Portal GUI
    [Documentation]   Logout from Portal GUI
    Click Element    xpath=//div[@id='header-user-icon']
    Run Keyword And Ignore Error    Click Button    xpath=//button[contains(text(),'Log out')]
    # TODO: Rework Logout tests to deal with intermittent "document unloaded while waiting for result" errors

Standard user Login To Portal GUI
    [Documentation]   Logs into Portal GUI
    [Arguments]    ${login_id}
    Go To    ${PORTAL_LOGIN_URL}
    Title Should Be    Login
    Input Text    xpath=//input[@ng-model='loginId']    ${login_id}
    Input Password    xpath=//input[@ng-model='password']    ${GLOBAL_PORTAL_ADMIN_PWD}
    Click Link    xpath=//a[@id='loginBtn']
    Sleep    5s
    Go To    ${PORTAL_HOME_URL}
    Wait Until Page Contains Element    xpath=//img[@alt='Onap Logo']    ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT}
    Log    Logged in to ${PORTAL_URL}${PORTAL_ENV}

Standard user Navigation Application Link Tab
    [Documentation]   Logs into Portal GUI as application admin
    Click Element    xpath=.//h3[contains(text(),'xDemo App')]/following::div[1]
    Page Should Contain    ONAP Portal
    Click Element    xpath=(.//span[@id='tab-Home'])[1]
    Set Selenium Implicit Wait    3000

Standard user Navigation Functional Menu
    [Documentation]   Logs into Portal GUI as application admin
    Click Link    xpath=//a[contains(.,'Manage')]
    Mouse Over    xpath=//*[contains(text(),'Technology Insertion')]
    Click Link    xpath= //*[contains(text(),'Infrastructure VNF Provisioning')]
    Page Should Contain    Welcome to VID
    Click Element    xpath=(.//span[@id='tab-Home'])[1]
    Set Selenium Implicit Wait    3000

Standard user Broadcast Notifications
    [Documentation]   Logs into Portal GUI as application admin
    [Arguments]    ${AdminBroadCastMsg}
    Click element    xpath=//*[@id='megamenu-notification-button']
    Click element    xpath=//*[@id='notification-history-link']
    Wait until Element is visible    xpath=//*[@id='app-title']    timeout=10
    Table Column Should Contain    xpath=//*[@id='notification-history-table']    2    ${AdminBroadCastMsg}
    log    ${AdminBroadCastMsg}

Standard user Category Notifications
    [Documentation]   Logs into Portal GUI as application admin
    [Arguments]    ${AdminCategoryMsg}
    Wait until Element is visible    xpath=//*[@id='app-title']    timeout=10
    Table Column Should Contain    xpath=//*[@id='notification-history-table']    2    ${AdminCategoryMsg}
    log    ${AdminCategoryMsg}

Standard user Logout from Portal GUI
    [Documentation]   Logout from Portal GUI
    Click Element    xpath=//div[@id='header-user-icon']
    Run Keyword And Ignore Error    Click Button    xpath=//button[contains(.,'Log out')]
    # TODO: Rework Logout tests to deal with intermittent "document unloaded while waiting for result" errors

Portal admin Add New Account
    ${rand}    Generate Random String    4    [NUMBERS]
    ${AppUserName}=           Set Variable    testApp${rand}
    ${AppPassword}=           Set Variable    testApp${rand}123!
    Click Link    //*[@id="parent-item-App-Account-Management"]
    Click Button    xpath=//button[@ng-click='toggleSidebar()']
    Set Selenium Implicit Wait    3000
    Click Button    //*[@id="account-onboarding-button-add"]
    Set Selenium Implicit Wait    3000
    Input Text    //*[@id="account-details-input-name"]    ${AppUserName}
    Input Text    //*[@id="account-details-input-username"]    ${AppUserName}
    Input Text    //*[@id="account-details-input-password"]    ${AppPassword}
    Input Text    //*[@id="account-details-input-repassword"]    ${AppPassword}
    #account-details-next-button
    Click Button    xpath=//button[@ng-click='accountAddDetails.saveChanges()']

Portal admin Delete Account
    Click Link    //*[@id="parent-item-App-Account-Management"]
    Click Button    xpath=//button[@ng-click='toggleSidebar()']
    Set Selenium Implicit Wait    3000
    Click Button    //*[@id="account-onboarding-button-add"]
    Set Selenium Implicit Wait    3000

Enhanced Notification on ONAP Portal
    [Documentation]     Runs portal Post request
    [Arguments]     ${data_path}     ${data}
    ${session}=         Create Session     portal         ${PORTAL_URL}
    ${headers}=     Create Dictionary     Accept=application/json    Content-Type=application/json    Authorization=Basic amlyYTpfcGFzcw==    username=jira    password=_pass
    ${resp}=     Post Request     portal     ${data_path}     data=${data}     headers=${headers}
    [Return]     ${resp}

Notification on ONAP Portal
    [Documentation]     Create Config portal
    ${configportal}=     Create Dictionary     jira_id=jira
    Templating.Create Environment    portal    ${GLOBAL_TEMPLATE_FOLDER}
    ${output} =     Templating.Apply Template     portal    ${portal_Template}     ${configportal}
    ${post_resp} =     Enhanced Notification on ONAP Portal     ${RESOURCE_PATH}     ${output}
    Should Be Equal As Strings     ${post_resp.status_code}     200

Portal Application Account Management
    [Documentation]    Navigate to Application Account Management tab
    Click Link    xpath=//a[@title='App Account Management']
    Click Button    xpath=//button[@id='account-onboarding-button-add']
    Input Text    xpath=//input[@name='name']    JIRA
    Input Text    xpath=//input[@name='username']    jira
    Input Text    xpath=//input[@name='password']    _pass
    Input Text    xpath=//input[@name='repassword']    _pass
    Click Element    xpath=//div[@ng-click='accountAddDetails.saveChanges()']
    Element Text Should Be    xpath=//*[@table-data='serviceList']    JIRA

Portal Application Account Management validation
    [Documentation]    Navigate to user notification tab
    Click Link    xpath=//a[@id='parent-item-User-Notifications']
    Click Element    xpath=//*[@id="megamenu-notification-button"]
    Click Element    xpath=//*[@id="notification-history-link"]
    Wait until Element is visible    xpath=//*[@id="notification-history-table"]    timeout=10
    Table Column Should Contain    xpath=//*[@id="notification-history-table"]    1    JIRA

Portal AAF new fields
    [Documentation]    Navigate to user Application details tab
    Click Link    xpath=//a[@title='Application Onboarding']
    Click Element    xpath=//td[contains(.,'xDemo App')]
    Page Should Contain    Name Space
    Page Should Contain    Centralized
    Click Element    xpath=//button[@id='button-notification-cancel']
    Set Selenium Implicit Wait    3000

Portal Change REST URL
    [Documentation]    Navigate to user Application details tab
    Click Link    xpath=//a[@title='Application Onboarding']
    Click Element    xpath=//td[contains(.,'xDemo App')]
    Input Text    xpath=//input[@name='restUrl']    ${PORTAL_XDEMPAPP_REST_URL}
    Click Element    xpath=//button[@id='button-save-app']
    Set Selenium Implicit Wait    6000
    Go To    ${PORTAL_HOME_PAGE}
    Wait Until Element Is Visible    xpath=//a[@title='Application Onboarding']    ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT}

Admin widget download
    Go To    ${PORTAL_HOME_URL}
    Wait until page contains Element    xpath=//a[@title='Widget Onboarding']     ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT}
    Click Link  xpath=//a[@title='Widget Onboarding']
    Wait until page contains Element    xpath=//table[@class='ng-scope']
    ${td_id}=  get element attribute    xpath=//*[contains(text(),'Events')]    id
    log    ${td_id}
    ${test}=    Get Substring     ${td_id}   -1
    log    ${test}
    ${download_link_id}=    Catenate    'widget-onboarding-div-download-widget-${test}'
    click Element  xpath=//*[@id=${download_link_id}]

Reset widget layout option
    Go To    ${PORTAL_HOME_URL}
    Wait Until Page Contains Element    xpath=//div[@id='widget-boarder']     ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT}
    Execute Javascript      document.getElementById('widgets').scrollTo(0,1400)
    Wait Until Page Contains Element     xpath=//*[@id='widget-gridster-Events-icon']    ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT}
    Execute Javascript      document.getElementById('widgets').scrollTo(0,1800)
    Drag And Drop By Offset   xpath=//*[@id='widget-gridster-Events-icon']   500  500
    Execute Javascript      document.getElementById('widgets').scrollTo(0,document.getElementById('widgets').scrollHeight);
    Execute Javascript      document.getElementById('dashboardDefaultPreference').click()
    Execute Javascript      document.getElementById('div-confirm-ok-button').click()

Add Portal Admin
    [Arguments]    ${login_id}
    Click Link    xpath=//a[@id='parent-item-Portal-Admins']
    Scroll Element Into View    xpath=//button[@id='portal-admin-button-add']
    Click Button    xpath=//button[@id='portal-admin-button-add']
    Input Text    xpath=//input[@id='input-user-search']    ${login_id}
    Click Button    xpath=//button[@id='button-search-users']
    Wait Until Page Contains Element     xpath=//span[@id='result-uuid-0']    ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT}
    Click Element    xpath=//span[@id='result-uuid-0']
    Click Button     xpath=//button[@id='pa-search-users-button-save']
    Click Button     xpath=//button[@id='admin-div-ok-button']

Delete Portal Admin
    Wait Until Page Does Not Contain Element     xpath=//*[@class='b2b-modal-header']
    Click Link    xpath=//a[@id='parent-item-Portal-Admins']
    Click Element    xpath=//td[contains(.,'portal')]/following::span[@id='1-button-portal-admin-remove']
    Click Button     xpath=//*[@id='div-confirm-ok-button']
