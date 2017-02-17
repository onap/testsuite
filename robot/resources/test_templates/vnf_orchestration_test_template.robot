*** Settings ***
Documentation	  This test template encapsulates the VNF Orchestration use case. 

Resource        ../vid/create_service_instance.robot
Resource        ../vid/vid_interface.robot
Resource        ../aai/service_instance.robot
Resource        ../vid/create_vid_vnf.robot
Resource        ../sdngc_interface.robot
Resource        model_test_template.robot

Resource        ../aai/create_customer.robot
Resource        ../aai/create_tenant.robot
Resource        ../aai/create_service.robot
Resource        ../openstack/neutron_interface.robot
Resource        ../heatbridge.robot


Library         OpenstackLibrary
Library 	    ExtendedSelenium2Library
Library	        UUID
Library	        Collections



*** Variables ***

${TENANT_NAME}    
${TENANT_ID}
${REGIONS}
${CUSTOMER_NAME}
${STACK_NAME}
${SERVICE} 
${VVG_SERVER_ID}

*** Keywords ***     
 
Orchestrate VNF
    [Arguments]    ${customer_name}    ${service}    ${product_family}    ${lcp_region}    ${tenant}
    ${uuid}=    Generate UUID  
    Set Test Variable    ${CUSTOMER_NAME}    ${customer_name}_${uuid}
    Set Test Variable    ${SERVICE}    ${service}
    ${vnf_name}=    Catenate    Vnf_Ete_Name${uuid}       
    ${service_name}=    Catenate    Service_Ete_Name${uuid}
    ${service_type}=    Set Variable    ${service}
    ${vf_module_name}=    Catenate    Vfmodule_Ete_Name${uuid}
    ${service_model_type}     ${vnf_type}    ${vf_modules} =    Model Distribution For Directory    ${service}
    ## MSO polling is 60 second intervals
    Sleep    70s     
    Run Keyword If   '${service}' == 'vVG'    Create VVG Server    ${uuid}  
    Create Customer For VNF    ${CUSTOMER_NAME}    ${CUSTOMER_NAME}    INFRA    ${service_type}    ${GLOBAL_AAI_CLOUD_OWNER}    ${GLOBAL_OPENSTACK_SERVICE_REGION}        
    Setup Browser   
    Login To VID GUI
    ${service_instance_id}=    Create VID Service Instance    ${customer_name}    ${service_model_type}    ${service}     ${service_name}
    Validate Service Instance    ${service_instance_id}    ${service}      ${customer_name}     
    Create VID VNF    ${service_instance_id}    ${vnf_name}    ${product_family}    ${lcp_region}    ${tenant}    ${vnf_type}
    ${vf_module_type}   ${closedloop_vf_module}=   Preload Vnf    ${service_instance_id}   ${vnf_name}   ${vnf_type}   ${vf_module_name}    ${vf_modules}    ${service}    ${uuid}
    ${vf_module_id}=   Create VID VNF module    ${service_instance_id}    ${vf_module_name}    ${lcp_region}    ${tenant}     ${vf_module_type}
    ${generic_vnf}=   Validate Generic VNF    ${vnf_name}    ${vnf_type}    ${service_instance_id}
    VLB Closed Loop Hack   ${service}   ${generic_vnf}   ${closedloop_vf_module}      
    Set Test Variable    ${STACK_NAME}   ${vf_module_name}         
    Execute Heatbridge    ${vf_module_name}    ${service_instance_id}    ${service}
    Validate VF Module      ${vf_module_name}    ${service}
    [Return]     ${vf_module_name}    ${service}
    [Teardown]    Close All Browsers


Create Customer For VNF
    [Documentation]    VNF Orchestration Test setup....
    ...                Create Tenant if not exists, Create Customer, Create Service and related relationships
    [Arguments]    ${customer_name}    ${customer_id}    ${customer_type}    ${service_type}    ${cloud_owner}  ${cloud_region_id}         
    ${resp}=    Create Customer    ${customer_name}    ${customer_id}    ${customer_type}    ${service_type}   ${cloud_owner}  ${cloud_region_id}    ${TENANT_ID}	
	Should Be Equal As Strings 	${resp} 	201
    Create Service If Not Exists    ${service_type}

Setup Orchestrate VNF
    [Documentation]    Called before each test case to ensure data required by the Orchstrate VNF exists 
    [Arguments]        ${cloud_owner}  ${cloud_region_id}   ${cloud_type}    ${owner_defined_type}    ${cloud_region_version}    ${cloud_zone}
    Initialize Tenant From Openstack
    Initialize Regions From Openstack
    :FOR    ${region}    IN    @{REGIONS}
    \    Inventory Tenant If Not Exists    ${cloud_owner}  ${region}  ${cloud_type}    ${owner_defined_type}    ${cloud_region_version}    ${cloud_zone}    ${TENANT_NAME}    ${TENANT_ID}       
    Log   Orchestrate VNF setup complete    
        
Initialize Tenant From Openstack
    Run Openstack Auth Request    auth
    ${tenants}=    Get Current Openstack Tenant     auth
    ${tenant_name}=    Evaluate    $tenants.get("name")
    ${tenant_id}=     Evaluate    $tenants.get("id")  
    Set Suite Variable	${TENANT_NAME}   ${tenant_name}
    Set Suite Variable	${TENANT_ID}     ${tenant_id}   

Initialize Regions From Openstack
    Run Openstack Auth Request    auth
    ${regs}=    Get Openstack Regions    auth
    Set Suite Variable	${REGIONS}     ${regs} 

Create VVG Server
    [Arguments]    ${uuid}            
    Run Openstack Auth Request    auth
    ${vvg_server_name}=    Catenate   vVG_${uuid}
    ${server}=   Add Server For Image Name  auth    ${vvg_server_name}   ${GLOBAL_VVGSERVER_IMAGE}   ${GLOBAL_VVGSERVER_FLAVOR}
    ${server}=       Get From Dictionary   ${server}   server
    ${server_id}=    Get From Dictionary   ${server}   id
    Set Test Variable    ${VVG_SERVER_ID}   ${server_id}
    ${vvg_params}=    Get VVG Preload Parameters 
    Set To Dictionary   ${vvg_params}   nova_instance   ${server_id}
    Wait for Server to Be Active    auth    ${server_id}    

Get VVG Preload Parameters    
    ${test_dict}=    Get From Dictionary    ${GLOBAL_PRELOAD_PARAMETERS}    Vnf-Orchestration
    ${vvg_params}   Get From Dictionary    ${test_dict}    vvg_preload.template
    [Return]    ${vvg_params}
       
Teardown VNF
    [Documentation]    Called at the end of a test case to tear down the VNF created by Orchestrate VNF
    Teardown VVG Server  
    # Free up rackspace resources until true teardown is implemented
    Run Keyword If   '${TEST STATUS}' == 'PASS'    Teardown Stack   ${STACK_NAME}
    Set Test Variable     ${VVG_SERVER_ID}   ''
    
    ## Conditional remove so as to enable manual teardown testing of failed stacks
    Run Keyword If   '${TEST STATUS}' == 'PASS'    Teardown Model Distribution  
    Log    Teardown VNF not completely implemented

Teardown VVG Server
    Return From Keyword if   '${VVG_SERVER_ID}' == ''
    Delete Server   auth   ${VVG_SERVER_ID}
    Wait for Server To Be Deleted    auth    ${VVG_SERVER_ID}    
    ${vvg_params}=    Get VVG Preload Parameters   
    Remove from Dictionary   ${vvg_params}   nova_instance
    Log    Teardown VVG Server Completed
    
Teardown Stack
    [Documentation]    Called at the end of a test case to tear down the Stack created by Orchestrate VNF
    [Arguments]   ${stack}
    Run Openstack Auth Request    auth
    ${stack_info}=    Get Stack Details    auth    ${stack}
    Log    ${stack_info}
    ${stack_id}=    Get From Dictionary    ${stack_info}    id
    ${key_pair_status}   ${keypair_name}=   Run Keyword And Ignore Error   Get From Dictionary    ${stack_info}    key_name
    Delete Openstack Stack      auth    ${stack}    ${stack_id}
    Log    Deleted ${stack} ${stack_id}
    Run Keyword If   '${key_pair_status}' == 'PASS'   Delete Openstack Keypair    auth    ${keypair_name}
    ## Removed  code to remove all of the IPs from the oam network - didn't help


Get Ecomp Private Net Ports
    [Arguments]    ${alias}    ${stack_info}    ${service}
    ${list}=    Create List
    ${netid}=    Get From Dictionary    ${stack_info}    ecomp_private_net_id
    ${cidr}=    Get From Dictionary    ${stack_info}    ecomp_private_net_cidr
    ${ip_addresses}=    Get Ecomp Ip Addresses    ${stack_info}    ${service}
    ${net_ports}=    Get Openstack Ports For Subnet    ${alias}    ${netid}    ${cidr}
    :for    ${ip_address}    in    @{ip_addresses}
    \    ${port}=    Find Ecomp Port     ${net_ports}    ${ip_address}
    \     Run Keyword If    ${port} is not None    Append To List    ${list}    ${port}        
    [Return]    ${list}
    
Get Ecomp Ip Addresses
    [Arguments]    ${stack_info}    ${service}
    ${ip_addresses}=    Create List
    ${names}=    Get From Dictionary    ${GLOBAL_SERVICE_ECOMP_IP_MAPPING}    ${service}
    :for    ${name}    in    @{names}
    \    ${ip}=    Get From Dictionary    ${stack_info}    ${name}
    \    Append To List    ${ip_addresses}    ${ip}
    [Return]    ${ip_addresses}

Find Ecomp Port
    [Arguments]    ${ports}    ${ip_address}
   :for    ${port}   in   @{ports}
    \    Return From Keyword If    '${port['fixed_ips'][0]['ip_address']}' == '${ip_address}'    ${port}
    [Return]    None
 

Clean A&AI Inventory 
    [Documentation]    Clean up Tenant in A&AI, Create Customer, Create Service and related relationships	
    [Arguments]    ${customer_id}    ${cloud_owner}    ${service_type}
    :FOR    ${region}    IN    @{REGIONS}
    \      Delete Tenant  ${TENANT_ID}    ${cloud_owner}  ${region}
    \      Delete Cloud Region  ${TENANT_ID}    ${cloud_owner}  ${region}
    Delete Customer    ${customer_id}
    Delete Service If Exists    ${service_type}    	

