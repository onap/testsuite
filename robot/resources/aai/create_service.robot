*** Settings ***
Documentation	  Create A&AI Customer API.

Resource    aai_interface.robot
Library    Collections
Library	   ONAPLibrary.Utilities
Library	   ONAPLibrary.Templating    


*** Variables ***
${INDEX PATH}     /aai/v11
${ROOT_SERVICE_PATH}  /service-design-and-creation/services

${SYSTEM USER}    robot-ete
${AAI_ADD_SERVICE_BODY}=    aai/add_service_body.jinja

*** Keywords ***
Create Service If Not Exists
    [Documentation]    Creates a service in A&AI if it doesn't exist
    [Arguments]    ${service_type}
    ${dict}=    Get Services
    ${status}    ${value}=    Run Keyword And Ignore Error    Dictionary Should Contain Key    ${dict}    ${service_type}
    Run Keyword If    '${status}' == 'FAIL'    Create Service    ${service_type}

Create Service
    [Documentation]    Creates a service in A&AI
    [Arguments]    ${service_type}
    ${uuid}=    Generate UUID4
    ${arguments}=    Create Dictionary    service_type=${service_type}    UUID=${uuid}
    Create Environment    aai    ${GLOBAL_TEMPLATE_FOLDER}
    ${data}=   Apply Template    aai   ${AAI_ADD_SERVICE_BODY}    ${arguments}
    ${fullpath}=    Catenate         ${INDEX PATH}${ROOT_SERVICE_PATH}/service/${uuid}
	${put_resp}=    Run A&AI Put Request     ${fullpath}    ${data}
    Should Be Equal As Strings 	${put_resp.status_code} 	201
	[Return]  ${put_resp.status_code}


Delete Service If Exists
    [Documentation]    Deletes a service in A&AI if it exists
    [Arguments]    ${service_type}
    ${dict}=    Get Services
    ${status}    ${value}=    Run Keyword And Ignore Error    Dictionary Should Contain Key    ${dict}    ${service_type}
    Run Keyword If    '${status}' == 'PASS'    Delete Service    ${dict['${service_type}']}

Delete Service
    [Documentation]    Delete  passed service in A&AI
    [Arguments]    ${dict}
    ${uuid}=    Get From Dictionary    ${dict}     service-id
    ${resource_version}=    Get From Dictionary    ${dict}     resource-version
    ${fullpath}=    Catenate         ${INDEX PATH}${ROOT_SERVICE_PATH}/service/${uuid}
	${resp}=    Run A&AI Delete Request    ${fullpath}    ${resource_version}
    Should Be Equal As Strings 	${resp.status_code} 	204


Get Services
    [Documentation]    Creates a service in A&AI
	${resp}=    Run A&AI Get Request     ${INDEX PATH}${ROOT_SERVICE_PATH}
	${dict}=    Create Dictionary
    ${status}    ${value}=    Run Keyword And Ignore Error    Should Be Equal As Strings 	${resp.status_code} 	200
    Run Keyword If    '${status}' == 'PASS'    Update Service Dictionary    ${dict}    ${resp.json()}
	[Return]  ${dict}

Update Service Dictionary
    [Arguments]    ${dict}    ${json}
    ${list}=    Evaluate    ${json}['service']
    :FOR   ${map}    IN    @{list}
    \    ${status}    ${service_type}=     Run Keyword And Ignore Error    Get From Dictionary    ${map}    service-description
    \    Run Keyword If    '${status}' == 'PASS'    Set To Dictionary    ${dict}    ${service_type}=${map}
    Log    ${dict}


