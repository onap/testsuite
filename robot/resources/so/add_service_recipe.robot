*** Settings ***
Documentation	   Creates a macro service recipe in SO Catalog DB

Library    OperatingSystem
Library    Collections
Library    ONAPLibrary.SO    WITH NAME    SO
Library    ONAPLibrary.Templating    WITH NAME    Templating
Resource    ../global_properties.robot

*** Variables ***
${SERVICE_RECIPE_PATH}    /serviceRecipe

${SYSTEM USER}    robot-ete
${SO_ADD_SERVICE_RECIPE}   so/service_recipe.jinja



*** Keywords ***
Add Service Recipe
    [Documentation]    Creates a macro service recipe in SO Catalog DB
    [Arguments]    ${service_model_UUID}  ${orchestrationUri}
    ${id}=  Get First Free Service Recipe Id
    ${arguments}=    Create Dictionary     service_model_UUID=${service_model_UUID}  orchestrationUri=${orchestrationUri}   id=${id}
    Templating.Create Environment    so    ${GLOBAL_TEMPLATE_FOLDER}
    ${data}=    Templating.Apply Template    so    ${SO_ADD_SERVICE_RECIPE}     ${arguments}
    ${auth}=  Create List  ${GLOBAL_SO_CATDB_USERNAME}    ${GLOBAL_SO_PASSWORD}
    ${get_resp}=   SO.Run Post Request   ${GLOBAL_SO_CATDB_ENDPOINT}    ${SERVICE_RECIPE_PATH}   ${data}    auth=${auth}
    Should Be Equal As Strings  ${get_resp.status_code}     201
    [Return]  ${get_resp.status_code}  ${get_resp.json()}

Get Service Recipe
    [Documentation]    Gets service recipe/s in SO
    [Arguments]    ${service_id}=
    ${auth}=  Create List  ${GLOBAL_SO_CATDB_USERNAME}    ${GLOBAL_SO_PASSWORD}
    ${get_resp}=    SO.Run Get Request    ${GLOBAL_SO_CATDB_ENDPOINT}    ${SERVICE_RECIPE_PATH}/${service_id}   auth=${auth}
    Should Be Equal As Strings  ${get_resp.status_code}     200
    [Return]   ${get_resp}

Get First Free Service Recipe Id
    [Documentation]    Gets first free service recipe id in SO
    ${get_resp}=  Get Service Recipe
    ${source data}=   Set Variable  ${get_resp.json()}
    Log  ${source data}
    ${serviceRecipes}=    Set Variable     ${source data['_embedded']['serviceRecipe']}
    ${ids}=    Create List
    :FOR    ${recipe}     IN      @{serviceRecipes}
    \    ${id}=    Get From Dictionary   ${recipe}     id
    \    Append To List    ${ids}    ${id}
    Sort list  ${ids}
    ${biggest_id}=  Get From List  ${ids}  -1
    Log  Biggest id is ${biggest_id} first free is ${biggest_id+1}
    [Return]  ${biggest_id+1}
