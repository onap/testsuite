*** Settings ***
Documentation	  Closed Loop Test cases

Resource    ../resources/test_templates/closedloop_test_template.robot

Test Teardown    Teardown Closed Loop

*** Test Cases ***

VFW Closed Loop Test
    [TAGS]    closedloop    vfwcl
    VFW Policy
VDNS Closed Loop Test
    [TAGS]    closedloop    vdnscl
    VDNS Policy
VFWCL Closed Loop Test
    [TAGS]    vfwclosedloop
    VFWCL High Test   ${pkg_host}
    VFWCL Low Test   ${pkg_host}
