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
Resource          ../resources/msb_interface.robot
Resource          ../resources/clamp_interface.robot

*** Test Cases ***   
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

Basic Microservice Bus Health Check
    [Tags]    health
    Run MSB Health Check

Basic CLAMP Health Check
    [Tags]    health
    Run CLAMP Health Check

catalog API Health Check
     [Tags]    health
     Run MSB Get Request  /api/catalog/v1/swagger.json

emsdriver API Health Check
     [Tags]    health
     Run MSB Get Request  /api/emsdriver/v1/swagger.json

gvnfmdriver API Health Check
     [Tags]    health
     Run MSB Get Request  /api/gvnfmdriver/v1/swagger.json

huaweivnfmdriver API Health Check
     [Tags]    health
     Run MSB Get Request  /api/huaweivnfmdriver/v1/swagger.json

multicloud API Health Check
     [Tags]    health
     Run MSB Get Request  /api/multicloud/v0/swagger.json

multicloud-ocata API Health Check
     [Tags]    health
     Run MSB Get Request  /api/multicloud-ocata/v0/swagger.json

multicloud-titanium_cloud API Health Check
     [Tags]    health
     Run MSB Get Request  /api/multicloud-titanium_cloud/v0/swagger.json

multicloud-vio API Health Check
     [Tags]    health
     Run MSB Get Request  /api/multicloud-vio/v0/swagger.json

nokiavnfmdriver API Health Check
     [Tags]    health
     Run MSB Get Request  /api/nokiavnfmdriver/v1/swagger.json

nslcm API Health Check
     [Tags]    health
     Run MSB Get Request  /api/nslcm/v1/swagger.json

resmgr API Health Check
     [Tags]    health
     Run MSB Get Request  /api/resmgr/v1/swagger.json

usecaseui-gui API Health Check
     [Tags]    health
     Run MSB Get Request  /iui/usecaseui/

vnflcm API Health Check
     [Tags]    health
     Run MSB Get Request  /api/vnflcm/v1/swagger.json

vnfmgr API Health Check
     [Tags]    health
     Run MSB Get Request  /api/vnfmgr/v1/swagger.json

vnfres API Health Check
     [Tags]    health
     Run MSB Get Request  /api/vnfres/v1/swagger.json

workflow API Health Check
     [Tags]    health
     Run MSB Get Request  /api/workflow/v1/swagger.json

ztesdncdriver API Health Check
     [Tags]    health
     Run MSB Get Request  /api/ztesdncdriver/v1/swagger.json

ztevmanagerdriver API Health Check
     [Tags]    health
     Run MSB Get Request  /api/ztevmanagerdriver/v1/swagger.json
