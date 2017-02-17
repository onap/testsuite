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


*** Variables ***
${ASSETS}              ${EXECDIR}/robot/assets/

*** Keywords ***
Validate Firewall Stack
    [Documentation]    Identifies the firewall servers in the VFW Stack in the GLOBAL_OPENSTACK_SERVICE_REGION
    [Arguments]    ${STACK_NAME}    
    Run Openstack Auth Request    auth
    ${stack_info}=    Wait for Stack to Be Deployed    auth    ${STACK_NAME}
    ${stack_id}=    Get From Dictionary    ${stack_info}    id
    ${server_list}=    Get Openstack Servers    auth 

    ${vpg_unprotected_ip}=    Get From Dictionary    ${stack_info}    vpg_private_ip_0
    ${vsn_protected_ip}=    Get From Dictionary    ${stack_info}    vsn_private_ip_0
    ${vpg_name_0}=    Get From Dictionary    ${stack_info}    vpg_name_0
    ${vfw_public_ip}=    Get Server Ip    ${server_list}    ${stack_info}   vfw_name_0    network_name=public     
    ${vpg_public_ip}=    Get Server Ip    ${server_list}    ${stack_info}   vpg_name_0    network_name=public     
    ${vsn_public_ip}=    Get Server Ip    ${server_list}    ${stack_info}   vsn_name_0    network_name=public     
    
    Wait For Server    ${vfw_public_ip}
    Wait For Server    ${vpg_public_ip}
    Wait For Server    ${vsn_public_ip}
    Log    Accessed all servers
    Wait For Firewall    ${vfw_public_ip}        
    Wait For Packet Generator    ${vpg_public_ip}      
    Wait For Packet Sink    ${vsn_public_ip}        
    Log    All server processes up
    ${appc}=    Create Mount Point In APPC    ${vpg_name_0}    ${vpg_public_ip}

    # Following hack was implemented because the stack doesn't always come up clean
    # It was found that rebooting the servers at this point did not improve the
    # chances of the packets flowing to the SNK 
    #${status}    ${data}=    Run Keyword And Ignore Error    Wait For Packets   ${vpg_public_ip}   ${vpg_unprotected_ip}   ${vsn_protected_ip}   ${vsn_public_ip}
    #Return From Keyword if    '${status}' == 'PASS'
    #Close All Connections
    #Find And Reboot The Server    ${stack_info}    ${server_list}    vfw_name_0 
    #Find And Reboot The Server    ${stack_info}    ${server_list}    vpg_name_0 
    #Find And Reboot The Server    ${stack_info}    ${server_list}    vsn_name_0
    ## Gives some time for servers to shutdown 
    #Sleep    10s 
    #Wait For Server    ${vfw_public_ip}
    #Wait For Server    ${vpg_public_ip}
    #Wait For Server    ${vsn_public_ip}

    Wait For Packets   ${vpg_public_ip}   ${vpg_unprotected_ip}   ${vsn_protected_ip}   ${vsn_public_ip}
    
Wait For Packets
    [Documentation]    Final vfw validation that packets are flowing from the pgn VM  to the snk VM
    [Arguments]   ${vpg_public_ip}   ${vpg_unprotected_ip}   ${vsn_protected_ip}   ${vsn_public_ip}             
    ${resp}=    Enable Stream    ${vpg_public_ip}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${syslog_message}=    Catenate    UDP: short packet: From ${vpg_unprotected_ip}:.* to ${vsn_protected_ip}:.* 
    Tail File on Host Until    ${vsn_public_ip}    UDP:    /var/log/syslog    ${syslog_message}    timeout=120s
    Disable All Streams    ${vpg_public_ip}    


Wait For Firewall
    [Documentation]     Wait for the defined firewall processes to come up
    [Arguments]    ${ip}    
    Wait for Process on Host    ./vpp_measurement_reporter    ${ip}    
    Wait for Process on Host    vpp -c /etc/vpp/startup.conf    ${ip}    

Wait For Packet Generator
    [Documentation]     Wait for the defined packet generator processes to come up
    [Arguments]    ${ip}    
    Wait for Process on Host    vpp -c /etc/vpp/startup.conf    ${ip}    
    Wait for Process on Host    java .* -jar /opt/honeycomb/Honeycomb/vpp-integration/minimal-distribution/target/vpp-integration-distribution-1.16.9-hc/vpp-integration-distribution-1.16.9/vpp-integration-distribution-1.16.9.jar    ${ip}    
    Wait Until Keyword Succeeds    180s    5s    Tail File on Host Until    ${ip}    Honeycomb    /var/log/honeycomb/honeycomb.log    - Honeycomb initialized   options=-c +0    timeout=120s
    Run Keyword And Ignore Error    Wait for Process on Host    run_traffic_fw_demo.sh    ${ip}    timeout=60s  
    Pkill Process On Host    "/bin/bash ./run_traffic_fw_demo.sh"    ${ip}
    
Wait For Packet Sink
    [Documentation]     Wait for the defined packet sink processes to come up
    [Arguments]    ${ip}
    Log    noting to check on ${ip}    
