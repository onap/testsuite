*** Settings ***
Documentation	  Executes the VNF Orchestration Test cases including setup and teardown
...

Resource         ../resources/test_templates/vnf_orchestration_test_template.robot

Test Setup            Setup Orchestrate VNF    ${GLOBAL_AAI_CLOUD_OWNER}    SharedNode    OwnerType    v1    CloudZone
Test Template         Orchestrate VNF Template
Test Teardown         Teardown VNF

*** Test Cases ***              CUSTOMER           SERVICE   PRODUCT_FAMILY  TENANT
Instantiate Virtual DNS             ETE_Customer    vLB      vLB             ${TENANT_NAME}
    [Tags]    ete    instantiate  stability72hr
Instantiate Virtual Volume Group    ETE_Customer    vVG      vVG             ${TENANT_NAME}
    [Tags]    ete    instantiate  stability72hr
Instantiate Virtual FirewallCL      ETE_Customer    vFWCL      vFWCL         ${TENANT_NAME}
    [Tags]    ete    instantiate  stability72hr
Instantiate Virtual Firewall        ETE_Customer    vFW      vFW             ${TENANT_NAME}





