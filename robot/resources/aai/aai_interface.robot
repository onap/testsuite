*** Settings ***
Documentation     The main interface for interacting with A&AI. It handles low level stuff like managing the http request library and A&AI required fields
Library 	      RequestsLibrary
Library	          UUID      
Resource            ../global_properties.robot

*** Variables ***
${AAI_HEALTH_PATH}  /aai/util/echo?action=long

*** Keywords ***
Run A&AI Health Check
    [Documentation]    Runs an A&AI health check
    ${resp}=    Run A&AI Get Request    ${AAI_HEALTH_PATH}    
    Should Be Equal As Strings 	${resp.status_code} 	200

Run A&AI Get Request
    [Documentation]    Runs an A&AI get request
    [Arguments]    ${data_path}
    ${auth}=  Create List  ${GLOBAL_AAI_USERNAME}    ${GLOBAL_AAI_PASSWORD}
    ${session}=    Create Session 	aai 	${GLOBAL_AAI_SERVER_URL}    auth=${auth}
    ${uuid}=    Generate UUID
    ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json    X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}
    ${resp}= 	Get Request 	aai 	${data_path}     headers=${headers}
    Log    Received response from aai ${resp.text}
    [Return]    ${resp}
    
Run A&AI Put Request
    [Documentation]    Runs an A&AI put request
    [Arguments]    ${data_path}    ${data}
    ${auth}=  Create List  ${GLOBAL_AAI_USERNAME}    ${GLOBAL_AAI_PASSWORD}
    ${session}=    Create Session 	aai 	${GLOBAL_AAI_SERVER_URL}    auth=${auth}
    ${uuid}=    Generate UUID
    ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json    X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}
    ${resp}= 	Put Request 	aai 	${data_path}     data=${data}    headers=${headers}
    Log    Received response from aai ${resp.text}
    [Return]    ${resp}

Run A&AI Post Request
    [Documentation]    Runs an A&AI Post request
    [Arguments]    ${data_path}    ${data}
    ${auth}=  Create List  ${GLOBAL_AAI_USERNAME}    ${GLOBAL_AAI_PASSWORD}
    ${session}=    Create Session 	aai 	${GLOBAL_AAI_SERVER_URL}    auth=${auth}
    ${uuid}=    Generate UUID
    ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json    X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}
    ${resp}= 	Post Request 	aai 	${data_path}     data=${data}    headers=${headers}
    Log    Received response from aai ${resp.text}
    [Return]    ${resp}
    
Run A&AI Delete Request
    [Documentation]    Runs an A&AI delete request
    [Arguments]    ${data_path}    ${resource_version}
    ${auth}=  Create List  ${GLOBAL_AAI_USERNAME}    ${GLOBAL_AAI_PASSWORD}
    ${session}=    Create Session 	aai 	${GLOBAL_AAI_SERVER_URL}    auth=${auth}
    ${uuid}=    Generate UUID
    ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json    X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}
    ${resp}= 	Delete Request 	aai 	${data_path}?resource-version=${resource_version}       headers=${headers}
    Log    Received response from aai ${resp.text}
    [Return]    ${resp}