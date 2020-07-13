*** Settings ***
Documentation     Test that ONAP components are available via basic API calls
Test Timeout      20 seconds

Library           ONAPLibrary.SO    WITH NAME    SO

Resource          ../resources/aai/aai_interface.robot
Resource          ../resources/sdc_interface.robot
Resource          ../resources/cds_interface.robot

*** Test Cases ***
Basic A&AI Health Check
    [Tags]    health-ingress    health-aai-ingress
    Run A&AI Health Check


Basic SDC Health Check
    [Tags]    health-ingress    health-sdc-ingress
    Run SDC Health Check

Basic SO Health Check
    [Tags]    health-ingress    core   health-so-ingress
    SO.Run Get Request    ${GLOBAL_SO_APIHAND_ENDPOINT}    ${GLOBAL_SO_HEALTH_CHECK_PATH}
    SO.Run Get Request    ${GLOBAL_SO_VNFM_ENDPOINT}    ${GLOBAL_SO_HEALTH_CHECK_PATH}


Basic CDS Health Check
    [Tags]    health-ingress    health-cds-ingress
    Run CDS Health Check
