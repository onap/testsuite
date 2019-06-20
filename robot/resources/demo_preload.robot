*** Settings ***
Documentation	  This test template encapsulates the VNF Orchestration use case.

Resource        test_templates/model_test_template.robot
Resource        test_templates/vnf_orchestration_test_template.robot
Resource        asdc_interface.robot
Resource        so_interface.robot
Resource        vid/vid_interface.robot
Resource	    policy_interface.robot
Resource        aai/create_availability_zone.robot

Library	        UUID
Library	        Collections
Library         OperatingSystem
Library         HttpLibrary.HTTP
Library         ExtendedSelenium2Library
Library         RequestsLibrary

*** Variables ***

${ADD_DEMO_CUSTOMER_BODY}   robot/assets/templates/aai/add_demo_customer.template
${AAI_INDEX_PATH}     /aai/v14
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
    ${uuid}=    Generate UUID
    ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json    USER_ID=${GLOBAL_VID_USERNAME}    X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}
    ${resp}= 	Post Request 	vid 	${data_path}   data=${vid_data}    headers=${headers}
	
Load Customer
    [Documentation]   Use openECOMP to Orchestrate a service.
    [Arguments]    ${customer_name}
    Setup Orchestrate VNF   ${GLOBAL_AAI_CLOUD_OWNER}   SharedNode    OwnerType    v1    CloudZone
    Set Test Variable    ${CUSTOMER_NAME}    ${customer_name}
    ${region}=   Get Openstack Region
    Create Customer For VNF Demo    ${CUSTOMER_NAME}    ${CUSTOMER_NAME}    INFRA    ${GLOBAL_AAI_CLOUD_OWNER}    ${region}   ${TENANT_ID}
    Create Customer For VNF Demo    ${CUSTOMER_NAME}    ${CUSTOMER_NAME}    INFRA    ${GLOBAL_AAI_CLOUD_OWNER}    RegionTlab  50b190410b2a4c229d8a6044a80ab7c1 
    Create Availability Zone If Not Exists    ${GLOBAL_AAI_CLOUD_OWNER}    ${region}   ${GLOBAL_AAI_AVAILABILITY_ZONE_NAME}

Load Models
    [Documentation]   Use openECOMP to Orchestrate a service.
    [Arguments]    ${customer_name}
    Set Test Variable    ${CUSTOMER_NAME}    ${customer_name}
    Log To Console   ${\n}Distributing vFWCL
    ${status}   ${value}=   Run Keyword And Ignore Error   Distribute Model   vFWCL   ${DEMO_PREFIX}VFWCL
    Log To Console   Distibuting vLB
    ${status}   ${value}=   Run Keyword And Ignore Error   Distribute Model   vLB   ${DEMO_PREFIX}VLB
    ##${status}   ${value}=   Run Keyword And Ignore Error   Distribute Model   vCPE   ${DEMO_PREFIX}VCPE
    ##${status}   ${value}=   Run Keyword And Ignore Error   Distribute Model   vIMS   ${DEMO_PREFIX}VIMS
    Log To Console   Distibuting vCPEInfra
    ${status}   ${value}=   Run Keyword And Ignore Error   Distribute Model   vCPEInfra   ${DEMO_PREFIX}VCPEInfra
    Log To Console   Distibuting vCPEvBNG
    ${status}   ${value}=   Run Keyword And Ignore Error   Distribute Model   vCPEvBNG   ${DEMO_PREFIX}VCPEvBNG
    Log To Console   Distibuting vCPEvBRGEMU
    ${status}   ${value}=   Run Keyword And Ignore Error   Distribute Model   vCPEvBRGEMU   ${DEMO_PREFIX}VCPEvBRGEMU 
    Log To Console   Distibuting vCPEvGMUX
    ${status}   ${value}=   Run Keyword And Ignore Error   Distribute Model   vCPEvGMUX    ${DEMO_PREFIX}VCPEvGMUX
    Log To Console   Distibuting vCPEvGW (this is not vCPEResCust service)
    ${status}   ${value}=   Run Keyword And Ignore Error   Distribute Model   vCPEvGW    ${DEMO_PREFIX}VCPEvGW

Distribute Model
    [Arguments]   ${service}   ${modelName}
    ${service_model_type}     ${vnf_type}    ${vf_modules}   ${catalog_resources}=   Model Distribution For Directory    ${service}   ${modelName}

Distribute vCPEResCust Model
    [Arguments]   ${service}   ${modelName}
    ${service_model_type}     ${vnf_type}    ${vf_modules}   ${catalog_resources}=   Model Distribution For vCPEResCust Directory    ${service}   ${modelName}


Create Customer For VNF Demo
    [Documentation]    Create demo customer for the demo
    [Arguments]    ${customer_name}   ${customer_id}   ${customer_type}    ${clouder_owner}    ${cloud_region_id}    ${tenant_id}
    Create Service If Not Exists    vFW
    Create Service If Not Exists    vFWCL
    Create Service If Not Exists    vLB
    Create Service If Not Exists    vCPE
    Create Service If Not Exists    vIMS
    Create Service If Not Exists    gNB
    ${data_template}=    OperatingSystem.Get File    ${ADD_DEMO_CUSTOMER_BODY}
    ${arguments}=    Create Dictionary    subscriber_name=${customer_name}    global_customer_id=${customer_id}    subscriber_type=${customer_type}     cloud_owner=${clouder_owner}  cloud_region_id=${cloud_region_id}    tenant_id=${tenant_id}
    Set To Dictionary   ${arguments}       service1=vFWCL       service2=vLB   service3=vCPE   service4=vIMS  service5=gNB   service6=vFW
    ${data}=	Fill JSON Template    ${data_template}    ${arguments}
    ${put_resp}=    Run A&AI Put Request     ${INDEX PATH}${ROOT_CUSTOMER_PATH}${customer_id}    ${data}
    ${status_string}=    Convert To String    ${put_resp.status_code}
    Should Match Regexp    ${status_string}    ^(200|201|412)$

Preload User Model
    [Documentation]   Preload the demo data for the passed VNF with the passed module name
    [Arguments]   ${vnf_name}   ${vf_module_name}
    # Go to A&AI and get information about the VNF we need to preload
    ${status}  ${generic_vnf}=   Run Keyword And Ignore Error   Get Service Instance    ${vnf_name}
    Run Keyword If   '${status}' == 'FAIL'   FAIL   VNF Name: ${vnf_name} is not found.
    ${vnf_type}=   Set Variable   ${generic_vnf['vnf-type']}
    ${relationships}=   Set Variable   ${generic_vnf['relationship-list']['relationship']}
    ${relationship_data}=    Get Relationship Data   ${relationships}
    ${customer_id}=   Catenate
    :for    ${r}   in   @{relationship_data}
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
    :for    ${r}   in   @{relationships}
    \     ${status}   ${relationship_data}   Run Keyword And Ignore Error    Set Variable   ${r['relationship-data']}
    \     Return From Keyword If    '${status}' == 'PASS'   ${relationship_data}


Get Generic VNF By ID
    [Arguments]   ${vnf_id}
    ${resp}=    Run A&AI Get Request      ${AAI_INDEX PATH}/network/generic-vnfs/generic-vnf?vnf-id=${vnf_id}
    Should Be Equal As Strings 	${resp.status_code} 	200
    [Return]   ${resp.json()}

Get Service Instance
    [Arguments]   ${vnf_name}
    ${resp}=    Run A&AI Get Request      ${AAI_INDEX PATH}/network/generic-vnfs/generic-vnf?vnf-name=${vnf_name}
    Should Be Equal As Strings 	${resp.status_code} 	200
    [Return]   ${resp.json()}

Get Persona Model Id
    [Documentation]    Query and Validates A&AI Service Instance
    [Arguments]    ${service_instance_id}    ${service_type}   ${customer_id}
    ${resp}=    Run A&AI Get Request      ${INDEX PATH}${CUSTOMER SPEC PATH}${customer_id}${SERVICE SUBSCRIPTIONS}${service_type}${SERVICE INSTANCE}${service_instance_id}
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
    ${vpg_public_ip}=    Get Server Ip    ${server_list}    ${stack_info}   vpg_name_0    network_name=public
 
    #  vpg_oam_ip is no longer needed - use vpg_public_ip
    #${vpg_oam_ip}=    Get From Dictionary    ${stack_info}    vpg_private_ip_1
    #${vpg_oam_ip}=    Get From Dictionary    ${stack_info}    vpg_onap_private_ip_0 
    #${appc}=    Create Mount Point In APPC    ${vpg_name_0}    ${vpg_oam_ip}
    #${appc}=    Create Mount Point In APPC    ${vnf_id}    ${vpg_oam_ip}

    ${appc}=    Create Mount Point In APPC    ${vnf_id}    ${vpg_public_ip}

Instantiate VNF
    [Arguments]   ${service}   ${vf_module_label}=NULL
    Setup Orchestrate VNF    ${GLOBAL_AAI_CLOUD_OWNER}    SharedNode    OwnerType    v1    CloudZone
    ${vf_module_name_list}    ${service}     ${generic_vnfs}=    Orchestrate VNF    DemoCust    ${service}   ${service}    ${TENANT_NAME}
    Save For Delete
    Log to Console   Customer Name=${CUSTOMER_NAME}
    :FOR  ${vf_module_name}  IN   @{vf_module_name_list}
    \   Log to Console   VNF Module Name=${vf_module_name}
    # Don't get from MSO for now due to SO-1186
    # ${model_invariant_id}=  Run MSO Get ModelInvariantId   ${SUITE_SERVICE_MODEL_NAME}  ${vf_module_label}
    ${model_invariant_id}=   Set Variable   ${EMPTY}
    :for    ${vf_module}    in    @{generic_vnfs}
    \    ${generic_vnf}=    Get From Dictionary    ${generic_vnfs}    ${vf_module}
    \    ${model_invariant_id}=    Set Variable If    '${vf_module_label}' in '${vf_module}'   ${generic_vnf['model-invariant-id']}    ${model_invariant_id}
    Log to Console   Update old vFWCL Policy for ModelInvariantID=${model_invariant_id}
    ${status}   ${value}=   Run Keyword And Ignore Error  Update vVFWCL Policy   ${model_invariant_id}
    :FOR  ${vf_module_name}  IN   @{vf_module_name_list}
    \   Log To Console   APPC Mount Point for VNF Module Name=${vf_module_name}
    \   ${status}   ${value}=   Run Keyword And Ignore Error  APPC Mount Point    ${vf_module_name}

Instantiate Demo VNF
    [Arguments]   ${service}   ${vf_module_label}=NULL
    Setup Orchestrate VNF    ${GLOBAL_AAI_CLOUD_OWNER}    SharedNode    OwnerType    v1    CloudZone
    ${vf_module_name}    ${service}    ${generic_vnfs}=   Orchestrate Demo VNF    Demonstration    ${service}   ${service}    ${TENANT_NAME}
    #Save For Delete
    Log to Console   Customer Name=${CUSTOMER_NAME}
    Log to Console   VNF Module Name=${vf_module_name}
    # Don't get from MSO for now due to SO-1186
    # ${model_invariant_id}=  Run MSO Get ModelInvariantId   ${SUITE_SERVICE_MODEL_NAME}  ${vf_module_label}
    ${model_invariant_id}=   Set Variable   ${EMPTY}
    :for    ${vf_module}    in    @{generic_vnfs}
    \    ${generic_vnf}=    Get From Dictionary    ${generic_vnfs}    ${vf_module}
    \    ${model_invariant_id}=    Set Variable If    '${vf_module_label}' in '${vf_module}'   ${generic_vnf['model-invariant-id']}    ${model_invariant_id}
    Log to Console   ModelInvariantID=${model_invariant_id}
    ${status}   ${value}=   Run Keyword And Ignore Error  Update vVFWCL Policy   ${model_invariant_id}
    ${status}   ${value}=   Run Keyword And Ignore Error  APPC Mount Point    ${vf_module_name}


Save For Delete
    [Documentation]   Create a variable file to be loaded for save for delete
    ${dict}=    Create Dictionary
    Set To Dictionary   ${dict}   TENANT_NAME=${TENANT_NAME}
    Set To Dictionary   ${dict}   TENANT_ID=${TENANT_ID}
    Set To Dictionary   ${dict}   CUSTOMER_NAME=${CUSTOMER_NAME}
    Set To Dictionary   ${dict}   STACK_NAME=${STACK_NAME}
    Set To Dictionary   ${dict}   SERVICE=${SERVICE}
    Set To Dictionary   ${dict}   VVG_SERVER_ID=${VVG_SERVER_ID}
    Set To Dictionary   ${dict}   SERVICE_INSTANCE_ID=${SERVICE_INSTANCE_ID}

    Set To Dictionary   ${dict}   VLB_CLOSED_LOOP_DELETE=${VLB_CLOSED_LOOP_DELETE}
    Set To Dictionary   ${dict}   VLB_CLOSED_LOOP_VNF_ID=${VLB_CLOSED_LOOP_VNF_ID}

    Set To Dictionary   ${dict}   CATALOG_SERVICE_ID=${CATALOG_SERVICE_ID}

    ${vars}=    Catenate
    ${keys}=   Get Dictionary Keys    ${dict}
    :for   ${key}   in   @{keys}
    \    ${value}=   Get From Dictionary   ${dict}   ${key}
    \    ${vars}=   Catenate   ${vars}${key} = "${value}"\n

    ${comma}=   Catenate
    ${vars}=    Catenate   ${vars}CATALOG_RESOURCE_IDS = [
    :for   ${id}   in    @{CATALOG_RESOURCE_IDS}
    \    ${vars}=    Catenate  ${vars}${comma} "${id}"
    \    ${comma}=   Catenate   ,
    ${vars}=    Catenate  ${vars}]\n
    OperatingSystem.Create File   ${FILE_CACHE}/${STACK_NAME}.py   ${vars}
    OperatingSystem.Create File   ${FILE_CACHE}/lastVNF4HEATBRIGE.py   ${vars}


