*** Settings ***
Documentation     PNF Registration Handler (PRH) test cases
Resource        ../aai/aai_interface.robot
Resource        ../sdc_interface.robot
Resource        ../mr_interface.robot
Resource        ../so/add_service_recipe.robot
Resource        ../test_templates/pnf_orchestration_test_template.robot
Resource        ../demo_preload.robot
Library         ONAPLibrary.Openstack
Library         OperatingSystem
Library         RequestsLibrary
Library         Collections
Library         ONAPLibrary.JSON
Library         ONAPLibrary.Utilities
Library         ONAPLibrary.Templating    WITH NAME    Templating
Library         ONAPLibrary.AAI    WITH NAME     AAI
Library         ONAPLibrary.SDC    WITH NAME     SDC
Library         ONAPLibrary.SO    WITH NAME     SO

*** Variables ***
${aai_so_registration_entry_template}=  aai/add_pnf_registration_info.jinja
${pnf_ves_integration_request}=  ves/pnf_registration_request.jinja
${DMAAP_MESSAGE_ROUTER_UNAUTHENTICATED_VES_PNFREG_OUTPUT_PATH}  /events/unauthenticated.VES_PNFREG_OUTPUT/2/1
${VES_ENDPOINT}     ${GLOBAL_DCAE_VES_PROTOCOL}://${GLOBAL_INJECTED_DCAE_VES_HOST}:${GLOBAL_DCAE_VES_SERVER_PORT}
${VES_data_path}   /eventListener/v7
${tenant_name}    dummy_tenant_for_pnf
${tenant_id}  dummy_tenant_id_for_pnf
${region}   ${GLOBAL_INJECTED_REGION}


*** Keywords ***
Create A&AI antry without SO and succesfully registrate PNF
    [Documentation]   Test case template for create A&AI antry without SO and succesfully registrate PNF
    [Arguments]   ${PNF_entry_dict}
    Send VES integration request  ${PNF_entry_dict}
    Wait Until Keyword Succeeds  10x  5s  Check VES_PNFREG_OUTPUT topic presence in MR
    Create PNF initial entry in A&AI  ${PNF_entry_dict}
    Send VES integration request  ${PNF_entry_dict}
    Verify PNF Integration Request in A&AI  ${PNF_entry_dict}

Create PNF initial entry in A&AI
    [Documentation]   Creates PNF initial entry in A&AI registry. Entry contains only correlation id (pnf-name)
    [Arguments]  ${PNF_entry_dict}
    Templating.Create Environment    aai    ${GLOBAL_TEMPLATE_FOLDER}
    ${template}=   Templating.Apply Template    aai    ${aai_so_registration_entry_template}   ${PNF_entry_dict}
    Log  Filled A&AI entry template ${template}
    ${correlation_id}=  Get From Dictionary  ${PNF_entry_dict}  correlation_id
    ${del_resp}=  Delete A&AI Entity  /network/pnfs/pnf/${PNF_entry_dict.correlation_id}
    Log  Removing existing entry "${PNF_entry_dict.correlation_id}" from A&AI registry
    ${put_resp}=  AAI.Run Put Request  ${AAI_FRONTEND_ENDPOINT}    /aai/v11/network/pnfs/pnf/${PNF_entry_dict.correlation_id}  ${template}    auth=${GLOBAL_AAI_AUTHENTICATION}
    Log  Adding new entry with correlation ID "${PNF_entry_dict.correlation_id}" to A&AI registry (empty IPv4 and IPv6 address)

Send VES integration request
    [Documentation]   Send VES integration request. Request contains correlation id (sourceName), oamV4IpAddress and oamV6IpAddress
    [Arguments]  ${PNF_entry_dict}
    Templating.Create Environment    aai    ${GLOBAL_TEMPLATE_FOLDER}
    ${template}=   Templating.Apply Template    aai    ${pnf_ves_integration_request}   ${PNF_entry_dict}
    ${post_resp}=  Run VES HTTP Post Request   ${template}
    Should Be Equal As Strings  ${post_resp.status_code}        202
    Log  VES integration request has been send

Verify PNF integration request in A&AI
    [Documentation]   Verify if PNF integration request entries are present in A&AI
    [Arguments]  ${PNF_entry_dict}
    Wait Until Keyword Succeeds  10x  5s  Query PNF A&AI updated entry  ${PNF_entry_dict}
    Log  PNF integration request in A&AI has been verified and contains all necessary entries

Query PNF A&AI updated entry
    [Documentation]   Query PNF A&AI updated entry
    [Arguments]  ${PNF_entry_dict}
    ${get_resp}=    AAI.Run Get Request    ${AAI_FRONTEND_ENDPOINT}    /aai/v11/network/pnfs/pnf/${PNF_entry_dict.correlation_id}    auth=${GLOBAL_AAI_AUTHENTICATION}
    Should Be Equal As Strings  ${get_resp.status_code}        200
    ${json_resp}=  Set Variable  ${get_resp.json()}
    Log  JSON recieved from A&AI endpoint ${json_resp}
    Should Be Equal As Strings  ${json_resp["ipaddress-v4-oam"]}      ${PNF_entry_dict.PNF_IPv4_address}
    Should Be Equal As Strings  ${json_resp["ipaddress-v6-oam"]}       ${PNF_entry_dict.PNF_IPv6_address}
    Should Be Equal As Strings  ${json_resp["pnf-name"]}       ${PNF_entry_dict.correlation_id}
    Log  PNF integration request in A&AI has been verified and contains all necessary entries

Check VES_PNFREG_OUTPUT topic presence in MR
    [Documentation]   Verify if unauthenticated.VES_PNFREG_OUTPUT topic is present in MR
    ${get_resp}=  Run MR Get Request  ${DMAAP_MESSAGE_ROUTER_UNAUTHENTICATED_VES_PNFREG_OUTPUT_PATH}
    Should Be Equal As Strings  ${get_resp.status_code}        200
    Log  unauthenticated.VES_PNFREG_OUTPUT topic is present in MR

Run VES HTTP Post Request
    [Documentation]    Runs a VES Post request
    [Arguments]     ${data}
    Disable Warnings
    ${session}=    Create Session       ves     ${VES_ENDPOINT}
    ${headers}=  Create Dictionary   Accept=application/json    Content-Type=application/json
    ${post_resp}=       Post Request    ves     ${VES_data_path}      data=${data}    headers=${headers}
    Log  PNF integration request ${data}
    Should Be Equal As Strings  ${post_resp.status_code}        202
    Log  VES has accepted event with status code ${post_resp.status_code}
    [Return]  ${post_resp}

Cleanup PNF entry in A&AI
    [Documentation]   Creates PNF initial entry in A&AI registry
    [Arguments]  ${PNF_entry_dict}
    ${del_resp}=  Delete A&AI Entity  /network/pnfs/pnf/${PNF_entry_dict.correlation_id}
    Log    Teardown complete


Check SO service completition status
    [Documentation]   Gets service status and compares with expected status
    [Arguments]    ${request_id}   ${so_expected_status}
    ${auth}=	Create List  ${GLOBAL_SO_USERNAME}    ${GLOBAL_SO_PASSWORD}
    ${so_status_request}=  SO.Run Get Request    ${GLOBAL_SO_ENDPOINT}    ${request_id}    auth=${auth}
    ${so_status_request_data}=   Set Variable  ${so_status_request.json()}
    ${so_status}=    Set Variable     ${so_status_request_data['request']['requestStatus']['requestState']}
    Should Be Equal As Strings  ${so_status}     ${so_expected_status}


Instantiate PNF_macro service and succesfully registrate PNF template
    [Documentation]   Test case template for design, create, instantiate PNF/macro service and succesfully registrate PNF
    [Arguments]    ${service_name}   ${PNF_entry_dict}   ${pnf_correlation_id}   ${service}=pNF    ${product_family}=pNF  ${customer_name}=ETE_Customer
    Log To Console   \nDistributing TOSCA Based PNF Model
    ${catalog_service_name}    ${catalog_resource_name}    ${vf_modules}   ${catalog_resources}    ${catalog_resource_ids}   ${catalog_service_id}  Model Distribution For Directory  ${service}  ${service_name}  cds=False   instantiationType=Macro  resourceType=PNF
    ${UUID}=  Get Service Model Parameter from SDC Service Catalog  ${service_name}  uuid
    Log To Console   Creating Service Recipe for TOSCA Based PNF Model
    ${service_recipe_id}=   Add Service Recipe  ${UUID}  mso/async/services/CreateVcpeResCustService_simplified
    Inventory Tenant If Not Exists    CloudOwner   ${region}  SharedNode  OwnerType  v1  CloudZone  ${tenant_id}   ${tenant_name}
    Load OwningEntity  project  Project-${customer_name}
    Load OwningEntity  owningEntity  OE-${customer_name}
    ${service_instance_id}  ${request_id}  ${full_customer_name}   Orchestrate PNF   ${customer_name}   ${service}    ${product_family}  ${pnf_correlation_id}  ${tenant_id}   ${tenant_name}  ${service_name}   Project-${customer_name}   OE-${customer_name}
    Wait Until Keyword Succeeds   120s  40s  Send and verify VES integration request in SO and A&AI   ${request_id}   ${PNF_entry_dict}
    [Teardown]   Instantiate PNF_macro service Teardown      ${catalog_service_id}    ${catalog_resource_ids}  ${PNF_entry_dict}  ${service_instance_id}  ${service_recipe_id}


Send and verify VES integration request in SO and A&AI
    [Documentation]   Gets service status and compares with expected status
    [Arguments]    ${request_id}   ${PNF_entry_dict}
    Send VES integration request  ${PNF_entry_dict}
    Verify PNF Integration Request in A&AI  ${PNF_entry_dict}
    Wait Until Keyword Succeeds   30s  10s  Check SO service completition status   ${request_id}   COMPLETE

Instantiate PNF_macro service Teardown
    [Arguments]  ${catalog_service_id}    ${catalog_resource_ids}  ${PNF_entry_dict}  ${service_instance_id}  ${service_recipe_id}
    Teardown Models  ${catalog_service_id}    ${catalog_resource_ids}
    Delete Service Recipe  ${service_recipe_id}
    Cleanup PNF entry in A&AI  ${PNF_entry_dict}