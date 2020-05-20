*** Settings ***
Documentation	  Executes the VNF Orchestration Test cases including setup and teardown
...

Resource         ../resources/test_templates/vnf_orchestration_test_template.robot

Test Template         Orchestrate VNF Template

*** Variables ***
${API_TYPE}   VNF_API


*** Test Cases ***              CUSTOMER           SERVICE   PRODUCT_FAMILY
Instantiate Virtual DNS             ETE_Customer    vLB      vLB
    [Tags]    instantiateVNFAPI
Instantiate Virtual Volume Group    ETE_Customer    vVG      vVG
    [Tags]    instantiateVNFAPI
Instantiate Virtual FirewallCL      ETE_Customer    vFWCL      vFWCL
    [Tags]    instantiateVNFAPI
Instantiate Virtual DNS No Delete             ETE_Customer    vLB      vLB          KEEP
    [Tags]    instantiateNoDeleteVNFAPI
Instantiate Virtual FirewallCL No Delete      ETE_Customer    vFWCL      vFWCL         KEEP
    [Tags]    instantiateNoDeleteVNFAPI
