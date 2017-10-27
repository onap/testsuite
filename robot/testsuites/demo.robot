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
    Execute Heatbridge   ${HB_STACK}   ${HB_SERVICE_INSTANCE_ID}    ${HB_SERVICE}

