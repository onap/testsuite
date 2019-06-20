*** Settings ***
Documentation     Operations on vpn-bindings in AAI for CCVPN use case,
...     using earliest API version where changes are implemented and
...     latest API version where changes are not implemented

Resource    aai_interface.robot
Resource    api_version_properties.robot
Resource    add-relationship-list.robot
Library    OperatingSystem
Library    Collections
Library    ONAPLibrary.Templating

*** Variables ***
${AAI_VPNB_ROOT_PATH}      /network/vpn-bindings/vpn-binding
${AAI_VPNB_EXAMPLES_PATH}      /examples/vpn-bindings
${AAI_VPNB_NODES_PATH}      /nodes/vpn-bindings
${AAI_ADD_VPNBINDING_BODY}=    aai/add-vpn-binding.jinja
${AAI_VPNB_API_NA_INDEX_PATH}=  ${AAI_BEIJING_INDEX_PATH}
${AAI_VPNB_API_IMPL_INDEX_PATH}=  ${AAI_CASABLANCA_INDEX_PATH}

*** Keywords ***
Create VPN Binding If Not Exists
    [Documentation]    Creates VPN Binding in AAI if it doesn't exist
    [Arguments]    ${vpn_id}
    ${get_resp}=    Run A&AI Get Request     ${AAI_VPNB_API_IMPL_INDEX_PATH}${AAI_VPNB_ROOT_PATH}/${vpn_id}
    Return From Keyword If    '${get_resp.status_code}' == '200'
    Create VPN Binding  ${vpn_id}

Create VPN Binding
    [Documentation]    Creates VPN Binding in AAI
    [Arguments]    ${vpn_id}
    ${arguments}=    Create Dictionary     vpn_id=${vpn_id}
    Create Environment    aai    ${GLOBAL_TEMPLATE_FOLDER}
    ${data}=   Apply Template    aai   ${AAI_ADD_VPNBINDING_BODY}    ${arguments}
    ${put_resp}=    Run A&AI Put Request     ${AAI_VPNB_API_IMPL_INDEX_PATH}${AAI_VPNB_ROOT_PATH}/${vpn_id}     ${data}
    ${status_string}=    Convert To String    ${put_resp.status_code}
    Should Match Regexp    ${status_string}     ^(201|200)$

Delete VPN Binding If Exists
    [Documentation]    Removes VPN Binding from AAI if it exists
    [Arguments]    ${vpn_id}
    ${get_resp}=    Run A&AI Get Request     ${AAI_VPNB_API_IMPL_INDEX_PATH}${AAI_VPNB_ROOT_PATH}/${vpn_id}
    Run Keyword If    '${get_resp.status_code}' == '200'    Delete VPN Binding     ${vpn_id}   ${get_resp.json()}

Delete VPN Binding
    [Documentation]    Removes VPN Binding from AAI
    [Arguments]    ${vpn_id}  ${json}
    ${resource_version}=   Catenate   ${json['resource-version']}
    ${put_resp}=    Run A&AI Delete Request    ${AAI_VPNB_API_IMPL_INDEX_PATH}${AAI_VPNB_ROOT_PATH}/${vpn_id}    ${resource_version}
    Should Be Equal As Strings  ${put_resp.status_code}         204

Get VPN Binding
    [Documentation]   Return VPN Binding
    [Arguments]    ${vpn_id}
    ${resp}=    Run A&AI Get Request     ${AAI_VPNB_API_IMPL_INDEX_PATH}${AAI_VPNB_ROOT_PATH}/${vpn_id}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]  ${resp.json()}

Get Valid VPN Binding URL
    [Documentation]   Return Valid VPN Binding URL
    [Arguments]    ${vpn_id}
    ${resp}=    Run A&AI Get Request     ${AAI_VPNB_API_IMPL_INDEX_PATH}${AAI_VPNB_ROOT_PATH}/${vpn_id}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]  ${AAI_VPNB_API_IMPL_INDEX_PATH}${AAI_VPNB_ROOT_PATH}/${vpn_id}

Get Nodes Query VPN Binding
    [Documentation]   Return Nodes query VPN Binding
    [Arguments]    ${vpn_id}
    ${resp}=    Run A&AI Get Request     ${AAI_VPNB_API_IMPL_INDEX_PATH}${AAI_VPNB_NODES_PATH}?vpn-id=${vpn_id}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]  ${resp.json()}

Get Example VPN Binding
    [Documentation]   Return Example VPN Binding
    ${resp}=    Run A&AI Get Request     ${AAI_VPNB_API_IMPL_INDEX_PATH}${AAI_VPNB_EXAMPLES_PATH}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]  ${resp.json()}

Confirm No VPN Binding
    [Documentation]   Confirm No VPN Binding
    [Arguments]    ${vpn_id}
    ${resp}=    Run A&AI Get Request     ${AAI_VPNB_API_IMPL_INDEX_PATH}${AAI_VPNB_ROOT_PATH}/${vpn_id}
    Should Be Equal As Strings  ${resp.status_code}     404

# Not applicable to VPN Binding as it appears in all known API versions
# Confirm API Not Implemented VPN Binding
    # [Documentation]   Confirm latest API version where VPN Binding is not implemented
    # [Arguments]    ${vpn_id}
    # ${resp}=    Run A&AI Get Request     ${AAI_VPNB_API_NA_INDEX_PATH}${AAI_VPNB_ROOT_PATH}/${vpn_id}
    # Should Be Equal As Strings  ${resp.status_code}     400

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

