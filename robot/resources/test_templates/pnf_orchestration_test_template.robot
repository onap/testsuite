*** Settings ***
Documentation	  This test template encapsulates the PNF Orchestration use case.

Resource        ../vid/create_service_instance.robot
Resource        ../vid/vid_interface.robot
Resource        ../aai/service_instance.robot
Resource        model_test_template.robot
Resource        ../openstack/neutron_interface.robot
Resource          ../sdc_interface.robot
Resource          vnf_orchestration_test_template.robot
Resource         ../so/create_service_instance.robot


Library         ONAPLibrary.Openstack
Library 	    SeleniumLibrary
Library	        Collections
Library	        ONAPLibrary.Utilities

*** Keywords ***

Orchestrate PNF Macro Flow
    [Documentation]   Use ONAP to Orchestrate a PNF Macro service.
    [Arguments]   ${customer_name}    ${service}    ${product_family}    ${pnf_correlation_id}  ${tenant_id}    ${tenant_name}   ${service_model_type}   ${region}  ${project_name}=Project-Demonstration   ${owning_entity}=OE-Demonstration
    ${lcp_region}=   Set Variable   ${region}
    ${uuid}=    Generate UUID4
    ${full_customer_name}=    Catenate    ${customer_name}_${uuid}
    ${service_name}=    Catenate    Service_Ete_Name${uuid}
    ${service_type}=    Set Variable    ${service}
    Create Customer For PNF     ${full_customer_name}    ${full_customer_name}     INFRA    ${service_type}    ${GLOBAL_AAI_CLOUD_OWNER}  ${tenant_id}  ${region}
    Setup Browser
    Login To VID GUI
    ${service_instance_id}  ${request_id}=   Wait Until Keyword Succeeds    300s   5s    Create VID PNF Service Instance    ${full_customer_name}    ${service_model_type}    ${service}     ${service_name}   ${project_name}   ${owning_entity}  ${product_family}  ${lcp_region}  ${tenant_name}  ${pnf_correlation_id}
    Wait Until Keyword Succeeds   120s   20s       Validate Service Instance    ${service_instance_id}    ${service}    ${full_customer_name}
    [Return]     ${service_instance_id}  ${request_id}  ${full_customer_name}

Orchestrate PNF Building Block Flow
    [Documentation]   Use ONAP to Orchestrate a PNF using GR api
    [Arguments]   ${service_model_name}  ${customer_name}    ${service}    ${product_family}    ${pnf_correlation_id}   ${region}   ${project_name}=Project-Demonstration   ${owning_entity}  ${owningEntityId}  ${project_name}=Project-Demonstration  ${lineOfBusinessName}=LOB-Demonstration    ${platformName}=Platform-Demonstration
    ${uuid}=   Generate UUID4
    ${full_customer_name}=    Catenate    ${customer_name}_${uuid}
    ${service_name}=    Catenate    Service_Ete_Name${uuid}
    ${service_type}=    Set Variable    ${service}
    Create Customer For PNF     ${full_customer_name}    ${full_customer_name}     INFRA    ${service_type}    ${GLOBAL_AAI_CLOUD_OWNER}  ${tenant_id}  ${region}
    ${json_resp}=  Get Service Catalog  ${service_model_name}
    ${service_model_uuid}=  Set Variable  ${json_resp["uuid"]}
    ${service_model_invariant_uuid }=  Set Variable  ${json_resp["invariantUUID"]}
    ${nf_resource_name}=  Set Variable  ${json_resp["componentInstances"][0]["name"]}
    ${nf_resource_uuid}=  Set Variable  ${json_resp["componentInstances"][0]["customizationUUID"]}
    ${componentName}=  Set Variable  ${json_resp["componentInstances"][0]["componentName"]}
    ${resource_ctalog_json}=  Get Resource Catalog  ${componentName}
    ${nf_model_invariant_uuid}=  Set Variable  ${json_resp["invariantUUID"]}
    ${nf_model_uuid}=  Set Variable  ${json_resp["uuid"]}
    ${nf_model_name}=  Set Variable  ${json_resp["name"]}
    ${productFamilyId}=  Get Service Id  ${product_family}
    ${arguments}=    Create Dictionary   service_model_invariant_uuid=${service_model_invariant_uuid}
    Set To Dictionary  ${arguments}  service_model_uuid  ${service_model_uuid}
    Set To Dictionary  ${arguments}  service_model_name  ${service_model_name}
    Set To Dictionary  ${arguments}  owningEntityId  ${owningEntityId}
    Set To Dictionary  ${arguments}  owningEntityName  ${owning_entity}
    Set To Dictionary  ${arguments}  full_customer_name  ${full_customer_name}
    Set To Dictionary  ${arguments}  service_name  ${service_name}
    Set To Dictionary  ${arguments}  productFamilyId  ${productFamilyId}
    Set To Dictionary  ${arguments}  service  ${service}
    Set To Dictionary  ${arguments}  nf_resource_name  ${nf_resource_name}
    Set To Dictionary  ${arguments}  nf_resource_uuid  ${nf_resource_uuid}
    Set To Dictionary  ${arguments}  nf_model_invariant_uuid  ${nf_model_invariant_uuid}
    Set To Dictionary  ${arguments}  nf_model_uuid  ${nf_model_uuid}
    Set To Dictionary  ${arguments}  nf_model_name  ${nf_model_name}
    Set To Dictionary  ${arguments}  platformName  ${platformName}
    Set To Dictionary  ${arguments}  lineOfBusinessName  ${lineOfBusinessName}
    Set To Dictionary  ${arguments}  productFamilyId  ${productFamilyId}
    Set To Dictionary  ${arguments}  nf_instance_name  ${pnf_correlation_id}
    ${request_id}  ${service_instance_id}=   Create PNF Service Using GR Api   ${arguments}
    Wait Until Keyword Succeeds   180  20s    Validate Service Instance    ${service_instance_id}    ${service}    ${full_customer_name}
    Wait Until Keyword Succeeds   180  20s    Check PNF orchestration status in A&AI  ${pnf_correlation_id}  Register
    [Return]     ${service_instance_id}  /onap/so/infra/orchestrationRequests/v7/${request_id}  ${full_customer_name}


Create Customer For PNF
    [Documentation]    PNF Orchestration Test setup....
    ...                Create Customer, Create Service and related relationships
    [Arguments]    ${customer_name}    ${customer_id}    ${customer_type}    ${service_type}    ${cloud_owner}    ${tenant_id}   ${cloud_region_id}
    Create Service If Not Exists    ${service_type}
    ${resp}=    Create Customer    ${customer_name}    ${customer_id}    ${customer_type}    ${service_type}   ${cloud_owner}  ${cloud_region_id}    ${tenant_id}
	Should Be Equal As Strings 	${resp} 	201