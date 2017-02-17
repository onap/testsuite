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
Resource          ../resources/heatbridge.robot

*** Test Cases ***   
Do Teardown
    Execute Heatbridge Teardown    Vfmodule_Ete_Name49a8fbc5-3e94-430d-80d6-a52826961170

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
