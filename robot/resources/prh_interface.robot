*** Settings ***
Documentation     The main interface for interacting with PRH. It handles low level stuff like managing the http request library and PRH required fields
Library 	      RequestsLibrary
Library	          UUID
Library           OperatingSystem
Library           Collections
Resource          global_properties.robot


*** Variables ***
${PRH_HEALTH_CHECK_PATH}    /heartbeat
${PRH_HEALTH_ENDPOINT}     ${GLOBAL_SERVER_PROTOCOL}://${GLOBAL_DNS_PRH_NAME}:${GLOBAL_PRH_HEALTH_SERVER_PORT}


*** Keywords ***
Run PRH Health Check
    [Documentation]    Runs a PRH health check
    Log    Creating session ${PRH_HEALTH_ENDPOINT}
    ${session}=    Create Session 	hv-ves 	${PRH_HEALTH_ENDPOINT}
    ${uuid}=    Generate UUID
    ${resp}= 	Get Request 	hv-ves 	${PRH_HEALTH_CHECK_PATH}
    Log    Received response code from hv-ves ${resp}
    Log    Received content from hv-ves ${resp.content}
    Should Be Equal As Strings 	${resp.status_code} 	200
