*** Settings ***
Documentation     The main interface for interacting with CDS. It handles low level stuff like managing the http request library and CDS required fields
Library               RequestsLibrary
Library           ONAPLibrary.Utilities
Library           OperatingSystem
Library           Collections
Resource          global_properties.robot

*** Variables ***
${CDS_HEALTH_CHECK_PATH}    /api/v1/execution-service/health-check 
${CDS_HEALTH_ENDPOINT}     ${GLOBAL_CDS_SERVER_PROTOCOL}://${GLOBAL_INJECTED_CDS_BLUEPRINT_PROCESSOR_IP_ADDR}:${GLOBAL_CDS_HEALTH_SERVER_PORT}

*** Keywords ***
Run CDS Health Check
    [Documentation]    Runs a CDS health check
    ${auth}=  Create List  ${GLOBAL_CDS_USERNAME}    ${GLOBAL_CDS_PASSWORD}
    Log    Creating session ${CDS_HEALTH_ENDPOINT}
    ${session}=    Create Session       cds    ${CDS_HEALTH_ENDPOINT}    auth=${auth}
    ${uuid}=    Generate UUID4
    ${headers}=  Create Dictionary     X-ECOMP-Client-Version=ONAP-R2   action=getTable    Accept=application/json    Content-Type=application/json    X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}
    ${resp}=    Get Request     cds    ${CDS_HEALTH_CHECK_PATH}     headers=${headers}
    Log    Received response code from cds ${resp}
    Log    Received content from cds ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200

