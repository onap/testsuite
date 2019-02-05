*** Settings ***
Documentation	  Executes the VNF Orchestration Test cases including setup and teardown
...
Library   Collections
Library    HTTPUtils
Resource         ../resources/demo_preload.robot
Resource         ../resources/asdc_interface.robot
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
    Load Customer   Demonstration
    Load Customer   SDN-ETHERNET-INTERNET

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

