*** Settings ***
Documentation	  Validate A&AI Models

Resource          aai_interface.robot
Library    Collections
Library    ONAPLibrary.AAI    WITH NAME    AAI

*** Variables ***
${INDEX_PATH}     /aai/v16
${MODELS_SPEC_PATH}    /service-design-and-creation/models/

*** Keywords ***
Validate Size Of AAI Models
    [Documentation]    Query and Validates A&AI Models 
    [Arguments]     ${min_size}=100
    ${resp}=    AAI.Run Get Request      ${AAI_FRONTEND_ENDPOINT}    ${INDEX_PATH}${MODELS_SPEC_PATH}   auth=${GLOBAL_AAI_AUTHENTICATION}
    ${count}=   Evaluate    sys.getsizeof(${resp.json()})    sys
    Should Be True    ${count} > ${min_size}
