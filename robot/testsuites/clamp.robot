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
    # model_name and template_name will be inputs or config after testing
    Run CLAMP Create Model   ControlLoopTest3     DCAE-Designer-Template-CLAMPT2VLB_v2_0_vLB0605c122-90f10
