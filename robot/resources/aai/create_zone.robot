*** Settings ***
Documentation	  Create A&AI Customer API.
...
...	              Create A&AI Customer API

Resource    ../json_templater.robot
Resource    aai_interface.robot
Library    OperatingSystem
Library    Collections



*** Variables ***
${ZONE_INDEX_PATH}     /aai/v11
${ROOT_ZONE_PATH}  /network/zones/zone

${SYSTEM USER}    robot-ete
${AAI_ADD_ZONE_BODY}=    robot/assets/templates/aai/add_zone_body.template

*** Keywords ***
Inventory Zone If Not Exists
    [Documentation]    Creates a service in A&AI if it doesn't exist
    [Arguments]    ${zone_id}=${GLOBAL_AAI_ZONE_ID}  ${zone_name}=${GLOBAL_AAI_ZONE_NAME}  ${design_type}=${GLOBAL_AAI_DESIGN_TYPE}    ${zone_context}=${GLOBAL_AAI_ZONE_CONTEXT}
    ${get_resp}=    Run A&AI Get Request     ${ZONE_INDEX_PATH}${ROOT_ZONE_PATH}/${zone_id}
    Return From Keyword If    '${get_resp.status_code}' == '200'
    Inventory Zone  ${zone_id}  ${zone_name}  ${design_type}    ${zone_context}

Inventory Zone
    [Documentation]    Inventorys a Tenant in A&AI
    [Arguments]    ${zone_id}  ${zone_name}  ${design_type}    ${zone_context}
    ${arguments}=    Create Dictionary     zone_id=${zone_id}  zone_name=${zone_name}  design_type=${design_type}    zone_context=${zone_context}
    ${data}=	Fill JSON Template File    ${AAI_ADD_ZONE_BODY}    ${arguments}
	${put_resp}=    Run A&AI Put Request     ${ZONE_INDEX_PATH}${ROOT_ZONE_PATH}/${zone_id}     ${data}
    ${status_string}=    Convert To String    ${put_resp.status_code}
    Should Match Regexp    ${status_string} 	^(201|200)$

Delete Zone
    [Documentation]    Removes both Tenant
    [Arguments]    ${zone_id}=${GLOBAL_AAI_ZONE_ID}
    ${get_resp}=    Run A&AI Get Request     ${ZONE_INDEX_PATH}${ROOT_ZONE_PATH}/${zone_id}
    Run Keyword If    '${get_resp.status_code}' == '200'    Delete Zone Exists    ${zone_id}   ${get_resp.json()}

Delete Zone Exists
    [Arguments]    ${zone_id}    ${json}
    ${resource_version}=   Catenate   ${json['resource-version']}
    ${put_resp}=    Run A&AI Delete Request    ${ZONE_INDEX_PATH}${ROOT_ZONE_PATH}/${zone_id}    ${resource_version}
    Should Be Equal As Strings 	${put_resp.status_code} 	204

Get Zone
    [Documentation]   Return zone
    [Arguments]    ${zone_id}
	${resp}=    Run A&AI Get Request     ${ZONE_INDEX_PATH}${ROOT_ZONE_PATH}/${zone_id}
    Should Be Equal As Strings 	${resp.status_code} 	200
	[Return]  ${resp.json()}





