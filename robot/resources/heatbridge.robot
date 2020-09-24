*** Settings ***
Library     HeatBridge
Library     Collections
Library     OperatingSystem
Library     ONAPLibrary.ServiceMapping    WITH NAME    ServiceMapping
Library     ONAPLibrary.Templating    WITH NAME    Templating
Library     ONAPLibrary.AAI    WITH NAME     AAI


Resource    openstack/keystone_interface.robot
Resource    openstack/heat_interface.robot
Resource    openstack/nova_interface.robot
Resource    openstack/neutron_interface.robot
Resource    aai/aai_interface.robot
Resource    aai/create_vnfc.robot

*** Variables ***
${MULTIPART_PATH}  /bulkadd
${NAMED_QUERY_PATH}  /aai/search/named-query
${NAMED_QUERY_TEMPLATE}    aai/named_query.jinja

${BASE_URI}   /cloud-infrastructure/cloud-regions/cloud-region/\${cloud}/\${region}
${IMAGE_URI}   ${BASE_URI}/images/image/\${image_id}
${FLAVOR_URI}   ${BASE_URI}/flavors/flavor/\${flavor}
${VSERVER_URI}   ${BASE_URI}/tenants/tenant/\${tenant}/vservers/vserver/\${vserver_id}
${L_INTERFACE_URI}   ${VSERVER_URI}/l-interfaces/l-interface/\${linterface_id}

*** Keywords ***
Execute Heatbridge
    [Documentation]   Run the Heatbridge against the stack to generate the bulkadd message
    ...    Execute the build add
    ...    Validate the add results by running the named query
    [Arguments]    ${stack_name}    ${vnf}    ${service}    ${ipv4_oam_address}
    Return From Keyword If    '${service}' == 'vVG'
    Run Openstack Auth Request    auth
    ${stack_info}=    Wait for Stack to Be Deployed    auth    ${stack_name}
    ${stack_id}=    Get From Dictionary    ${stack_info}    id
    ${tenant_id}=   Get From Dictionary    ${stack_info}    OS::project_id
    ${vnf_id}=    Get From Dictionary    ${stack_info}    vnf_id
    ${KeyIsPresent}=    Run Keyword And Return Status       Dictionary Should Contain Key       ${stack_info}      ${ipv4_oam_address}
    ${ipv4_vnf_address}=   Run Keyword If      ${KeyIsPresent}     Get From Dictionary  ${stack_info}      ${ipv4_oam_address}
    Run Set VNF Params  ${vnf_id}  ${ipv4_vnf_address}  ACTIVE  Active
    ### Create a vnfc for each vServer ###
    ${stack_resources}=    Get Stack Resources    auth    ${stack_name}    ${stack_id}
    ${resource_list}=    Get From Dictionary    ${stack_resources}    resources
    :FOR   ${resource}    IN    @{resource_list}
    \    Run Keyword If    '${resource['resource_type']}' == 'OS::Nova::Server'    Run Create VNFC    auth    ${resource['physical_resource_id']}    ${service}
    ${keystone_api_version}=    Run Keyword If    '${GLOBAL_INJECTED_OPENSTACK_KEYSTONE_API_VERSION}'==''    Get KeystoneAPIVersion
    ...    ELSE    Set Variable   ${GLOBAL_INJECTED_OPENSTACK_KEYSTONE_API_VERSION}
    ${url}   ${path}=   Get Keystone Url And Path   ${keystone_api_version}
    ${openstack_identity_url}=    Catenate    ${url}${path}
    ${region}=   Get Openstack Region
    ${user}   ${pass}=   Get Openstack Credentials
    Run Keyword If   '${keystone_api_version}'=='v2.0'    Init Bridge    ${openstack_identity_url}    ${user}    ${pass}    ${tenant_id}    ${region}   ${GLOBAL_AAI_CLOUD_OWNER}
    ...    ELSE    Init Bridge    ${openstack_identity_url}    ${user}    ${pass}    ${tenant_id}    ${region}   ${GLOBAL_AAI_CLOUD_OWNER}    ${GLOBAL_INJECTED_OPENSTACK_DOMAIN_ID}    ${GLOBAL_INJECTED_OPENSTACK_PROJECT_NAME}
    ${request}=    Bridge Data    ${stack_id}
    Log    ${request}
    ${resp}=    AAI.Run Put Request    ${AAI_FRONTEND_ENDPOINT}    ${VERSIONED_INDEX_PATH}${MULTIPART_PATH}    ${request}    auth=${GLOBAL_AAI_AUTHENTICATION}
    ${status_string}=    Convert To String    ${resp.status_code}
    Should Match Regexp    ${status_string} 	^(201|200)$
    ${reverse_heatbridge}=   Generate Reverse Heatbridge From Stack Info   ${stack_info}
    Run Validation Query    ${stack_info}    ${service}    ${vnf}
    [Return]    ${reverse_heatbridge}

Run Create VNFC
    [Documentation]    Create a VNFC for a vServer
    [Arguments]    ${alias}     ${vserver_id}    ${service}
    ${resp}=    Get Openstack Server By Id   ${alias}     ${vserver_id}
    Return From Keyword If   '${resp.status_code}' != '200'
    ${info}=   Set Variable   ${resp.json()}
    ${keys}=    Create Dictionary
    ${vnfc_name}=   Catenate    ${info['server']['name']}
    ${vnfc_nc}=    Set Variable  ${service}
    ${vnfc_func}=    Set Variable  ${service}
    Create VNFC If Not Exists    ${vnfc_name}     ${vnfc_nc}     ${vnfc_func}

Run Validation Query
    [Documentation]    Run A&AI query to validate the bulk add
    [Arguments]    ${stack_info}    ${service}    ${vnf}
    Return from Keyword If    '${service}' == ''
    ServiceMapping.Set Directory    default    ${GLOBAL_SERVICE_MAPPING_DIRECTORY}
    ${server_name_parameter}=    ServiceMapping.Get Validate Name Mapping    default    ${service}    ${vnf}
    ${vserver_name}=    Get From Dictionary    ${stack_info}   ${server_name_parameter}
    Run Vserver Query   ${vserver_name}

Run Vserver Query
    [Documentation]    Run A&AI query to validate the bulk add
    [Arguments]    ${vserver_name}
    ${dict}=    Create Dictionary    vserver_name=${vserver_name}
    Templating.Create Environment    aai    ${GLOBAL_TEMPLATE_FOLDER}
    ${request}=   Templating.Apply Template    aai   ${NAMED_QUERY_TEMPLATE}    ${dict}
    ${resp}=    AAI.Run Post Request      ${AAI_FRONTEND_ENDPOINT}    ${NAMED_QUERY_PATH}    ${request}	    auth=${GLOBAL_AAI_AUTHENTICATION}
    Should Be Equal As Strings    ${resp.status_code}    200

Run Set VNF Params
    [Documentation]  Run A&A GET and PUT to set prov-status, orchestration status, and ipv4-oam-address
    [Arguments]   ${vnf_id}  ${ipv4_vnf_address}  ${prov_status}=ACTIVE  ${orch_status}=Active
    ${payload}=  Run Get Generic VNF by VnfId   ${vnf_id}
    ${vnf_type}=    Catenate    ${payload['vnf-type']}
    set to dictionary    ${payload}    prov-status    ${prov_status}
    set to dictionary    ${payload}    orchestration-status   ${orch_status}
    set to dictionary    ${payload}    ipv4-oam-address  ${ipv4_vnf_address}
    ${payload_string}=    evaluate    json.dumps(${payload})    json
    ${put_resp}=    AAI.Run Put Request      ${AAI_FRONTEND_ENDPOINT}    ${VERSIONED_INDEX_PATH}/network/generic-vnfs/generic-vnf/${vnf_id}    ${payload_string}	auth=${GLOBAL_AAI_AUTHENTICATION}
    ${status_string}=    Convert To String    ${put_resp.status_code}
    Should Match Regexp    ${status_string}    ^(200|201)$
    Log    Set VNF ProvStatus: ${vnf_id} to ${prov_status}

Run Get Generic VNF By VnfId
    [Documentation]  Get VNF GET Payload with resource ID
    [Arguments]   ${vnf_id}
    ${resp}=    AAI.Run Get Request    ${AAI_FRONTEND_ENDPOINT}    ${VERSIONED_INDEX_PATH}/network/generic-vnfs/generic-vnf?vnf-id=${vnf_id}    auth=${GLOBAL_AAI_AUTHENTICATION}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]   ${resp.json()}

Execute Reverse Heatbridge
    [Documentation]   VID has already torn down the stack, reverse HB
    [Arguments]   ${uris_to_delete}
    Return From Keyword If   len(${uris_to_delete}) == 0
    :FOR   ${uri}    IN   @{uris_to_delete}
    \    Run Keyword And Ignore Error    Delete A&AI Entity   ${uri}

Generate Reverse Heatbridge From Stack Name
    [Arguments]   ${stack_name}
    Run Openstack Auth Request    auth
    ${stack_info}=    Wait for Stack to Be Deployed    auth    ${stack_name}   timeout=10s
    ${reverse_heatbridge}=    Generate Reverse Heatbridge From Stack Info   ${stack_info}
    [Return]    ${reverse_heatbridge}

Generate Reverse Heatbridge From Stack Info
    [Arguments]   ${stack_info}
    ${reverse_heatbridge}=    Create List
    ${stack_name}=    Get From Dictionary    ${stack_info}    name
    ${stack_id}=    Get From Dictionary    ${stack_info}    id
    ${tenant_id}=   Get From Dictionary    ${stack_info}    OS::project_id
    ${region}=   Get Openstack Region
    ${keys}=    Create Dictionary   region=${region}   cloud=${GLOBAL_AAI_CLOUD_OWNER}   tenant=${tenant_id}
    ${stack_resources}=    Get Stack Resources    auth    ${stack_name}    ${stack_id}
    ${resource_list}=    Get From Dictionary    ${stack_resources}    resources
    :FOR   ${resource}    IN    @{resource_list}
    \    Log     ${resource}
    \    Run Keyword If    '${resource['resource_type']}' == 'OS::Neutron::Port'    Generate Linterface Uri    auth    ${resource['physical_resource_id']}   ${reverse_heatbridge}   ${keys}
    :FOR   ${resource}    IN    @{resource_list}
    \    Log     ${resource}
    \    Run Keyword If    '${resource['resource_type']}' == 'OS::Nova::Server'    Generate Vserver Uri    auth    ${resource['physical_resource_id']}  ${reverse_heatbridge}   ${keys}   ${resource_list}
    [Return]    ${reverse_heatbridge}

Generate Vserver Uri
    [Documentation]   Run teardown against the server to generate a message that removes it
    [Arguments]    ${alias}    ${port_id}   ${reverse_heatbridge}   ${keys}   ${resource_list}
    ${resp}=    Get Openstack Server By Id   ${alias}	  ${port_id}
    Return From Keyword If   '${resp.status_code}' != '200'
    ${info}=   Set Variable   ${resp.json()}
    Set To Dictionary   ${keys}   vserver_id=${info['server']['id']}
    Set To Dictionary   ${keys}   flavor=${info['server']['flavor']['id']}
    Set To Dictionary   ${keys}   image_id=${info['server']['image']['id']}
    ${uri}=   Templating.Template String    ${VSERVER_URI}    ${keys}
    Append To List  ${reverse_heatbridge}   ${uri}
    ${uri}=   Templating.Template String    ${FLAVOR_URI}    ${keys}
    Append To List  ${reverse_heatbridge}   ${uri}
    ${uri}=   Templating.Template String    ${IMAGE_URI}    ${keys}
    Append To List  ${reverse_heatbridge}   ${uri}

Generate Linterface Uri
    [Documentation]   Run teardown against the server to generate a message that removes it
    [Arguments]    ${alias}    ${server_id}   ${reverse_heatbridge}   ${keys}
    ${resp}=    Get Openstack Port By Id   ${alias}	${server_id}
    Return From Keyword If   '${resp.status_code}' != '200'
    ${info}=   Set Variable   ${resp.json()}
    Set To Dictionary   ${keys}   vserver_id=${info['port']['device_id']}
    Set To Dictionary   ${keys}   linterface_id=${info['port']['name']}
    ${uri}=   Templating.Template String    ${L_INTERFACE_URI}    ${keys}
    Append To List  ${reverse_heatbridge}   ${uri}
