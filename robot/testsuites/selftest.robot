*** Settings ***
Documentation     Operability check for Robot framework container.
Library           ExtendedSelenium2Library

*** Variables ***
${CHROME_DRIVER_CONTAINER_BINARY_PATH}    /usr/lib/chromium-browser/chromedriver
${URL_TO_CHECK}   https://google.com
${TITLE_TO_EXPECT}    Google

*** Keywords ***
Setup Chromium Browser
    [Documentation]    Opens chromium-browser to a given page with options set.
    ${chrome_options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys
    Call Method    ${chrome_options}    add_argument    no-sandbox
    Create Webdriver    Chrome    chrome_options=${chrome_options}    executable_path=${CHROME_DRIVER_CONTAINER_BINARY_PATH}
    
Open URL
    [Arguments]    ${URL}
    Go To    ${URL}

Check Title
    [Arguments]    ${EXPECTED}
    ${title} =    Get Title
    Should Start With    ${title}    ${EXPECTED}

Teardown
    Close All Browsers

*** Test Cases ***
Open google.com page to verify that framework is operable.
    [Tags]    selftest
    Setup Chromium Browser
    Open URL    ${URL_TO_CHECK}
    Check Title    ${TITLE_TO_EXPECT}
    Teardown
