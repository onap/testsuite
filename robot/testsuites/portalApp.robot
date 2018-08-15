*** Settings ***
Documentation    This is RobotFrame work script
Resource	../resources/portal-sdk/portalDef.robot

*** Test Cases ***

Portal Health Check    
     Run Portal Health Check
     
Login into Portal URL   
    Portal admin Login To Portal GUI  
    
## Portal R1 Release
#   # [Documentation]    ONAP Portal R1 functionality  test
#    # Notification on ONAP Portal
#    # Portal Application Account Management validation

#Portal Change REST URL Of X-DemoApp
#   [Documentation]    Portal Change REST URL Of X-DemoApp    
#      Portal Change REST URL
    
#Portal R1 Release for AAF
#   [Documentation]    ONAP Portal R1 functionality for AAF test    
#      Portal AAF new fields    
	  
#Create Microse service onboarding
#	Portal admin Microservice Onboarding
	
###Delete Microse service
#	##Portal admin Microservice Delete
   
#Create Widget for all users
#	Portal Admin Create Widget for All users 

#Delete Widget for all users
#	Portal Admin Delete Widget for All users    
     		
#Create Widget for Application Roles
#	Portal Admin Create Widget for Application Roles
    
##Delete Widget for Application Roles
#	#Portal Admin Delete Widget for Application Roles	

##EP Admin widget download
#	#Admin widget download
    
#EP Admin widget layout reset
#	Reset widget layout option   

#Validate Functional Top Menu Get Access    
#	Functional Top Menu Get Access  
    
#Validate Functional Top Menu Contact Us      
#	Functional Top Menu Contact Us
    
#Edit Functional Menu    
#	Portal admin Edit Functional menu
    
#Broadbond Notification functionality 
#	${AdminBroadCastMsg}=    Portal Admin Broadcast Notifications 
#	set global variable    ${AdminBroadCastMsg}   
   
#Category Notification functionality 
#	${AdminCategoryMsg}=   Portal Admin Category Notifications
#	set global variable    ${AdminCategoryMsg} 	
         
#Create a Test user for Application Admin -Test
#	Portal admin Add Application admin User New user -Test
	 
#Create a Test User for Apllication Admin
#	Portal admin Add Application admin User New user	 
	 
#Add Application Admin for Existing User Test user 
#	Portal admin Add Application Admin Exiting User -APPDEMO	 
 
#Create a Test user for Standared User    
#	Portal admin Add Standard User New user
    
#Add Application Admin for Exisitng User   
#	Portal admin Add Application Admin Exiting User 
            
#Delete Application Admin for Exisitng User   
#	Portal admin Delete Application Admin Existing User
    
#Add Standard User Role for Existing user 
#	Portal admin Add Standard User Existing user     
    
#Edit Standard User Role for Existing user
#	Portal admin Edit Standard User Existing user 
    
#Delete Standard User Role for Existing user    
#	Portal admin Delete Standard User Existing user 

##Add Account new account from App Account Management
#	#Portal admin Add New Account
            
##Delete Account new account from App Account Management
#	#Portal admin Delete Account

##EP Create Portal Admin
#	#Add Portal Admin	

##EP Portal Admin delete
#    #Delete Portal Admin	
	
#Logout from Portal GUI as Portal Admin
#    Portal admin Logout from Portal GUI

## Application Admin user Test cases 
	 
#Login To Portal GUI as APP Admin    
#	Application admin Login To Portal GUI
        
##Navigate Functional Link as APP Admin  
	##Application Admin Navigation Functional Menu   
    
#Add Standard User Role for Existing user as APP Admin
#	Application admin Add Standard User Existing user    
    
#Edit Standard User Role for Existing user as APP Admin
#	Application admin Edit Standard User Existing user 
    
#Delete Standard User Role for Existing user as APP Admin   
#	Application admin Delete Standard User Existing user 
	 
##Navigate Application Link as APP Admin  
#	#Application Admin Navigation Application Link Tab 	 

#Logout from Portal GUI as APP Admin   
#	Application admin Logout from Portal GUI
   
##Standard User Test cases
   
#Login To Portal GUI as Standared User    
#	Standared user Login To Portal GUI   

##Navigate Application Link as Standared User  
#	#Standared user Navigation Application Link Tab 
    
##Navigate Functional Link as Standared User  
#	#Standared user Navigation Functional Menu     
     
##Broadcast Notifications Standared user
#	#Standared user Broadcast Notifications    ${AdminBroadCastMsg} 
      
##Category Notifications Standared user
#	#Standared user Category Notifications    ${AdminCategoryMsg}      
      
#Logout from Portal GUI as Standared User
#	Standared User Logout from Portal GUI

Teardown  
     [Documentation]    Close All Open browsers     
     Close All Browsers    
    
