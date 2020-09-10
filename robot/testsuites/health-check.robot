*** Settings ***
Documentation     Test that ONAP components are available via basic API calls
Test Timeout      20 seconds

Library           ONAPLibrary.SO    WITH NAME    SO

Resource          ../resources/dcae_interface.robot
Resource          ../resources/sdnc_interface.robot
Resource          ../resources/aai/aai_interface.robot
Resource          ../resources/vid/vid_interface.robot
Resource          ../resources/policy_interface.robot
Resource          ../resources/sdc_interface.robot
Resource          ../resources/appc_interface.robot
Resource          ../resources/portal_interface.robot
Resource          ../resources/mr_interface.robot
Resource          ../resources/bc_interface.robot
Resource          ../resources/aaf_interface.robot
Resource          ../resources/msb_interface.robot
Resource          ../resources/clamp_interface.robot
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
Resource          ../resources/cds_interface.robot


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
    [Tags]    health-cli    health
    Run CLI Health Check

Basic CLAMP Health Check
    [Tags]    health    medium  health-clamp
    Run CLAMP Health Check

Basic DCAE Health Check
    [Tags]    health    medium   health-dcaegen2
    Run DCAE Health Check

Basic DMAAP Data Router Health Check
    [Tags]    health    datarouter   health-dmaap
    Run DR Health Check

Basic DMAAP Message Router Health Check
    [Tags]    health    core  health-dmaap
    Run MR Health Check

Basic DMAAP Message Router PubSub Health Check
    [Tags]    healthmr    core    health-dmaap
    [Timeout]   30
    Run MR PubSub Health Check

Basic DMAAP Bus Controller Health Check With Basic Auth
    [Tags]    health    health-dmaap
    Run BC Health Check With Basic Auth

Basic External API NBI Health Check
    [Tags]    health    externalapi    api    small
    Run NBI Health Check

Basic Log Elasticsearch Health Check
    [Tags]    oom   health-log
    Run Log Elasticsearch Health Check

Basic Log Kibana Health Check
    [Tags]    oom   health-log
    Run Log Kibana Health Check

Basic Log Logstash Health Check
    [Tags]    oom   health-log
    Run Log Logstash Health Check

Basic Microservice Bus Health Check
    [Tags]    health    small  health-msb
    Run MSB Health Check

Basic Multicloud API Health Check
    [Tags]    health    multicloud    small  health-multicloud
    Run MSB Get Request    /api/multicloud/v0/swagger.json

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

Enhanced Policy New Healthcheck
    [Tags]    health    medium   health-policy
    Run Create Policy Post Request
    Run Get Policy Get Request
    Run Deploy Policy Pap Post Request
    Run Undeploy Policy
    Run Delete Policy Request

Basic Pomba AAI-context-builder Health Check
    [Tags]    oom   health-pomba
    Run Pomba Aai Context Builder Health Check

Basic Pomba SDC-context-builder Health Check
    [Tags]    oom   health-pomba
    Run Pomba Sdc Context Builder Health Check

Basic Pomba Network-discovery-context-builder Health Check
    [Tags]    oom   health-pomba
    Run Pomba Network Discovery Context Builder Health Check

Basic Pomba Service-Decomposition Health Check
    [Tags]    oom   health-pomba
    Run Pomba Service Decomposition Health Check

Basic Pomba Network-Discovery-MicroService Health Check
    [Tags]    oom  health-pomba
    Run Pomba Network Discovery MicroService Health Check

Basic Pomba Pomba-Kibana Health Check
    [Tags]    oom   health-pomba
    Run Pomba Kibana Health Check

Basic Pomba Elastic-Search Health Check
    [Tags]    oom   health-pomba
    Run Pomba Elastic Search Health Check

Basic Pomba Sdnc-Context-Builder Health Check
    [Tags]    oom   health-pomba
    Run Pomba Sdnc Context Builder Health Check

Basic Pomba Context-Aggregator Health Check
    [Tags]    oom   health-pomba
    Run Pomba Context Aggregator Health Check

Basic Portal Health Check
    [Tags]    health    core   health-portal
    Run Portal Health Check

Basic SDC Health Check
    [Tags]    health    core   health-sdc
    Run SDC Health Check

Basic SDNC Health Check
    [Tags]    health    core   health-sdnc
    Run SDNC Health Check

SDNC Health Check - VNF API
    [Tags]    health    core   health-sdnc
    Run SDNC Health Check VNF API

SDNC Health Check - GENERIC-RESOURCE-API
    [Tags]    health    core   health-sdnc
    Run SDNC Health Check Generic Resource API

Basic SO Health Check
    [Tags]    health    core   health-so
    SO.Run Get Request    ${GLOBAL_SO_APIHAND_ENDPOINT}    ${GLOBAL_SO_HEALTH_CHECK_PATH}
    SO.Run Get Request    ${GLOBAL_SO_SDCHAND_ENDPOINT}    ${GLOBAL_SO_HEALTH_CHECK_PATH}
    SO.Run Get Request    ${GLOBAL_SO_BPMN_ENDPOINT}    ${GLOBAL_SO_HEALTH_CHECK_PATH}
    SO.Run Get Request    ${GLOBAL_SO_CATDB_ENDPOINT}    ${GLOBAL_SO_HEALTH_CHECK_PATH}
    SO.Run Get Request    ${GLOBAL_SO_OPENSTACK_ENDPOINT}    ${GLOBAL_SO_HEALTH_CHECK_PATH}
    SO.Run Get Request    ${GLOBAL_SO_REQDB_ENDPOINT}    ${GLOBAL_SO_HEALTH_CHECK_PATH}
    SO.Run Get Request    ${GLOBAL_SO_SDNC_ENDPOINT}    ${GLOBAL_SO_HEALTH_CHECK_PATH}
    SO.Run Get Request    ${GLOBAL_SO_VFC_ENDPOINT}    ${GLOBAL_SO_HEALTH_CHECK_PATH}
    SO.Run Get Request    ${GLOBAL_SO_VNFM_ENDPOINT}    ${GLOBAL_SO_HEALTH_CHECK_PATH}

Basic UseCaseUI API Health Check
    [Tags]    health    api    medium   health-uui
    Run MSB Get Request    /iui/usecaseui/

Basic VFC gvnfmdriver API Health Check
    [Tags]    health    3rdparty   health-vfc
    Run MSB Get Request    /api/gvnfmdriver/v1/health_check

Basic VFC huaweivnfmdriver API Health Check
    [Tags]    health    3rdparty   health-vfc
    Run MSB Get Request    /api/huaweivnfmdriver/v1/swagger.json

Basic VFC nslcm API Health Check
    [Tags]    health    api   health-vfc
    Run MSB Get Request    /api/nslcm/v1/health_check

Basic VFC vnflcm API Health Check
    [Tags]    health    api  health-vfc
    Run MSB Get Request    /api/vnflcm/v1/health_check

Basic VFC vnfmgr API Health Check
    [Tags]    health    api  health-vfc
    Run MSB Get Request    /api/vnfmgr/v1/health_check

Basic VFC vnfres API Health Check
    [Tags]    health    api   health-vfc
    Run MSB Get Request    /api/vnfres/v1/health_check

Basic VFC ztevnfmdriver API Health Check
    [Tags]    health    3rdparty   health-vfc
    Run MSB Get Request    /api/ztevnfmdriver/v1/health_check

Basic VID Health Check
    [Tags]    health    small  health-vid
    [Timeout]    120
    Setup Browser
    Run VID Health Check

Basic VNFSDK Health Check
    [Tags]    health    health-vnfsdk
    Run VNFSDK Health Check

Health Distribution Test
    [Tags]    healthdist
    [Timeout]    1200
    Model Distribution For Directory With Teardown   vFW

Portal Login Tests
    [Tags]    healthlogin
    [Timeout]   120
    Run Portal Login Tests

Portal Application Access Tests
    [Tags]    healthportalapp
    [Timeout]    900
    Run Portal Application Access Tests

Portal SDC Application Access Test
    [Tags]    healthportalapp2
    [Timeout]    180
    Run Portal Application Login Test   cs0008   demo123456!   gridster-SDC-icon-link   tabframe-SDC    Welcome to SDC
    Close All Browsers

Portal VID Application Access Test
    [Tags]    healthportalapp2
    [Timeout]    180
    Run Portal Application Login Test   demo    demo123456!  gridster-Virtual-Infrastructure-Deployment-icon-link   tabframe-Virtual-Infrastructure-Deployment    Welcome to VID
    Close All Browsers

Portal A&AI UI Application Access Test
    [Tags]    healthportalapp2
    [Timeout]    180
    Run Portal Application Login Test   demo    demo123456!  gridster-A&AI-UI-icon-link   tabframe-A&AI-UI    A&AI
    Close All Browsers

Portal Policy Editor Application Access Test
    [Tags]    healthportalapp2
    [Timeout]    180
    Run Portal Application Login Test   demo    demo123456!  gridster-Policy-icon-link   tabframe-Policy    Policy Editor
    Close All Browsers

Portal SO Monitoring Application Access Test
    [Tags]    healthportalapp2
    [Timeout]    180
    Run Portal Application Login Test   demo    demo123456!  gridster-SO-Monitoring-icon-link   tabframe-SO-Monitoring   SO
    Close All Browsers

Portal xDemo APP Application Access Test
    [Tags]    healthportalapp2
    [Timeout]    180
    Run Portal Application Login Test   demo    demo123456!  gridster-xDemo-App-icon-link   tabframe-xDemo-App   xDemo
    Close All Browsers

Portal CLI Application Access Test
    [Tags]    healthportalapp2
    [Timeout]    180
    Run Portal Application Login Test   demo    demo123456!  gridster-CLI-icon-link   tabframe-CLI   CLI
    Close All Browsers


Basic Holmes Rule Management API Health Check
    [Tags]    health-dcaegen2
    Run Holmes Rule Mgmt Healthcheck

Basic Holmes Engine Management API Health Check
    [Tags]    health-dcaegen2
    Run Holmes Engine Mgmt Healthcheck

Basic Multicloud-fcaps API Health Check
    [Tags]    health    multicloud   health-multicloud
    Run MSB Get Request    /api/multicloud-fcaps/v1/healthcheck

Basic Modeling genericparser API Health Check
    [Tags]    health    api   health-modeling
    Run MSB Get Request    /api/parser/v1/health_check

Basic CDS Health Check
    [Tags]    health    medium   health-cds
    Run CDS Health Check
