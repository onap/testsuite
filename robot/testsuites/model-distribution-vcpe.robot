*** Settings ***
Documentation	  Testing sdc.
Library    OperatingSystem
Library    RequestsLibrary
Library    Collections
Resource          ../resources/test_templates/model_test_template_vcperescust.robot

Test Template         Model Distribution For vCPEResCust Directory

*** Test Cases ***
Distribute vCPEResCust Model    vCPEResCust
    [Tags]    distributevCPEResCust
