*** Settings ***
Documentation     The main interface for interacting with A&AI. It handles low level stuff like managing the http request library and A&AI required fields
Library 	      RequestsLibrary
Library	          ONAPLibrary.Utilities
Library           ONAPLibrary.AAI    WITH NAME     AAI
Resource            ../global_properties.robot

*** Variables ***
${AAI_HEALTH_PATH}  /aai/util/echo?action=long
${VERSIONED_INDEX_PATH}     /aai/v11
${AAI_FRONTEND_ENDPOINT}    ${GLOBAL_AAI_SERVER_PROTOCOL}://${GLOBAL_INJECTED_AAI_IP_ADDR}:${GLOBAL_AAI_SERVER_PORT}


*** Keywords ***
Run A&AI Health Check
    [Documentation]    Runs an A&AI health check
    ${resp}=    AAI.Run Get Request    ${AAI_FRONTEND_ENDPOINT}    ${AAI_HEALTH_PATH}    auth=${GLOBAL_AAI_AUTHENTICATION}
    Should Be Equal As Strings 	${resp.status_code} 	200

Delete A&AI Entity
    [Documentation]    Deletes an entity in A&AI
    [Arguments]    ${uri}
    ${resp}=    AAI.Run Get Request    ${AAI_FRONTEND_ENDPOINT}    ${VERSIONED_INDEX_PATH}${uri}    auth=${GLOBAL_AAI_AUTHENTICATION}
	Run Keyword If    '${resp.status_code}' == '200'    Delete A&AI Entity Exists    ${uri}    ${resp.json()['resource-version']}

Delete A&AI Entity Exists
    [Documentation]    Deletes an  A&AI	entity
    [Arguments]    ${uri}    ${resource_version_id}
    ${put_resp}=    AAI.Run Delete Request    ${AAI_FRONTEND_ENDPOINT}    ${VERSIONED_INDEX_PATH}${uri}    ${resource_version_id}    auth=${GLOBAL_AAI_AUTHENTICATION}
    Should Be Equal As Strings 	${put_resp.status_code} 	204