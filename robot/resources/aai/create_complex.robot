*** Settings ***
Documentation	  Create A&AI Customer API.

Resource    aai_interface.robot
Library    OperatingSystem
Library    Collections
Library    ONAPLibrary.Templating    


*** Variables ***
${COMPLEX_INDEX_PATH}     /aai/v11
${ROOT_COMPLEXES_PATH}  /cloud-infrastructure/complexes
${ROOT_COMPLEX_PATH}  /cloud-infrastructure/complexes/complex

${AAI_ADD_COMPLEX_BODY}    aai/add_complex_body.jinja

*** Keywords ***
Inventory Complex If Not Exists
    [Documentation]    Creates a service in A&AI if it doesn't exist
    [Arguments]    ${complex_name}   ${physical_location_id}   ${cloud_owner}   ${region}   ${owner_defined_type}
    ${get_resp}=    Run A&AI Get Request     ${COMPLEX_INDEX_PATH}${ROOT_COMPLEX_PATH}/${physical_location_id}
    Return From Keyword If    '${get_resp.status_code}' == '200'
    Inventory Complex  ${complex_name}   ${physical_location_id}   ${cloud_owner}   ${region}   ${owner_defined_type}

Inventory Complex
    [Documentation]    Inventorys a Complex in A&AI
    [Arguments]    ${complex_name}   ${physical_location_id}   ${cloud_owner}   ${region}   ${owner_defined_type}
    ${arguments}=    Create Dictionary     complex_name=${complex_name}
    Set To Dictionary   ${arguments}     physical_location_id=${physical_location_id}
    Set To Dictionary   ${arguments}     cloud_owner=${cloud_owner}
    Set To Dictionary   ${arguments}     region=${region}
    Set To Dictionary   ${arguments}     owner_defined_type=${owner_defined_type}
    Create Environment    aai    ${GLOBAL_TEMPLATE_FOLDER}
    ${data}=   Apply Template    aai   ${AAI_ADD_COMPLEX_BODY}    ${arguments}
	${put_resp}=    Run A&AI Put Request     ${COMPLEX_INDEX_PATH}${ROOT_COMPLEX_PATH}/${physical_location_id}     ${data}
    ${status_string}=    Convert To String    ${put_resp.status_code}
    Should Match Regexp    ${status_string} 	^(201|200)$

Delete Complex If Exists
    [Documentation]    Removes a complex
    [Arguments]    ${physical_location_id}
    ${get_resp}=    Run A&AI Get Request     ${COMPLEX_INDEX_PATH}${ROOT_COMPLEX_PATH}/${physical_location_id}
    Run Keyword If    '${get_resp.status_code}' == '200'    Delete Complex    ${physical_location_id}   ${get_resp.json()}

Delete Complex
    [Arguments]    ${physical_location_id}    ${json}
    ${resource_version}=   Catenate   ${json['resource-version']}
    ${put_resp}=    Run A&AI Delete Request    ${COMPLEX_INDEX_PATH}${ROOT_COMPLEX_PATH}/${physical_location_id}    ${resource_version}
    Should Be Equal As Strings 	${put_resp.status_code} 	204

Get Complex
    [Documentation]   Return a complex
    [Arguments]    ${physical_location_id}
	${resp}=    Run A&AI Get Request     ${COMPLEX_INDEX_PATH}${ROOT_COMPLEX_PATH}/${physical_location_id}
    Should Be Equal As Strings 	${resp.status_code} 	200
	[Return]  ${resp.json()}

Get Complexes
    [Documentation]   Return all complexes
	${resp}=    Run A&AI Get Request     ${COMPLEX_INDEX_PATH}${ROOT_COMPLEXES_PATH}
    Should Be Equal As Strings 	${resp.status_code} 	200
    Log    ${resp.json()}
	[Return]  ${resp.json()}