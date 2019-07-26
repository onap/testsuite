*** Settings ***
Documentation	  Testing sdc.
Library    OperatingSystem
Library    RequestsLibrary
Library    Collections
Resource          ../resources/test_templates/model_test_template.robot

Test Template         Model Distribution For Directory

*** Test Cases ***
Distribute vLB Model    vLB
    [Tags]    distribute   distributeVLB
Distribute vFW Model    vFW
    [Tags]    distribute
Distribute vVG Model    vVG
    [Tags]    distribute
Distribute vFWDT Model    vFWDT
    [Tags]    distributeVFWDT
