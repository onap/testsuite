*** Settings ***
Library     HeatBridge
Library     Collections
Library     StringTemplater
Library     OperatingSystem
Library     UUID

Resource    openstack/keystone_interface.robot
Resource    openstack/heat_interface.robot
Resource    openstack/nova_interface.robot
Resource    aai/aai_interface.robot

*** Variables ***
${VERSIONED_INDEX_PATH}     /aai/v8
${MULTIPART_PATH}  /bulkadd
${NAMED_QUERY_PATH}  /aai/search/named-query
${NAMED_QUERY_TEMPLATE}    robot/assets/templates/aai/named_query.template    
${REVERSE_HEATBRIDGE}


*** Keywords ***
Execute Heatbridge
    [Documentation]   Run the Heatbridge against the stack to generate the bulkadd message
    ...    Execute the build add
    ...    Validate the add results by running the named query 
    [Arguments]    ${stack_name}    ${service_instance_id}    ${service} 
    Return From Keyword If    '${service}' == 'vVG'   
    Run Openstack Auth Request    auth
    ${stack_info}=    Wait for Stack to Be Deployed    auth    ${stack_name}
    ${stack_id}=    Get From Dictionary    ${stack_info}    id
    ${tenant_id}=   Get From Dictionary    ${stack_info}    OS::project_id
    ${vnf_id}=    Get From Dictionary    ${stack_info}    vnf_id
    ${openstack_identity_url}=    Catenate    ${GLOBAL_OPENSTACK_KEYSTONE_SERVER}/v2.0   
    Init Bridge    ${openstack_identity_url}    ${GLOBAL_VM_PROPERTIES['openstack_username']}    ${GLOBAL_VM_PROPERTIES['openstack_password']}    ${tenant_id}    ${GLOBAL_OPENSTACK_SERVICE_REGION}    ${GLOBAL_AAI_CLOUD_OWNER}    
    ${request}=    Bridge Data    ${stack_id}
    Log    ${request}
    ${resp}=    Run A&AI Put Request    ${VERSIONED_INDEX_PATH}${MULTIPART_PATH}    ${request}
    Should Be Equal As Strings    ${resp.status_code}     200
    Generate Reverse Heatbridge   ${request}
    Run Validation Query    ${stack_info}    ${service}

Run Validation Query
    [Documentation]    Run A&AI query to validate the bulk add 
    [Arguments]    ${stack_info}    ${service}
    Return from Keyword If    '${service}' == ''    
    ${server_name_parameter}=    Get From Dictionary    ${GLOBAL_VALIDATE_NAME_MAPPING}    ${service}
    ${vserver_name}=    Get From Dictionary    ${stack_info}   ${server_name_parameter}
    Run Vserver Query   ${vserver_name}     

Run Vserver Query
    [Documentation]    Run A&AI query to validate the bulk add 
    [Arguments]    ${vserver_name}
    ${dict}=    Create Dictionary    vserver_name=${vserver_name}
    ${request}=    OperatingSystem.Get File    ${NAMED_QUERY_TEMPLATE}
    ${request}=    Template String    ${request}    ${dict}    
    ${resp}=    Run A&AI Post Request    ${NAMED_QUERY_PATH}    ${request}
    Should Be Equal As Strings    ${resp.status_code}    200   
    
Generate Reverse Heatbridge
    [Documentation]    Turn all of the HB puts into deletes... 
    [Arguments]    ${heatbridge_string}
    ${heatbridge}=  To Json    ${heatbridge_string}
    ${list}=    Get From Dictionary   ${heatbridge}   transactions
    ${transactions}=    Create List
    ${dupeDict}   Create Dictionary    
    :for   ${t}   in   @{list}
    \   ${entry}=    Get Deletes From Heatbridge   ${t}   ${dupeDict}
    \   Run Keyword If   len(${entry}) > 0    Append To List    ${transactions}   ${entry}    
    ${reverse}=    Create Dictionary    transactions=${transactions}
    Set Test Variable   ${REVERSE_HEATBRIDGE}   ${reverse}
    [Return]      ${REVERSE_HEATBRIDGE} 

Get Deletes From Heatbridge
    [Documentation]    Turn all of the HB puts into deletes... Should be one 'put' with one 
    ...   Not sure why this is structured this way, dictionary with operation as the key
    ...   So only one occurrance of an each operation, but with list of urls/bodies
    ...   So multiple gets, puts, etc. but in which order??? 
    [Arguments]    ${putDict}   ${dupeDict}
    ${deleteDict}=    Create Dictionary
    ${keys}=   Get Dictionary Keys    ${putDict} 
    # We do not expect anyhting other than 'put'
    :for   ${key}   in    @{keys}
    \    Should be Equal   ${key}   put  
    \    ${list}=   Get From Dictionary   ${putDict}   put
    \    ${deleteList}=   Get List Of Deletes   ${list}   ${dupeDict}
    \    Run Keyword If   len(${deleteList}) > 0   Set To Dictionary    ${deleteDict}   delete=${deleteList}
    [Return]    ${deleteDict}           

Get List Of Deletes
    [Documentation]    Turn the list of puts into a list of deletes... 
    ...   There is only on hash per 'put' but it looks like there can be more...
    [Arguments]    ${putList}    ${dupeDict}
    ${deleteList}=   Create List
    :for   ${put}   in    @{putList}     
    \   ${uri}=   Get From Dictionary   ${put}   uri
    \   Continue For Loop If    '${uri}' in ${dupeDict}
    \   ${delete}=    Create Dictionary   uri=${uri}
    \   Append To List     ${deleteList}   ${delete}
    \   Set To Dictionary   ${dupeDict}   ${uri}=${uri} 
    [Return]   ${deleteList}  
         
Execute Bulk Transaction    
    [Arguments]    ${transaction}
    :for   ${put}    in    ${transaction}
    \    Execute Put List    ${put}

Execute Put List 
    [Arguments]    ${put}
    Log    ${put}
    ${list}=   Get From Dictionary    ${put}    put 
    :for   ${request}    in    @{list}
    \    Execute Single Put    ${request}
        
Execute Single Put 
    [Arguments]    ${request}
    ${data}=    Get From Dictionary    ${request}    body
    ${path}=    Get From Dictionary    ${request}    uri
    ${resp}=    Run A&AI Put Request    ${VERSIONED_INDEX_PATH}${path}    ${data}
    Should Be Equal As Strings        ${resp.status_code} 	201
    

Execute Reverse Heatbridge
    [Documentation]   VID has already torn down the stack, reverse HB 
    [Arguments]    ${reverse_heatbridge}
    ${resp}=    Run A&AI Put Request    ${VERSIONED_INDEX_PATH}${MULTIPART_PATH}    ${reverse_heatbridge}
    Should Be Equal As Strings    ${resp.status_code}     200
    

Execute Heatbridge Teardown
    [Documentation]   Run teardown against the stack to generate a bulkadd message that removes it
    [Arguments]    ${stack_name}
    Run Openstack Auth Request    auth
    ${stack_info}=    Wait for Stack to Be Deployed    auth    ${stack_name}
    ${stack_id}=    Get From Dictionary    ${stack_info}    id
    ${tenant_id}=   Get From Dictionary    ${stack_info}    OS::project_id
    ${stack_resources}=    Get Stack Resources    auth    ${stack_name}    ${stack_id}
    ${resource_list}=    Get From Dictionary    ${stack_resources}    resources
    Get Length    ${resource_list}
    Log     ${resource_list}
    :FOR   ${resource}    in    @{resource_list}
    \    Log     ${resource}
    \    Run Keyword If    '${resource['resource_type']}' == 'OS::Nova::Server'    Execute Server Teardown    auth    ${resource['physical_resource_id']}

Execute Server Teardown
    [Documentation]   Run teardown against the server to generate a message that removes it
    [Arguments]    ${alias}    ${server_id}
    ${server}=    Get Openstack Server By Id   ${alias}	${server_id}
    Log     ${server}