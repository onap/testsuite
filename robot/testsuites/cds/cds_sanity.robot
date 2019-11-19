*** Settings ***
Documentation     The main interface for interacting with CDS
Library           RequestsLibrary
Library           requests
Force Tags        cds
Resource          ../resources/cds/cds_interface.robot

*** Variables ***

${VLB_CBA}                          robot/assets/cds/vFW.zip
${VFW_CBA}                          robot/assets/cds/vLB.zip
${CONTROLLER_BLUEPRINT_ENDPOINT}    ${GLOBAL_CCSDK_CDS_SERVER_PROTOCOL}://${GLOBAL_INJECTED_CCSDK_CDS_BLUEPRINT_PROCESSOR_IP_ADDR}:${GLOBAL_CCSDK_CDS_HEALTH_SERVER_PORT}
${VERSIONED_INDEX_PATH}             /api/v1/
${PATH_CBA}                         robot/assets/cds
*** Test Cases ***

Run CDS enrich API for vLB
    [Documentation]    Runs a check on CDS enrich API
    ${file}=    Evaluate    {'file': open('${VLB_CBA}', 'r')}
    ${resp}=    CDS Post Request with files   url=${CONTROLLER_BLUEPRINT_ENDPOINT}${VERSIONED_INDEX_PATH}blueprint-model/enrich    files=${file}
    Should Be Equal As Strings  ${resp.status_code}    200

Run CDS enrich API for vFW
    [Documentation]    Runs a check on CDS enrich API
    ${file}=    Evaluate    {'file': open('${VFW_CBA}', 'r')}
    ${resp}=    CDS Post Request with files   url=${CONTROLLER_BLUEPRINT_ENDPOINT}${VERSIONED_INDEX_PATH}blueprint-model/enrich    files=${file}
    Should Be Equal As Strings  ${resp.status_code}    200

