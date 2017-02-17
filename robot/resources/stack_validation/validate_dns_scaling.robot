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
Resource          packet_generator_interface.robot
Resource          validate_common.robot


*** Variables ***
${ASSETS}              ${EXECDIR}/robot/assets/

*** Keywords ***
Validate Dns Scaling Stack
    [Documentation]    Identifies the servers in the STACK_NAME in the GLOBAL_OPENSTACK_SERVICE_REGION
    [Arguments]    ${STACK_NAME}    
    Run Openstack Auth Request    auth
    ${stack_info}=    Wait for Stack to Be Deployed    auth    ${STACK_NAME}
    ${stack_id}=    Get From Dictionary    ${stack_info}    id
    ${server_list}=    Get Openstack Servers    auth 
    Log     ${server_list}
    #${vpg_unprotected_ip}=    Get From Dictionary    ${stack_info}    vpg_private_ip_0
    #${vsn_protected_ip}=    Get From Dictionary    ${stack_info}    vsn_private_ip_0
    ${vdns_public_ip}=    Get Server Ip    ${server_list}    ${stack_info}   vdns_name_0    network_name=public     
    Wait For Server    ${vdns_public_ip}
    Log    Accessed all servers
    #Wait for vDNS    ${vdns_public_ip}
    Log    All server processes up

Wait For vDNS
    [Documentation]     Wait for the defined firewall processes to come up
    [Arguments]    ${ip}    
    Wait for Process on Host    java DNSServer     ${ip}    

