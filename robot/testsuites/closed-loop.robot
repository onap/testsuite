*** Settings ***
Documentation	  Closed Loop Test cases

Resource    ../resources/test_templates/closedloop_test_template.robot

*** Variables ***
${PACKET_GENERATOR_HOST}

*** Test Cases ***
VFW Closed Loop Test
    [TAGS]    closedloop    vfwcl
    VFW Policy

VDNS Closed Loop Test
    [TAGS]    closedloop    vdnscl
    VDNS Policy

VFWCL Closed Loop Test
    [TAGS]    vfwclosedloop
    Log     ${EMPTY}
    VFWCL High Test   ${PACKET_GENERATOR_HOST}
    Sleep  60
    VFWCL Low Test   ${PACKET_GENERATOR_HOST}
    [Teardown]  VFWCL Set To Medium    ${PACKET_GENERATOR_HOST}

VFWCL Repush Monitoring And Operational Policies
    [TAGS]   repushpolicy
    Validate the vFWCL Policy
    Run Keyword And Ignore Error     Run Undeploy vFW Monitoring Policy
    Validate the vFWCL Policy
    Run Keyword And Ignore Error     Run Undeploy Policy
    Validate the vFWCL Policy
    Run Keyword and Ignore Error     Run Delete vFW Monitoring Policy
    Validate the vFWCL Policy
    Run Keyword And Ignore Error     Run Delete vFW Operational Policy
    Validate the vFWCL Policy
    Update vVFWCL Policy     ${MODEL_INVARIANT_ID}
    Validate the vFWCL Policy
