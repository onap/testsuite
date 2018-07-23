*** Settings ***
Documentation     The main interface for interacting with MSO. It handles low level stuff like managing the http request library and MSO required fields
Library 	      RequestsLibrary
Library	          UUID
Library           OperatingSystem
Library           Collections
Resource          global_properties.robot
Resource          ../resources/json_templater.robot
*** Variables ***
${MSO_HEALTH_CHECK_PATH}    /ecomp/mso/infra/globalhealthcheck
${MSO_ENDPOINT}     ${GLOBAL_MSO_SERVER_PROTOCOL}://${GLOBAL_INJECTED_SO_IP_ADDR}:${GLOBAL_MSO_SERVER_PORT}

*** Keywords ***
Run MSO Health Check
    [Documentation]    Runs an MSO global health check
    ${auth}=  Create List  ${GLOBAL_MSO_USERNAME}    ${GLOBAL_MSO_PASSWORD}
    ${session}=    Create Session 	mso 	${MSO_ENDPOINT}
    ${uuid}=    Generate UUID
    ${headers}=  Create Dictionary     Accept=text/html    Content-Type=text/html    X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}
    ${resp}= 	Get Request 	mso 	${MSO_HEALTH_CHECK_PATH}     headers=${headers}
    Should Be Equal As Strings 	${resp.status_code} 	200

Run MSO Get ModelInvariantId
    [Documentation]    Runs an MSO Get ModelInvariantID for ClosedLoop Polieis 
    [Arguments]    ${service_model_name}    
    ${param_dict}=    Create Dictionary    serviceModelName    ${service_model_name}
    ${param}=   Evaluate   urllib.urlencode(${param_dict})    urllib
    ${data_path}=   Catenate   SEPARATOR=     /ecomp/mso/catalog/v2/serviceVnfs?  ${param}
    ${resp}=    Run MSO Get Request    ${data_path}
    Log    ${resp.json()}
    [Return]   ${resp.json()['serviceVnfs'][0]['modelInfo']['modelInvariantUuid']}
    
Run MSO Get Request
    [Documentation]    Runs an MSO get request
    [Arguments]    ${data_path}    ${accept}=application/json
    ${auth}=  Create List  ${GLOBAL_MSO_USERNAME}    ${GLOBAL_MSO_PASSWORD}
    Log    Creating session ${MSO_ENDPOINT}
    ${session}=    Create Session 	mso 	${MSO_ENDPOINT}    auth=${auth}
    ${uuid}=    Generate UUID
    ${headers}=  Create Dictionary     Accept=${accept}    Content-Type=application/json    X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}
    ${resp}= 	Get Request 	mso 	${data_path}     headers=${headers}
    Log    Received response from mso ${resp.text}
    [Return]    ${resp}

Poll MSO Get Request
    [Documentation]    Runs an MSO get request until a certain status is received. valid values are COMPLETE
    [Arguments]    ${data_path}     ${status}
    ${auth}=  Create List  ${GLOBAL_MSO_USERNAME}    ${GLOBAL_MSO_PASSWORD}
    Log    Creating session ${MSO_ENDPOINT}
    ${session}=    Create Session 	mso 	${MSO_ENDPOINT}    auth=${auth}
    ${uuid}=    Generate UUID
    ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json    X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}
    #do this until it is done
    :FOR    ${i}    IN RANGE    20
    \    ${resp}= 	Get Request 	mso 	${data_path}     headers=${headers}
    \    Should Not Contain    ${resp.text}    FAILED
    \    Log    ${resp.json()['request']['requestStatus']['requestState']}
    \    ${exit_loop}=    Evaluate    "${resp.json()['request']['requestStatus']['requestState']}" == "${status}"
    \    Exit For Loop If  ${exit_loop}
    \    Sleep    15s
    Log    Received response from mso ${resp.text}
    [Return]    ${resp}

Run MSO Post request
    [Documentation]    Runs an MSO post request
    [Arguments]  ${data_path}  ${data}
    ${auth}=  Create List  ${GLOBAL_MSO_USERNAME}    ${GLOBAL_MSO_PASSWORD}
    Log    Creating session ${MSO_ENDPOINT}
    ${session}=    Create Session 	mso 	${MSO_ENDPOINT}    auth=${auth}
    ${uuid}=    Generate UUID
    ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json    X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}
	${resp}= 	Post Request 	mso 	${data_path}     data=${data}   headers=${headers}
	Log    Received response from mso ${resp.text}
	[Return]  ${resp}

Run MSO Delete request
    [Documentation]    Runs an MSO Delete request
    [Arguments]  ${data_path}  ${data}
    ${auth}=    Create List    ${GLOBAL_MSO_USERNAME}    ${GLOBAL_MSO_PASSWORD}
    Log    Creating session ${MSO_ENDPOINT}
    ${session}=    Create Session    mso    ${MSO_ENDPOINT}    auth=${auth}
    ${uuid}=    Generate UUID
    ${headers}=    Create Dictionary    Accept=application/json    Content-Type=application/json    X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}
    ${resp}=    Delete Request    mso    ${data_path}    ${data}    headers=${headers}
    Log    Received response from mso ${resp.text}
    [Return]    ${resp}
