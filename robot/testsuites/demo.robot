*** Settings ***
Documentation	  Executes the VNF Orchestration Test cases including setup and teardown
...
Library   Collections
Library    HTTPUtils
Resource         ../resources/demo_preload.robot
*** Variables ***

${VNF_NAME}       DemoVNF
${MODULE_NAME}    DemoModuleName

${HB_STACK}
${HB_SERVICE_INSTANCE_ID}
${HB_SERVICE}


*** Test Cases ***
Initialize Customer And Models
    [Tags]   InitDemo
    Load Customer And Models   Demonstration

Initialize Customer
    [Tags]   InitCustomer
    Load OwningEntity  lineOfBusiness  LOB-${customer_name}
    Load OwningEntity  platform  Platform-${customer_name}
    Load OwningEntity  project  Project-${customer_name}
    Load OwningEntity  owningEntity  OE-${customer_name}
    Load Customer   Demonstration

Initialize Models
    [Tags]   InitDistribution
    Load Models   Demonstration

Preload VNF
    [Tags]   PreloadDemo
    Preload User Model   ${VNF_NAME}   ${MODULE_NAME}


Create APPC Mount Point
    [Tags]   APPCMountPointDemo
    APPC Mount Point    ${MODULE_NAME}

Instantiate VFW
    [Tags]   instantiateVFW
    Instantiate VNF   vFW

Instantiate VFWCL
    [Tags]   instantiateVFWCL
    Instantiate VNF   vFWCL  base_vpkg


Delete Instantiated VNF
    [Documentation]   This test assumes all necessary variables are loaded via the variable file create in  Save For Delete
    ...    The Teardown VNF needs to be in the teardown step of the test case...
    [Tags]   deleteVNF
    Setup Browser
    Login To VID GUI
    Delete VNF
    [Teardown]   Teardown VNF

Run Heatbridge
    [Documentation]
    ...    Try to run heatbridge
    [Tags]   heatbridge
    Execute Heatbridge   ${HB_STACK}   ${HB_SERVICE_INSTANCE_ID}    ${HB_SERVICE}    ${HB_IPV4_OAM_ADDRESS}

Preload APPC CDT GUI
    [Documentation]
    ...    APPC CDT Preload Demo
    [Tags]   APPCCDTPreloadDemo
    Setup Browser
    Preload APPC CDT GUI
#    Preload APPC CDT GUI   demo   reference_AllAction_vLoadBalancer_vLoadBalancer-test0_0.0.1V.json   ${EXECDIR}/robot/assets/templates/appc/reference_AllAction_vLoadBalancer_vLoadBalancer-test0_0.0.1V.json   ${EXECDIR}/robot/assets/templates/appc/template_ConfigScaleOut_vLoadBalancer_vLoadBalancer-test0_0.0.1V_vLB.xml   ${EXECDIR}/robot/assets/templates/appc/pd_ConfigScaleOut_vLoadBalancer_vLoadBalancer-test0_0.0.1V_vLB.yaml

Preload VF Module
    [Tags]   PreloadVFModule
    Preload User Model for VF Module   ${VNF_NAME}   ${VF_MODULE_NAME}   ${VF_MODULE_TYPE_PATTERN}   ${VF_MODULE_DATA_FILE}

ADD Complex
    [Tags]   AddComplex
    Create AAI Complex   ${COMPLEX_NAME_ID}   ${LATITUDE}   ${LONGITUDE}

ADD Customer
    [Tags]   AddCustomer
    Load OwningEntity  lineOfBusiness  LOB-${CUSTOMER-NAME}
    Load OwningEntity  platform  Platform-${CUSTOMER-NAME}
    Load OwningEntity  project  Project-${CUSTOMER-NAME}
    Load OwningEntity  owningEntity  OE-${CUSTOMER-NAME}
    Create AAI Customer   ${CUSTOMER-NAME}   ${SERVICE-TYPE}

Associate Customer And Cloud Region
    [Tags]   AssociateCustomerCloudRegion
    Associate Customer And Cloud Region   ${CUSTOMER-NAME}   ${SERVICE-TYPE}   ${CLOUD-OWNER}   ${CLOUD-REGION-ID}   ${TENANT-NAME}
