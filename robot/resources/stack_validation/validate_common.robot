*** Settings ***
Documentation	  Testing openstack.
Library    OperatingSystem
Library    SSHLibrary
Library    RequestsLibrary
Library    ONAPLibrary.JSON
Library    ONAPLibrary.Openstack
Library    Collections
Resource          ../../resources/openstack/keystone_interface.robot
Resource          ../../resources/openstack/nova_interface.robot
Resource          ../../resources/openstack/heat_interface.robot
Resource          ../../resources/ssh/files.robot
Resource          packet_generator_interface.robot


*** Variables ***

*** Keywords ***
Wait For Server
    [Documentation]    Attempts to login to the passed server info and verify (??). Uses server info to get public ip and locate corresponding provate key file
    [Arguments]    ${server_ip}    ${timeout}=300s
    Wait Until Keyword Succeeds    ${timeout}    5 sec    Open Connection And Log In    ${server_ip}    root    ${GLOBAL_INJECTED_PRIVATE_KEY}
    ${lines}=   Grep Local File    "Accepted publickey"    /var/log/auth.log
    Log    ${lines}
    Should Not Be Empty    ${lines}

Get Server Ip
    [Arguments]    ${server_list}    ${stack_info}    ${key_name}    ${network_name}=public
    ${server_name}=   Get From Dictionary     ${stack_info}   ${key_name}
    ${server}=    Get From Dictionary    ${server_list}    ${server_name}
    Log    Entering Get Openstack Server Ip
    ${ip}=    Search Addresses    ${server}    ${network_name}
    Log    Returned Get Openstack Server Ip
    [Return]    ${ip}

Find And Reboot The Server
    [Documentation]    Code to reboot the server by teh heat server name parameter value
    [Arguments]    ${stack_info}    ${server_list}    ${server_name_parameter}
    ${server_name}=   Get From Dictionary     ${stack_info}   ${server_name_parameter}
    ${vfw_server}=    Get From Dictionary    ${server_list}    ${server_name}
    ${vfw_server_id}=    Get From Dictionary    ${vfw_server}    id
    Reboot Server    auth   ${vfw_server_id}


Search Addresses
    [Arguments]   ${server}   ${network_name}
    ${addresses}   Get From Dictionary   ${server}   addresses
    ${status}   ${server_ip}=   Run Keyword And Ignore Error   Find Rackspace   ${addresses}   ${network_name}
    Return From Keyword If   '${status}'=='PASS'   ${server_ip}
    ${status}   ${server_ip}=   Run Keyword And Ignore Error   Find Openstack   ${addresses}   ${network_name}
    Return From Keyword If   '${status}'=='PASS'   ${server_ip}
    ${status}   ${server_ip}=   Run Keyword And Ignore Error   Find Openstack 2   ${addresses}   ${network_name}
    Return From Keyword If   '${status}'=='PASS'   ${server_ip}
    Fail  ${server}/${network_name} Not Found

Find Rackspace
    [Arguments]   ${addresses}   ${network_name}
    ${ips}   Get From Dictionary   ${addresses}   ${network_name}
    ${ip}=   Get V4 IP   ${ips}
    [Return]   ${ip}

Find Openstack
    [Arguments]   ${addresses}   ${network_name}
    ${network_name}=   Set Variable If    '${network_name}' == 'public'    external   ${network_name}
    ${ip}=   Get V4 IP Openstack   ${addresses}   ${network_name}
    [Return]   ${ip}

Find Openstack 2
    [Arguments]   ${addresses}   ${network_name}
    ${network_name}=   Set Variable If    '${network_name}' == 'public'    floating   ${network_name}
    ${ipmaps}=   Get From Dictionary   ${addresses}   ${GLOBAL_INJECTED_NETWORK}
    ${ip}=   Get V4 IP Openstack 2  ${ipmaps}   ${network_name}
    [Return]   ${ip}

Get V4 IP
    [Arguments]   ${ipmaps}
    :FOR   ${ipmap}   IN   @{ipmaps}
    \    ${ip}   Get From Dictionary   ${ipmap}   addr
    \    ${version}   Get From Dictionary   ${ipmap}   version
    \    Return from Keyword if   '${version}' == '4'   ${ip}
    Fail  No Version 4 IP

Get V4 IP Openstack
    [Arguments]   ${addresses}   ${testtype}
    ${ipmaps}=   Get From Dictionary   ${addresses}   ${testtype}
    :FOR   ${ipmap}   IN   @{ipmaps}
    \    ${ip}   Get From Dictionary   ${ipmap}   addr
    \    ${version}   Get From Dictionary   ${ipmap}   version
    \    Return from Keyword if   '${version}'=='4'   ${ip}
    Fail  No Version 4 IP

Get V4 IP Openstack 2
    [Arguments]   ${ipmaps}   ${testtype}
    :FOR   ${ipmap}   IN   @{ipmaps}
    \    ${type}   Get From Dictionary   ${ipmap}   OS-EXT-IPS:type
    \    ${ip}   Get From Dictionary   ${ipmap}   addr
    \    ${version}   Get From Dictionary   ${ipmap}   version
    \    Return from Keyword if   '${version}'=='4' and '${type}'=='${testtype}'   ${ip}
    Fail  No Version 4 IP
