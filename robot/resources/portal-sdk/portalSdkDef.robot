*** Settings ***
Documentation    This is RobotFrame work script
Library    SeleniumLibrary


*** Keywords ***

Validate SDK Sub Menu
    [Documentation]    Logs into SDK GUI as Portal admin
    Page Should Contain    Home
    Page Should Contain    Sample Pages
    Page Should Contain    Reports
    Page Should Contain    Profile
    Page Should Contain    Admin

Click Sample Pages and validate sub Menu
    [Documentation]    Click Sample Pages
    Comment    Select frame    xpath=.//*[@id='tabframe-xDemo-App']
    Click Link    xpath=//a[@id='parent-item-Sample-Pages']
    Element Text Should Be    xpath=//a[@title='Collaboration']    Collaboration
    Element Text Should Be    xpath=//a[@title='Notebook']    Notebook
    Click Link    xpath=//a[contains(@title,'Collaboration')]
    Page Should Contain    User List
    Comment    Select frame    xpath=.//*[@id='tabframe-xDemo-App']
    Click Link    xpath=//a[@id='parent-item-Sample-Pages']
    Click Link    xpath=//a[contains(@title,'Notebook')]
    Element Text Should Be    xpath=//h1[contains(.,'Notebook')]    Notebook

Click Reports and validate sub Menu
     [Documentation]    Click Reports Tab
     #Select frame    xpath=.//*[@id='tabframe-xDemo-App']
     Click Link    xpath=//a[@id='parent-item-Reports']
     Element Text Should Be    xpath=//a[@title='All Reports']    All Reports
     Element Text Should Be    xpath=//a[@title='Create Reports']    Create Reports
     Click Link    xpath=//a[contains(@title,'All Reports')]
     Page Should Contain    Report search
     Comment    Select frame    xpath=.//*[@id='tabframe-xDemo-App']
     Click Link    xpath=//a[@id='parent-item-Reports']
     Click Link    xpath=//a[contains(@title,'Create Reports')]
     Page Should Contain    Report Wizard

Click Profile and validate sub Menu
    [Documentation]    Click Profile Tab
    Comment    Select frame    xpath=.//*[@id='tabframe-xDemo-App']
    Click Link    xpath=//a[@id='parent-item-Profile']
    Element Text Should Be    xpath=//a[@title='Search']    Search
    Element Text Should Be    xpath=//a[@title='Self']    Self
    Click Link    xpath=//a[contains(@title,'Search')]
    Page Should Contain    Profile Search
    Comment    Select frame    xpath=.//*[@id='tabframe-xDemo-App']
    Click Link    xpath=//a[@id='parent-item-Profile']
    Click Link    xpath=//a[contains(@title,'Self')]
    Page Should Contain    Self Profile Detail

Click Admin and validate sub Menu
    [Documentation]    Click Admin Tab
    Comment    Select frame    xpath=.//*[@id='tabframe-xDemo-App']
    Click Link    xpath=//a[@id='parent-item-Admin']
    Element Text Should Be    xpath=//a[@title='Roles']    Roles
    Element Text Should Be    xpath=//a[@title='Role Functions']    Role Functions
    Element Text Should Be    xpath=//a[@title='Cache Admin']    Cache Admin
    Element Text Should Be    xpath=//a[@title='Menus']    Menus
    Element Text Should Be    xpath=//a[@title='Usage']    Usage
    Click Link    xpath=//a[contains(@title,'Roles')]
    Page Should Contain    Roles
    Comment    Select frame    xpath=.//*[@id='tabframe-xDemo-App']
    Click Link    xpath=//a[@id='parent-item-Admin']
    Click Link    xpath=//a[contains(@title,'Role Function')]
    Page Should Contain    Role Function
    Comment    Select frame    xpath=.//*[@id='tabframe-xDemo-App']
    Click Link    xpath=.//a[@id='parent-item-Admin']
    #Select frame    xpath=.//*[@id='tabframe-xDemo-App']
    Click Link    xpath=//a[@id='parent-item-Admin']
    Click Link    xpath=//a[contains(@title,'Cache Admin')]
    Page Should Contain    Cache Regions
    Comment    Select frame    xpath=.//*[@id='tabframe-xDemo-App']
    Click Link    xpath=.//a[@id='parent-item-Admin']
    Click Link    xpath=//a[@id='parent-item-Admin']
    Click Link    xpath=//a[contains(@title,'Menus')]
    Page Should Contain    Admin Menu Items
    Comment    Select frame    xpath=.//*[@id='tabframe-xDemo-App']
    Click Link    xpath=//a[@id='parent-item-Admin']
    Click Link    xpath=//a[@id='parent-item-Admin']
    Click Link    xpath=//a[contains(@title,'Usage')]
    Page Should Contain    Current Usage