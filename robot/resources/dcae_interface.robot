*** Settings ***
Documentation     The main interface for interacting with DCAE. It handles low level stuff like managing the http request library and DCAE required fields
Library 	      RequestsLibrary
Library	          UUID
Library           OperatingSystem
Library           Collections
Resource          global_properties.robot

*** Variables ***
${DCAE_HEALTH_CHECK_PATH}    /healthcheck
${DCAE_ENDPOINT}     ${GLOBAL_DCAE_SERVER_PROTOCOL}://${GLOBAL_INJECTED_DCAE_IP_ADDR}:${GLOBAL_DCAE_SERVER_PORT}

*** Keywords ***
Run DCAE Health Check
    [Documentation]    Runs a DCAE health check
    ${auth}=  Create List  ${GLOBAL_DCAE_USERNAME}    ${GLOBAL_DCAE_PASSWORD}
    Log    Creating session ${DCAE_ENDPOINT}
    ${session}=    Create Session 	dcae 	${DCAE_ENDPOINT}    auth=${auth}
    ${uuid}=    Generate UUID
    ${headers}=  Create Dictionary     X-ECOMP-Client-Version=ONAP-R2   action=getTable    Accept=application/json    Content-Type=application/json    X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}
    ${resp}= 	Get Request 	dcae 	${DCAE_HEALTH_CHECK_PATH}     headers=${headers}
    Log    Received response from dcae ${resp.json()}
    Should Be Equal As Strings 	${resp.status_code} 	200
    Check DCAE Results    ${resp.json()}

Check DCAE Results
    [Documentation]    Parse DCAE JSON response and make sure all rows have healthTestStatus=GREEN (except for the exceptions ;-)
    [Arguments]    ${json}
    ${service_names}=   Get DCAE Healthcheck Service Names
    :for   ${service}   in   @{json}
    \    ${sn}=   Get From DIctionary    ${service}   ServiceName
    \    ${status}=   Get From Dictionary   ${service}   Status
    \    Run Keyword If   '${status}'=='passing'   Remove Values From List   ${service_names}   ${sn}   
    Should Be Empty    ${service_names}   Services failing healthcheck ${service_names}   
    
    
Get DCAE Healthcheck Service Names
    [Documentation]    From Lusheng's email servaices that must be passing for DCAE to be healthy. Mayne grab from a config file?
    ${service_names}=   Create List
    Append To List    ${service_names}   cdap
    Append To List    ${service_names}   cdap_broker
    Append To List    ${service_names}   config_binding_service
    Append To List    ${service_names}   deployment_handler
    Append To List    ${service_names}   inventory
    Append To List    ${service_names}   service_change_handler
    Append To List    ${service_names}   policy_handler
    Append To List    ${service_names}   platform_dockerhost
    Append To List    ${service_names}   component_dockerhost
    Append To List    ${service_names}   cloudify_manager
    Append To List    ${service_names}   VES
    Append To List    ${service_names}   TCA
    Append To List    ${service_names}   Holmes
    [Return]   ${service_names}

