*** Settings ***
Documentation	  The main interface for interacting with AAF. It handles low level stuff like managing the http request library and AAF required fields
Library 	      RequestsLibrary
Library	          ONAPLibrary.Utilities

Resource          global_properties.robot

*** Variables ***
${AAF_HEALTH_CHECK_PATH}        /authz/perms/user/${GLOBAL_AAF_USERNAME}

*** Keywords ***
Run AAF Health Check
     [Documentation]    Runs AAF Health check
     ${resp}=    Run AAF Get Request    ${AAF_HEALTH_CHECK_PATH}
     Should Be Equal As Strings 	${resp.status_code} 	200
     #Should Contain    ${resp.json()}    access

Run AAF Get Request
     [Documentation]    Runs AAF Get request
     [Arguments]    ${data_path}
     ${session}=    Create Session 	aaf	${GLOBAL_AAF_SERVER}    auth=${GLOBAL_AAF_AUTHENTICATION}
     ${uuid}=    Generate UUID4
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json    X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}
     ${resp}= 	GET On Session 	aaf 	${data_path}     headers=${headers}
     Log    Received response from aaf ${resp.text}
     [Return]    ${resp}
