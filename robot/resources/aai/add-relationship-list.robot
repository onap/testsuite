*** Settings ***
Documentation     Operations on relationship-list sub-object in AAI,
...    using specified base URL path including API version where it is implemented,
...    relies on system to choose default EdgeRule for the pair of object classes

Resource    aai_interface.robot
Library    Collections
Library    ONAPLibrary.Templating    WITH NAME    Templating
Library    ONAPLibrary.AAI    WITH NAME    AAI

*** Variables ***
${AAI_RELATIONSHIPLIST_PATH}      relationship-list
${AAI_RELATIONSHIP_PATH}=      ${AAI_RELATIONSHIPLIST_PATH}/relationship
${AAI_ADD_RELATIONSHIP_BODY}    aai/add-relationship.jinja
${AAI_RELATIONSHIP_DEPTH}=    ?depth=1

*** Keywords ***
Add Relationship
    [Documentation]    Adds Relationship sub-object to existing object in AAI
    [Arguments]    ${api_version_base_object_url}  ${related_class_name}  ${related_object_url}
    ${arguments}=    Create Dictionary     related_class_name=${related_class_name}  related_object_url=${related_object_url}
    Templating.Create Environment    aai    ${GLOBAL_TEMPLATE_FOLDER}
    ${data}=   Templating.Apply Template    aai   ${AAI_ADD_RELATIONSHIP_BODY}    ${arguments}
    ${put_resp}=    AAI.Run Put Request     ${AAI_FRONTEND_ENDPOINT}    ${api_version_base_object_url}/${AAI_RELATIONSHIP_PATH}     ${data}    auth=${GLOBAL_AAI_AUTHENTICATION}
    ${status_string}=    Convert To String    ${put_resp.status_code}
    Should Match Regexp    ${status_string}     ^(201|200)$

Get RelationshipList
    [Documentation]   Return RelationshipList of the object in AAI
    [Arguments]    ${api_version_base_object_url}
    ${resp}=  Get Object With Depth  ${api_version_base_object_url}
    Log    Returning response ${resp['${AAI_RELATIONSHIPLIST_PATH}']}
    [Return]  ${resp['${AAI_RELATIONSHIPLIST_PATH}']}

Get Object With Depth
    [Documentation]   Return Object with Depth parameter to show RelationshipList
    [Arguments]    ${api_version_base_object_url}
    ${resp}=    AAI.Run Get Request     ${AAI_FRONTEND_ENDPOINT}    ${api_version_base_object_url}${AAI_RELATIONSHIP_DEPTH}    auth=${GLOBAL_AAI_AUTHENTICATION}
    Should Be Equal As Strings  ${resp.status_code}     200
    Log    Returning response ${resp.json()}
    [Return]  ${resp.json()}