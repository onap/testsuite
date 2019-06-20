*** Settings ***
Documentation     The main interface for interacting with Openstack. It handles low level stuff like managing the authtoken and Openstack required fields
Library           ONAPLibrary.Openstack
Library 	      RequestsLibrary
Library           Collections
Library           ONAPLibrary.Templating    
Resource    ../global_properties.robot
Resource    openstack_common.robot

*** Variables ***
${OPENSTACK_NEUTRON_API_VERSION}    /v2.0
${OPENSTACK_NEUTRON_NETWORK_PATH}    /networks
${OPENSTACK_NEUTRON_NETWORK_ADD_BODY_FILE}    openstack/neutron_add_network.jinja
${OPENSTACK_NEUTRON_SUBNET_PATH}    /subnets
${OPENSTACK_NEUTRON_SUBNET_ADD_BODY_FILE}    openstack/neutron_add_subnet.jinja
${OPENSTACK_NEUTRON_PORT_PATH}    /ports

*** Keywords ***
Get Openstack Network
    [Documentation]    Runs an Openstack Request and returns the network info
    [Arguments]    ${alias}    ${network_id}
    ${resp}=    Internal Get Openstack    ${alias}    ${GLOBAL_OPENSTACK_NEUTRON_SERVICE_TYPE}    ${OPENSTACK_NEUTRON_NETWORK_PATH}    /${network_id}
    [Return]    ${resp.json()}

Get Openstack Networks
    [Documentation]    Runs an Openstack Request and returns the network info
    [Arguments]    ${alias}
    ${resp}=    Internal Get Openstack    ${alias}    ${GLOBAL_OPENSTACK_NEUTRON_SERVICE_TYPE}    ${OPENSTACK_NEUTRON_NETWORK_PATH}
    [Return]    ${resp.json()}

Get Openstack Subnets
    [Documentation]    Runs an Openstack Request and returns the network info
    [Arguments]    ${alias}
    ${resp}=    Internal Get Openstack    ${alias}    ${GLOBAL_OPENSTACK_NEUTRON_SERVICE_TYPE}    ${OPENSTACK_NEUTRON_SUBNET_PATH}
    [Return]    ${resp.json()}

Get Openstack Ports
    [Documentation]    Runs an Openstack Request and returns the network info
    [Arguments]    ${alias}
    ${resp}=    Internal Get Openstack    ${alias}    ${GLOBAL_OPENSTACK_NEUTRON_SERVICE_TYPE}    ${OPENSTACK_NEUTRON_PORT_PATH}
    [Return]    ${resp.json()}

Add Openstack Network
    [Documentation]    Runs an Openstack Request to add a network and returns that network id of the created network
    [Arguments]    ${alias}    ${name}
    ${arguments}=    Create Dictionary    name=${name}
    Create Environment    openstack    ${GLOBAL_TEMPLATE_FOLDER}
    ${data}=   Apply Template    openstack    ${OPENSTACK_NEUTRON_NETWORK_ADD_BODY_FILE}    ${arguments}
    ${resp}=    Internal Post Openstack    ${alias}    ${GLOBAL_OPENSTACK_NEUTRON_SERVICE_TYPE}    ${OPENSTACK_NEUTRON_NETWORK_PATH}    data_path=    data=${data}
    Should Be Equal As Strings    201  ${resp.status_code}
    [Return]    ${resp.json()['network']['id']}

Delete Openstack Network
    [Documentation]    Runs an Openstack Request to delete a network
    [Arguments]    ${alias}    ${network_id}
    ${resp}=    Internal Delete Openstack    ${alias}    ${GLOBAL_OPENSTACK_NEUTRON_SERVICE_TYPE}    ${OPENSTACK_NEUTRON_NETWORK_PATH}	  /${network_id}
    ${status_string}=    Convert To String    ${resp.status_code}
    Should Match Regexp    ${status_string}    ^(204|200)$
    [Return]    ${resp.text}

Add Openstack Network With Subnet If Not Exists
    [Documentation]    Runs an Openstack Request to add a network and returns that network id of the created network
    [Arguments]    ${alias}    ${name}    ${cidr}
    ${network}=    Get Openstack Subnet By Name    ${alias}    ${name}   ${cidr}
    ${pass}    ${v}=    Run Keyword and Ignore Error    Dictionary Should Contain Key    ${network}    id
    Run Keyword If    '${pass}' == 'FAIL'    Add Openstack Network With Subnet    ${alias}    ${name}    ${cidr}
    ${network}=    Get Openstack Subnet By Name    ${alias}    ${name}   ${cidr}
    ${network_id}=     Get From Dictionary    ${network}    id
    [Return]     ${network_id}


Add Openstack Network With Subnet
    [Documentation]    Runs an Openstack Request to add a network and returns that network id of the created network
    [Arguments]    ${alias}    ${name}    ${cidr}
    ${network_id}=    Add Openstack Network    ${alias}    ${name}
    ${arguments}=    Create Dictionary    network_id=${network_id}    cidr=${cidr}    subnet_name=${name}
    Create Environment    openstack    ${GLOBAL_TEMPLATE_FOLDER}
    ${data}=   Apply Template    openstack    ${OPENSTACK_NEUTRON_SUBNET_ADD_BODY_FILE}    ${arguments}
    ${resp}=    Internal Post Openstack    ${alias}    ${GLOBAL_OPENSTACK_NEUTRON_SERVICE_TYPE}    ${OPENSTACK_NEUTRON_SUBNET_PATH}    data_path=    data=${data}
    Should Be Equal As Strings    201  ${resp.status_code}
    [Return]     ${network_id}

Get Openstack Subnet By Name
    [Documentation]    Retrieve the subnet from openstack by it's name.
    [Arguments]    ${alias}    ${network_name}    ${network_cidr}
    ${resp}=    Get Openstack Subnets    ${alias}
    @{list}=    Get From Dictionary    ${resp}    subnets
    ${returnnet}=    Set Variable
    :FOR    ${net}    IN    @{list}
    \    ${name}=   Get From Dictionary    ${net}    name
    \    ${cidr}=   Get From Dictionary    ${net}    cidr
    \    ${returnnet}=    Set Variable    ${net}
    \    Exit For Loop If    '${name}'=='${network_name}' and '${cidr}'=='${network_cidr}'
    \    ${returnnet}=    Create DIctionary
    [Return]    ${returnnet}

Get Openstack IP By Name
    [Arguments]    ${alias}    ${network_name}    ${cidr}    ${ip}
    ${ports}=    Get Openstack Ports For Subnet    ${alias}    ${network_name}    ${cidr}
    Log    ${ports}
    :FOR    ${port}   IN   @{ports}
    \    Return From Keyword If    '${port['fixed_ips'][0]['ip_address']}' == '${ip}'    ${port}
    [Return]    None

Get Openstack Ports For Subnet
    [Arguments]    ${alias}    ${network_name}    ${cidr}
    ${net}=    Get Openstack Subnet By Name    ${alias}    ${network_name}    ${cidr}
    ${ports}=    Get Openstack Ports     ${alias}
    ${net_ports}=    Create List
    :FOR    ${port}    IN    @{ports['ports']}
    \    Run Keyword If   '${net['network_id']}' == '${port['network_id']}'    Append To List    ${net_ports}   ${port}
    [Return]   ${net_ports}

Get Openstack Port By Id
    [Arguments]    ${alias}    ${port_id}
    ${resp}=    Internal Get Openstack    ${alias}    ${GLOBAL_OPENSTACK_NEUTRON_SERVICE_TYPE}    ${OPENSTACK_NEUTRON_PORT_PATH}/${port_id}
    [Return]    ${resp}


Delete Openstack Port
    [Arguments]    ${alias}    ${port_id}
    ${resp}=    Internal Delete Openstack    ${alias}    ${GLOBAL_OPENSTACK_NEUTRON_SERVICE_TYPE}    ${OPENSTACK_NEUTRON_PORT_PATH}	  /${port_id}
    ${status_string}=    Convert To String    ${resp.status_code}
    Should Match Regexp    ${status_string}    ^(204|200)$
    [Return]    ${resp.text}

