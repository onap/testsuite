*** Settings ***
Documentation	  Create A&AI Customer API.

Resource    aai_interface.robot
Library    OperatingSystem
Library    Collections
Library    ONAPLibrary.Templating    WITH NAME    Templating
Library    ONAPLibrary.AAI    WITH NAME    AAI


*** Variables ***
${ZONE_INDEX_PATH}     /aai/v11
${ROOT_ZONE_PATH}  /network/zones/zone

${AAI_ADD_ZONE_BODY}=    aai/add_zone_body.jinja

*** Keywords ***
Inventory Zone If Not Exists
    [Documentation]    Creates a service in A&AI if it doesn't exist
    [Arguments]    ${zone_id}=${GLOBAL_AAI_ZONE_ID}  ${zone_name}=${GLOBAL_AAI_ZONE_NAME}  ${design_type}=${GLOBAL_AAI_DESIGN_TYPE}    ${zone_context}=${GLOBAL_AAI_ZONE_CONTEXT}
    ${auth}=  Create List  ${GLOBAL_AAI_USERNAME}    ${GLOBAL_AAI_PASSWORD}
    ${get_resp}=    AAI.Run Get Request     ${AAI_FRONTEND_ENDPOINT}    ${ZONE_INDEX_PATH}${ROOT_ZONE_PATH}/${zone_id}        auth=${auth}
    Return From Keyword If    '${get_resp.status_code}' == '200'
    Inventory Zone  ${zone_id}  ${zone_name}  ${design_type}    ${zone_context}

Inventory Zone
    [Documentation]    Inventorys a Tenant in A&AI
    [Arguments]    ${zone_id}  ${zone_name}  ${design_type}    ${zone_context}
    ${arguments}=    Create Dictionary     zone_id=${zone_id}  zone_name=${zone_name}  design_type=${design_type}    zone_context=${zone_context}
    Templating.Create Environment    aai    ${GLOBAL_TEMPLATE_FOLDER}
    ${data}=   Templating.Apply Template    aai   ${AAI_ADD_ZONE_BODY}    ${arguments}
    ${auth}=  Create List  ${GLOBAL_AAI_USERNAME}    ${GLOBAL_AAI_PASSWORD}
	${put_resp}=    AAI.Run Put Request     ${AAI_FRONTEND_ENDPOINT}    ${ZONE_INDEX_PATH}${ROOT_ZONE_PATH}/${zone_id}     ${data}        auth=${auth}
    ${status_string}=    Convert To String    ${put_resp.status_code}
    Should Match Regexp    ${status_string} 	^(201|200)$

Delete Zone
    [Documentation]    Removes both Tenant
    [Arguments]    ${zone_id}=${GLOBAL_AAI_ZONE_ID}
    ${auth}=  Create List  ${GLOBAL_AAI_USERNAME}    ${GLOBAL_AAI_PASSWORD}
    ${get_resp}=    AAI.Run Get Request     ${AAI_FRONTEND_ENDPOINT}    ${ZONE_INDEX_PATH}${ROOT_ZONE_PATH}/${zone_id}        auth=${auth}
    Run Keyword If    '${get_resp.status_code}' == '200'    Delete Zone Exists    ${zone_id}   ${get_resp.json()}

Delete Zone Exists
    [Arguments]    ${zone_id}    ${json}
    ${resource_version}=   Catenate   ${json['resource-version']}
    ${auth}=  Create List  ${GLOBAL_AAI_USERNAME}    ${GLOBAL_AAI_PASSWORD}
    ${put_resp}=    AAI.Run Delete Request    ${AAI_FRONTEND_ENDPOINT}    ${ZONE_INDEX_PATH}${ROOT_ZONE_PATH}/${zone_id}    ${resource_version}        auth=${auth}
    Should Be Equal As Strings 	${put_resp.status_code} 	204

Get Zone
    [Documentation]   Return zone
    [Arguments]    ${zone_id}
    ${auth}=  Create List  ${GLOBAL_AAI_USERNAME}    ${GLOBAL_AAI_PASSWORD}
	${resp}=    AAI.Run Get Request     ${AAI_FRONTEND_ENDPOINT}    ${ZONE_INDEX_PATH}${ROOT_ZONE_PATH}/${zone_id}        auth=${auth}
    Should Be Equal As Strings 	${resp.status_code} 	200
	[Return]  ${resp.json()}
