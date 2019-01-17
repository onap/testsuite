*** Settings ***
Documentation     Testing CLAMP
...
...               Testing ecomp components are available via calls.
Test Timeout      120 second
Resource          ../resources/clamp_interface.robot

*** Test Cases ***
Basic CLAMP Health Check
    [Tags]    clamp
    ${current_model_id}=   Run CLAMP Get Model Names
    ${current_control_loop_id}=   Run CLAMP Get Control Loop    ${current_model_id}
    Run CLAMP Get Properties    ${current_control_loop_id}

