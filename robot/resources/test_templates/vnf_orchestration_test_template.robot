*** Settings ***
Documentation	  This test template encapsulates the VNF Orchestration use case.

Resource        ../vid/create_service_instance.robot
Resource        ../vid/vid_interface.robot
Resource        ../aai/service_instance.robot
Resource        ../vid/create_vid_vnf.robot
Resource        ../vid/teardown_vid.robot
Resource        ../sdnc_interface.robot
Resource        model_test_template.robot

Resource        ../aai/create_zone.robot
Resource        ../aai/create_customer.robot
Resource        ../aai/create_complex.robot
Resource        ../aai/create_tenant.robot
Resource        ../aai/create_service.robot
Resource        ../openstack/neutron_interface.robot
Resource        ../heatbridge.robot


Library         ONAPLibrary.Openstack
Library 	    SeleniumLibrary
Library	        Collections
Library	        ONAPLibrary.Utilities
Library         ONAPLibrary.JSON
Library         ONAPLibrary.ServiceMapping    WITH NAME    ServiceMapping


*** Keywords ***
Orchestrate VNF Template
    [Documentation]   Use ONAP to Orchestrate a service.
    [Arguments]    ${customer_name}    ${service}    ${product_family}    ${delete_flag}=DELETE
    ${uuid}=    Generate UUID4
    ${catalog_service_id}=    Set Variable    ${None}    # default to empty
    ${catalog_resource_ids}=    Set Variable    ${None}    # default to empty
    ${tenant_id}    ${tenant_name}=    Setup Orchestrate VNF    ${GLOBAL_AAI_CLOUD_OWNER}    SharedNode    OwnerType    v1    CloudZone
    ${vf_module_name_list}   ${generic_vnfs}    ${server_id}    ${service_instance_id}    ${catalog_resource_ids}   ${catalog_service_id}    ${uris_to_delete}=    Orchestrate VNF   ${customer_name}_${uuid}    ${service}    ${product_family}    ${tenant_id}    ${tenant_name}
    Run Keyword If   '${delete_flag}' == 'DELETE'   Delete VNF    ${tenant_name}    ${server_id}    ${customer_name}_${uuid}    ${service_instance_id}    ${vf_module_name_list}    ${uris_to_delete}
    [Teardown]         Teardown VNF    ${customer_name}_${uuid}    ${catalog_service_id}    ${catalog_resource_ids}

Orchestrate VNF
    [Documentation]   Use ONAP to Orchestrate a service.
    [Arguments]    ${customer_name}    ${service}    ${product_family}    ${tenant_id}    ${tenant_name}    ${project_name}=Project-Demonstration   ${owning_entity}=OE-Demonstration
    ${lcp_region}=   Get Openstack Region
    ${uuid}=    Generate UUID4
    ${service_name}=    Catenate    Service_Ete_Name${uuid}
    ${service_type}=    Set Variable    ${service}
    ${service_model_type}     ${vnf_type}    ${vf_modules}   ${catalog_resources}    ${catalog_resource_ids}   ${catalog_service_id}=    Model Distribution For Directory    ${service}
    ${server_id}=     Run Keyword If   '${service}' == 'vVG'    Create VVG Server    ${uuid}
    Create Customer For VNF    ${customer_name}    ${customer_name}    INFRA    ${service_type}    ${GLOBAL_AAI_CLOUD_OWNER}    ${tenant_id}
    Setup Browser
    Login To VID GUI
    ${service_instance_id}=   Wait Until Keyword Succeeds    300s   5s    Create VID Service Instance    ${customer_name}    ${service_model_type}    ${service}     ${service_name}   ${project_name}   ${owning_entity}
    Wait Until Keyword Succeeds   60s   20s      Validate Service Instance    ${service_instance_id}    ${service}      ${customer_name}
    ServiceMapping.Set Directory    default    ${GLOBAL_SERVICE_MAPPING_DIRECTORY}
    ${vnflist}=    ServiceMapping.Get Service Vnf Mapping    default    ${service}
    ${generic_vnfs}=    Create Dictionary
    ${vnf_name_index}=   Set Variable  0
    ${vf_module_name_list}=    Create List
    ${uuid}=    Evaluate    str("${uuid}")[:8]
    :FOR   ${vnf}   IN   @{vnflist}
    # APPC max is 50 characters
    \   ${vnf_name}=    Catenate    Ete_${vnf}_${uuid}_${vnf_name_index}
    \   ${vf_module_name}=    Catenate    Vfmodule_Ete_${vnf}_${uuid}_${vnf_name_index}
    \   ${vnf_name_index}=   Evaluate   ${vnf_name_index} + 1
    \   ${vnf_type}=   Get VNF Type   ${catalog_resources}   ${vnf}    ${service}
    \   ${vf_module}=    Get VF Module    ${catalog_resources}   ${vnf}    ${service}
    \   Create VID VNF    ${service_instance_id}    ${vnf_name}    ${product_family}    ${lcp_region}    ${tenant_name}    ${vnf_type}   ${customer_name}
    \   ${vf_module_type}   ${closedloop_vf_module}=   Preload Vnf    ${service_instance_id}   ${vnf_name}   ${vnf_type}   ${vf_module_name}    ${vf_module}    ${vnf}    ${uuid}    ${service}
    \   ${vf_module_id}=   Create VID VNF module    ${service_instance_id}    ${vf_module_name}    ${lcp_region}    ${tenant_name}     ${vf_module_type}   ${customer_name}   ${vnf_name}
    \   ${generic_vnf}=   Validate Generic VNF    ${vnf_name}    ${vnf_type}    ${service_instance_id}
    \   Set To Dictionary    ${generic_vnfs}    ${vf_module_type}    ${generic_vnf}
    #    TODO: Need to look at a better way to default ipv4_oam_interface  search for Heatbridge
    \   ${uris_to_delete}=    Execute Heatbridge    ${vf_module_name}    ${vnf}  ${service}    ipv4_oam_interface
    \   Validate VF Module      ${vf_module_name}    ${vnf}
    \   Append To List   ${vf_module_name_list}    ${vf_module_name}
    [Return]     ${vf_module_name_list}   ${generic_vnfs}    ${server_id}    ${service_instance_id}    ${catalog_resource_ids}   ${catalog_service_id}    ${uris_to_delete}


Orchestrate Demo VNF
    [Documentation]   Use ONAP to Orchestrate a service from Demonstration Models.
    [Arguments]    ${customer_name}    ${service}    ${product_family}    ${tenant_id}    ${tenant_name}  ${project_name}=Project-Demonstration   ${owning_entity}=OE-Demonstration
    ${service_model_type}=   Set Variable If
    ...                      '${service}'=='vFWCL'     demoVFWCL
    ...                      '${service}'=='vFW'       demoVFW
    ...                      '${service}'=='vLB'       demoVLB
    ${lcp_region}=   Get Openstack Region
    ${uuid}=    Generate UUID4
    ${full_customer_name}=    Catenate    ${customer_name}_${uuid}
    #${full_customer_name}=     Catenate    ${customer_name}
    ${list}=    Create List
    ${vf_module_name_list}=    Create List
    ${service_name}=    Catenate    Service_Ete_Name${uuid}
    ${service_type}=    Set Variable    ${service}
    ${vnf_json_resources}=   Get SDC Demo Vnf Catalog Resource      ${service_model_type}
    ${server_id}=     Run Keyword If   '${service}' == 'vVG'    Create VVG Server    ${uuid}
    Create Customer For VNF    ${full_customer_name}    ${full_customer_name}    INFRA    ${service_type}    ${GLOBAL_AAI_CLOUD_OWNER}    ${tenant_id}
    Setup Browser
    Login To VID GUI
    #${service_instance_id}=   Wait Until Keyword Succeeds    300s   5s    Create VID Service Instance    ${customer_name}    ${service_model_type}    ${service}     ${service_name}   ${project_name}   ${owning_entity}
    ${service_instance_id}=   Wait Until Keyword Succeeds    300s   5s    Create VID Service Instance    ${full_customer_name}    ${service_model_type}    ${service}     ${service_name}   ${project_name}   ${owning_entity}
    #Validate Service Instance    ${service_instance_id}    ${service}      ${customer_name}
    Validate Service Instance    ${service_instance_id}    ${service}      ${full_customer_name}
    ServiceMapping.Set Directory    default    ${GLOBAL_SERVICE_MAPPING_DIRECTORY}
    ${vnflist}=    ServiceMapping.Get Service Vnf Mapping    default    ${service}
    ${generic_vnfs}=    Create Dictionary
    :FOR   ${vnf}   IN   @{vnflist}
    \   ${vnf_name}=    Catenate    Ete_${vnf}_${uuid}
    \   ${vf_module_name}=    Catenate    Vfmodule_Demo_${vnf}_${uuid}
    \   ${vnf_type}=    Set Variable  ${vnf_json_resources['${vnf}']['vnf_type']}
    \   ${vf_module}=   Set Variable  ${vnf_json_resources['${vnf}']['vf_module']}
    \   Create VID VNF    ${service_instance_id}    ${vnf_name}    ${product_family}    ${lcp_region}    ${tenant_name}    ${vnf_type}   ${full_customer_name}
    \   ${vf_module_entry}=   Create Dictionary    name=${vf_module}
    \   ${vf_modules}=   Create List    ${vf_module_entry}
    \   ${vf_module_type}   ${closedloop_vf_module}=   Preload Vnf    ${service_instance_id}   ${vnf_name}   ${vnf_type}   ${vf_module_name}    ${vf_modules}    ${vnf}    ${uuid}    ${service}   ${server_id}
    \   ${vf_module_id}=   Create VID VNF module    ${service_instance_id}    ${vf_module_name}    ${lcp_region}    ${tenant_name}     ${vf_module_type}   ${full_customer_name}   ${vnf_name}
    \   ${generic_vnf}=   Validate Generic VNF    ${vnf_name}    ${vnf_type}    ${service_instance_id}
    \   Set To Dictionary    ${generic_vnfs}    ${vf_module_type}    ${generic_vnf}
    #    TODO: Need to look at a better way to default ipv4_oam_interface  search for Heatbridge
    \   Execute Heatbridge    ${vf_module_name}    ${vnf}  ${service}    ipv4_oam_interface
    \   Validate VF Module      ${vf_module_name}    ${vnf}
    \   Append To List   ${vf_module_name_list}   ${vf_module_name}
    [Return]     ${vf_module_name}    ${service}    ${generic_vnfs}


Get VNF Type
    [Documentation]    To support services with multiple VNFs, we need to dig the vnf type out of the SDC catalog resources to select in the VID UI
    [Arguments]   ${resources}   ${vnf}    ${service}
    ${cr}=   Get Catalog Resource    ${resources}    ${vnf}    ${service}
    ${vnf_type}=   Get From Dictionary   ${cr}   name
    [Return]   ${vnf_type}

Get VF Module
    [Documentation]    To support services with multiple VNFs, we need to dig the vnf type out of the SDC catalog resources to select in the VID UI
    [Arguments]   ${resources}   ${vnf}    ${service}
    ${cr}=   Get Catalog Resource    ${resources}    ${vnf}    ${service}
    ${vf_module}=    Find Element In Array    ${cr['groups']}    type    org.openecomp.groups.VfModule
    [Return]  ${vf_module}

Get Catalog Resource
    [Documentation]    To support services with multiple VNFs, we need to dig the vnf type out of the SDC catalog resources to select in the VID UI
    [Arguments]   ${resources}   ${vnf}    ${service}

    ${base_name}=  Get Name Pattern   ${vnf}    ${service}
    ${keys}=    Get Dictionary Keys    ${resources}

    :FOR   ${key}   IN    @{keys}
    \    ${cr}=   Get From Dictionary    ${resources}    ${key}
    \    Return From Keyword If   '${base_name}' in '${cr['allArtifacts']['heat1']['artifactDisplayName']}'    ${cr}
    \    Run Keyword If    'heat2' in ${cr['allArtifacts']}    Return From Keyword If   '${base_name}' in '${cr['allArtifacts']['heat2']['artifactDisplayName']}'    ${cr}
    Fail    Unable to find catalog resource for ${vnf} ${base_name}

Get Name Pattern
    [Documentation]    To support services with multiple VNFs, we need to dig the vnf type out of the SDC catalog resources to select in the VID UI
    [Arguments]   ${vnf}    ${service}
    ServiceMapping.Set Directory    default    ${GLOBAL_SERVICE_MAPPING_DIRECTORY}
    ${list}=    ServiceMapping.Get Service Template Mapping    default    ${service}    ${vnf}
    :FOR    ${dict}   IN   @{list}
    \   ${base_name}=   Get From Dictionary    ${dict}    name_pattern
    \   Return From Keyword If   '${dict['isBase']}' == 'true'   ${base_name}
    Fail  Unable to locate base name pattern

Create Customer For VNF
    [Documentation]    VNF Orchestration Test setup....
    ...                Create Tenant if not exists, Create Customer, Create Service and related relationships
    [Arguments]    ${customer_name}    ${customer_id}    ${customer_type}    ${service_type}    ${cloud_owner}    ${tenant_id}
    ${cloud_region_id}=   Get Openstack Region
    Create Service If Not Exists    ${service_type}
    ${resp}=    Create Customer    ${customer_name}    ${customer_id}    ${customer_type}    ${service_type}   ${cloud_owner}  ${cloud_region_id}    ${tenant_id}
	Should Be Equal As Strings 	${resp} 	201

Setup Orchestrate VNF
    [Documentation]    Called before each test case to ensure tenant and region data
    ...                required by the Orchstrate VNF exists in A&AI
    [Arguments]        ${cloud_owner}  ${cloud_type}    ${owner_defined_type}    ${cloud_region_version}    ${cloud_zone}
    ${tenant_id}    ${tenant_name}=    Initialize Tenant From Openstack
    Run Openstack Auth Request    auth
    ${regs}=    Get Openstack Regions    auth
    :FOR    ${region}    IN    @{regs}
    \    Inventory Tenant If Not Exists    ${cloud_owner}  ${region}  ${cloud_type}    ${owner_defined_type}    ${cloud_region_version}    ${cloud_zone}    ${tenant_id}    ${tenant_name}
    Inventory Zone If Not Exists
    Inventory Complex If Not Exists    ${GLOBAL_AAI_COMPLEX_NAME}   ${GLOBAL_AAI_PHYSICAL_LOCATION_ID}   ${GLOBAL_AAI_CLOUD_OWNER}   ${GLOBAL_INJECTED_REGION}   ${GLOBAL_AAI_CLOUD_OWNER_DEFINED_TYPE}
    Log   Orchestrate VNF setup complete
    [Return]    ${tenant_id}    ${tenant_name}

Initialize Tenant From Openstack
    [Documentation]    Initialize the tenant test variables
    Run Openstack Auth Request    auth
    ${tenants}=    Get Current Openstack Tenant     auth
    ${tenant_name}=    Evaluate    $tenants.get("name")
    ${tenant_id}=     Evaluate    $tenants.get("id")
    [Return]    ${tenant_id}    ${tenant_name}

Create VVG Server
    [Documentation]    For the VolumeGroup test case, create a server to attach the volume group to be orchestrated.
    [Arguments]    ${uuid}
    Run Openstack Auth Request    auth
    ${vvg_server_name}=    Catenate   vVG_${uuid}
    ${server}=   Add Server For Image Name  auth    ${vvg_server_name}   ${GLOBAL_INJECTED_VM_IMAGE_NAME}   ${GLOBAL_INJECTED_VM_FLAVOR}   ${GLOBAL_INJECTED_PUBLIC_NET_ID}
    ${server}=       Get From Dictionary   ${server}   server
    ${server_id}=    Get From Dictionary   ${server}   id
    Wait for Server to Be Active    auth    ${server_id}
    [Return]    ${server_id}

Delete VNF
    [Documentation]    Called at the end of a test case to tear down the VNF created by Orchestrate VNF
    [Arguments]    ${tenant_name}    ${server_id}    ${customer_name}    ${service_instance_id}    ${vf_module_name_list}    ${uris_to_delete}
    ${lcp_region}=   Get Openstack Region
    ${list}=    Create List
    # remove duplicates, sort vFW-> vPKG , revers to get vPKG > vFWSNK
    ${sorted_stack_names}=    Create List
    ${sorted_stack_names}=  Remove Duplicates   ${vf_module_name_list}
    Sort List   ${sorted_stack_names}
    Reverse List   ${sorted_stack_names}
    :FOR   ${stack}   IN   @{sorted_stack_names}
    \     ${keypair_name}=    Get Stack Keypairs   ${stack}
    \     Append To List   ${list}   ${keypair_name}
    Teardown VVG Server    ${server_id}
    Run Keyword and Ignore Error   Teardown VID   ${service_instance_id}   ${lcp_region}   ${tenant_name}   ${customer_name}    ${uris_to_delete}
    #
    :FOR   ${stack}   IN   @{sorted_stack_names}
    \    Run Keyword and Ignore Error    Teardown Stack    ${stack}
    \    Log    Stack Deleted ${stack}
    # only needed if stack deleted but not keypair
    :FOR   ${key_pair}   IN   @{list}
    \    Run Keyword and Ignore Error    Delete Stack Keypair  ${key_pair}
    \    Log    Key pair Deleted ${key_pair}
    Log    VNF Deleted

Teardown VNF
    [Documentation]    Called at the end of a test case to tear down the VNF created by Orchestrate VNF
    [Arguments]    ${customer_name}     ${catalog_service_id}    ${catalog_resource_ids}
    Teardown Models     ${catalog_service_id}    ${catalog_resource_ids}
    Clean A&AI Inventory    ${customer_name}
    Close All Browsers

Teardown VVG Server
    [Documentation]   Teardown the server created as a place to mount the Volume Group.
    [Arguments]    ${server_id}
    Return From Keyword if   '${server_id}' == ''
    Return From Keyword if   '${server_id}' == 'None'
    Delete Server   auth   ${server_id}
    Wait for Server To Be Deleted    auth    ${server_id}
    Log    Teardown VVG Server Completed

Get Stack Keypairs
    [Documentation]  Get keypairs from openstack
    [Arguments]   ${stack}
    Run Openstack Auth Request    auth
    # Openstack can be delayed in making stack available to API
    ${stack_info}=    Wait Until Keyword Succeeds    300s    15s   Get Stack Details    auth    ${stack}
    Log    ${stack_info}
    ${stack_id}=    Get From Dictionary    ${stack_info}    id
    ${key_pair_status}   ${keypair_name}=   Run Keyword And Ignore Error   Get From Dictionary    ${stack_info}    key_name
    [Return]   ${keypair_name}

Delete Stack Keypair
    [Documentation]  Delete keypairs from openstack
    [Arguments]   ${keypair_name}
    Run Openstack Auth Request    auth
    Run Keyword   Delete Openstack Keypair    auth    ${keypair_name}

Teardown Stack
    [Documentation]    OBSOLETE - Called at the end of a test case to tear down the Stack created by Orchestrate VNF
    [Arguments]   ${stack}
    Run Openstack Auth Request    auth
    ${stack_info}=    Get Stack Details    auth    ${stack}
    Log    ${stack_info}
    ${stack_id}=    Get From Dictionary    ${stack_info}    id
    ${key_pair_status}   ${keypair_name}=   Run Keyword And Ignore Error   Get From Dictionary    ${stack_info}    key_name
    Delete Openstack Stack      auth    ${stack}    ${stack_id}
    Log    Deleted ${stack} ${stack_id}
    Run Keyword If   '${key_pair_status}' == 'PASS'   Delete Openstack Keypair    auth    ${keypair_name}

Clean A&AI Inventory
    [Documentation]    Clean up Tenant in A&AI, Create Customer, Create Service and related relationships
    [Arguments]   ${customer_name}
    Delete Customer    ${customer_name}
