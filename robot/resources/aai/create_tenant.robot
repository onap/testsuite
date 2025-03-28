*** Settings ***
Documentation	  Create A&AI Customer API.

Resource    aai_interface.robot
Library    Collections
Library    ONAPLibrary.Templating    WITH NAME    Templating
Library    ONAPLibrary.AAI    WITH NAME    AAI


*** Variables ***
${INDEX PATH}     /aai/v11
${ROOT_TENANT_PATH}  /cloud-infrastructure/cloud-regions/cloud-region/

${AAI_ADD_TENANT_BODY}=    aai/add_tenant_body.jinja

*** Keywords ***
Inventory Tenant If Not Exists
    [Documentation]    Creates a service in A&AI if it doesn't exist
    [Arguments]    ${cloud_owner}  ${cloud_region_id}  ${cloud_type}    ${owner_defined_type}    ${cloud_region_version}    ${cloud_zone}    ${tenant_id}    ${tenant_name}
    ${dict}=    Get Tenants    ${cloud_owner}   ${cloud_region_id}
    ${status}    ${value}=    Run Keyword And Ignore Error    Dictionary Should Contain Key    ${dict}    ${tenant_id}
    Run Keyword If    '${status}' == 'FAIL'    Inventory Tenant    ${cloud_owner}  ${cloud_region_id}  ${cloud_type}    ${owner_defined_type}    ${cloud_region_version}    ${cloud_zone}    ${tenant_id}    ${tenant_name}

Inventory Tenant
    [Documentation]    Inventorys a Tenant in A&AI
    [Arguments]    ${cloud_owner}  ${cloud_region_id}  ${cloud_type}    ${owner_defined_type}    ${cloud_region_version}    ${cloud_zone}    ${tenant_id}    ${tenant_name}
    ${json_resource_version}=   Get Resource Version If Exists   ${cloud_owner}  ${cloud_region_id}  ${cloud_type}    ${owner_defined_type}    ${cloud_region_version}    ${cloud_zone}
    ${arguments}=    Create Dictionary     cloud_owner=${cloud_owner}  cloud_region_id=${cloud_region_id}  cloud_type=${cloud_type}    owner_defined_type=${owner_defined_type}    cloud_region_version=${cloud_region_version}    cloud_zone=${cloud_zone}    tenant_id=${tenant_id}    tenant_name=${tenant_name}   resource_version=${json_resource_version}
    Templating.Create Environment    aai    ${GLOBAL_TEMPLATE_FOLDER}
    ${data}=   Templating.Apply Template    aai   ${AAI_ADD_TENANT_BODY}    ${arguments}
	${put_resp}=    AAI.Run Put Request     ${AAI_FRONTEND_ENDPOINT}    ${INDEX PATH}${ROOT_TENANT_PATH}${cloud_owner}/${cloud_region_id}     ${data}        auth=${GLOBAL_AAI_AUTHENTICATION}
    ${status_string}=    Convert To String    ${put_resp.status_code}
    Should Match Regexp    ${status_string} 	^(201|200)$

Get Resource Version If Exists
    [Documentation]    Creates a service in A&AI if it doesn't exist
    [Arguments]    ${cloud_owner}  ${cloud_region_id}  ${cloud_type}    ${owner_defined_type}    ${cloud_region_version}    ${cloud_zone}
    ${resource_version}=   Set Variable
    ${resp}=    Get Cloud Region    ${cloud_owner}   ${cloud_region_id}
    Return from Keyword if   '${resp.status_code}' != '200'   ${resource_version}
    ${json}=   Set Variable   ${resp.json()}
    ${resource_version}=   Catenate   ${json['resource-version']}
    [Return]   "resource-version":"${resource_version}",


Delete Tenant
    [Documentation]    Removes both Tenant
    [Arguments]    ${tenant_id}    ${cloud_owner}    ${cloud_region_id}
    ${get_resp}=    AAI.Run Get Request     ${AAI_FRONTEND_ENDPOINT}    ${INDEX PATH}${ROOT_TENANT_PATH}${cloud_owner}/${cloud_region_id}/tenants/tenant/${tenant_id}        auth=${GLOBAL_AAI_AUTHENTICATION}
    Run Keyword If    '${get_resp.status_code}' == '200'    Delete Tenant Exists    ${tenant_id}    ${cloud_owner}    ${cloud_region_id}    ${get_resp.json()['resource-version']}

Delete Tenant Exists
    [Arguments]    ${tenant_id}    ${cloud_owner}    ${cloud_region_id}    ${resource_version}
    ${put_resp}=    AAI.Run Delete Request    ${AAI_FRONTEND_ENDPOINT}    ${INDEX PATH}${ROOT_TENANT_PATH}${cloud_owner}/${cloud_region_id}/tenants/tenant/${tenant_id}    ${resource_version}        auth=${GLOBAL_AAI_AUTHENTICATION}
    Should Be Equal As Strings 	${put_resp.status_code} 	204

Delete Cloud Region
    [Documentation]    Removes both Tenant and Cloud Region in A&AI
    [Arguments]    ${tenant_id}    ${cloud_owner}    ${cloud_region_id}
    ${get_resp}=    AAI.Run Get Request     ${AAI_FRONTEND_ENDPOINT}    ${INDEX PATH}${ROOT_TENANT_PATH}${cloud_owner}/${cloud_region_id}        auth=${GLOBAL_AAI_AUTHENTICATION}
	Run Keyword If    '${get_resp.status_code}' == '200'    Delete Cloud Region Exists   ${tenant_id}    ${cloud_owner}    ${cloud_region_id}    ${get_resp.json()['resource-version']}

Delete Cloud Region Exists
    [Documentation]   Delete may get status 400 (Bad Request) if the region is still referenced
    [Arguments]    ${tenant_id}    ${cloud_owner}    ${cloud_region_id}    ${resource_version}
    ${put_resp}=    AAI.Run Delete Request    ${AAI_FRONTEND_ENDPOINT}    ${INDEX PATH}${ROOT_TENANT_PATH}${cloud_owner}/${cloud_region_id}   ${resource_version}        auth=${GLOBAL_AAI_AUTHENTICATION}
    ${status_string}=    Convert To String    ${put_resp.status_code}
    Should Match Regexp    ${status_string}    ^(204|400)$

Get Tenants
    [Documentation]   Return list of tenants for this cloud owner/region
    [Arguments]    ${cloud_owner}    ${cloud_region_id}
	${resp}=    AAI.Run Get Request     ${AAI_FRONTEND_ENDPOINT}    ${INDEX PATH}${ROOT_TENANT_PATH}${cloud_owner}/${cloud_region_id}/tenants        auth=${GLOBAL_AAI_AUTHENTICATION}
	${dict}=    Create Dictionary
    ${status}    ${value}=    Run Keyword And Ignore Error    Should Be Equal As Strings 	${resp.status_code} 	200
    Run Keyword If    '${status}' == 'PASS'    Update Tenant Dictionary    ${dict}    ${resp.json()}
	[Return]  ${dict}

Get Cloud Region
    [Documentation]   Returns the Cloud Region if it exists
    [Arguments]    ${cloud_owner}    ${cloud_region_id}
	${resp}=    AAI.Run Get Request     ${AAI_FRONTEND_ENDPOINT}    ${INDEX PATH}${ROOT_TENANT_PATH}${cloud_owner}/${cloud_region_id}        auth=${GLOBAL_AAI_AUTHENTICATION}
	[Return]  ${resp}

Update Tenant Dictionary
    [Arguments]    ${dict}    ${json}
    @{list}=  Copy List      ${json['tenant']}
    FOR   ${map}    IN    @{list}
        ${status}    ${tenant_id}=     Run Keyword And Ignore Error    Get From Dictionary    ${map}    tenant-id
        Run Keyword If    '${status}' == 'PASS'    Set To Dictionary    ${dict}    ${tenant_id}=${map}
    END
    Log    ${dict}
