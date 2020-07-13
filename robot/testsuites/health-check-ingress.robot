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

Resource          ../resources/sms_interface.robot
Resource          ../resources/dr_interface.robot
Resource          ../resources/pomba_interface.robot
Resource          ../resources/holmes_interface.robot
Resource          ../resources/cds_interface.robot

*** Test Cases ***
Basic A&AI Health Check
    [Tags]    health-ingress    core  health-aai-ingress
    Run A&AI Health Check


Basic SDC Health Check
    [Tags]    health-ingress    core   health-sdc-ingress
    Run SDC Health Check

Basic SO Health Check
    [Tags]    health-ingress    core   health-so-ingress
    SO.Run Get Request    ${GLOBAL_SO_APIHAND_ENDPOINT}    ${GLOBAL_SO_HEALTH_CHECK_PATH}
    SO.Run Get Request    ${GLOBAL_SO_VNFM_ENDPOINT}    ${GLOBAL_SO_HEALTH_CHECK_PATH}


Basic CDS Health Check
    [Tags]    health-ingress    medium   health-cds-ingress
    Run CDS Health Check
