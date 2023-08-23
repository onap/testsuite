*** Settings ***
Documentation     Test that ONAP components are available via basic API calls
Test Timeout      100 seconds

Library           ONAPLibrary.SO    WITH NAME    SO

Resource          ../resources/dcae_interface.robot
Resource          ../resources/sdnc_interface.robot
Resource          ../resources/aai/aai_interface.robot
Resource          ../resources/policy_interface.robot
Resource          ../resources/sdc_interface.robot
Resource          ../resources/portal_interface.robot
Resource          ../resources/dmaap/mr_interface.robot
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
Resource          ../resources/dmaap/dr_interface.robot
Resource          ../resources/pomba_interface.robot
Resource          ../resources/holmes_interface.robot
Resource          ../resources/cds_interface.robot
Resource          ../resources/dcae_ms_interface.robot
Resource          ../resources/mariadb_galera_interface.robot
Resource          ../resources/multicloud_interface.robot
Resource          ../resources/uui_interface.robot
Resource          ../resources/vfc_interface.robot
Resource          ../resources/modeling_interface.robot

Suite Teardown     Close All Browsers

*** Test Cases ***
Basic A&AI Health Check
    [Tags]    health    core  health-aai
    Run A&AI Health Check

Enhanced A&AI Health Check
    [Tags]    health    core  health-aai
    Run Resource API AAI Inventory check
    Run Traversal API AAI Inventory check

Basic AAF Health Check
    [Tags]    health-aaf
    Run AAF Health Check

Basic AAF SMS Health Check
    [Tags]    health-aaf
    Run SMS Health Check

Basic CLI Health Check
    [Tags]    health-cli    health
    Run CLI Health Check

Basic CLAMP Health Check
    [Tags]    health-clamp
    Run CLAMP Health Check

Basic DCAE Microservices Health Check
    [Tags]    health    medium   health-dcaegen2-services
    Run DCAE Microservices Health Check

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

Basic External API NBI Health Check
    [Tags]    health    externalapi    api    medium
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
    [Tags]    medium  health-msb
    Run MSB Health Check

Basic Multicloud API Health Check
    [Tags]    health    multicloud    small  health-multicloud
    Run MultiCloud Health Check

Basic Multicloud-pike API Health Check
    [Tags]    health    multicloud    small   health-multicloud
    Run MultiCloud-pike Health Check

Basic Multicloud-starlingx API Health Check
    [Tags]    multicloud   health-multicloud
    Run MultiCloud-starlingx Health Check

Basic Multicloud-titanium_cloud API Health Check
    [Tags]    multicloud   health-multicloud
    Run MultiCloud-titanium_cloud Health Check

Basic Multicloud-vio API Health Check
    [Tags]    multicloud   health-multicloud
    Run MultiCloud-vio Health Check

Basic Multicloud-k8s API Health Check
    [Tags]    health    multicloud   health-multicloud
    Run MultiCloud-k8s Health Check

Basic Multicloud-fcaps API Health Check
    [Tags]    health    multicloud   health-multicloud
    Run MultiCloud-fcaps Health Check

Basic Multicloud-prometheus API Health Check
    [Tags]    multicloud   health-multicloud
    Run MultiCloud-prometheus Health Check

Basic OOF-Homing Health Check
    [Tags]    health    medium   health-oof
    Run OOF-Homing Health Check

Basic OOF-OSDF Health Check
    [Tags]    health    medium  health-oof
    Run OOF-OSDF Health Check

Basic Policy Health Check
    [Tags]    health    medium   health-policy
    Run Policy Health Check

Enhanced Policy New Healthcheck
    [Tags]    health    medium   health-policy
    [Timeout]   60
    Check for Existing Policy and Clean up
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

Basic SDC Health Check
    [Tags]    health    core   health-sdc
    Run SDC Health Check

Enhanced SDC Health Check
    [Tags]    health    core   health-sdc
    Run SDC BE ONBOARD Healthcheck
    Run SDC BE Healthcheck

Basic SDNC Health Check
    [Tags]    health    core   health-sdnc
    Run SDNC Health Check

Enhanced SDNC Health Check
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
    Run UUI Health Check

Basic VFC gvnfmdriver API Health Check
    [Tags]    health    3rdparty   health-vfc
    Run VFC gvnfmdriver Health Check

Basic VFC huaweivnfmdriver API Health Check
    [Tags]    health    3rdparty   health-vfc
    Run VFC huaweivnfmdriver Health Check

Basic VFC nslcm API Health Check
    [Tags]    health    api   health-vfc
    Run VFC nslcm Health Check

Basic VFC vnflcm API Health Check
    [Tags]    health    api  health-vfc
    Run VFC vnflcm Health Check

Basic VFC vnfmgr API Health Check
    [Tags]    health    api  health-vfc
    Run VFC vnfmgr Health Check

Basic VFC vnfres API Health Check
    [Tags]    health    api   health-vfc
    Run VFC vnfres Health Check

Basic VFC ztevnfmdriver API Health Check
    [Tags]    health    3rdparty   health-vfc
    Run VFC ztevnfmdriver Health Check

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
    [Tags]    health-holmes    health
    Run Holmes Rule Mgmt Healthcheck

Basic Holmes Engine Management API Health Check
    [Tags]    health-holmes    health
    Run Holmes Engine Mgmt Healthcheck

Basic Modeling Parser API Health Check
    [Tags]    health    api   health-modeling
    Run Modeling Parser Healthcheck

Enhanced CDS Health Check
    [Tags]    health    small   health-cds
    Run CDS Basic Health Check
    Run CDS Create Data Dictionary Health Check
    Run CDS GET Data Dictionary Health Check
    Run CDS Bootstrap Health Check
    Run CDS Enrich CBA Health Check
    Run CDS Publish CBA Health Check
    Run CDS Process CBA Health Check
    Run CDS Delete CBA Health Check

Mariadb Galera Pod Connectivity Test
    [Tags]    health-mariadb-galera
    Check for Mariadb Galera Pod Connection

Mariadb Galera SO Connectivity Test
    [Tags]    health-mariadb-galera
    Check for SO Databases Connection
