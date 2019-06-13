*** Settings ***
Documentation	  The main interface for interacting with SMS.
Library 	      RequestsLibrary
Resource          global_properties.robot

*** Variables ***
${SMS_HEALTH_CHECK_PATH}        /v1/sms/healthcheck
${SMS_ENDPOINT}     ${GLOBAL_SMS_SERVER_PROTOCOL}://${GLOBAL_SMS_SERVER_NAME}:${GLOBAL_SMS_SERVER_PORT}

*** Keywords ***
Run SMS Health Check
     [Documentation]    Runs SMS Health check
     ${resp}=    Run SMS Get Request    ${SMS_HEALTH_CHECK_PATH}
     Should Be Equal As Strings 	${resp.status_code} 	200

Run SMS Get Request
     [Documentation]    Runs SMS Get request
     [Arguments]    ${data_path}
     ${session}=    Create Session  smssession  ${SMS_ENDPOINT}
     ${resp}= 	Get Request     smssession 	${data_path}
     Should Be Equal As Integers 	${resp.status_code} 	200
     Log    Received response from SMS ${resp.text}
     [Return]    ${resp}