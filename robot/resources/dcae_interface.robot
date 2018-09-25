*** Settings ***
Documentation     The main interface for interacting with DCAE. It handles low level stuff like managing the http request library and DCAE required fields
Library 	      RequestsLibrary
Library	          UUID
Library           OperatingSystem
Library           Collections
Resource          global_properties.robot

*** Variables ***
${DCAE_HEALTH_CHECK_PATH}    /healthcheck
${VES_HV_HEALTH_CHECK_PATH}    /health/ready
${DCAE_HEALTH_ENDPOINT}     ${GLOBAL_DCAE_SERVER_PROTOCOL}://${GLOBAL_INJECTED_DCAE_IP_ADDR}:${GLOBAL_DCAE_HEALTH_SERVER_PORT}
${VES_HV_HEALTH_ENDPOINT}   ${GLOBAL_DCAE_SERVER_PROTOCOL}://${GLOBAL_DNS_VES_NAME}:${GLOBAL_HV_VES_HEALTH_SERVER_PORT}


*** Keywords ***
Run DCAE Health Check
    [Documentation]    Runs a DCAE health check
    ${auth}=  Create List  ${GLOBAL_DCAE_USERNAME}    ${GLOBAL_DCAE_PASSWORD}
    Log    Creating session ${DCAE_HEALTH_ENDPOINT}
    ${session}=    Create Session 	dcae 	${DCAE_HEALTH_ENDPOINT}    auth=${auth}
    ${uuid}=    Generate UUID
    ${headers}=  Create Dictionary     X-ECOMP-Client-Version=ONAP-R2   action=getTable    Accept=application/json    Content-Type=application/json    X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}
    ${resp}= 	Get Request 	dcae 	${DCAE_HEALTH_CHECK_PATH}     headers=${headers}
    Log    Received response code from dcae ${resp}
    Log    Received content from dcae ${resp.content}
    Should Be Equal As Strings 	${resp.status_code} 	200

Run VES-HV Health Check
    [Documentation]    Runs a VES-HV health check
    Log    Creating session ${VES_HV_HEALTH_ENDPOINT}
    ${session}=    Create Session 	hv-ves 	${VES_HV_HEALTH_ENDPOINT}
    ${uuid}=    Generate UUID
    ${resp}= 	Get Request 	hv-ves 	${VES_HV_HEALTH_CHECK_PATH}
    Log    Received response code from hv-ves ${resp}
    Log    Received content from hv-ves ${resp.content}
    Should Be Equal As Strings 	${resp.status_code} 	200
