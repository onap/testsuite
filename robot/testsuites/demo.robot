*** Settings ***
Documentation	  Executes the VNF Orchestration Test cases including setup and teardown
...

Resource         ../resources/demo_preload.robot
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



