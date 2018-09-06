*** Settings ***
Documentation    This is RobotFrame work script
Resource	../resources/portal-sdk/portalDef.robot
Resource	../resources/portal-sdk/portalSdkDef.robot

*** Test Cases ***
     
Login into Portal URL
    [TAGS]  portal
    Portal admin Login To Portal GUI  
    
# Portal R1 Release
    [TAGS]  portal
   #[Documentation]    ONAP Portal R1 functionality  test
   # Notification on ONAP Portal
   # Portal Application Account Management validation

Portal Change REST URL Of X-DemoApp
    [TAGS]  portal
    [Documentation]    Portal Change REST URL Of X-DemoApp
    Portal Change REST URL
    
Portal R1 Release for AAF
    [TAGS]  portal
    [Documentation]    ONAP Portal R1 functionality for AAF test
    Portal AAF new fields
	  
Create Microse service onboarding
    [TAGS]  portal
	Portal admin Microservice Onboarding
	
#Delete Microse service
    #[TAGS]  portal
	#Portal admin Microservice Delete
   
#Create Widget for all users
    #[TAGS]  portal
#	Portal Admin Create Widget for All users

#Delete Widget for all users
    #[TAGS]  portal
#	Portal Admin Delete Widget for All users
     		
#Create Widget for Application Roles
    #[TAGS]  portal
#	Portal Admin Create Widget for Application Roles
    
#Delete Widget for Application Roles
    #[TAGS]  portal
	#Portal Admin Delete Widget for Application Roles

#EP Admin widget download
    #[TAGS]  portal
	#Admin widget download
    
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
    
Broadbond Notification functionality
    [TAGS]  portal
	${AdminBroadCastMsg}=    Portal Admin Broadcast Notifications
	set global variable    ${AdminBroadCastMsg}
   
Category Notification functionality
    [TAGS]  portal
	${AdminCategoryMsg}=   Portal Admin Category Notifications
	set global variable    ${AdminCategoryMsg}
         
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
    
Add Standard User Role for Existing user
    [TAGS]  portal
	Portal admin Add Standard User Existing user
    
Edit Standard User Role for Existing user
    [TAGS]  portal
	Portal admin Edit Standard User Existing user
    
Delete Standard User Role for Existing user
    [TAGS]  portal
	Portal admin Delete Standard User Existing user

#Add Account new account from App Account Management
    #[TAGS]  portal
	#Portal admin Add New Account
            
#Delete Account new account from App Account Management
    #[TAGS]  portal
	#Portal admin Delete Account

#EP Create Portal Admin
    #[TAGS]  portal
	#Add Portal Admin

#EP Portal Admin delete
    #[TAGS]  portal
    #Delete Portal Admin
	
Logout from Portal GUI as Portal Admin
    [TAGS]  portal
    Portal admin Logout from Portal GUI

# Application Admin user Test cases
	 
Login To Portal GUI as APP Admin
    [TAGS]  portal
	Application admin Login To Portal GUI

#Navigate Functional Link as APP Admin
    #[TAGS]  portal
    #Application Admin Navigation Functional Menu
    
Add Standard User Role for Existing user as APP Admin
    [TAGS]  portal
	Application admin Add Standard User Existing user
    
Edit Standard User Role for Existing user as APP Admin
    [TAGS]  portal
	Application admin Edit Standard User Existing user
    
Delete Standard User Role for Existing user as APP Admin
    [TAGS]  portal
	Application admin Delete Standard User Existing user

#Navigate Application Link as APP Admin
    #[TAGS]  portal
	#Application Admin Navigation Application Link Tab

Logout from Portal GUI as APP Admin
    [TAGS]  portal
	Application admin Logout from Portal GUI
   
#Standard User Test cases
   
Login To Portal GUI as Standared User
    [TAGS]  portal
	Standared user Login To Portal GUI

#Navigate Application Link as Standared User
    #[TAGS]  portal
	#Standared user Navigation Application Link Tab
    
#Navigate Functional Link as Standared User
    #[TAGS]  portal
	#Standared user Navigation Functional Menu
     
#Broadcast Notifications Standared user
    #[TAGS]  portal
	#Standared user Broadcast Notifications    ${AdminBroadCastMsg}
      
#Category Notifications Standared user
    #[TAGS]  portal
	#Standared user Category Notifications    ${AdminCategoryMsg}
      
Logout from Portal GUI as Standared User
    [TAGS]  portal
	Standared User Logout from Portal GUI
    Close All Browsers
    
### SDK Tests Start
#Loginto SDK Portal
#   [TAGS]  portal
#    SDKPortal admin Login To Portal GUI
#
#Navigate to Application link
#   [TAGS]  portal
#    SDKPortalAdmin Navigation Application Link Tab
#
#Validate Sub menu
#   [TAGS]  portal
#    Validate SDK Sub Menu
#
#Validate Sample Pages
#   [TAGS]  portal
#    Click Sample Pages and validate sub Menu
#
##Validate Reports sub Menu
#   [TAGS]  portal
##    Click Reports and validate sub Menu
#
#Validate Profile sub Menu
#   [TAGS]  portal
#    Click Profile and validate sub Menu
#
#Validate Admin sub Menu
#   [TAGS]  portal
#    Click Admin and validate sub Menu
#    Close All Browsers
