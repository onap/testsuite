*** Settings ***
Documentation     Testing CLAMP
...
...               Testing ecomp components are available via calls.
Test Timeout      10 second
Resource          ../resources/clamp_interface.robot

*** Test Cases ***
Basic CLAMP Health Check
    [Tags]    clamp
    Run CLAMP Get Model Names

