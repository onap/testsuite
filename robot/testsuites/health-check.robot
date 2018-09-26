*** Settings ***
Test Timeout    1 minute
Documentation    Testing ecomp components are available via calls.
...
...                Testing ecomp components are available via calls.

Resource          ../resources/dcae_interface.robot
Resource          ../resources/sdngc_interface.robot
Resource          ../resources/aai/aai_interface.robot
Resource          ../resources/vid/vid_interface.robot
Resource          ../resources/policy_interface.robot
Resource          ../resources/so_interface.robot
Resource          ../resources/asdc_interface.robot
Resource          ../resources/appc_interface.robot
Resource          ../resources/portal_interface.robot
Resource          ../resources/mr_interface.robot
Resource          ../resources/aaf_interface.robot
Resource          ../resources/msb_interface.robot
Resource          ../resources/clamp_interface.robot
Resource          ../resources/music/music_interface.robot
Resource          ../resources/test_templates/model_test_template.robot
Resource          ../resources/nbi_interface.robot
Resource          ../resources/cli_interface.robot
Resource          ../resources/vnfsdk_interface.robot
Resource          ../resources/log_interface.robot
Resource          ../resources/oof_interface.robot
Resource          ../resources/sms_interface.robot
Resource          ../resources/dr_interface.robot
Resource          ../resources/pomba_interface.robot

*** Test Cases ***
Basic A&AI Health Check
    [Tags]    health    core
    Run A&AI Health Check

Basic AAF Health Check
    [Tags]    health    core
    Run AAF Health Check

Basic AAF SMS Health Check
    [Tags]    health    core
    Run SMS Health Check

Basic APPC Health Check
    [Tags]    health    core
    Run APPC Health Check

Basic CLI Health Check
    [Tags]    health    core
    Run CLI Health Check

Basic CLAMP Health Check
    [Tags]    health    core
    Run CLAMP Health Check

Basic DCAE Health Check
    [Tags]    health    dcae
    Run DCAE Health Check

Basic DMAAP Data Router Health Check
    [Tags]    health    core  datarouter
    Run DR Health Check

Basic DMAAP Message Router Health Check
    [Tags]    health    core
    Run MR Health Check

Basic External API NBI Health Check
    [Tags]    health    externalapi    api
    Run NBI Health Check

Basic Log Elasticsearch Health Check
    [Tags]    health    core    oom
    Run Log Elasticsearch Health Check

Basic Log Kibana Health Check
    [Tags]    health    core    oom
    Run Log Kibana Health Check

Basic Log Logstash Health Check
    [Tags]    health    core   oom
    Run Log Logstash Health Check

Basic Microservice Bus Health Check
    [Tags]    health    core
    Run MSB Health Check

Basic Multicloud API Health Check
    [Tags]    health    multicloud
    Run MSB Get Request  /api/multicloud/v0/swagger.json

Basic Multicloud-ocata API Health Check
    [Tags]    health    multicloud
    Run MSB Get Request  /api/multicloud-ocata/v0/swagger.json

Basic Multicloud-titanium_cloud API Health Check
    [Tags]    health    multicloud
    Run MSB Get Request  /api/multicloud-titaniumcloud/v1/swagger.json

Basic Multicloud-vio API Health Check
     [Tags]    health    multicloud
     Run MSB Get Request  /api/multicloud-vio/v0/swagger.json

Basic OOF-Homing Health Check
    [Tags]    health    core
    Run OOF-Homing Health Check

Basic OOF-SNIRO Health Check
    [Tags]    health    core
    Run OOF-SNIRO Health Check

Basic Policy Health Check
    [Tags]    health    core
    Run Policy Health Check

Basic Pomba AAI-context-builder Health Check
    [Tags]    health    core    oom
    Run Pomba Aai Context Builder Health Check

Basic Pomba SDC-context-builder Health Check
    [Tags]    health    core    oom
    Run Pomba Sdc Context Builder Health Check

Basic Pomba Network-discovery-context-builder Health Check
    [Tags]    health    core    oom
    Run Pomba Network Discovery Context Builder Health Check

Basic Portal Health Check
    [Tags]    health    core
    Run Portal Health Check

Basic SDC Health Check
    [Tags]    health    core
    Run ASDC Health Check

Basic SDNC Health Check
    [Tags]    health    core
    Run SDNGC Health Check

Basic SO Health Check
    [Tags]    health    core
    Run SO Global Health Check

Basic UseCaseUI API Health Check
     [Tags]    health    api
     Run MSB Get Request  /iui/usecaseui/

Basic VFC catalog API Health Check
    [Tags]    health    api
    Run MSB Get Request  /api/catalog/v1/swagger.json

Basic VFC emsdriver API Health Check
    [Tags]    health    3rdparty
    Run MSB Get Request  /api/emsdriver/v1/swagger.json

Basic VFC gvnfmdriver API Health Check
    [Tags]    health    3rdparty
    Run MSB Get Request  /api/gvnfmdriver/v1/swagger.json

Basic VFC huaweivnfmdriver API Health Check
    [Tags]    health    3rdparty
    Run MSB Get Request  /api/huaweivnfmdriver/v1/swagger.json

Basic VFC jujuvnfmdriver API Health Check
    [Tags]    health    3rdparty
    Run MSB Get Request  /api/jujuvnfmdriver/v1/swagger.json

Basic VFC multivimproxy API Health Check
    [Tags]    health    3rdparty
    Run MSB Get Request  /api/multivimproxy/v1/swagger.json

Basic VFC nokiavnfmdriver API Health Check
     [Tags]    health    3rdparty
     Run MSB Get Request  /api/nokiavnfmdriver/v1/swagger.json

Basic VFC nokiav2driver API Health Check
     [Tags]    health    3rdparty
     Run MSB Get Request  /api/NokiaSVNFM/v1/swagger.json

Basic VFC nslcm API Health Check
     [Tags]    health    api
     Run MSB Get Request  /api/nslcm/v1/swagger.json

Basic VFC resmgr API Health Check
     [Tags]    health    api
     Run MSB Get Request  /api/resmgr/v1/swagger.json

Basic VFC vnflcm API Health Check
     [Tags]    health    api
     Run MSB Get Request  /api/vnflcm/v1/swagger.json

Basic VFC vnfmgr API Health Check
     [Tags]    health    api
     Run MSB Get Request  /api/vnfmgr/v1/swagger.json

Basic VFC vnfres API Health Check
     [Tags]    health    api
     Run MSB Get Request  /api/vnfres/v1/swagger.json

Basic VFC workflow API Health Check
     [Tags]    health    api
     Run MSB Get Request  /api/workflow/v1/swagger.json

Basic VFC ztesdncdriver API Health Check
     [Tags]    health    3rdparty
     Run MSB Get Request  /api/ztesdncdriver/v1/swagger.json

Basic VFC ztevnfmdriver API Health Check
     [Tags]    health    3rdparty
     Run MSB Get Request  /api/ztevnfmdriver/v1/swagger.json

Basic VID Health Check
    [Tags]    health    core
    Run VID Health Check

Basic VNFSDK Health Check
    [Tags]    health    core
    Run VNFSDK Health Check

Health Distribution Test
    [Tags]    healthdist
    [Timeout]   600
    Model Distribution For Directory    vFW

Portal Login Tests
    [Tags]    healthlogin
    Run Portal Login Tests

Portal Application Access Tests
    [Tags]    healthportalapp
    [Timeout]   180
    Run Portal Application Access Tests
