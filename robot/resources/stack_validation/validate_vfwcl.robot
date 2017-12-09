*** Settings ***
Documentation	  Testing openstack.
Library    OperatingSystem
Library    SSHLibrary
Library    RequestsLibrary
Library    JSONUtils
Library    OpenstackLibrary
Library    HEATUtils
Library    Collections
Resource          ../../resources/openstack/keystone_interface.robot
Resource          ../../resources/openstack/nova_interface.robot
Resource          ../../resources/openstack/heat_interface.robot
Resource          ../../resources/ssh/files.robot
Resource          ../../resources/ssh/processes.robot
Resource          ../appc_interface.robot
Resource          packet_generator_interface.robot
Resource          validate_common.robot
Resource          validate_vfw.robot


*** Variables ***
${TV_VFW_PUBLIC_IP}
${TV_VSN_PUBLIC_IP}

*** Keywords ***
Validate FirewallPKG Stack
    [Documentation]    Identifies and validates the firewall servers in the VFW Stack
    [Arguments]    ${STACK_NAME}
    Run Openstack Auth Request    auth
    ${stack_info}=    Wait for Stack to Be Deployed    auth    ${STACK_NAME}
    ${stack_id}=    Get From Dictionary    ${stack_info}    id
    ${server_list}=    Get Openstack Servers    auth

    ${vpg_unprotected_ip}=    Get From Dictionary    ${stack_info}    vpg_private_ip_0
    ${vsn_protected_ip}=    Get From Dictionary    ${stack_info}    vsn_private_ip_0
    ${vpg_name_0}=    Get From Dictionary    ${stack_info}    vpg_name_0
    ${vnf_id}=    Get From Dictionary    ${stack_info}    vnf_id
    
    ${vpg_public_ip}=    Get Server Ip    ${server_list}    ${stack_info}   vpg_name_0    network_name=public
    Wait For Server    ${vpg_public_ip}
    Log    Accessed all servers
    Wait For Packet Generator    ${vpg_public_ip}
    Log    All server processes up
    ${vpg_oam_ip}=    Get From Dictionary    ${stack_info}    vpg_private_ip_1
    
    ${appc}=    Create Mount Point In APPC    ${vnf_id}    ${vpg_oam_ip}
    Wait For Packets   ${vpg_public_ip}   ${vpg_unprotected_ip}   ${vsn_protected_ip}   ${TV_VSN_PUBLIC_IP}

Validate FirewallSNK Stack
    [Documentation]    Identifies and validates the firewall servers in the VFW Stack
    [Arguments]    ${STACK_NAME}
    Run Openstack Auth Request    auth
    ${stack_info}=    Wait for Stack to Be Deployed    auth    ${STACK_NAME}
    ${stack_id}=    Get From Dictionary    ${stack_info}    id
    ${server_list}=    Get Openstack Servers    auth

    ${vfw_public_ip}=    Get Server Ip    ${server_list}    ${stack_info}   vfw_name_0    network_name=public
    ${vsn_public_ip}=    Get Server Ip    ${server_list}    ${stack_info}   vsn_name_0    network_name=public

    Wait For Server    ${vfw_public_ip}
    Wait For Server    ${vsn_public_ip}
    Log    Accessed all servers
    Wait For Firewall    ${vfw_public_ip}
    Wait For Packet Sink    ${vsn_public_ip}
    # Save for teh PKG validation
    Set Test Variable   ${TV_VFW_PUBLIC_IP}   ${vfw_public_ip}
    Set Test Variable   ${TV_VSN_PUBLIC_IP}   ${vsn_public_ip}
    Log    All server processes up


