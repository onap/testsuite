*** Settings ***
Documentation     Instantiate VNF via Direct SO Calls
...
Test Timeout      600 second
Resource          ../resources/so/direct_instantiate.robot

*** Variables ***
${CSAR_FILE}
${VFW_TEMPLATE}     robot/assets/templates/vcpeutils/template.vfw_vfmodule.json


*** Test Cases ***
SO Direct Instantiate vFW VNF
    [Tags]    instantiateVFWdirectso
    [Documentation]   Direct REST API into SO
    ...    ./ete-k8s.sh onap healtdist   (cpy csar file name)
    ...    ./ete-k8s.sh onap instantiateVFWdirectso  CSAR_FILE:/tmp/csar/service-Vfw20190413133734-csar.csar
    Run Keyword If   '${CSAR_FILE}' == ''   Fail   "CSAR_FILE must not be empty (/tmp/csar/service-Vfw20190413133734-csar.csar)"
    Instantiate Service Direct To SO     vFW    ${CSAR_FILE}   ${VFW_TEMPLATE}
