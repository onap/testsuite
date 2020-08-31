*** Settings ***
Documentation     The main interface for interacting with A&AI. It handles low level stuff like managing the http request library and A&AI required fields
Library 	      RequestsLibrary
Library	          ONAPLibrary.Utilities
Library           ONAPLibrary.AAI    WITH NAME     AAI
Resource            ../global_properties.robot

*** Variables ***
${AAI_HEALTH_PATH}  /aai/util/echo?action=long
${VERSIONED_INDEX_PATH}     /aai/v14
${AAI_FRONTEND_ENDPOINT}    ${GLOBAL_AAI_SERVER_PROTOCOL}://${GLOBAL_INJECTED_AAI_IP_ADDR}:${GLOBAL_AAI_SERVER_PORT}
${model_invariant_id}    AAI-HealthCheck-Dummy
${data_path}                /aai/v14/service-design-and-creation/models/model/${model_invariant_id}
${PUT_data}    {"model-invariant-id": "AAI-HealthCheck-Dummy","model-type": "service"}
${traversal_data_path}    /aai/v14/query?format=count
${traversal_data}   {"start" : "service-design-and-creation/models"}


*** Keywords ***
Run A&AI Health Check
    [Documentation]    Runs an A&AI health check
    ${resp}=    AAI.Run Get Request    ${AAI_FRONTEND_ENDPOINT}    ${AAI_HEALTH_PATH}    auth=${GLOBAL_AAI_AUTHENTICATION}
    Should Be Equal As Strings 	${resp.status_code} 	200

Run Resource API AAI Inventory check
    [Documentation]    Runs  A&AI Inventory health check Resource API
    ${GET_res}=    AAI.Run Get Request    ${AAI_FRONTEND_ENDPOINT}    ${data_path}    auth=${GLOBAL_AAI_AUTHENTICATION}
    Run Keyword If    ${GET_res.status_code}== 200    Run Delete dummy data and perform resource API check    	
    Run Keyword If    ${GET_res.status_code}== 404    Run Resource API

Run Delete dummy data and perform resource API check
    [Documentation]    Delete Existing dummy data and performing put get and delete activity
    ${GET_res}=    AAI.Run Get Request    ${AAI_FRONTEND_ENDPOINT}    ${data_path}    auth=${GLOBAL_AAI_AUTHENTICATION}
    ${json} =      Set Variable   ${GET_res.json()}
    ${resource_version}  Set Variable  ${json["resource-version"]}
    ${delete_response}=    AAI.Run Delete Request    ${AAI_FRONTEND_ENDPOINT}    ${data_path}    ${resource_version}    auth=${GLOBAL_AAI_AUTHENTICATION}
    Should Be Equal As Strings  ${delete_response.status_code}     204
    Run Resource API

Run Resource API
    [Documentation]    Resource API check with put get and delete request
    #PUT Request
    ${Put_resp}=    AAI.Run Put Request    ${AAI_FRONTEND_ENDPOINT}    ${data_path}    ${PUT_data}    auth=${GLOBAL_AAI_AUTHENTICATION}
    Should Be Equal As Strings  ${Put_resp.status_code}     201
    #GET Request
    ${GET_resp}=    AAI.Run Get Request    ${AAI_FRONTEND_ENDPOINT}    ${data_path}    auth=${GLOBAL_AAI_AUTHENTICATION}
    Should Be Equal As Strings  ${GET_resp.status_code}     200
    ${res_body}=   Convert to string     ${GET_resp.content}
    Should contain    ${res_body}   ${model_invariant_id}
    #DELETE Request
    ${json} =      Set Variable   ${GET_resp.json()}
    ${resource_version}  Set Variable  ${json["resource-version"]}
    ${delete_response}=    AAI.Run Delete Request    ${AAI_FRONTEND_ENDPOINT}    ${data_path}    ${resource_version}    auth=${GLOBAL_AAI_AUTHENTICATION}
    Should Be Equal As Strings  ${delete_response.status_code}     204

Run Traversal API AAI Inventory check
    [Documentation]    Runs  A&AI Inventory health check Traversal API
    ${Put_resp}=    AAI.Run Put Request    ${AAI_FRONTEND_ENDPOINT}    ${traversal_data_path}    ${traversal_data}    auth=${GLOBAL_AAI_AUTHENTICATION}
    Should Be Equal As Strings  ${Put_resp.status_code}     200

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
