*** Settings ***
Documentation	  Executes the VNF Orchestration Test cases including setup and teardown
...

Library    Collections
Library    OperatingSystem

Resource         ../resources/demo_preload.robot
Resource         ../resources/test_templates/vnf_orchestration_test_template.robot

*** Variables ***

${VNF_NAME}       DemoVNF
${MODULE_NAME}    DemoModuleName

*** Test Cases ***        
Initialize Customer And Models
    [Tags]   InitDemo          
    Load Customer And Models   Demonstration     

Preload VNF
    [Tags]   PreloadDemo          
    Preload Demo   ${VNF_NAME}   ${MODULE_NAME}      
   
Create APPC Mount Point
    [Tags]   APPCMountPointDemo          
    APPC Mount Point    ${MODULE_NAME}      



Instantiate VFW
    [Tags]   instantiateVFW
    Setup Orchestrate VNF    ${GLOBAL_AAI_CLOUD_OWNER}    SharedNode    OwnerType    v1    CloudZone
    ${vf_module_name}    ${service}=    Orchestrate VNF    DemoCust    vFW      vFW    ${TENANT_NAME}
    Save For Delete
    Log to Console   Customer Name=${CUSTOMER_NAME}
    Log to Console   VNF Module Name=${vf_module_name}

Delete Instantiated VNF
    [Documentation]   This test assumes all necessary variables are loaded via the variable file create in  Save For Delete
    [Tags]   deleteVNF
    Setup Browser
    Login To VID GUI
    Delete VNF
    [Teardown]   Teardown VNF
    

*** Keywords ***
Save For Delete
    [Documentation]   Create a variable file to be loaded for save for delete
    ${dict}=    Create Dictionary
    Set To Dictionary   ${dict}   TENANT_NAME=${TENANT_NAME}
    Set To Dictionary   ${dict}   TENANT_ID=${TENANT_ID}
    Set To Dictionary   ${dict}   CUSTOMER_NAME=${CUSTOMER_NAME}
    Set To Dictionary   ${dict}   STACK_NAME=${STACK_NAME}
    Set To Dictionary   ${dict}   SERVICE=${SERVICE}
    Set To Dictionary   ${dict}   VVG_SERVER_ID=${VVG_SERVER_ID}
    Set To Dictionary   ${dict}   SERVICE_INSTANCE_ID=${SERVICE_INSTANCE_ID}
    
    Set To Dictionary   ${dict}   VLB_CLOSED_LOOP_DELETE=${VLB_CLOSED_LOOP_DELETE}
    Set To Dictionary   ${dict}   VLB_CLOSED_LOOP_VNF_ID=${VLB_CLOSED_LOOP_VNF_ID}
   
    Set To Dictionary   ${dict}   CATALOG_SERVICE_ID=${CATALOG_SERVICE_ID}

    ${vars}=    Catenate
    ${keys}=   Get Dictionary Keys    ${dict}
    :for   ${key}   in   @{keys}
    \    ${value}=   Get From Dictionary   ${dict}   ${key}
    \    ${vars}=   Catenate   ${vars}${key} = "${value}"\n
    
    ${comma}=   Catenate    
    ${vars}=    Catenate   ${vars}CATALOG_RESOURCE_IDS = [    
    :for   ${id}   in    @{CATALOG_RESOURCE_IDS}
    \    ${vars}=    Catenate  ${vars}${comma} "${id}"
    \    ${comma}=   Catenate   ,    
    ${vars}=    Catenate  ${vars}]\n 
    OperatingSystem.Create File   /share/${STACK_NAME}.py   ${vars}
    
    