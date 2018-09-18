*** Settings ***
Documentation	  Executes the VNF Orchestration with CDS Test cases including setup and teardown
...

Resource         ../resources/test_templates/vnf_orchestration_with_cds_test_template.robot

Test Template         Orchestrate VNF With CDS Template

*** Test Cases ***              CUSTOMER           SERVICE   PRODUCT_FAMILY  TENANT
Instantiate Virtual vFW With CDS           ETE_Customer    vFW      vFW             ${TENANT_NAME}
    [Tags]    cds

