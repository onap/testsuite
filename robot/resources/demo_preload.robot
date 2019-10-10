*** Settings ***
Documentation	  This test template encapsulates the VNF Orchestration use case.

Resource        test_templates/model_test_template.robot
Resource        test_templates/model_test_template_vcperescust.robot
Resource        test_templates/vnf_orchestration_test_template.robot
Resource        sdc_interface.robot
Resource        vid/vid_interface.robot
Resource        consul_interface.robot
Resource        policy_interface.robot
Resource        aai/create_availability_zone.robot
Resource        so/direct_instantiate.robot
Resource        aai/create_tenant.robot
Resource        aai/create_complex.robot

Library	        ONAPLibrary.Utilities
Library	        Collections
Library         OperatingSystem
Library         SeleniumLibrary
Library         RequestsLibrary
Library	        ONAPLibrary.Templating    WITH NAME    Templating
Library	        ONAPLibrary.AAI    WITH NAME    AAI
Library	        ONAPLibrary.SO    WITH NAME    SO

*** Variables ***

${ADD_DEMO_CUSTOMER_BODY}   aai/add_demo_customer.jinja
${ADD_SINGLE_SERVICE_CUSTOMER_BODY}    aai/add_customer.jinja
${AAI_INDEX_PATH}     /aai/v8
${VF_MODULES_NAME}     _Demo_VFModules.json
${FILE_CACHE}    /share/
${DEMO_PREFIX}   demo
${VPKG_MODULE_LABEL}    base_vpkg


*** Keywords ***
Load VID Entities
    [Documentation]     Uploads customer-related Entities info to VID
    [Arguments]     ${customer_name}
    Load OwningEntity  lineOfBusiness  LOB-${customer_name}
    Load OwningEntity  platform  Platform-${customer_name}
    Load OwningEntity  project  Project-${customer_name}
    Load OwningEntity  owningEntity  OE-${customer_name}

Load Customer And Models
    [Documentation]   Use ONAP to Orchestrate a service.
    [Arguments]    ${customer_name}
    Load VID Entities   ${customer_name}
    Load Customer  ${customer_name}
    Load Models  ${customer_name}

Load CNF Customer and Models
    [Documentation]   Preload VID,AAI,SDC,SO and Multicloud databases with CNF-related data
    [Arguments]    ${customer_name}
    Load VID Entities   ${customer_name}
    Load CNF Customer   ${customer_name}    ${customer_name}    INFRA   ${GLOBAL_AAI_CNF_CLOUD_OWNER}
    ...                 k8sregion   k8stenant   k8stenant
    #Loading models to be finished

Load OwningEntity
    [Documentation]   Use ONAP to Orchestrate a service.
    [Arguments]    ${parameter}   ${name}
    ${data_path}=  Set Variable  /maintenance/category_parameter/${parameter}
    ${vid_data}=  Set Variable  {"options":["${name}"]}
    ${auth}=  Create List  ${GLOBAL_VID_USERNAME}    ${GLOBAL_VID_PASSWORD}
    Log    Creating session ${data_path}
    ${session}=    Create Session       vid    ${VID_ENDPOINT}${VID_ENV}     auth=${auth}
    ${uuid}=    Generate UUID4
    ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json    USER_ID=${GLOBAL_VID_USERNAME}    X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}
    ${resp}= 	Post Request 	vid 	${data_path}   data=${vid_data}    headers=${headers}
	

Load CNF Customer
    [Documentation]   Preload AAI,SO and Multicloud databases with CNF-related Customer, Service and Cloud sites
    [Arguments]    ${customer_name}   ${customer_id}   ${customer_type}    ${cloud_owner}    ${cloud_region_id}    ${tenant_id}  ${tenant_name}

    Inventory Tenant If Not Exists  ${cloud_owner}  ${cloud_region_id}  k8s  ${GLOBAL_AAI_CLOUD_OWNER_DEFINED_TYPE}  v1  CloudZone  ${tenant_id}  ${tenant_name}
    Inventory Complex If Not Exists  ${GLOBAL_AAI_CNF_COMPLEX_NAME}  ${GLOBAL_AAI_CNF_PHYSICAL_LOCATION_ID}  ${cloud_owner}  ${cloud_region_id}  ${GLOBAL_AAI_CLOUD_OWNER_DEFINED_TYPE}
    Create Service If Not Exists    vFW_CNF

    ${arguments}=    Create Dictionary  subscriber_name=${customer_name}  global_customer_id=${customer_id}  subscriber_type=${customer_type}   cloud_owner1=${cloud_owner}  cloud_region_id1=${cloud_region_id}  tenant_id1=${tenant_id}  service1=vFW_CNF
    Templating.Create Environment    aai    ${GLOBAL_TEMPLATE_FOLDER}
    ${data}=   Templating.Apply Template    aai   ${ADD_SINGLE_SERVICE_CUSTOMER_BODY}    ${arguments}
    ${put_resp}=    AAI.Run Put Request     ${AAI_FRONTEND_ENDPOINT}    ${INDEX PATH}${ROOT_CUSTOMER_PATH}${customer_id}    ${data}    auth=${GLOBAL_AAI_AUTHENTICATION}
    ${status_string}=    Convert To String    ${put_resp.status_code}
    Should Match Regexp    ${status_string}    ^(200|201|412)$

    ${catdb_template_arguments}=    Create Dictionary   site_name=${cloud_owner}  region_id=${cloud_region_id}
    ...                             clli=${GLOBAL_AAI_CNF_COMPLEX_NAME}     orchestrator=multicloud
    ...                             identity_service_id=DEFAULT_KEYSTONE
    ${catdb_auth}=  Create List  ${GLOBAL_SO_CATDB_USERNAME}    ${GLOBAL_SO_PASSWORD}
    SO.Upsert Cloud Configuration    ${GLOBAL_SO_CATDB_ENDPOINT}    ${GLOBAL_SO_CLOUD_CONFIG_PATH}    ${GLOBAL_TEMPLATE_FOLDER}    ${GLOBAL_SO_CLOUD_CONFIG_TEMPLATE}    ${catdb_template_arguments}    auth=${catdb_auth}

    #Register cloud via multicloud-titaniumcloud
    #Update CatalogDB with relevant cloud data
    #(Optional) Provide credentials for k8splugin

Load Customer
    [Documentation]   Use ONAP to Orchestrate a service.
    [Arguments]    ${customer_name}
    ${tenant_id}    ${tenant_name}=    Setup Orchestrate VNF   ${GLOBAL_AAI_CLOUD_OWNER}   SharedNode    OwnerType    v1    CloudZone
    ${region}=   Get Openstack Region
    Create Customer For VNF Demo    ${customer_name}    ${customer_name}    INFRA    ${GLOBAL_AAI_CLOUD_OWNER}    ${region}   ${tenant_id}
    Create Customer For VNF Demo    ${customer_name}    ${customer_name}    INFRA    ${GLOBAL_AAI_CLOUD_OWNER}    RegionTlab  50b190410b2a4c229d8a6044a80ab7c1 
    Create Availability Zone If Not Exists    ${GLOBAL_AAI_CLOUD_OWNER}    ${region}   ${GLOBAL_AAI_AVAILABILITY_ZONE_NAME}

Load Models
    [Documentation]   Use ONAP to Orchestrate a service.
    [Arguments]    ${customer_name}
    Log   ${\n}Distributing vFWCL
    ${status}   ${value}=   Run Keyword And Ignore Error   Distribute Model   vFWCL   ${DEMO_PREFIX}VFWCL
    Log   Distibuting vLB
    ${status}   ${value}=   Run Keyword And Ignore Error   Distribute Model   vLB   ${DEMO_PREFIX}VLB
    Log   Distibuting vLB_CDS
    ${status}   ${value}=   Run Keyword And Ignore Error   Distribute Model   vLB_CDS   ${DEMO_PREFIX}VLB_CDS  True
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
    [Arguments]   ${service}   ${modelName}  ${cds}=False   ${instantiationType}=A-la-carte  ${resourceType}=VF
    Model Distribution For Directory    ${service}   ${modelName}  ${cds}  ${instantiationType}  ${resourceType}

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
    ${put_resp}=    AAI.Run Put Request     ${AAI_FRONTEND_ENDPOINT}    ${INDEX PATH}${ROOT_CUSTOMER_PATH}${customer_id}    ${data}    auth=${GLOBAL_AAI_AUTHENTICATION}
    ${status_string}=    Convert To String    ${put_resp.status_code}
    Should Match Regexp    ${status_string}    ^(200|201|412)$

Preload User Model
    [Documentation]   Preload the demo data for the passed VNF with the passed module name
    [Arguments]   ${vnf_name}   ${vf_module_name}    ${service}    ${service_instance_id}    ${vnf}=${service}
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
    Preload Vnf    ${service_instance_id}   ${vnf_name}   ${vnf_type}   ${vf_module_name}    ${vf_modules}    ${vnf}    demo    ${service}
    [Teardown]    Close All Browsers


Get Relationship Data
    [Arguments]   ${relationships}
    :FOR    ${r}   IN   @{relationships}
    \     ${status}   ${relationship_data}   Run Keyword And Ignore Error    Set Variable   ${r['relationship-data']}
    \     Return From Keyword If    '${status}' == 'PASS'   ${relationship_data}


Get Generic VNF By ID
    [Arguments]   ${vnf_id}
    ${resp}=    AAI.Run Get Request    ${AAI_FRONTEND_ENDPOINT}    ${AAI_INDEX PATH}/network/generic-vnfs/generic-vnf?vnf-id=${vnf_id}    auth=${GLOBAL_AAI_AUTHENTICATION}
    Should Be Equal As Strings 	${resp.status_code} 	200
    [Return]   ${resp.json()}

Get Service Instance
    [Arguments]   ${vnf_name}
    ${resp}=    AAI.Run Get Request    ${AAI_FRONTEND_ENDPOINT}    ${AAI_INDEX PATH}/network/generic-vnfs/generic-vnf?vnf-name=${vnf_name}    auth=${GLOBAL_AAI_AUTHENTICATION}
    Should Be Equal As Strings 	${resp.status_code} 	200
    [Return]   ${resp.json()}

Get Persona Model Id
    [Documentation]    Query and Validates A&AI Service Instance
    [Arguments]    ${service_instance_id}    ${service_type}   ${customer_id}
    ${resp}=    AAI.Run Get Request    ${AAI_FRONTEND_ENDPOINT}    ${INDEX PATH}${CUSTOMER SPEC PATH}${customer_id}${SERVICE SUBSCRIPTIONS}${service_type}${SERVICE INSTANCE}${service_instance_id}    auth=${GLOBAL_AAI_AUTHENTICATION}
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
    ${vf_module_name_list}   ${generic_vnfs}    ${server_id}    ${service_instance_id}    ${catalog_resource_ids}   ${catalog_service_id}    ${uris_to_delete}=    Orchestrate VNF    DemoCust_${uuid}    ${service}   ${service}    ${tenant_id}    ${tenant_name}
    ${stack_name} = 	Get From List 	${vf_module_name_list} 	-1
    Save For Delete    ${tenant_id}    ${tenant_name}    ${server_id}    DemoCust_${uuid}    ${service_instance_id}    ${stack_name}    ${catalog_service_id}    ${catalog_resource_ids}
    :FOR  ${vf_module_name}  IN   @{vf_module_name_list}
    \   Log   VNF Module Name=${vf_module_name}
    # Don't get from SO for now due to SO-1186
    # ${model_invariant_id}=  Run SO Get ModelInvariantId   ${suite_service_model_name}  ${vf_module_label}
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

Instantiate VNF CDS
    [Arguments]   ${service}   ${vf_module_label}=NULL
    ${status}   ${value}=   Run Keyword And Ignore Error   Distribute Model   vLB_CDS   demoVLB_CDS  True
    ${resp}=  Get Service Catalog  demoVLB_CDS
    ${service-uuid}=     Set Variable    ${resp['uuid']}  
    ${service-invariantUUID}=     Set Variable    ${resp['invariantUUID']}     
    ${requestid}=   CDS Service Instantiate  demoVLB_CDS  ${service-uuid}  ${service-invariantUUID}
    ${auth}=  Create List  ${GLOBAL_SO_CATDB_USERNAME }  ${GLOBAL_SO_PASSWORD}        
    SO.Run Polling Get Request  ${GLOBAL_SO_APIHAND_ENDPOINT}  ${GLOBAL_SO_ORCHESTRATION_REQUESTS_PATH}/${requestid}  tries=30   interval=60  auth=${auth}

Instantiate Demo VNF
    [Arguments]   ${service}   ${vf_module_label}=NULL
    ${tenant_id}    ${tenant_name}=    Setup Orchestrate VNF    ${GLOBAL_AAI_CLOUD_OWNER}    SharedNode    OwnerType    v1    CloudZone
    ${vf_module_name}    ${service}    ${generic_vnfs}=   Orchestrate Demo VNF    Demonstration    ${service}   ${service}    ${tenant_id}    ${tenant_name}
    Log   VNF Module Name=${vf_module_name}
    # Don't get from SO for now due to SO-1186
    # ${model_invariant_id}=  Run SO Get ModelInvariantId   ${suite_service_model_name}  ${vf_module_label}
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


