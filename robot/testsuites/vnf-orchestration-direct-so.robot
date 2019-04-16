*** Settings ***
Documentation     Instantiate VNF via Direct SO Calls 
...
Test Timeout      600 second
Resource          ../resources/so/direct_instantiate.robot

*** Variables ***
${CSAR_FILE}   
${VFW_TEMPLATE}     ../assets/templates/vcpeutils/template.vfw_vfmodule.json


*** Test Cases ***
SO Direct Instantiate vFW VNF
    [Tags]    instantiateVFWdirectso
    Run Keyword If   '${CSAR_FILE}' == ''   Fail   "CSAR_FILE must not be empty (/tmp/csar/service-Vfw20190413133734-csar.csar)"
    Instantiate Service Direct To SO     vFW    ${CSAR_FILE}   ${VFW_TEMPLATE}
