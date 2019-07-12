*** Settings ***
Documentation	  Executes the VNF Orchestration Test cases including setup and teardown
...

Resource         ../resources/test_templates/vnf_orchestration_test_template.robot

Test Template         Orchestrate VNF Template

*** Test Cases ***              CUSTOMER           SERVICE   PRODUCT_FAMILY
Instantiate Virtual DNS             ETE_Customer    vLB      vLB             
    [Tags]    instantiate  stability72hr
Instantiate Virtual Volume Group    ETE_Customer    vVG      vVG             
    [Tags]    instantiate  stability72hr
Instantiate Virtual FirewallCL      ETE_Customer    vFWCL      vFWCL        
    [Tags]    instantiate  stability72hr
Instantiate Virtual DNS No Delete             ETE_Customer    vLB      vLB          KEEP
    [Tags]    instantiateNoDelete
Instantiate Virtual FirewallCL No Delete      ETE_Customer    vFWCL      vFWCL         KEEP
    [Tags]    instantiateNoDelete
Instantiate Virtual Firewall        ETE_Customer    vFW      vFW





