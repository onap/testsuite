*** Settings ***
Documentation	  Testing openstack.
Library    OperatingSystem
Library    Process
Library    SSHLibrary
Library    RequestsLibrary
Library    ONAPLibrary.JSON
Library    ONAPLibrary.Openstack
Library    Collections
Library    String
Library           ONAPLibrary.ServiceMapping

Resource          ../openstack/keystone_interface.robot
Resource          ../openstack/nova_interface.robot
Resource          ../openstack/heat_interface.robot
Resource          ../ssh/files.robot
Resource          ../demo_preload.robot
Resource          packet_generator_interface.robot
Resource          validate_common.robot
Resource          ../test_templates/vnf_orchestration_test_template.robot


*** Variables ***

*** Keywords ***
Policy Check FirewallCL Stack
    [Documentation]    Executes the vFW policy closed loop test.
    [Arguments]    ${stacknamemap}    ${policy_rate}
    Run Openstack Auth Request    auth
    ${vsnk_stack_name}=   Get From Dictionary    ${stacknamemap}    vFWSNK
    ${vpkg_stack_name}=   Get From Dictionary    ${stacknamemap}    vPKG
    ${vsnk_stack_info}=    Wait for Stack to Be Deployed    auth    ${vsnk_stack_name}
    ${vpkg_stack_info}=    Wait for Stack to Be Deployed    auth    ${vpkg_stack_name}
    ${server_list}=    Get Openstack Servers    auth
    Log     ${server_list}
    ${vpkg_id}=   Get From Dictionary     ${vpkg_stack_info}   vnf_id
    ${status}  ${generic_vnf}=   Run Keyword And Ignore Error   Get Generic VNF By ID    ${vpkg_id}
    Run Keyword If   '${status}' == 'FAIL'   FAIL   VNF ID: ${vpkg_id} is not found.
    ${invariantUUID}   Get From Dictionary  ${generic_vnf}   persona-model-id
    Update vVFWCL Policy   ${invariantUUID}

    ${vpg_unprotected_ip}=    Get From Dictionary    ${vpkg_stack_info}    vpg_int_unprotected_private_ip_0
    ${vsn_protected_ip}=    Get From Dictionary    ${vsnk_stack_info}    vsn_int_protected_private_ip_0
    ${vpg_public_ip}=    Get Server Ip    ${server_list}    ${vpkg_stack_info}   vpg_name_0    network_name=public
    ${vsn_public_ip}=    Get Server Ip    ${server_list}    ${vsnk_stack_info}   vsn_name_0    network_name=public
    ${upper_bound}=    Evaluate    ${policy_rate}*2
    Wait Until Keyword Succeeds    30m    2s    Run VFW Policy Check    ${vpg_public_ip}   ${policy_rate}    ${upper_bound}    1

Run VFW Policy Check
    [Documentation]     Push traffic above upper bound, wait for policy to fix it, push traffic to lower bound, wait for policy to fix it,
    [Arguments]    ${vpg_public_ip}    ${policy_rate}    ${upper_bound}    ${lower_bound}
    # Force traffic above threshold
    Check For Policy Enforcement    ${vpg_public_ip}    ${policy_rate}    ${upper_bound}
    # Force traffic below threshold
    Check For Policy Enforcement    ${vpg_public_ip}    ${policy_rate}    ${lower_bound}


Check For Policy Enforcement
    [Documentation]     Push traffic above upper bound, wait for policy to fix it, push traffic to lower bound, wait for policy to fix it,
    [Arguments]    ${vpg_public_ip}    ${policy_rate}    ${forced_rate}
    Enable Streams    ${vpg_public_ip}    ${forced_rate}
    Wait Until Keyword Succeeds    20s    2s    Test For Expected Rate    ${vpg_public_ip}    ${forced_rate}
    Wait Until Keyword Succeeds    10m    2s    Test For Expected Rate    ${vpg_public_ip}    ${policy_rate}

Test For Expected Rate
    [Documentation]    Ge the number of pg-streams from the PGN, and test to see if it is what we expect.
    [Arguments]    ${vpg_public_ip}    ${number_of_streams}
    ${list}=    Get List Of Enabled Streams    ${vpg_public_ip}
    ${list}=    Evaluate   ${list['sample-plugin']}['pg-streams']['pg-stream']
    Length Should Be    ${list}    ${number_of_streams}



Policy Check vLB Stack
    [Documentation]    Executes the vLB policy closed loop test
    [Arguments]    ${stack_name}    ${policy_rate}
    Run Openstack Auth Request    auth
    ${stack_info}=    Wait for Stack to Be Deployed    auth    ${stack_name}
    ${stack_id}=    Get From Dictionary    ${stack_info}    id
    ${server_list}=    Get Openstack Servers    auth
    ${vlb_public_ip}=    Get Server Ip    ${server_list}    ${stack_info}   vlb_name_0    network_name=public
    ${upper_bound}=    Evaluate    ${policy_rate}*2
    Start DNS Traffic    ${vlb_public_ip}    ${upper_bound}

    # Now wiat for the dnsscaling stack to be deployed
    ${prefix}=    Get DNSScaling Prefix
    ${dnsscaling}=    Replace String Using Regexp    ${stack_name}    ^Vfmodule_    ${prefix}
    ${dnsscaling_info}=    Wait for Stack to Be Deployed    auth    ${dnsscaling}
    VLB Closed Loop Hack Update   ${dnsscaling}
    # TO DO: Log into vLB and cehck that traffic is flowing to the new DNS
    [Return]    ${dnsscaling}

Get DNSScaling Prefix
    Set Directory    default    ./demo/service_mapping
    ${mapping}=    Get Service Template Mapping    default    vLB    vLB
    :FOR   ${dict}    IN   @{mapping}
    \    Return From Keyword If    '${dict['isBase']}' == 'false'    ${dict['prefix']}
    [Return]   None


Start DNS Traffic
    [Documentation]   Run nslookups at rate per second. Run for 10 minutes or until it is called by the terminate process
    [Arguments]    ${vlb_public_ip}    ${rate}
    ${pid}=   Start Process   ./dnstraffic.sh   ${vlb_public_ip}   ${rate}   ${GLOBAL_DNS_TRAFFIC_DURATION}
    [Return]    ${pid}
