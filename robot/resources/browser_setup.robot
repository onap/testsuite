*** Settings ***
Documentation     The main interface for interacting with VID. It handles low level stuff like managing the selenium request library and VID required steps
Library           Collections
Library           OperatingSystem
Library           SeleniumLibrary
Resource          global_properties.robot

*** Variables ***
${HEADLESS}   True

*** Keywords ***
Setup Browser
    [Documentation]   Sets up browser based upon the value of ${GLOBAL_SELENIUM_BROWSER}
    Run Keyword If    '${GLOBAL_SELENIUM_BROWSER}' == 'firefox'    Setup Browser Firefox
    Run Keyword If    '${GLOBAL_SELENIUM_BROWSER}' == 'chrome'    Setup Browser Chrome
    Log    Running with ${GLOBAL_SELENIUM_BROWSER}

Setup Browser Firefox
    ${caps}=   Evaluate   sys.modules['selenium.webdriver'].common.desired_capabilities.DesiredCapabilities.FIREFOX   sys
    Set To Dictionary   ${caps}   marionette=
    Set To Dictionary   ${caps}   elementScrollBehavior    1
    ${wd}=   Create WebDriver   Firefox   capabilities=${caps}
    Set Global Variable    ${GLOBAL_SELENIUM_BROWSER_CAPABILITIES}    ${caps}


Setup Browser Chrome
    ${chrome_options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys
    ${user_data_dir}=   Evaluate    tempfile.mkdtemp()  sys
    Call Method    ${chrome_options}    add_argument    user-data-dir\=${user_data_dir}
    Call Method    ${chrome_options}    add_argument    no-sandbox
    Call Method    ${chrome_options}    add_argument    ignore-certificate-errors
    Run Keyword If  ${HEADLESS}==True  Call Method    ${chrome options}    add_argument    headless
    Call Method    ${chrome_options}    set_capability    acceptInsecureCerts     ${True}
    Create Webdriver  Chrome   options=${chrome_options}
    Set Global Variable    ${GLOBAL_SELENIUM_BROWSER_CAPABILITIES}




Handle Proxy Warning
    [Documentation]    Handle Intermediate Warnings from Proxies
    ${status}    ${data}=    Run Keyword And Ignore Error   Variable Should Exist    ${GLOBAL_PROXY_WARNING_TITLE}
    Return From Keyword if    '${status}' != 'PASS'
    ${status}    ${data}=    Run Keyword And Ignore Error   Variable Should Exist    ${GLOBAL_PROXY_WARNING_CONTINUE_XPATH}
    Return From Keyword if    '${status}' != 'PASS'
    Return From Keyword if    "${GLOBAL_PROXY_WARNING_TITLE}" == ''
    Return From Keyword if    "${GLOBAL_PROXY_WARNING_CONTINUE_XPATH}" == ''
    ${test}    ${value}=    Run keyword and ignore error    Title Should Be     ${GLOBAL_PROXY_WARNING_TITLE}
    Run keyword If    '${test}' == 'PASS'    Click Element    xpath=${GLOBAL_PROXY_WARNING_CONTINUE_XPATH}
