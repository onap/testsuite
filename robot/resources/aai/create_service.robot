*** Settings ***
Documentation	  Create A&AI Customer API.

Resource    aai_interface.robot
Library    Collections
Library	   ONAPLibrary.Utilities
Library    ONAPLibrary.Templating    WITH NAME    Templating
Library    ONAPLibrary.AAI    WITH NAME    AAI


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
    Templating.Create Environment    aai    ${GLOBAL_TEMPLATE_FOLDER}
    ${data}=   Templating.Apply Template    aai   ${AAI_ADD_SERVICE_BODY}    ${arguments}
    ${fullpath}=    Catenate         ${INDEX PATH}${ROOT_SERVICE_PATH}/service/${uuid}
	${put_resp}=    AAI.Run Put Request     ${AAI_FRONTEND_ENDPOINT}    ${fullpath}    ${data}        auth=${GLOBAL_AAI_AUTHENTICATION}
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
	${resp}=    AAI.Run Delete Request    ${AAI_FRONTEND_ENDPOINT}    ${fullpath}    ${resource_version}        auth=${GLOBAL_AAI_AUTHENTICATION}
    Should Be Equal As Strings 	${resp.status_code} 	204

Get Services
    [Documentation]    Creates a service in A&AI
	${resp}=    AAI.Run Get Request     ${AAI_FRONTEND_ENDPOINT}    ${INDEX PATH}${ROOT_SERVICE_PATH}        auth=${GLOBAL_AAI_AUTHENTICATION}
	${dict}=    Create Dictionary
    ${status}    ${value}=    Run Keyword And Ignore Error    Should Be Equal As Strings 	${resp.status_code} 	200
    Run Keyword If    '${status}' == 'PASS'    Update Service Dictionary    ${dict}    ${resp.json()}
	[Return]  ${dict}

Get Service Id
    [Documentation]    Gets a service id in A&AI
    [Arguments]    ${service_description}
	${resp}=    AAI.Run Get Request     ${AAI_FRONTEND_ENDPOINT}    ${INDEX PATH}${ROOT_SERVICE_PATH}        auth=${GLOBAL_AAI_AUTHENTICATION}
	${resp_json}=  Set Variable  ${resp.json()}
    ${id}=  Set Variable
    @{list}=  Copy List   ${resp_json['service']}
    FOR   ${map}    IN    @{list}
        ${service_type}=    Get From Dictionary    ${map}    service-description
        ${service_id}=     Get From Dictionary    ${map}    service-id
        ${id}   Run Keyword If    '${service_type}' == '${service_description}'    Set Variable    ${service_id}
    END
    [Return]  ${id}

Update Service Dictionary
    [Arguments]    ${dict}    ${json}
    @{list}=  Copy List   ${json['service']}
    FOR   ${map}    IN    @{list}
        ${status}    ${service_type}=     Run Keyword And Ignore Error    Get From Dictionary    ${map}    service-description
        Run Keyword If    '${status}' == 'PASS'    Set To Dictionary    ${dict}    ${service_type}=${map}
    END
    Log    ${dict}