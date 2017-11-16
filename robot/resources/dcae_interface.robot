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
    # ${service_names} to contain only the names of services that are passing
    ${service_names}=    Evaluate    map( lambda s: s['ServiceName'], filter(lambda s: s['Status'] == 'passing', ${json} ))
    Should Contain Match    ${service_names}   cdap
    Should Contain Match    ${service_names}   cdap_broker
    Should Contain Match    ${service_names}   config_binding_service
    Should Contain Match    ${service_names}   deployment_handler
    Should Contain Match    ${service_names}   inventory
    Should Contain Match    ${service_names}   service-change-handler
    # Should Contain Match    ${service_names}   policy_handler
    Should Contain Match    ${service_names}   platform_dockerhost
    Should Contain Match    ${service_names}   component_dockerhost
    Should Contain Match    ${service_names}   cloudify_manager
    Should Contain Match    ${service_names}   regexp=.*dcaegen2-collectors-ves
    Should Contain Match    ${service_names}   regexp=.*cdap_app_cdap_app_tca
    Should Contain Match    ${service_names}   regexp=.*dcae-analytics-holmes-rule-management
    Should Contain Match    ${service_names}   regexp=.*dcae-analytics-holmes-engine-management
    [Return]   ${service_names}

