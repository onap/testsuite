*** Settings ***
Test Timeout    5 minutes
Documentation    End-to-end test cases for basic ONAP Portal functionalities
Resource        ../resources/portal-sdk/portalDef.robot
Resource        ../resources/portal_interface.robot
Library         SeleniumLibrary
Suite Teardown  Close All Browsers

*** Test Cases ***

Login into Portal URL
    [TAGS]  portal
    Portal admin Login To Portal GUI

Portal Change REST URL Of X-DemoApp
    [TAGS]  portal
    [Documentation]    Portal Change REST URL Of X-DemoApp
    Portal Change REST URL

Portal R1 Release for AAF
    [TAGS]  portal
    [Documentation]    ONAP Portal R1 functionality for AAF test
    Portal AAF new fields

EP Admin widget layout reset
    [TAGS]  portal
    Reset widget layout option

Validate Functional Top Menu Get Access
    [TAGS]  portal
    Functional Top Menu Get Access

Validate Functional Top Menu Contact Us
    [TAGS]  portal
    Functional Top Menu Contact Us

Edit Functional Menu
    [TAGS]  portal
    Portal admin Edit Functional menu

Create a Test user for Application Admin -Test
    [TAGS]  portal
    ${login_id}    ${email_address}=    Generate Random User    portal
    Portal admin Add Application admin User New user -Test    ${login_id}    ${email_address}

Create a Test User for Application Admin
    [TAGS]  portal
    ${login_id}    ${email_address}=    Generate Random User    demoapp
    Portal admin Add Application admin User New user    ${login_id}    ${email_address}

Add Application Admin for Existing User Test user
    [TAGS]  portal
    ${login_id}    ${email_address}=    Generate Random User    demoapp
    Portal admin Add Application Admin Existing User -APPDEMO    ${login_id}

Create a Test user for Standard User
    [TAGS]  portal
    ${login_id}    ${email_address}=    Generate Random User    demosta
    Portal admin Add Standard User New user    ${login_id}    ${email_address}

Add Application Admin for Existing User
    [TAGS]  portal
    ${login_id}    ${email_address}=    Generate Random User    portal
    Portal admin Add Application Admin Existing User    ${login_id}

Delete Application Admin for Existing User
    [TAGS]  portal
    ${login_id}    ${email_address}=    Generate Random User    portal
    Portal admin Delete Application Admin Existing User    ${login_id}

Logout from Portal GUI as Portal Admin
    [TAGS]  portal
    Portal admin Logout from Portal GUI

# Application Admin user Test cases

Login To Portal GUI as APP Admin
    [TAGS]  portal
    ${login_id}    ${email_address}=    Generate Random User    demoapp
    Application admin Login To Portal GUI    ${login_id}

Logout from Portal GUI as APP Admin
    [TAGS]  portal
    Application admin Logout from Portal GUI

#Standard User Test cases

Logout from Portal GUI as Standard User
    [TAGS]  portal
    Standard User Logout from Portal GUI
    Close All Browsers
