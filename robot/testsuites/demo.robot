*** Settings ***
Documentation	  Executes the VNF Orchestration Test cases including setup and teardown
...
Library   Collections
Resource         ../resources/demo_preload.robot
Resource         ../resources/asdc_interface.robot
Resource         ../resources/so_interface.robot

*** Variables ***

${VNF_NAME}       DemoVNF
${MODULE_NAME}    DemoModuleName

${HB_STACK}
${HB_SERVICE}
${HB_IPV4_OAM_ADDRESS}
${TENANT_NAME}
${VVG_SERVER_ID}
${SERVICE}
${CUSTOMER_NAME}
${SERVICE_INSTANCE_ID}
${STACK_NAMES}
${CATALOG_SERVICE_ID}
${CATALOG_RESOURCE_IDS}
${REVERSE_HEATBRIDGE}

*** Test Cases ***
Initialize Customer And Models
    [Tags]   InitDemo
    Load Customer And Models   Demonstration

Initialize SO Openstack Identity For V3
    [Tags]   InitDemo
    Run Keyword If    '${GLOBAL_INJECTED_OPENSTACK_KEYSTONE_API_VERSION}'=='v3'     Create Cloud Configuration v3    ${GLOBAL_INJECTED_REGION}   ${GLOBAL_INJECTED_REGION}  ${GLOBAL_INJECTED_REGION}   DEFAULT_KEYSTONE  ${GLOBAL_INJECTED_KEYSTONE}/${GLOBAL_INJECTED_OPENSTACK_KEYSTONE_API_VERSION}     ${GLOBAL_INJECTED_OPENSTACK_USERNAME}   ${GLOBAL_INJECTED_OPENSTACK_SO_ENCRYPTED_PASSWORD}    ${GLOBAL_INJECTED_OPENSTACK_TENANT_ID}     admin    KEYSTONE_V3    USERNAME_PASSWORD  ${GLOBAL_INJECTED_OPENSTACK_DOMAIN_ID}  ${GLOBAL_INJECTED_OPENSTACK_USER_DOMAIN}

Initialize Customer
    [Tags]   InitCustomer
    Load Customer   Demonstration
    Load Customer   SDN-ETHERNET-INTERNET

Initialize Models
    [Tags]   InitDistribution
    Load Models   Demonstration

Preload VNF
    [Tags]   PreloadDemo
    Preload User Model   ${VNF_NAME}   ${MODULE_NAME}    ${SERVICE}    ${SERVICE_INSTANCE_ID}

Create APPC Mount Point
    [Tags]   APPCMountPointDemo
    APPC Mount Point    ${MODULE_NAME}

Instantiate VFW
    [Tags]   instantiateVFW
    Instantiate VNF   vFW   base_vfw

Instantiate Demo VFWCL
    [Tags]   instantiateDemoVFWCL
    Instantiate Demo VNF   vFWCL   base_vpkg

Instantiate VFWCL
    [Tags]   instantiateVFWCL
    Instantiate VNF   vFWCL  base_vpkg

Instantiate VFWDT
    [Tags]   instantiateVFWDT
    Instantiate VNF   vFWDT  base_vpkg


Delete Instantiated VNF
    [Documentation]   This test assumes all necessary variables are loaded via the variable file create in  Save For Delete
    ...    The Teardown VNF needs to be in the teardown step of the test case...
    [Tags]   deleteVNF
    Setup Browser
    Login To VID GUI
    Delete VNF    ${TENANT_NAME}    ${VVG_SERVER_ID}    ${CUSTOMER_NAME}    ${SERVICE_INSTANCE_ID}    ${STACK_NAMES}    ${REVERSE_HEATBRIDGE}
    [Teardown]   Teardown VNF    ${CUSTOMER_NAME}    ${CATALOG_SERVICE_ID}    ${CATALOG_RESOURCE_IDS}

Run Heatbridge
    [Documentation]
    ...    Try to run heatbridge
    [Tags]   heatbridge
    Execute Heatbridge   ${HB_STACK}   ${HB_SERVICE}    ${HB_IPV4_OAM_ADDRESS}

Preload APPC CDT GUI
    [Documentation]
    ...    APPC CDT Preload Demo
    [Tags]   APPCCDTPreloadDemo
    Setup Browser
    Preload APPC CDT GUI

Distribute vFWNG CDS Model
    [Documentation]    Distribute vFWNG for CDS
    [Tags]    DistributeVFWNG
    [Timeout]    600
    Model Distribution For Directory    service=vFWNG    cds=vfwng

Distribute Demo vFWDT Model
    [Documentation]    Distribute Demo vFWDT  (does not delete model after distribution)
    [Tags]    DistributeDemoVFWDT
    [Timeout]    600
    Model Distribution For Directory    service=vFWDT   

