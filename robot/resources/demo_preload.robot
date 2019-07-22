*** Settings ***
Documentation	  This test template encapsulates the VNF Orchestration use case.

Resource        test_templates/model_test_template.robot
Resource        test_templates/model_test_template_vcperescust.robot
Resource        test_templates/vnf_orchestration_test_template.robot
Resource        asdc_interface.robot
Resource        so_interface.robot
Resource        vid/vid_interface.robot
Resource        consul_interface.robot
Resource	policy_interface.robot
Resource        aai/create_availability_zone.robot

Library	        ONAPLibrary.Utilities
Library	        Collections
Library         OperatingSystem
Library         SeleniumLibrary
Library         RequestsLibrary
Library	        ONAPLibrary.Templating    WITH NAME    Templating
Library	        ONAPLibrary.AAI    WITH NAME    AAI

*** Variables ***

${ADD_DEMO_CUSTOMER_BODY}   aai/add_demo_customer.jinja
${AAI_INDEX_PATH}     /aai/v8
${VF_MODULES_NAME}     _Demo_VFModules.json
${FILE_CACHE}    /share/
${DEMO_PREFIX}   demo
${VPKG_MODULE_LABEL}    base_vpkg


*** Keywords ***
Load Customer And Models
    [Documentation]   Use openECOMP to Orchestrate a service.
    [Arguments]    ${customer_name}
    Load OwningEntity  lineOfBusiness  LOB-${customer_name}
    Load OwningEntity  platform  Platform-${customer_name}
    Load OwningEntity  project  Project-${customer_name}
    Load OwningEntity  owningEntity  OE-${customer_name}
    Load Customer  ${customer_name}
    Load Models  ${customer_name}

Load OwningEntity
    [Documentation]   Use openECOMP to Orchestrate a service.
    [Arguments]    ${parameter}   ${name}
    ${data_path}=  Set Variable  /maintenance/category_parameter/${parameter}
    ${vid_data}=  Set Variable  {"options":["${name}"]}
    ${auth}=  Create List  ${GLOBAL_VID_USERNAME}    ${GLOBAL_VID_PASSWORD}
    Log    Creating session ${data_path}
    ${session}=    Create Session       vid    ${VID_ENDPOINT}${VID_ENV}     auth=${auth}
    ${uuid}=    Generate UUID4
    ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json    USER_ID=${GLOBAL_VID_USERNAME}    X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}
    ${resp}= 	Post Request 	vid 	${data_path}   data=${vid_data}    headers=${headers}
	
Load Customer
    [Documentation]   Use openECOMP to Orchestrate a service.
    [Arguments]    ${customer_name}
    ${tenant_id}    ${tenant_name}=    Setup Orchestrate VNF   ${GLOBAL_AAI_CLOUD_OWNER}   SharedNode    OwnerType    v1    CloudZone
    ${region}=   Get Openstack Region
    Create Customer For VNF Demo    ${customer_name}    ${customer_name}    INFRA    ${GLOBAL_AAI_CLOUD_OWNER}    ${region}   ${tenant_id}
    Create Customer For VNF Demo    ${customer_name}    ${customer_name}    INFRA    ${GLOBAL_AAI_CLOUD_OWNER}    RegionTlab  50b190410b2a4c229d8a6044a80ab7c1 
    Create Availability Zone If Not Exists    ${GLOBAL_AAI_CLOUD_OWNER}    ${region}   ${GLOBAL_AAI_AVAILABILITY_ZONE_NAME}

Load Models
    [Documentation]   Use openECOMP to Orchestrate a service.
    [Arguments]    ${customer_name}
    Log   ${\n}Distributing vFWCL
    ${status}   ${value}=   Run Keyword And Ignore Error   Distribute Model   vFWCL   ${DEMO_PREFIX}VFWCL
    Log   Distibuting vLB
    ${status}   ${value}=   Run Keyword And Ignore Error   Distribute Model   vLB   ${DEMO_PREFIX}VLB
    ##${status}   ${value}=   Run Keyword And Ignore Error   Distribute Model   vCPE   ${DEMO_PREFIX}VCPE
    ##${status}   ${value}=   Run Keyword And Ignore Error   Distribute Model   vIMS   ${DEMO_PREFIX}VIMS
    Log   Distibuting vCPEInfra
    ${status}   ${value}=   Run Keyword And Ignore Error   Distribute Model   vCPEInfra   ${DEMO_PREFIX}VCPEInfra
    Log   Distibuting vCPEvBNG
    ${status}   ${value}=   Run Keyword And Ignore Error   Distribute Model   vCPEvBNG   ${DEMO_PREFIX}VCPEvBNG
    Log   Distibuting vCPEvBRGEMU
    ${status}   ${value}=   Run Keyword And Ignore Error   Distribute Model   vCPEvBRGEMU   ${DEMO_PREFIX}VCPEvBRGEMU 
    Log   Distibuting vCPEvGMUX
    ${status}   ${value}=   Run Keyword And Ignore Error   Distribute Model   vCPEvGMUX    ${DEMO_PREFIX}VCPEvGMUX
    Log   Distibuting vCPEvGW (this is not vCPEResCust service)
    ${status}   ${value}=   Run Keyword And Ignore Error   Distribute Model   vCPEvGW    ${DEMO_PREFIX}VCPEvGW

Distribute Model
    [Arguments]   ${service}   ${modelName}
    Model Distribution For Directory    ${service}   ${modelName}

Distribute vCPEResCust Model
    [Arguments]   ${service}   ${modelName}
    Model Distribution For vCPEResCust Directory    ${service}   ${modelName}

Create Customer For VNF Demo
    [Documentation]    Create demo customer for the demo
    [Arguments]    ${customer_name}   ${customer_id}   ${customer_type}    ${clouder_owner}    ${cloud_region_id}    ${tenant_id}
    Create Service If Not Exists    vFW
    Create Service If Not Exists    vFWCL
    Create Service If Not Exists    vLB
    Create Service If Not Exists    vCPE
    Create Service If Not Exists    vIMS
    Create Service If Not Exists    gNB
    ${arguments}=    Create Dictionary    subscriber_name=${customer_name}    global_customer_id=${customer_id}    subscriber_type=${customer_type}     cloud_owner=${clouder_owner}  cloud_region_id=${cloud_region_id}    tenant_id=${tenant_id}
    Set To Dictionary   ${arguments}       service1=vFWCL       service2=vLB   service3=vCPE   service4=vIMS  service5=gNB   service6=vFW
    Templating.Create Environment    aai    ${GLOBAL_TEMPLATE_FOLDER}
    ${data}=   Templating.Apply Template    aai   ${ADD_DEMO_CUSTOMER_BODY}    ${arguments}
    ${auth}=  Create List  ${GLOBAL_AAI_USERNAME}    ${GLOBAL_AAI_PASSWORD}
    ${put_resp}=    AAI.Run Put Request     ${AAI_FRONTEND_ENDPOINT}    ${INDEX PATH}${ROOT_CUSTOMER_PATH}${customer_id}    ${data}    auth=${auth}
    ${status_string}=    Convert To String    ${put_resp.status_code}
    Should Match Regexp    ${status_string}    ^(200|201|412)$

Preload User Model
    [Documentation]   Preload the demo data for the passed VNF with the passed module name
    [Arguments]   ${vnf_name}   ${vf_module_name}    ${service}    ${service_instance_id}
    # Go to A&AI and get information about the VNF we need to preload
    ${status}  ${generic_vnf}=   Run Keyword And Ignore Error   Get Service Instance    ${vnf_name}
    Run Keyword If   '${status}' == 'FAIL'   FAIL   VNF Name: ${vnf_name} is not found.
    ${vnf_type}=   Set Variable   ${generic_vnf['vnf-type']}
    ${relationships}=   Set Variable   ${generic_vnf['relationship-list']['relationship']}
    ${relationship_data}=    Get Relationship Data   ${relationships}
    ${customer_id}=   Catenate
    :FOR    ${r}   IN   @{relationship_data}
    \   ${service}=   Set Variable If    '${r['relationship-key']}' == 'service-subscription.service-type'   ${r['relationship-value']}    ${service}
    \   ${service_instance_id}=   Set Variable If    '${r['relationship-key']}' == 'service-instance.service-instance-id'   ${r['relationship-value']}   ${service_instance_id}
    \   ${customer_id}=    Set Variable If   '${r['relationship-key']}' == 'customer.global-customer-id'   ${r['relationship-value']}   ${customer_id}
    ${invariantUUID}=   Get Persona Model Id     ${service_instance_id}    ${service}    ${customer_id}

    # We still need the vf module names. We can get them from VID using the persona_model_id (invariantUUID) from A&AI
    Setup Browser
    Login To VID GUI
    ${vf_modules}=   Get Module Names from VID    ${invariantUUID}
    Log    ${generic_vnf}
    Log   ${service_instance_id},${vnf_name},${vnf_type},${vf_module_name},${vf_modules},${service}
    Preload Vnf    ${service_instance_id}   ${vnf_name}   ${vnf_type}   ${vf_module_name}    ${vf_modules}    ${service}    demo
    [Teardown]    Close All Browsers


Get Relationship Data
    [Arguments]   ${relationships}
    :FOR    ${r}   IN   @{relationships}
    \     ${status}   ${relationship_data}   Run Keyword And Ignore Error    Set Variable   ${r['relationship-data']}
    \     Return From Keyword If    '${status}' == 'PASS'   ${relationship_data}


Get Generic VNF By ID
    [Arguments]   ${vnf_id}
    ${auth}=  Create List  ${GLOBAL_AAI_USERNAME}    ${GLOBAL_AAI_PASSWORD}
    ${resp}=    AAI.Run Get Request    ${AAI_FRONTEND_ENDPOINT}    ${AAI_INDEX PATH}/network/generic-vnfs/generic-vnf?vnf-id=${vnf_id}    auth=${auth}
    Should Be Equal As Strings 	${resp.status_code} 	200
    [Return]   ${resp.json()}

Get Service Instance
    [Arguments]   ${vnf_name}
    ${auth}=  Create List  ${GLOBAL_AAI_USERNAME}    ${GLOBAL_AAI_PASSWORD}
    ${resp}=    AAI.Run Get Request    ${AAI_FRONTEND_ENDPOINT}    ${AAI_INDEX PATH}/network/generic-vnfs/generic-vnf?vnf-name=${vnf_name}    auth=${auth}
    Should Be Equal As Strings 	${resp.status_code} 	200
    [Return]   ${resp.json()}

Get Persona Model Id
    [Documentation]    Query and Validates A&AI Service Instance
    [Arguments]    ${service_instance_id}    ${service_type}   ${customer_id}
    ${auth}=  Create List  ${GLOBAL_AAI_USERNAME}    ${GLOBAL_AAI_PASSWORD}
    ${resp}=    AAI.Run Get Request    ${AAI_FRONTEND_ENDPOINT}    ${INDEX PATH}${CUSTOMER SPEC PATH}${customer_id}${SERVICE SUBSCRIPTIONS}${service_type}${SERVICE INSTANCE}${service_instance_id}    auth=${auth}
    ${persona_model_id}=   Get From DIctionary   ${resp.json()['service-instance'][0]}    model-invariant-id
    [Return]   ${persona_model_id}

APPC Mount Point
    [Arguments]   ${vf_module_name}
    Run Openstack Auth Request    auth
    ${status}   ${stack_info}=   Run Keyword and Ignore Error    Wait for Stack to Be Deployed    auth    ${vf_module_name}   timeout=120s
    Run Keyword if   '${status}' == 'FAIL'   FAIL   ${vf_module_name} Stack is not found
    ${stack_id}=    Get From Dictionary    ${stack_info}    id
    ${server_list}=    Get Openstack Servers    auth
    ${vpg_name_0}=    Get From Dictionary    ${stack_info}    vpg_name_0
    ${vnf_id}=    Get From Dictionary    ${stack_info}    vnf_id
    ${vpg_public_ip}=    Get Server Ip    ${server_list}    ${stack_info}   vpg_name_0    network_name=${GLOBAL_INJECTED_OPENSTACK_PUBLIC_NETWORK}
    ${appc}=    Create Mount Point In APPC    ${vnf_id}    ${vpg_public_ip}

Instantiate VNF
    [Arguments]   ${service}   ${vf_module_label}=NULL
    ${tenant_id}    ${tenant_name}=    Setup Orchestrate VNF    ${GLOBAL_AAI_CLOUD_OWNER}    SharedNode    OwnerType    v1    CloudZone
    ${uuid}=    Generate UUID4
    ${vf_module_name_list}   ${generic_vnfs}    ${server_id}    ${service_instance_id}    ${catalog_resource_ids}   ${catalog_service_id}=    Orchestrate VNF    DemoCust_${uuid}    ${service}   ${service}    ${tenant_id}    ${tenant_name}
    ${stack_name} = 	Get From List 	${vf_module_name_list} 	-1
    Save For Delete    ${tenant_id}    ${tenant_name}    ${server_id}    DemoCust_${uuid}    ${service_instance_id}    ${stack_name}    ${catalog_service_id}    ${catalog_resource_ids}
    :FOR  ${vf_module_name}  IN   @{vf_module_name_list}
    \   Log   VNF Module Name=${vf_module_name}
    # Don't get from MSO for now due to SO-1186
    # ${model_invariant_id}=  Run MSO Get ModelInvariantId   ${suite_service_model_name}  ${vf_module_label}
    ${model_invariant_id}=   Set Variable   ${EMPTY}
    :FOR    ${vf_module}    IN    @{generic_vnfs}
    \    ${generic_vnf}=    Get From Dictionary    ${generic_vnfs}    ${vf_module}
    \    ${model_invariant_id}=    Set Variable If    '${vf_module_label}' in '${vf_module}'   ${generic_vnf['model-invariant-id']}    ${model_invariant_id}
    Log   Update old vFWCL Policy for ModelInvariantID=${model_invariant_id}
    ${status}   ${value}=   Run Keyword And Ignore Error  Update vVFWCL Policy   ${model_invariant_id}
    :FOR  ${vf_module_name}  IN   @{vf_module_name_list}
    \   Log   APPC Mount Point for VNF Module Name=${vf_module_name}
    \   ${status}   ${value}=   Run Keyword And Ignore Error  APPC Mount Point    ${vf_module_name}
    Log   Update Tca ControlLoopName
    Update Tca ControlLoopName    ${model_invariant_id}

Instantiate Demo VNF
    [Arguments]   ${service}   ${vf_module_label}=NULL
    ${tenant_id}    ${tenant_name}=    Setup Orchestrate VNF    ${GLOBAL_AAI_CLOUD_OWNER}    SharedNode    OwnerType    v1    CloudZone
    ${vf_module_name}    ${service}    ${generic_vnfs}=   Orchestrate Demo VNF    Demonstration    ${service}   ${service}    ${tenant_id}    ${tenant_name}
    Log   VNF Module Name=${vf_module_name}
    # Don't get from MSO for now due to SO-1186
    # ${model_invariant_id}=  Run MSO Get ModelInvariantId   ${suite_service_model_name}  ${vf_module_label}
    ${model_invariant_id}=   Set Variable   ${EMPTY}
    :FOR    ${vf_module}    IN    @{generic_vnfs}
    \    ${generic_vnf}=    Get From Dictionary    ${generic_vnfs}    ${vf_module}
    \    ${model_invariant_id}=    Set Variable If    '${vf_module_label}' in '${vf_module}'   ${generic_vnf['model-invariant-id']}    ${model_invariant_id}
    Log   ModelInvariantID=${model_invariant_id}
    ${status}   ${value}=   Run Keyword And Ignore Error  Update vVFWCL Policy   ${model_invariant_id}
    ${status}   ${value}=   Run Keyword And Ignore Error  APPC Mount Point    ${vf_module_name}


Save For Delete
    [Documentation]   Create a variable file to be loaded for save for delete
    [Arguments]    ${tenant_id}    ${tenant_name}    ${vvg_server_id}    ${customer_name}    ${service_instance_id}    ${stack_name}    ${catalog_service_id}    ${catalog_resource_ids}
    ${dict}=    Create Dictionary
    Set To Dictionary   ${dict}   TENANT_NAME=${tenant_name}
    Set To Dictionary   ${dict}   TENANT_ID=${tenant_id}
    Set To Dictionary   ${dict}   CUSTOMER_NAME=${customer_name}
    Set To Dictionary   ${dict}   STACK_NAME=${stack_name}
    Set To Dictionary   ${dict}   VVG_SERVER_ID=${vvg_server_id}
    Set To Dictionary   ${dict}   SERVICE_INSTANCE_ID=${service_instance_id}
    Set To Dictionary   ${dict}   CATALOG_SERVICE_ID=${catalog_service_id}

    ${vars}=    Catenate
    ${keys}=   Get Dictionary Keys    ${dict}
    :FOR   ${key}   IN   @{keys}
    \    ${value}=   Get From Dictionary   ${dict}   ${key}
    \    ${vars}=   Catenate   ${vars}${key} = "${value}"\n

    ${comma}=   Catenate
    ${vars}=    Catenate   ${vars}CATALOG_RESOURCE_IDS = [
    :FOR   ${id}   IN    @{catalog_resource_ids}
    \    ${vars}=    Catenate  ${vars}${comma} "${id}"
    \    ${comma}=   Catenate   ,
    ${vars}=    Catenate  ${vars}]\n
    OperatingSystem.Create File   ${FILE_CACHE}/${stack_name}.py   ${vars}
    OperatingSystem.Create File   ${FILE_CACHE}/lastVNF4HEATBRIGE.py   ${vars}


