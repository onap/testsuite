*** Settings ***
Documentation	  Closed Loop Test cases

Resource    ../resources/test_templates/closedloop_test_template.robot

Test Teardown    Teardown Closed Loop

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
    Log To Console    ${EMPTY}
    VFWCL High Test   ${PACKET_GENERATOR_HOST}
    VFWCL Low Test   ${PACKET_GENERATOR_HOST}
    [Teardown]    VFWCL Set To Medium    ${PACKET_GENERATOR_HOST}
