*** Settings ***
Documentation     Testing CLAMP
...
...               Testing ecomp components are available via calls.
...               ${CURRENT_MODEL_ID} is a testsuite variable used for the context of the test
...               ${CURRENT_CONTROL_LOOP_ID} is a testsuite variable used for the context of the test
Test Timeout      120 second
Resource          ../resources/clamp_interface.robot

*** Test Cases ***
Basic CLAMP Health Check
    [Tags]    clamp
    Run CLAMP Get Model Names
    Run CLAMP Get Control Loop    ${CURRENT_MODEL_ID}
    Run CLAMP Get Properties    ${CURRENT_CONTROL_LOOP_ID}
