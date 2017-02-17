*** Settings ***
Documentation	  Testing openstack.
Library    String
Library    DNSUtils
Library    Collections
Resource          validate_common.robot


*** Variables ***
${ASSETS}              ${EXECDIR}/robot/assets/

*** Keywords ***
Validate vVG Stack 
    [Documentation]    Identifies the LB and DNS servers in the vLB stack in the GLOBAL_OPENSTACK_SERVICE_REGION
    [Arguments]    ${stack_name}    
    Log    All server processes up

