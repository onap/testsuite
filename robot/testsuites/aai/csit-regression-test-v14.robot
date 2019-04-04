*** Settings ***
Documentation   AAI CSIT-style regression tests for CCVPN - new schema elements introduced in Casablanca release for CCVPN use case
Test Timeout    20s
Resource    ${EXECDIR}/robot/resources/aai/csit-connectivities.robot
Resource    ${EXECDIR}/robot/resources/aai/csit-vpn-bindings.robot

*** Variables ***
${connectivity_id}=  robot-connectivity-test-1
${vpn_id}=  robot-vpn-test-1
${connectivity_class}=  connectivity
${vpn_class}=  vpn-binding

*** Test Cases ***
Connectivity test case
    [Tags]    aai  csit  ccvpn  connectivity  csit_aai_ccvpn_connectivity
    Confirm API Not Implemented Connectivity  ${connectivity_id}
    Get Example Connectivity
    Confirm No Connectivity  ${connectivity_id}
    Create Connectivity If Not Exists  ${connectivity_id}
    ${get_resp}=  Get Connectivity  ${connectivity_id}
    ${nodes_resp}=  Get Nodes Query Connectivity  ${connectivity_id}
    [Teardown]  Run Keywords  Delete Connectivity If Exists  ${connectivity_id}  AND  Confirm No Connectivity  ${connectivity_id}

VPN Binding test case
    [Tags]    aai  csit  ccvpn  vpn-binding  csit_aai_ccvpn_vpn-binding
    Confirm API Not Implemented VPN Binding  ${vpn_id}
    Get Example VPN Binding
    Confirm No VPN Binding  ${vpn_id}
    Create VPN Binding If Not Exists  ${vpn_id}
    ${get_resp}=  Get VPN Binding  ${vpn_id}
    ${nodes_resp}=  Get Nodes Query VPN Binding  ${vpn_id}
    [Teardown]  Run Keywords  Delete VPN Binding If Exists  ${vpn_id}  AND  Confirm No VPN Binding  ${vpn_id}

Connectivity to VPN Binding Relationship test case
    [Tags]    aai  csit  ccvpn  connectivity  vpn-binding  relationship  csit_aai_ccvpn_connectivity_vpn-binding_relationship
    Confirm No Connectivity  ${connectivity_id}
    Confirm No VPN Binding  ${vpn_id}
    Create Connectivity If Not Exists  ${connectivity_id}
    Create VPN Binding If Not Exists  ${vpn_id}
    Get Connectivity  ${connectivity_id}
    Get VPN Binding  ${vpn_id}
    ${vpnbinding_url}=  Get Valid VPN Binding URL  ${vpn_id}
    Add Connectivity Relationship  ${connectivity_id}  ${vpn_class}  ${vpnbinding_url}
    ${connectivity_rel}=  Get Connectivity RelationshipList  ${connectivity_id}
    ${connectivity_rel_txt}=  Catenate  ${connectivity_rel}
    Should Match Regexp    ${connectivity_rel_txt}     ${vpnbinding_url}
    Should Match Regexp    ${connectivity_rel_txt}     ${vpn_class}
    Get Connectivity With RelationshipList  ${connectivity_id}
    [Teardown]  Run Keywords  Delete Connectivity If Exists  ${connectivity_id}  AND  Delete VPN Binding If Exists  ${vpn_id}

VPN Binding Relationship to Connectivity test case
    [Tags]    aai  csit  ccvpn  connectivity  vpn-binding  relationship  csit_aai_ccvpn_vpn-binding_connectivity_relationship
    Confirm No Connectivity  ${connectivity_id}
    Confirm No VPN Binding  ${vpn_id}
    Create Connectivity If Not Exists  ${connectivity_id}
    Create VPN Binding If Not Exists  ${vpn_id}
    Get Connectivity  ${connectivity_id}
    Get VPN Binding  ${vpn_id}
    ${connectivity_url}=  Get Valid Connectivity URL  ${connectivity_id}
    Add VPN Binding Relationship  ${vpn_id}  ${connectivity_class}  ${connectivity_url}
    ${vpn_rel}=  Get VPN Binding RelationshipList  ${vpn_id}
    ${vpn_rel_txt}=  Catenate  ${vpn_rel}
    Should Match Regexp    ${vpn_rel_txt}     ${connectivity_url}
    Should Match Regexp    ${vpn_rel_txt}     ${connectivity_class}
    Get VPN Binding With RelationshipList  ${vpn_id}
    [Teardown]  Run Keywords  Delete Connectivity If Exists  ${connectivity_id}  AND  Delete VPN Binding If Exists  ${vpn_id}

All Teardowns test case
    [Tags]    teardowns  csit_aai_ccvpn_teardowns
    Delete Connectivity If Exists  ${connectivity_id}
    Delete VPN Binding If Exists  ${vpn_id}
    Confirm No Connectivity  ${connectivity_id}
    Confirm No VPN Binding  ${vpn_id}

