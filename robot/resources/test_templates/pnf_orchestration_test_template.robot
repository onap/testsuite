*** Settings ***
Documentation	  This test template encapsulates the VNF Orchestration use case.

Resource        ../vid/create_service_instance.robot
Resource        ../vid/vid_interface.robot
Resource        ../aai/service_instance.robot
Resource        model_test_template.robot
Resource        ../openstack/neutron_interface.robot


Library         ONAPLibrary.Openstack
Library 	    SeleniumLibrary
Library	        Collections
Library	        ONAPLibrary.Utilities

*** Keywords ***

Orchestrate PNF
    [Documentation]   Use ONPA to Orchestrate a PNF Macro service.
    [Arguments]    ${customer_name}    ${service}    ${product_family}    ${pnf_correlation_id}  ${tenant_id}    ${tenant_name}   ${service_model_type}   ${project_name}=Project-Demonstration   ${owning_entity}=OE-Demonstration
    ${lcp_region}=   Get Openstack Region
    ${uuid}=    Generate UUID4
    ${full_customer_name}=    Catenate    ${customer_name}_${uuid}
    ${list}=    Create List
    ${service_name}=    Catenate    Service_Ete_Name${uuid}
    ${service_type}=    Set Variable    ${service}
    Create Customer For VNF     ${full_customer_name}    ${full_customer_name}     INFRA    ${service_type}    ${GLOBAL_AAI_CLOUD_OWNER}  ${tenant_id}
    Setup Browser
    Login To VID GUI
    ${service_instance_id}  ${request_id}=   Wait Until Keyword Succeeds    300s   5s    Create VID PNF Service Instance    ${full_customer_name}    ${service_model_type}    ${service}     ${service_name}   ${project_name}   ${owning_entity}  ${product_family}  ${lcp_region}  ${tenant_name}  ${pnf_correlation_id}
    Validate Service Instance    ${service_instance_id}    ${service}    ${full_customer_name}
    [Return]     ${service}  ${request_id}  ${full_customer_name}
