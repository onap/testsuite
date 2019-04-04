*** Settings ***
Documentation     Operations on vpn-bindings in AAI for CCVPN use case,
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
${AAI_VPNB_CONTAINER_PATH}=  /vpn-bindings
${AAI_VPNB_SUBOBJECT_PATH}=  /vpn-binding
${AAI_VPNB_UNIQUE_KEY}=      vpn-id
${AAI_VPNB_CSIT_BODY}=       robot/assets/templates/aai/csit-vpn-binding.template
${AAI_VPNB_ROOT_PATH}=       ${AAI_NETWORK_PATH}${AAI_VPNB_CONTAINER_PATH}${AAI_VPNB_SUBOBJECT_PATH}
${AAI_VPNB_API_NA_INDEX_PATH}=    ${AAI_UNSUPPORTED_INDEX_PATH}
${AAI_VPNB_API_IMPL_INDEX_PATH}=  ${AAI_CASABLANCA_INDEX_PATH}

*** Keywords ***
Create VPN Binding If Not Exists
    [Documentation]    Creates VPN Binding in AAI if it doesn't exist
    [Arguments]    ${vpn_id}
    ${get_resp}=    Get SubObject  ${AAI_VPNB_API_IMPL_INDEX_PATH}${AAI_NETWORK_PATH}  ${AAI_VPNB_CONTAINER_PATH}  ${AAI_VPNB_SUBOBJECT_PATH}  ${AAI_VPNB_UNIQUE_KEY}  ${vpn_id}
    Return From Keyword If    '${get_resp.status_code}' == '200'
    Create VPN Binding  ${vpn_id}

Create VPN Binding
    [Documentation]    Creates VPN Binding in AAI
    [Arguments]    ${vpn_id}
    ${arguments}=    Create Dictionary     vpn_id=${vpn_id}
    ${put_resp}=    Create SubObject  ${AAI_VPNB_API_IMPL_INDEX_PATH}${AAI_NETWORK_PATH}  ${AAI_VPNB_CONTAINER_PATH}  ${AAI_VPNB_SUBOBJECT_PATH}  ${vpn_id}  ${AAI_VPNB_CSIT_BODY}  ${arguments}

Delete VPN Binding If Exists
    [Documentation]    Removes VPN Binding from AAI if it exists
    [Arguments]    ${vpn_id}
    ${get_resp}=    Get SubObject  ${AAI_VPNB_API_IMPL_INDEX_PATH}${AAI_NETWORK_PATH}  ${AAI_VPNB_CONTAINER_PATH}  ${AAI_VPNB_SUBOBJECT_PATH}  ${AAI_VPNB_UNIQUE_KEY}  ${vpn_id}
    Run Keyword If    '${get_resp.status_code}' == '200'    Delete VPN Binding     ${vpn_id}   ${get_resp.json()}

Delete VPN Binding
    [Documentation]    Removes VPN Binding from AAI
    [Arguments]    ${vpn_id}  ${json}
    ${del_resp}=    Delete SubObject  ${AAI_VPNB_API_IMPL_INDEX_PATH}${AAI_NETWORK_PATH}  ${AAI_VPNB_CONTAINER_PATH}  ${AAI_VPNB_SUBOBJECT_PATH}  ${vpn_id}  ${json}

Get VPN Binding
    [Documentation]   Return VPN Binding
    [Arguments]    ${vpn_id}
    ${get_resp}=    Get SubObject  ${AAI_VPNB_API_IMPL_INDEX_PATH}${AAI_NETWORK_PATH}  ${AAI_VPNB_CONTAINER_PATH}  ${AAI_VPNB_SUBOBJECT_PATH}  ${AAI_VPNB_UNIQUE_KEY}  ${vpn_id}
    Should Be Equal As Strings  ${get_resp.status_code}     200
    [Return]  ${get_resp.json()}

Get Valid VPN Binding URL
    [Documentation]   Return Valid VPN Binding URL
    [Arguments]    ${vpn_id}
    ${resp}=    Get Valid SubObject URL  ${AAI_VPNB_API_IMPL_INDEX_PATH}${AAI_NETWORK_PATH}  ${AAI_VPNB_CONTAINER_PATH}  ${AAI_VPNB_SUBOBJECT_PATH}  ${vpn_id}
    [Return]  ${resp}

Get Nodes Query VPN Binding
    [Documentation]   Return Nodes query VPN Binding
    [Arguments]    ${vpn_id}
    ${get_resp}=    Confirm Nodes Query SubObjects  ${AAI_VPNB_API_IMPL_INDEX_PATH}  ${AAI_VPNB_CONTAINER_PATH}  ${AAI_VPNB_UNIQUE_KEY}  ${vpn_id}
    [Return]  ${get_resp.json()}

Get Example VPN Binding
    [Documentation]   Return Example VPN Binding
    ${get_resp}=    Confirm Examples Query SubObjects  ${AAI_VPNB_API_IMPL_INDEX_PATH}  ${AAI_VPNB_CONTAINER_PATH}
    [Return]  ${get_resp.json()}

Confirm No VPN Binding
    [Documentation]   Confirm No VPN Binding
    [Arguments]    ${vpn_id}
    ${get_resp}=    Get SubObject  ${AAI_VPNB_API_IMPL_INDEX_PATH}${AAI_NETWORK_PATH}  ${AAI_VPNB_CONTAINER_PATH}  ${AAI_VPNB_SUBOBJECT_PATH}  ${AAI_VPNB_UNIQUE_KEY}  ${vpn_id}
    Should Be Equal As Strings  ${get_resp.status_code}     404

Confirm API Not Implemented VPN Binding
    [Documentation]   Confirm latest API version where VPN Binding is not implemented
    [Arguments]    ${vpn_id}
    ${resp}=    Confirm API Not Implemented SubObject  ${AAI_VPNB_API_NA_INDEX_PATH}${AAI_NETWORK_PATH}  ${AAI_VPNB_CONTAINER_PATH}  ${AAI_VPNB_SUBOBJECT_PATH}  ${vpn_id}

Add VPN Binding Relationship
    [Documentation]    Adds Relationship to existing VPN Binding in AAI
    [Arguments]    ${vpn_id}  ${related_class_name}  ${related_object_url}
    ${put_resp}=    Add Relationship     ${AAI_VPNB_API_IMPL_INDEX_PATH}${AAI_VPNB_ROOT_PATH}/${vpn_id}  ${related_class_name}  ${related_object_url}

Get VPN Binding RelationshipList
    [Documentation]   Return relationship-list from VPN Binding
    [Arguments]    ${vpn_id}
    ${resp}=    Get RelationshipList     ${AAI_VPNB_API_IMPL_INDEX_PATH}${AAI_VPNB_ROOT_PATH}/${vpn_id}
    [Return]  ${resp}

Get VPN Binding With RelationshipList
    [Documentation]   Return VPN Binding with relationship-list
    [Arguments]    ${vpn_id}
    ${resp}=    Get Object With Depth     ${AAI_VPNB_API_IMPL_INDEX_PATH}${AAI_VPNB_ROOT_PATH}/${vpn_id}
    [Return]  ${resp}

