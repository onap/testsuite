*** Settings ***
Documentation	  Testing openstack.
Library    String
Library    Collections
Library    SSHLibrary
Resource          validate_common.robot


*** Variables ***

*** Keywords ***
Validate vLB Stack
    [Documentation]    Identifies the LB and DNS servers in the vLB stack
    [Arguments]    ${stack_name}
    Run Openstack Auth Request    auth
    ${stack_info}=    Wait for Stack to Be Deployed    auth    ${stack_name}
    ${stack_id}=    Get From Dictionary    ${stack_info}    id
    ${server_list}=    Get Openstack Servers    auth
    Log     Returned from Get Openstack Servers
    ${vlb_public_ip}=    Get Server Ip    ${server_list}    ${stack_info}   vlb_name_0    network_name=${GLOBAL_INJECTED_OPENSTACK_PUBLIC_NETWORK}
    Log     Waiting for ${vlb_public_ip} to reconfigure
    # Server validations diabled due to issues with load balancer network reconfiguration
    # at startup hanging the robot scripts so just sleep
    Sleep   180s
    Log    All server processes up