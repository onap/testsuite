*** Settings ***
Documentation	  Create A&AI Customer API.

Resource   aai_interface.robot
Library    Collections
Library    ONAPLibrary.Templating    WITH NAME    Templating
Library    ONAPLibrary.AAI    WITH NAME    AAI

*** Variables ***
${INDEX PATH}     /aai/v11
${ROOT_CUSTOMER_PATH}  /business/customers/customer/
${SYSTEM USER}    robot-ete
${A&AI ADD CUSTOMER BODY}    aai/add_customer.jinja

*** Keywords ***
Create Customer
    [Documentation]    Creates a customer in A&AI
    [Arguments]    ${customer_name}  ${customer_id}  ${customer_type}    ${service_type}      ${clouder_owner}    ${cloud_region_id}    ${tenant_id}
    ${arguments}=    Create Dictionary    subscriber_name=${customer_name}    global_customer_id=${customer_id}    subscriber_type=${customer_type}     cloud_owner1=${clouder_owner}  cloud_region_id1=${cloud_region_id}    tenant_id1=${tenant_id}    service1=${service_type}
    Templating.Create Environment    aai    ${GLOBAL_TEMPLATE_FOLDER}
    ${data}=   Templating.Apply Template    aai   ${A&AI ADD CUSTOMER BODY}    ${arguments}
	${put_resp}=    AAI.Run Put Request     ${AAI_FRONTEND_ENDPOINT}    ${INDEX PATH}${ROOT_CUSTOMER_PATH}${customer_id}    ${data}        auth=${GLOBAL_AAI_AUTHENTICATION}
    Should Be Equal As Strings 	${put_resp.status_code} 	201
	[Return]  ${put_resp.status_code}

Delete Customer
    [Documentation]    Deletes a customer in A&AI
    [Arguments]    ${customer_id}
    ${get_resp}=    AAI.Run Get Request     ${AAI_FRONTEND_ENDPOINT}    ${INDEX PATH}${ROOT_CUSTOMER_PATH}${customer_id}        auth=${GLOBAL_AAI_AUTHENTICATION}
	Run Keyword If    '${get_resp.status_code}' == '200'    Delete Customer Exists    ${customer_id}    ${get_resp.json()['resource-version']}

Delete Customer Exists
    [Documentation]    Deletes a customer in A&AI
    [Arguments]    ${customer_id}    ${resource_version_id}
    ${put_resp}=    AAI.Run Delete Request    ${AAI_FRONTEND_ENDPOINT}    ${INDEX PATH}${ROOT_CUSTOMER_PATH}${customer_id}    ${resource_version_id}        auth=${GLOBAL_AAI_AUTHENTICATION}
    Should Be Equal As Strings 	${put_resp.status_code} 	204

Get OwningEntity Id
    [Documentation]   Returns OwningEntity Id based on OwningEntity name
    [Arguments]    ${name}
    ${resp}=    AAI.Run Get Request    ${AAI_FRONTEND_ENDPOINT}    /aai/v11/business/owning-entities   auth=${GLOBAL_AAI_AUTHENTICATION}
  	${resp_json}=  Set Variable  ${resp.json()}
    @{list}=  Copy List   ${resp_json['owning-entity']}
    ${id}=  Set Variable
    FOR   ${map}    IN    @{list}
        ${owning_entity_name}=       Get From Dictionary    ${map}    owning-entity-name
        ${owning_entity_id}=       Get From Dictionary    ${map}    owning-entity-id
        ${id}   Run Keyword If    '${owning_entity_name}' == '${name}'    Set Variable    ${owning_entity_id}
    END
    [Return]  ${id}