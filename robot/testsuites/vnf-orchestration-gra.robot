*** Settings ***
Documentation	  Executes the VNF Orchestration Test cases using GRA API including setup and teardown
...

Resource         ../resources/test_templates/vnf_orchestration_test_template.robot

Test Template         Orchestrate VNF Template

*** Variables ***
${API_TYPE}   GRA_API

*** Test Cases ***              CUSTOMER           SERVICE   PRODUCT_FAMILY

Instantiate Virtual DNS GRA             ETE_Customer    vLB      vLB
    [Tags]    instantiateGRA    instantiate  stability72hr   stability72hrvLB
Instantiate Virtual Volume Group GRA    ETE_Customer    vVG      vVG
    [Tags]    instantiateGRA    instantiate  stability72hr   stability72hrvVG
Instantiate Virtual FirewallCL GRA      ETE_Customer    vFWCL      vFWCL
    [Tags]    instantiateGRA    instantiate  stability72hr   stability72hrvFWCL
Instantiate Virtual DNS GRA No Delete             ETE_Customer    vLB      vLB          KEEP
    [Tags]    instantiateNoDelete   instantiateNoDeleteVLB
Instantiate Virtual FirewallCL GRA No Delete      ETE_Customer    vFWCL      vFWCL         KEEP
    [Tags]    instantiateNoDelete    instantiateNoDeleteVFWCL
