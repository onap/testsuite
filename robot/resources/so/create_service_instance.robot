*** Settings ***
Documentation	   Creates a macro service recipe in SO Catalog DB

Library    OperatingSystem
Library    Collections
Library    ONAPLibrary.SO    WITH NAME    SO
Library    ONAPLibrary.Templating    WITH NAME    Templating
Resource    ../global_properties.robot

*** Variables ***
${CREATE_SERVICE_PATH}    /onap/so/infra/serviceInstantiation/v7/serviceInstances

${SYSTEM USER}    robot-ete
${CREATE_PNF_SERVICE_GR_API}   so/create_pnf_service_building_block.jinja

*** Keywords ***
Create PNF Service Using GR Api
    [Documentation]    Creates a PNF service using GR Api
    [Arguments]   ${arguments}
    Templating.Create Environment    so    ${GLOBAL_TEMPLATE_FOLDER}
    ${data}=    Templating.Apply Template    so    ${CREATE_PNF_SERVICE_BUILDING_BLOCK}     ${arguments}
    ${auth}=  Create List  ${GLOBAL_SO_CATDB_USERNAME}    ${GLOBAL_SO_PASSWORD}
    ${get_resp}=   SO.Run Post Request   ${GLOBAL_SO_CATDB_ENDPOINT}    ${CREATE_PNF_SERVICE_GR_API}   ${data}    auth=${auth}
    [Return]  ${get_resp}