*** Settings ***
Documentation	  Executes the VNF Orchestration Test cases including setup and teardown
...

Resource         ../resources/test_templates/vnf_orchestration_test_template.robot

Test Setup            Setup Orchestrate VNF    ${GLOBAL_AAI_CLOUD_OWNER}    ${GLOBAL_OPENSTACK_SERVICE_REGION}    SharedNode    OwnerType    v1    CloudZone  
Test Template         Orchestrate VNF
Test Teardown         Teardown VNF  
    
*** Test Cases ***              CUSTOMER           SERVICE   PRODUCT_FAMILY  LCP_REGION                             TENANT        
Instantiate Virtual Firewall        ETE_Customer    vFW      vFW             ${GLOBAL_OPENSTACK_SERVICE_REGION}    ${TENANT_NAME}          
    [Tags]    ete    instantiate
Instantiate Virtual DNS             ETE_Customer    vLB      vLB             ${GLOBAL_OPENSTACK_SERVICE_REGION}    ${TENANT_NAME}          
    [Tags]    ete    instantiate
Instantiate Virtual Volume Group    ETE_Customer    vVG      vVG             ${GLOBAL_OPENSTACK_SERVICE_REGION}    ${TENANT_NAME}          
    [Tags]    ete    instantiate

   



