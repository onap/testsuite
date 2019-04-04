*** Settings ***
Documentation     Operations on generic-vnfs in AAI for BBS use case,
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
${AAI_GVNF_CONTAINER_PATH}=  /generic-vnfs
${AAI_GVNF_SUBOBJECT_PATH}=  /generic-vnf
${AAI_GVNF_UNIQUE_KEY}=      vnf-id
${AAI_GVNF_CSIT_BODY}=       robot/assets/templates/aai/csit-generic-vnf.template
${AAI_GVNF_ROOT_PATH}=       ${AAI_NETWORK_PATH}${AAI_GVNF_CONTAINER_PATH}${AAI_GVNF_SUBOBJECT_PATH}
${AAI_GVNF_API_NA_INDEX_PATH}=    ${AAI_UNSUPPORTED_INDEX_PATH}
${AAI_GVNF_API_IMPL_INDEX_PATH}=  ${AAI_DUBLIN_INDEX_PATH}
# ${AAI_GVNF_API_IMPL_INDEX_PATH}=  ${AAI_CASABLANCA_INDEX_PATH}

*** Keywords ***
Create GenericVnf If Not Exists
    [Documentation]    Creates GenericVnf in AAI if it doesn't exist
    [Arguments]    ${vnf_id}  ${vnf_type}
    ${get_resp}=    Get SubObject  ${AAI_GVNF_API_IMPL_INDEX_PATH}${AAI_NETWORK_PATH}  ${AAI_GVNF_CONTAINER_PATH}  ${AAI_GVNF_SUBOBJECT_PATH}  ${AAI_GVNF_UNIQUE_KEY}  ${vnf_id}
    Return From Keyword If    '${get_resp.status_code}' == '200'
    Create GenericVnf  ${vnf_id}  ${vnf_type}

Create GenericVnf
    [Documentation]    Creates GenericVnf in AAI
    [Arguments]    ${vnf_id}  ${vnf_type}
    ${arguments}=    Create Dictionary     vnf_id=${vnf_id}  vnf_type=${vnf_type}
    ${put_resp}=    Create SubObject  ${AAI_GVNF_API_IMPL_INDEX_PATH}${AAI_NETWORK_PATH}  ${AAI_GVNF_CONTAINER_PATH}  ${AAI_GVNF_SUBOBJECT_PATH}  ${vnf_id}  ${AAI_GVNF_CSIT_BODY}  ${arguments}

Delete GenericVnf If Exists
    [Documentation]    Removes GenericVnf from AAI if it exists
    [Arguments]    ${vnf_id}
    ${get_resp}=    Get SubObject  ${AAI_GVNF_API_IMPL_INDEX_PATH}${AAI_NETWORK_PATH}  ${AAI_GVNF_CONTAINER_PATH}  ${AAI_GVNF_SUBOBJECT_PATH}  ${AAI_GVNF_UNIQUE_KEY}  ${vnf_id}
    Run Keyword If    '${get_resp.status_code}' == '200'    Delete GenericVnf     ${vnf_id}   ${get_resp.json()}

Delete GenericVnf
    [Documentation]    Removes GenericVnf from AAI
    [Arguments]    ${vnf_id}  ${json}
    ${del_resp}=    Delete SubObject  ${AAI_GVNF_API_IMPL_INDEX_PATH}${AAI_NETWORK_PATH}  ${AAI_GVNF_CONTAINER_PATH}  ${AAI_GVNF_SUBOBJECT_PATH}  ${vnf_id}  ${json}

Get GenericVnf
    [Documentation]   Return GenericVnf
    [Arguments]    ${vnf_id}
    ${get_resp}=    Get SubObject  ${AAI_GVNF_API_IMPL_INDEX_PATH}${AAI_NETWORK_PATH}  ${AAI_GVNF_CONTAINER_PATH}  ${AAI_GVNF_SUBOBJECT_PATH}  ${AAI_GVNF_UNIQUE_KEY}  ${vnf_id}
    Should Be Equal As Strings  ${get_resp.status_code}     200
    [Return]  ${get_resp.json()}

Get Valid GenericVnf URL
    [Documentation]   Return Valid GenericVnf URL
    [Arguments]    ${vnf_id}
    ${resp}=    Get Valid SubObject URL  ${AAI_GVNF_API_IMPL_INDEX_PATH}${AAI_NETWORK_PATH}  ${AAI_GVNF_CONTAINER_PATH}  ${AAI_GVNF_SUBOBJECT_PATH}  ${vnf_id}
    [Return]  ${resp}

Get Nodes Query GenericVnf
    [Documentation]   Return Nodes query GenericVnf
    [Arguments]    ${vnf_id}
    ${get_resp}=    Confirm Nodes Query SubObjects  ${AAI_GVNF_API_IMPL_INDEX_PATH}  ${AAI_GVNF_CONTAINER_PATH}  ${AAI_GVNF_UNIQUE_KEY}  ${vnf_id}
    [Return]  ${get_resp.json()}

Get Example GenericVnf
    [Documentation]   Return Example GenericVnf
    ${get_resp}=    Confirm Examples Query SubObjects  ${AAI_GVNF_API_IMPL_INDEX_PATH}  ${AAI_GVNF_CONTAINER_PATH}
    [Return]  ${get_resp.json()}

Confirm No GenericVnf
    [Documentation]   Confirm No GenericVnf
    [Arguments]    ${vnf_id}
    ${get_resp}=    Get SubObject  ${AAI_GVNF_API_IMPL_INDEX_PATH}${AAI_NETWORK_PATH}  ${AAI_GVNF_CONTAINER_PATH}  ${AAI_GVNF_SUBOBJECT_PATH}  ${AAI_GVNF_UNIQUE_KEY}  ${vnf_id}
    Should Be Equal As Strings  ${get_resp.status_code}     404

Confirm API Not Implemented GenericVnf
    [Documentation]   Confirm latest API version where GenericVnf is not implemented
    [Arguments]    ${vnf_id}
    ${resp}=    Confirm API Not Implemented SubObject  ${AAI_GVNF_API_NA_INDEX_PATH}${AAI_NETWORK_PATH}  ${AAI_GVNF_CONTAINER_PATH}  ${AAI_GVNF_SUBOBJECT_PATH}  ${vnf_id}

Add GenericVnf Relationship
    [Documentation]    Adds Relationship to existing GenericVnf in AAI
    [Arguments]    ${vnf_id}  ${related_class_name}  ${related_object_url}
    ${put_resp}=    Add Relationship     ${AAI_GVNF_API_IMPL_INDEX_PATH}${AAI_GVNF_ROOT_PATH}/${vnf_id}  ${related_class_name}  ${related_object_url}

Get GenericVnf RelationshipList
    [Documentation]   Return relationship-list from GenericVnf
    [Arguments]    ${vnf_id}
    ${resp}=    Get RelationshipList     ${AAI_GVNF_API_IMPL_INDEX_PATH}${AAI_GVNF_ROOT_PATH}/${vnf_id}
    [Return]  ${resp}

Get GenericVnf With RelationshipList
    [Documentation]   Return GenericVnf with relationship-list
    [Arguments]    ${vnf_id}
    ${resp}=    Get Object With Depth     ${AAI_GVNF_API_IMPL_INDEX_PATH}${AAI_GVNF_ROOT_PATH}/${vnf_id}
    [Return]  ${resp}

