*** Settings ***
Documentation     Operations on pnfs in AAI for BBS use case,
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
${AAI_PNF_CONTAINER_PATH}=  /pnfs
${AAI_PNF_SUBOBJECT_PATH}=  /pnf
${AAI_PNF_UNIQUE_KEY}=      pnf-name
${AAI_PNF_CSIT_BODY}=       robot/assets/templates/aai/csit-pnf.template
${AAI_PNF_ROOT_PATH}=       ${AAI_NETWORK_PATH}${AAI_PNF_CONTAINER_PATH}${AAI_PNF_SUBOBJECT_PATH}
${AAI_PNF_API_NA_INDEX_PATH}=    ${AAI_UNSUPPORTED_INDEX_PATH}
${AAI_PNF_API_IMPL_INDEX_PATH}=  ${AAI_DUBLIN_INDEX_PATH}
# ${AAI_PNF_API_IMPL_INDEX_PATH}=  ${AAI_CASABLANCA_INDEX_PATH}

*** Keywords ***
Create Pnf If Not Exists
    [Documentation]    Creates Pnf in AAI if it doesn't exist
    [Arguments]    ${pnf_name}  ${pnf_id}
    ${get_resp}=    Get SubObject  ${AAI_PNF_API_IMPL_INDEX_PATH}${AAI_NETWORK_PATH}  ${AAI_PNF_CONTAINER_PATH}  ${AAI_PNF_SUBOBJECT_PATH}  ${AAI_PNF_UNIQUE_KEY}  ${pnf_name}
    Return From Keyword If    '${get_resp.status_code}' == '200'
    Create Pnf  ${pnf_name}  ${pnf_id}

Create Pnf
    [Documentation]    Creates Pnf in AAI
    [Arguments]    ${pnf_name}  ${pnf_id}
    ${arguments}=    Create Dictionary     pnf_name=${pnf_name}  pnf_id=${pnf_id}
    ${put_resp}=    Create SubObject  ${AAI_PNF_API_IMPL_INDEX_PATH}${AAI_NETWORK_PATH}  ${AAI_PNF_CONTAINER_PATH}  ${AAI_PNF_SUBOBJECT_PATH}  ${pnf_name}  ${AAI_PNF_CSIT_BODY}  ${arguments}

Delete Pnf If Exists
    [Documentation]    Removes Pnf from AAI if it exists
    [Arguments]    ${pnf_name}
    ${get_resp}=    Get SubObject  ${AAI_PNF_API_IMPL_INDEX_PATH}${AAI_NETWORK_PATH}  ${AAI_PNF_CONTAINER_PATH}  ${AAI_PNF_SUBOBJECT_PATH}  ${AAI_PNF_UNIQUE_KEY}  ${pnf_name}
    Run Keyword If    '${get_resp.status_code}' == '200'    Delete Pnf     ${pnf_name}   ${get_resp.json()}

Delete Pnf
    [Documentation]    Removes Pnf from AAI
    [Arguments]    ${pnf_name}  ${json}
    ${del_resp}=    Delete SubObject  ${AAI_PNF_API_IMPL_INDEX_PATH}${AAI_NETWORK_PATH}  ${AAI_PNF_CONTAINER_PATH}  ${AAI_PNF_SUBOBJECT_PATH}  ${pnf_name}  ${json}

Get Pnf
    [Documentation]   Return Pnf
    [Arguments]    ${pnf_name}
    ${get_resp}=    Get SubObject  ${AAI_PNF_API_IMPL_INDEX_PATH}${AAI_NETWORK_PATH}  ${AAI_PNF_CONTAINER_PATH}  ${AAI_PNF_SUBOBJECT_PATH}  ${AAI_PNF_UNIQUE_KEY}  ${pnf_name}
    Should Be Equal As Strings  ${get_resp.status_code}     200
    [Return]  ${get_resp.json()}

Get Valid Pnf URL
    [Documentation]   Return Valid Pnf URL
    [Arguments]    ${pnf_name}
    ${resp}=    Get Valid SubObject URL  ${AAI_PNF_API_IMPL_INDEX_PATH}${AAI_NETWORK_PATH}  ${AAI_PNF_CONTAINER_PATH}  ${AAI_PNF_SUBOBJECT_PATH}  ${pnf_name}
    [Return]  ${resp}

Get Nodes Query Pnf
    [Documentation]   Return Nodes query Pnf
    [Arguments]    ${pnf_name}
    ${get_resp}=    Confirm Nodes Query SubObjects  ${AAI_PNF_API_IMPL_INDEX_PATH}  ${AAI_PNF_CONTAINER_PATH}  ${AAI_PNF_UNIQUE_KEY}  ${pnf_name}
    [Return]  ${get_resp.json()}

Get Example Pnf
    [Documentation]   Return Example Pnf
    ${get_resp}=    Confirm Examples Query SubObjects  ${AAI_PNF_API_IMPL_INDEX_PATH}  ${AAI_PNF_CONTAINER_PATH}
    [Return]  ${get_resp.json()}

Confirm No Pnf
    [Documentation]   Confirm No Pnf
    [Arguments]    ${pnf_name}
    ${get_resp}=    Get SubObject  ${AAI_PNF_API_IMPL_INDEX_PATH}${AAI_NETWORK_PATH}  ${AAI_PNF_CONTAINER_PATH}  ${AAI_PNF_SUBOBJECT_PATH}  ${AAI_PNF_UNIQUE_KEY}  ${pnf_name}
    Should Be Equal As Strings  ${get_resp.status_code}     404

Confirm API Not Implemented Pnf
    [Documentation]   Confirm latest API version where Pnf is not implemented
    [Arguments]    ${pnf_name}
    ${resp}=    Confirm API Not Implemented SubObject  ${AAI_PNF_API_NA_INDEX_PATH}${AAI_NETWORK_PATH}  ${AAI_PNF_CONTAINER_PATH}  ${AAI_PNF_SUBOBJECT_PATH}  ${pnf_name}

Add Pnf Relationship
    [Documentation]    Adds Relationship to existing Pnf in AAI
    [Arguments]    ${pnf_name}  ${related_class_name}  ${related_object_url}
    ${put_resp}=    Add Relationship     ${AAI_PNF_API_IMPL_INDEX_PATH}${AAI_PNF_ROOT_PATH}/${pnf_name}  ${related_class_name}  ${related_object_url}

Get Pnf RelationshipList
    [Documentation]   Return relationship-list from Pnf
    [Arguments]    ${pnf_name}
    ${resp}=    Get RelationshipList     ${AAI_PNF_API_IMPL_INDEX_PATH}${AAI_PNF_ROOT_PATH}/${pnf_name}
    [Return]  ${resp}

Get Pnf With RelationshipList
    [Documentation]   Return Pnf with relationship-list
    [Arguments]    ${pnf_name}
    ${resp}=    Get Object With Depth     ${AAI_PNF_API_IMPL_INDEX_PATH}${AAI_PNF_ROOT_PATH}/${pnf_name}
    [Return]  ${resp}

