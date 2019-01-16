*** Settings ***
Documentation     Testing CLAMP
...
...               Testing ecomp components are available via calls.
Test Timeout      120 second
Resource          ../resources/clamp_interface.robot

*** Test Cases ***
Basic CLAMP Health Check
    [Tags]    clamp
    Run CLAMP Get Model Names
    Run CLAMP Get Control Loop    CLAMPT2VLB_v2_0_vLB0605c122-90f10
    Run CLAMP Get Properties    5fcdb3b7-5a5b-45da-83f6-14cce29181c8
