*** Settings ***
Test Timeout    5 minute
Documentation    This is RobotFrame work script
Resource	../resources/portal-sdk/portalDef.robot
Resource    ../resources/portal_interface.robot
Library        SeleniumLibrary
Suite Setup     Generate Random User Name
Suite Teardown    Close All Browsers

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
	Portal admin Add Application admin User New user -Test

Create a Test User for Apllication Admin
    [TAGS]  portal
	Portal admin Add Application admin User New user
	 
Add Application Admin for Existing User Test user
    [TAGS]  portal
	Portal admin Add Application Admin Exiting User -APPDEMO

Create a Test user for Standared User
    [TAGS]  portal
	Portal admin Add Standard User New user
    
Add Application Admin for Exisitng User
    [TAGS]  portal
	Portal admin Add Application Admin Exiting User
            
Delete Application Admin for Exisitng User
    [TAGS]  portal
	Portal admin Delete Application Admin Existing User
    
Logout from Portal GUI as Portal Admin
    [TAGS]  portal
    Portal admin Logout from Portal GUI

# Application Admin user Test cases
	 
Login To Portal GUI as APP Admin
    [TAGS]  portal
    Application admin Login To Portal GUI

Logout from Portal GUI as APP Admin
    [TAGS]  portal
	Application admin Logout from Portal GUI
   
#Standard User Test cases
   
Logout from Portal GUI as Standared User
    [TAGS]  portal
	Standared User Logout from Portal GUI
    Close All Browsers
