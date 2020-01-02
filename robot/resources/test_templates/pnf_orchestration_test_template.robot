*** Settings ***
Documentation	  This test template encapsulates the PNF Orchestration use case.

Resource        ../vid/create_service_instance.robot
Resource        ../vid/vid_interface.robot
Resource        ../aai/service_instance.robot
Resource        model_test_template.robot
Resource        ../openstack/neutron_interface.robot
Resource          ../sdc_interface.robot
Resource          vnf_orchestration_test_template.robot


Library         ONAPLibrary.Openstack
Library 	    SeleniumLibrary
Library	        Collections
Library	        ONAPLibrary.Utilities

*** Keywords ***

Orchestrate PNF
    [Documentation]   Use ONAP to Orchestrate a PNF Macro service.
    [Arguments]    ${customer_name}    ${service}    ${product_family}    ${pnf_correlation_id}  ${tenant_id}    ${tenant_name}   ${service_model_type}   ${project_name}=Project-Demonstration   ${owning_entity}=OE-Demonstration
    ${lcp_region}=   Set Variable   ${GLOBAL_INJECTED_REGION}
    ${uuid}=    Generate UUID4
    ${full_customer_name}=    Catenate    ${customer_name}_${uuid}
    ${list}=    Create List
    ${service_name}=    Catenate    Service_Ete_Name${uuid}
    ${service_type}=    Set Variable    ${service}
    Create Customer For PNF     ${full_customer_name}    ${full_customer_name}     INFRA    ${service_type}    ${GLOBAL_AAI_CLOUD_OWNER}  ${tenant_id}  ${GLOBAL_INJECTED_REGION}
    Setup Browser
    Login To VID GUI
    ${service_instance_id}  ${request_id}=   Wait Until Keyword Succeeds    300s   5s    Create VID PNF Service Instance    ${full_customer_name}    ${service_model_type}    ${service}     ${service_name}   ${project_name}   ${owning_entity}  ${product_family}  ${lcp_region}  ${tenant_name}  ${pnf_correlation_id}
    Wait Until Keyword Succeeds   60s   20s       Validate Service Instance    ${service_instance_id}    ${service}    ${full_customer_name}
    [Return]     ${service}  ${request_id}  ${full_customer_name}


Create Customer For PNF
    [Documentation]    PNF Orchestration Test setup....
    ...                Create Customer, Create Service and related relationships
    [Arguments]    ${customer_name}    ${customer_id}    ${customer_type}    ${service_type}    ${cloud_owner}    ${tenant_id}   ${cloud_region_id}
    Create Service If Not Exists    ${service_type}
    ${resp}=    Create Customer    ${customer_name}    ${customer_id}    ${customer_type}    ${service_type}   ${cloud_owner}  ${cloud_region_id}    ${tenant_id}
	Should Be Equal As Strings 	${resp} 	201