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
    VFWCL Low Test   ${PACKET_GENERATOR_HOST}
    [Teardown]  VFWCL Set To Medium    ${PACKET_GENERATOR_HOST}

VFWCL Repush Operation Policy
    [TAGS]   repushpolicy
    Run Keyword And Ignore Error    Undeploy Policy     operational.modifyconfig
    Update vVFWCL Policy     ${MODEL_INVARIANT_ID}
