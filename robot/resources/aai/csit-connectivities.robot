*** Settings ***
Documentation     Operations on connectivities in AAI for CCVPN use case,
...               using earliest API version where it is implemented
...               and latest API version where it is not implemented

Resource    ../json_templater.robot
Resource    aai_interface.robot
Resource    csit-api-version-properties.robot
Resource    csit-relationship-list.robot
Resource    csit-subobject.robot
Library    OperatingSystem
Library    Collections


*** Variables ***
${AAI_CONN_CONTAINER_PATH}=  /connectivities
${AAI_CONN_SUBOBJECT_PATH}=  /connectivity
${AAI_CONN_UNIQUE_KEY}=      connectivity-id
${AAI_CONN_CSIT_BODY}=       robot/assets/templates/aai/csit-connectivity.template
${AAI_CONN_ROOT_PATH}=       ${AAI_NETWORK_PATH}${AAI_CONN_CONTAINER_PATH}${AAI_CONN_SUBOBJECT_PATH}
${AAI_CONN_API_NA_INDEX_PATH}=    ${AAI_BEIJING_INDEX_PATH}
${AAI_CONN_API_IMPL_INDEX_PATH}=  ${AAI_CASABLANCA_INDEX_PATH}

*** Keywords ***
Create Connectivity If Not Exists
    [Documentation]    Creates Connectivity in AAI if it doesn't exist
    [Arguments]    ${connectivity_id}
    ${get_resp}=    Get SubObject  ${AAI_CONN_API_IMPL_INDEX_PATH}${AAI_NETWORK_PATH}  ${AAI_CONN_CONTAINER_PATH}  ${AAI_CONN_SUBOBJECT_PATH}  ${AAI_CONN_UNIQUE_KEY}  ${connectivity_id}
    Return From Keyword If    '${get_resp.status_code}' == '200'
    Create Connectivity  ${connectivity_id}

Create Connectivity
    [Documentation]    Creates Connectivity in AAI
    [Arguments]    ${connectivity_id}
    ${arguments}=    Create Dictionary     connectivity_id=${connectivity_id}
    ${put_resp}=    Create SubObject  ${AAI_CONN_API_IMPL_INDEX_PATH}${AAI_NETWORK_PATH}  ${AAI_CONN_CONTAINER_PATH}  ${AAI_CONN_SUBOBJECT_PATH}  ${connectivity_id}  ${AAI_CONN_CSIT_BODY}  ${arguments}

Delete Connectivity If Exists
    [Documentation]    Removes Connectivity from AAI if it exists
    [Arguments]    ${connectivity_id}
    ${get_resp}=    Get SubObject  ${AAI_CONN_API_IMPL_INDEX_PATH}${AAI_NETWORK_PATH}  ${AAI_CONN_CONTAINER_PATH}  ${AAI_CONN_SUBOBJECT_PATH}  ${AAI_CONN_UNIQUE_KEY}  ${connectivity_id}
    Run Keyword If    '${get_resp.status_code}' == '200'    Delete Connectivity     ${connectivity_id}   ${get_resp.json()}

Delete Connectivity
    [Documentation]    Removes Connectivity from AAI
    [Arguments]    ${connectivity_id}  ${json}
    ${del_resp}=    Delete SubObject  ${AAI_CONN_API_IMPL_INDEX_PATH}${AAI_NETWORK_PATH}  ${AAI_CONN_CONTAINER_PATH}  ${AAI_CONN_SUBOBJECT_PATH}  ${connectivity_id}  ${json}

Get Connectivity
    [Documentation]   Return Connectivity
    [Arguments]    ${connectivity_id}
    ${get_resp}=    Get SubObject  ${AAI_CONN_API_IMPL_INDEX_PATH}${AAI_NETWORK_PATH}  ${AAI_CONN_CONTAINER_PATH}  ${AAI_CONN_SUBOBJECT_PATH}  ${AAI_CONN_UNIQUE_KEY}  ${connectivity_id}
    Should Be Equal As Strings  ${get_resp.status_code}     200
    [Return]  ${get_resp.json()}

Get Valid Connectivity URL
    [Documentation]   Return Valid Connectivity URL
    [Arguments]    ${connectivity_id}
    ${resp}=    Get Valid SubObject URL  ${AAI_CONN_API_IMPL_INDEX_PATH}${AAI_NETWORK_PATH}  ${AAI_CONN_CONTAINER_PATH}  ${AAI_CONN_SUBOBJECT_PATH}  ${connectivity_id}
    [Return]  ${resp}

Get Nodes Query Connectivity
    [Documentation]   Return Nodes query Connectivity
    [Arguments]    ${connectivity_id}
    ${get_resp}=    Confirm Nodes Query SubObjects  ${AAI_CONN_API_IMPL_INDEX_PATH}  ${AAI_CONN_CONTAINER_PATH}  ${AAI_CONN_UNIQUE_KEY}  ${connectivity_id}
    [Return]  ${get_resp.json()}

Get Example Connectivity
    [Documentation]   Return Example Connectivity
    ${get_resp}=    Confirm Examples Query SubObjects  ${AAI_CONN_API_IMPL_INDEX_PATH}  ${AAI_CONN_CONTAINER_PATH}
    [Return]  ${get_resp.json()}

Confirm No Connectivity
    [Documentation]   Confirm No Connectivity
    [Arguments]    ${connectivity_id}
    ${get_resp}=    Get SubObject  ${AAI_CONN_API_IMPL_INDEX_PATH}${AAI_NETWORK_PATH}  ${AAI_CONN_CONTAINER_PATH}  ${AAI_CONN_SUBOBJECT_PATH}  ${AAI_CONN_UNIQUE_KEY}  ${connectivity_id}
    Should Be Equal As Strings  ${get_resp.status_code}     404

Confirm API Not Implemented Connectivity
    [Documentation]   Confirm latest API version where Connectivity is not implemented
    [Arguments]    ${connectivity_id}
    ${resp}=    Confirm API Not Implemented SubObject  ${AAI_CONN_API_NA_INDEX_PATH}${AAI_NETWORK_PATH}  ${AAI_CONN_CONTAINER_PATH}  ${AAI_CONN_SUBOBJECT_PATH}  ${connectivity_id}

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

