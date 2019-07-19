*** Settings ***
Documentation     Operations on connectivities in AAI for CCVPN use case, using earliest API version where it is implemented and latest API version where it is not implemented

Resource    aai_interface.robot
Resource    api_version_properties.robot
Resource    add-relationship-list.robot
Library    OperatingSystem
Library    Collections
Library    ONAPLibrary.Templating    WITH NAME    Templating
Library    ONAPLibrary.AAI    WITH NAME    AAI

*** Variables ***
${AAI_CONN_ROOT_PATH}      /network/connectivities/connectivity
${AAI_CONN_EXAMPLES_PATH}      /examples/connectivities
${AAI_CONN_NODES_PATH}      /nodes/connectivities
${AAI_ADD_CONNECTIVITY_BODY}=    aai/add-connectivity.jinja
${AAI_CONN_API_NA_INDEX_PATH}=  ${AAI_BEIJING_INDEX_PATH}
${AAI_CONN_API_IMPL_INDEX_PATH}=  ${AAI_CASABLANCA_INDEX_PATH}

*** Keywords ***
Create Connectivity If Not Exists
    [Documentation]    Creates Connectivity in AAI if it doesn't exist
    [Arguments]    ${connectivity_id}
    ${auth}=  Create List  ${GLOBAL_AAI_USERNAME}    ${GLOBAL_AAI_PASSWORD}
    ${get_resp}=    AAI.Run Get Request     ${AAI_FRONTEND_ENDPOINT}    ${AAI_CONN_API_IMPL_INDEX_PATH}${AAI_CONN_ROOT_PATH}/${connectivity_id}        auth=${auth}
    Return From Keyword If    '${get_resp.status_code}' == '200'
    Create Connectivity  ${connectivity_id}

Create Connectivity
    [Documentation]    Creates Connectivity in AAI
    [Arguments]    ${connectivity_id}
    ${arguments}=    Create Dictionary     connectivity_id=${connectivity_id}
    Templating.Create Environment    aai    ${GLOBAL_TEMPLATE_FOLDER}
    ${data}=   Templating.Apply Template    aai   ${AAI_ADD_CONNECTIVITY_BODY}    ${arguments}
    ${auth}=  Create List  ${GLOBAL_AAI_USERNAME}    ${GLOBAL_AAI_PASSWORD}
    ${put_resp}=    AAI.Run Put Request     ${AAI_FRONTEND_ENDPOINT}    ${AAI_CONN_API_IMPL_INDEX_PATH}${AAI_CONN_ROOT_PATH}/${connectivity_id}     ${data}        auth=${auth}
    ${status_string}=    Convert To String    ${put_resp.status_code}
    Should Match Regexp    ${status_string}     ^(201|200)$

Delete Connectivity If Exists
    [Documentation]    Removes Connectivity from AAI if it exists
    [Arguments]    ${connectivity_id}
    ${auth}=  Create List  ${GLOBAL_AAI_USERNAME}    ${GLOBAL_AAI_PASSWORD}
    ${get_resp}=    AAI.Run Get Request     ${AAI_FRONTEND_ENDPOINT}    ${AAI_CONN_API_IMPL_INDEX_PATH}${AAI_CONN_ROOT_PATH}/${connectivity_id}        auth=${auth}
    Run Keyword If    '${get_resp.status_code}' == '200'    Delete Connectivity     ${connectivity_id}   ${get_resp.json()}

Delete Connectivity
    [Documentation]    Removes Connectivity from AAI
    [Arguments]    ${connectivity_id}  ${json}
    ${resource_version}=   Catenate   ${json['resource-version']}
    ${auth}=  Create List  ${GLOBAL_AAI_USERNAME}    ${GLOBAL_AAI_PASSWORD}
    ${put_resp}=    AAI.Run Delete Request    ${AAI_FRONTEND_ENDPOINT}    ${AAI_CONN_API_IMPL_INDEX_PATH}${AAI_CONN_ROOT_PATH}/${connectivity_id}    ${resource_version}        auth=${auth}
    Should Be Equal As Strings  ${put_resp.status_code}         204

Get Connectivity
    [Documentation]   Return Connectivity
    [Arguments]    ${connectivity_id}
    ${auth}=  Create List  ${GLOBAL_AAI_USERNAME}    ${GLOBAL_AAI_PASSWORD}
    ${resp}=    AAI.Run Get Request     ${AAI_FRONTEND_ENDPOINT}    ${AAI_CONN_API_IMPL_INDEX_PATH}${AAI_CONN_ROOT_PATH}/${connectivity_id}        auth=${auth}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]  ${resp.json()}

Get Valid Connectivity URL
    [Documentation]   Return Valid Connectivity URL
    [Arguments]    ${connectivity_id}
    ${auth}=  Create List  ${GLOBAL_AAI_USERNAME}    ${GLOBAL_AAI_PASSWORD}
    ${resp}=    AAI.Run Get Request     ${AAI_FRONTEND_ENDPOINT}    ${AAI_CONN_API_IMPL_INDEX_PATH}${AAI_CONN_ROOT_PATH}/${connectivity_id}        auth=${auth}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]  ${AAI_CONN_API_IMPL_INDEX_PATH}${AAI_CONN_ROOT_PATH}/${connectivity_id}

Get Nodes Query Connectivity
    [Documentation]   Return Nodes query Connectivity
    [Arguments]    ${connectivity_id}
    ${auth}=  Create List  ${GLOBAL_AAI_USERNAME}    ${GLOBAL_AAI_PASSWORD}
    ${resp}=    AAI.Run Get Request     ${AAI_FRONTEND_ENDPOINT}    ${AAI_CONN_API_IMPL_INDEX_PATH}${AAI_CONN_NODES_PATH}?connectivity-id=${connectivity_id}        auth=${auth}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]  ${resp.json()}

Get Example Connectivity
    [Documentation]   Return Example Connectivity
    ${auth}=  Create List  ${GLOBAL_AAI_USERNAME}    ${GLOBAL_AAI_PASSWORD}
    ${resp}=    AAI.Run Get Request     ${AAI_FRONTEND_ENDPOINT}    ${AAI_CONN_API_IMPL_INDEX_PATH}${AAI_CONN_EXAMPLES_PATH}        auth=${auth}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]  ${resp.json()}

Confirm No Connectivity
    [Documentation]   Confirm No Connectivity
    [Arguments]    ${connectivity_id}
    ${auth}=  Create List  ${GLOBAL_AAI_USERNAME}    ${GLOBAL_AAI_PASSWORD}
    ${resp}=    AAI.Run Get Request     ${AAI_FRONTEND_ENDPOINT}    ${AAI_CONN_API_IMPL_INDEX_PATH}${AAI_CONN_ROOT_PATH}/${connectivity_id}        auth=${auth}
    Should Be Equal As Strings  ${resp.status_code}     404

Confirm API Not Implemented Connectivity
    [Documentation]   Confirm latest API version where Connectivity is not implemented
    [Arguments]    ${connectivity_id}
    ${auth}=  Create List  ${GLOBAL_AAI_USERNAME}    ${GLOBAL_AAI_PASSWORD}
    ${resp}=    AAI.Run Get Request     ${AAI_FRONTEND_ENDPOINT}    ${AAI_CONN_API_NA_INDEX_PATH}${AAI_CONN_ROOT_PATH}/${connectivity_id}        auth=${auth}
    Should Be Equal As Strings  ${resp.status_code}     400

Add Connectivity Relationship
    [Documentation]    Adds Relationship to existing Connectivity in AAI
    [Arguments]    ${connectivity_id}  ${related_class_name}  ${related_object_url}
    ${put_resp}=    Add Relationship     ${AAI_CONN_API_IMPL_INDEX_PATH}${AAI_CONN_ROOT_PATH}/${connectivity_id}  ${related_class_name}  ${related_object_url}

Get Connectivity RelationshipList
    [Documentation]   Return relationship-list from Connectivity
    [Arguments]    ${connectivity_id}
    ${resp}=    Get RelationshipList     ${AAI_CONN_API_IMPL_INDEX_PATH}${AAI_CONN_ROOT_PATH}/${connectivity_id}
    [Return]  ${resp}

Get Connectivity With RelationshipList
    [Documentation]   Return Connectivity with relationship-list
    [Arguments]    ${connectivity_id}
    ${resp}=    Get Object With Depth     ${AAI_CONN_API_IMPL_INDEX_PATH}${AAI_CONN_ROOT_PATH}/${connectivity_id}
    [Return]  ${resp}

