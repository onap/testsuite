*** Settings ***
Documentation     Testing ecomp components are available via calls.
...
...               Testing ecomp components are available via calls.
Test Timeout      10 second
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
Resource          ../resources/bc_interface.robot
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
Resource          ../resources/holmes_interface.robot
# Remove other references after a soak period
#Resource          ../resources/vvp_interface.robot

*** Test Cases ***
Basic A&AI Health Check
    [Tags]    health    core  health-aai
    Run A&AI Health Check

Basic AAF Health Check
    [Tags]    health    small  health-aaf
    Run AAF Health Check

Basic AAF SMS Health Check
    [Tags]    health    small  health-aaf
    Run SMS Health Check

Basic APPC Health Check
    [Tags]    health    small   health-appc
    Run APPC Health Check

Basic CLI Health Check
    [Tags]    health    small  health-cli
    Run CLI Health Check

Basic CLAMP Health Check
    [Tags]    health    medium  health-clamp
    Run CLAMP Health Check

Basic DCAE Health Check
    [Tags]    health    medium   health-dcae
    Run DCAE Health Check

Basic DMAAP Data Router Health Check
    [Tags]    health    datarouter   health-dmaap
    Run DR Health Check

Basic DMAAP Message Router Health Check
    [Tags]    health    core  health-dmaap
    Run MR Health Check

Basic DMAAP Message Router PubSub Health Check
    [Tags]    healthmr    health-dmaap
    [Timeout]   30
    Run MR PubSub Health Check

Basic DMAAP Bus Controller Health Check With Basic Auth
    [Tags]    health    health-dmaap
    Run BC Health Check With Basic Auth

Basic External API NBI Health Check
    [Tags]    health    externalapi    api    small
    Run NBI Health Check

Basic Log Elasticsearch Health Check
    [Tags]    health    small    oom   health-log
    Run Log Elasticsearch Health Check

Basic Log Kibana Health Check
    [Tags]    health    small    oom   health-log
    Run Log Kibana Health Check

Basic Log Logstash Health Check
    [Tags]    health    small    oom   health-log
    Run Log Logstash Health Check

Basic Microservice Bus Health Check
    [Tags]    health    small  health-msb
    Run MSB Health Check

Basic Multicloud API Health Check
    [Tags]    health    multicloud    small  health-multicloud
    Run MSB Get Request    /api/multicloud/v0/swagger.json

Basic Multicloud-ocata API Health Check
    [Tags]    health    multicloud    small   health-multicloud
    Run MSB Get Request    /api/multicloud-ocata/v0/swagger.json

Basic Multicloud-pike API Health Check
    [Tags]    health    multicloud    small   health-multicloud
    Run MSB Get Request    /api/multicloud-pike/v0/swagger.json

Basic Multicloud-starlingx API Health Check
    [Tags]    health    multicloud   health-multicloud
    Run MSB Get Request    /api/multicloud-starlingx/v0/swagger.json

Basic Multicloud-titanium_cloud API Health Check
    [Tags]    health    multicloud   health-multicloud
    Run MSB Get Request    /api/multicloud-titaniumcloud/v1/swagger.json

Basic Multicloud-vio API Health Check
    [Tags]    health    multicloud   health-multicloud
    Run MSB Get Request    /api/multicloud-vio/v0/swagger.json

Basic Multicloud-thinkcloud API Health Check
    [Tags]    health    multicloud   health-multicloud
    Run MSB Get Request    /api/multicloud-thinkcloud/v0/swagger.json

Basic Multicloud-k8s API Health Check
    [Tags]    health    multicloud   health-multicloud
    Run MSB Get Request    /api/multicloud-k8s/v1/v1/healthcheck

Basic OOF-Homing Health Check
    [Tags]    health    medium   health-oof
    Run OOF-Homing Health Check

Basic OOF-SNIRO Health Check
    [Tags]    health    medium  health-oof
    Run OOF-SNIRO Health Check

Basic OOF-CMSO Health Check
    [Tags]    health    medium  health-oof
    Run OOF-CMSO Health Check

Basic Policy Health Check
    [Tags]    health    medium   health-policy
    Run Policy Health Check
    Run Policy API Healthcheck
    Run Policy PAP Healthcheck
    Run Policy Distribution Healthcheck
    Run Policy XACML PDP Healthcheck
    Run Policy APEX PDP Healthcheck

Basic Pomba AAI-context-builder Health Check
    [Tags]    health    oom   health-pomba
    Run Pomba Aai Context Builder Health Check

Basic Pomba SDC-context-builder Health Check
    [Tags]    health    oom   health-pomba
    Run Pomba Sdc Context Builder Health Check

Basic Pomba Network-discovery-context-builder Health Check
    [Tags]    health    oom   health-pomba
    Run Pomba Network Discovery Context Builder Health Check

Basic Pomba Service-Decomposition Health Check
    [Tags]    health    oom   health-pomba
    Run Pomba Service Decomposition Health Check

Basic Pomba Network-Discovery-MicroService Health Check
    [Tags]    health    oom  health-pomba
    Run Pomba Network Discovery MicroService Health Check

Basic Pomba Pomba-Kibana Health Check
    [Tags]    health    oom   health-pomba
    Run Pomba Kibana Health Check

Basic Pomba Elastic-Search Health Check
    [Tags]    health    oom   health-pomba
    Run Pomba Elastic Search Health Check

Basic Pomba Sdnc-Context-Builder Health Check
    [Tags]    health    oom   health-pomba
    Run Pomba Sdnc Context Builder Health Check

Basic Pomba Context-Aggregator Health Check
    [Tags]    health    oom   health-pomba
    Run Pomba Context Aggregator Health Check

Basic Portal Health Check
    [Tags]    health    core   health-portal
    Run Portal Health Check

Basic SDC Health Check
    [Tags]    health    core   health-sdc
    Run ASDC Health Check

Basic SDNC Health Check
    [Tags]    health    core   health-sdnc
    Run SDNGC Health Check

Basic SO Health Check
    [Tags]    health    core   health-so
    Run SO Global Health Check

Basic UseCaseUI API Health Check
    [Tags]    health    api    medium   health-uui
    Run MSB Get Request    /iui/usecaseui/

Basic VFC catalog API Health Check
    [Tags]    health    api   health-vfc
    Run MSB Get Request    /api/catalog/v1/swagger.json

Basic VFC emsdriver API Health Check
    [Tags]    health    3rdparty  health-vfc
    Run MSB Get Request    /api/emsdriver/v1/swagger.json

Basic VFC gvnfmdriver API Health Check
    [Tags]    health    3rdparty   health-vfc
    Run MSB Get Request    /api/gvnfmdriver/v1/swagger.json

Basic VFC huaweivnfmdriver API Health Check
    [Tags]    health    3rdparty   health-vfc
    Run MSB Get Request    /api/huaweivnfmdriver/v1/swagger.json

Basic VFC jujuvnfmdriver API Health Check
    [Tags]    health    3rdparty   health-vfc
    Run MSB Get Request    /api/jujuvnfmdriver/v1/swagger.json

Basic VFC multivimproxy API Health Check
    [Tags]    health    3rdparty   health-vfc
    Run MSB Get Request    /api/multivimproxy/v1/swagger.json

Basic VFC nokiav2driver API Health Check
    [Tags]    health    3rdparty   health-vfc
    Run MSB Get Request    /api/NokiaSVNFM/v1/swagger.json

Basic VFC nslcm API Health Check
    [Tags]    health    api   health-vfc
    Run MSB Get Request    /api/nslcm/v1/swagger.json

Basic VFC resmgr API Health Check
    [Tags]    health    api  health-vfc
    Run MSB Get Request    /api/resmgr/v1/swagger.json

Basic VFC vnflcm API Health Check
    [Tags]    health    api  health-vfc
    Run MSB Get Request    /api/vnflcm/v1/swagger.json

Basic VFC vnfmgr API Health Check
    [Tags]    health    api  health-vfc
    Run MSB Get Request    /api/vnfmgr/v1/swagger.json

Basic VFC vnfres API Health Check
    [Tags]    health    api   health-vfc
    Run MSB Get Request    /api/vnfres/v1/swagger.json

Basic VFC workflow API Health Check
    [Tags]    health    api   health-vfc
    Run MSB Get Request    /api/workflow/v1/swagger.json

Basic VFC ztesdncdriver API Health Check
    [Tags]    health    3rdparty   health-vfc
    Run MSB Get Request    /api/ztesdncdriver/v1/swagger.json

Basic VFC ztevnfmdriver API Health Check
    [Tags]    health    3rdparty   health-vfc
    Run MSB Get Request    /api/ztevnfmdriver/v1/swagger.json

Basic VID Health Check
    [Tags]    health    small  health-vid
    Run VID Health Check

Basic VNFSDK Health Check
    [Tags]    health    health-vnfsdk
    Run VNFSDK Health Check

Health Distribution Test
    [Tags]    healthdist
    [Timeout]    1200
    Model Distribution For Directory    vFW

Portal Login Tests
    [Tags]    healthlogin
    Run Portal Login Tests

Portal Application Access Tests
    [Tags]    healthportalapp
    [Timeout]    180
    Run Portal Application Access Tests

Basic Holmes Rule Management API Health Check
    [Tags]    health    medium   health-dcae
    Run Holmes Rule Mgmt Healthcheck

Basic Holmes Engine Management API Health Check
    [Tags]    health    medium   health-dcae
    Run Holmes Engine Mgmt Healthcheck

Basic Multicloud-fcaps API Health Check
    [Tags]    health    multicloud   health-multicloud
    Run MSB Get Request    /api/multicloud-fcaps/v1/healthcheck

Basic Modeling genericparser API Health Check
    [Tags]    health    api   health-modeling
    Run MSB Get Request    /api/parser/v1/health_check
