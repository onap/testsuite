*** Settings ***
Documentation	  Testing ecomp components are available via calls.
...
...	              Testing ecomp components are available via calls.

Resource          ../resources/dcae_interface.robot
Resource          ../resources/sdngc_interface.robot
Resource          ../resources/aai/aai_interface.robot
Resource          ../resources/vid/vid_interface.robot
Resource          ../resources/policy_interface.robot
Resource          ../resources/mso_interface.robot
Resource          ../resources/asdc_interface.robot
Resource          ../resources/appc_interface.robot
Resource          ../resources/portal_interface.robot
Resource          ../resources/mr_interface.robot
Resource          ../resources/aaf_interface.robot

*** Test Cases ***
Wait For ONAP Startup
    [Documentation]   When running healh check for the 1st time after ONAP startup
    ...    use -i waitForOnap -i health 
    ...    This will run HC for up to the timeout (1 hour) before reporting HC failure.  
    [Tags]    waitForONAP
	Wait Until Keyword Succeeds   ${GLOBAL_ONAP_STARTUP_TIMEOUT}   60s   Wait For ONAP
   
Basic DCAE Health Check
    [Tags]    health
	Run DCAE Health Check
	
Basic SDNGC Health Check
    [Tags]    health
	Run SDNGC Health Check
	
Basic A&AI Health Check
    [Tags]    health
	Run A&AI Health Check

Basic Policy Health Check
    [Tags]    health
    Run Policy Health Check
    
Basic MSO Health Check
    [Tags]    health
    Run MSO Health Check
    
Basic ASDC Health Check
    [Tags]    health
    Run ASDC Health Check

Basic APPC Health Check    
    [Tags]    health
    Run APPC Health Check
    
Basic Portal Health Check    
    [Tags]    health
    Run Portal Health Check
	
Basic Message Router Health Check
    [Tags]    health
	Run MR Health Check
	
Basic VID Health Check
    [Tags]    health
	Run VID Health Check



*** Keywords ***
Wait For ONAP
	Run DCAE Health Check
	Run SDNGC Health Check
	Run A&AI Health Check
    Run Policy Health Check
    Run MSO Health Check
    Run ASDC Health Check
    Run APPC Health Check
    Run Portal Health Check
	Run MR Health Check
	Run VID Health Check
    