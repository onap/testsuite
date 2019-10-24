*** Settings ***
Documentation	  Executes the VNF Orchestration Test cases using GRA API including setup and teardown
...

Resource         ../resources/test_templates/vnf_orchestration_test_template.robot

Test Template         Orchestrate VNF Template

*** Variables ***
${API_TYPE}   GRA_API

*** Test Cases ***              CUSTOMER           SERVICE   PRODUCT_FAMILY

Instantiate Virtual DNS GRA             ETE_Customer    vLB      vLB
    [Tags]    instantiateGRA
Instantiate Virtual Volume Group GRA    ETE_Customer    vVG      vVG
    [Tags]    instantiateGRA
Instantiate Virtual FirewallCL GRA      ETE_Customer    vFWCL      vFWCL
    [Tags]    instantiateGRA

