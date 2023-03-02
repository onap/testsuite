*** Settings ***
Documentation     The main interface for interacting with VFC
Library           RequestsLibrary
Library            Collections

Resource          global_properties.robot

*** Variables ***
${VFC_GVNFMDRIVER_HEALTH_CHECK_PATH}        /api/gvnfmdriver/v1/health_check
${VFC_HUAWEIVNFMDRIVER_HEALTH_CHECK_PATH}        /api/huaweivnfmdriver/v1/swagger.json
${VFC_NSLCM_HEALTH_CHECK_PATH}        /api/nslcm/v1/health_check
${VFC_VNFLCM_HEALTH_CHECK_PATH}        /api/vnflcm/v1/health_check
${VFC_VNFMGR_HEALTH_CHECK_PATH}        /api/vnfmgr/v1/health_check
${VFC_VNFRES_HEALTH_CHECK_PATH}        /api/vnfres/v1/health_check
${VFC_ZTEVNFDRIVER_HEALTH_CHECK_PATH}        /api/ztevnfmdriver/v1/health_check

${VFC_GVNFMDRIVER_ENDPOINT}     ${GLOBAL_VFC_GVNFMDRIVER_SERVER_PROTOCOL}://${GLOBAL_INJECTED_VFC_GVNFMDRIVER_IP_ADDR}:${GLOBAL_VFC_GVNFMDRIVER_SERVER_PORT}
${VFC_HUAWEIVNFMDRIVER_ENDPOINT}     ${GLOBAL_VFC_HUAWEIVNFMDRIVER_SERVER_PROTOCOL}://${GLOBAL_INJECTED_VFC_HUAWEIVNFMDRIVER_IP_ADDR}:${GLOBAL_VFC_HUAWEIVNFMDRIVER_SERVER_PORT}
${VFC_NSLCM_ENDPOINT}     ${GLOBAL_VFC_NSLCM_SERVER_PROTOCOL}://${GLOBAL_INJECTED_VFC_NSLCM_IP_ADDR}:${GLOBAL_VFC_NSLCM_SERVER_PORT}
${VFC_VNFLCM_ENDPOINT}     ${GLOBAL_VFC_VNFLCM_SERVER_PROTOCOL}://${GLOBAL_INJECTED_VFC_VNFLCM_IP_ADDR}:${GLOBAL_VFC_VNFLCM_SERVER_PORT}
${VFC_VNFMGR_ENDPOINT}     ${GLOBAL_VFC_VNFMGR_SERVER_PROTOCOL}://${GLOBAL_INJECTED_VFC_VNFMGR_IP_ADDR}:${GLOBAL_VFC_VNFMGR_SERVER_PORT}
${VFC_VNFRES_ENDPOINT}     ${GLOBAL_VFC_VNFRES_SERVER_PROTOCOL}://${GLOBAL_INJECTED_VFC_VNFRES_IP_ADDR}:${GLOBAL_VFC_VNFRES_SERVER_PORT}
${VFC_ZTEVNFDRIVER_ENDPOINT}     ${GLOBAL_VFC_ZTEVNFDRIVER_SERVER_PROTOCOL}://${GLOBAL_INJECTED_VFC_ZTEVNFDRIVER_IP_ADDR}:${GLOBAL_VFC_ZTEVNFDRIVER_SERVER_PORT}

*** Keywords ***
Run VFC gvnfmdriver Health Check
     [Documentation]    Runs VFC gvnfmdriver Health check
     ${resp}=    Run VFC Get Request   ${VFC_GVNFMDRIVER_ENDPOINT}   ${VFC_GVNFMDRIVER_HEALTH_CHECK_PATH}
     Should Be Equal As Integers   ${resp.status_code}   200

Run VFC huaweivnfmdriver Health Check
     [Documentation]    Runs VFC huaweivnfmdriver Health check
     ${resp}=    Run VFC Get Request   ${VFC_HUAWEIVNFMDRIVER_ENDPOINT}   ${VFC_HUAWEIVNFMDRIVER_HEALTH_CHECK_PATH}
     Should Be Equal As Integers   ${resp.status_code}   200

Run VFC nslcm Health Check
     [Documentation]    Runs VFC nslcm Health check
     ${resp}=    Run VFC Get Request   ${VFC_NSLCM_ENDPOINT}   ${VFC_NSLCM_HEALTH_CHECK_PATH}
     Should Be Equal As Integers   ${resp.status_code}   200

Run VFC vnflcm Health Check
     [Documentation]    Runs VFC vnflcm Health check
     ${resp}=    Run VFC Get Request   ${VFC_VNFLCM_ENDPOINT}   ${VFC_VNFLCM_HEALTH_CHECK_PATH}
     Should Be Equal As Integers   ${resp.status_code}   200

Run VFC vnfmgr Health Check
     [Documentation]    Runs VFC vnfmgr Health check
     ${resp}=    Run VFC Get Request   ${VFC_VNFMGR_ENDPOINT}   ${VFC_VNFMGR_HEALTH_CHECK_PATH}
     Should Be Equal As Integers   ${resp.status_code}   200

Run VFC vnfres Health Check
     [Documentation]    Runs VFC vnfres Health check
     ${resp}=    Run VFC Get Request   ${VFC_VNFRES_ENDPOINT}   ${VFC_VNFRES_HEALTH_CHECK_PATH}
     Should Be Equal As Integers   ${resp.status_code}   200

Run VFC ztevnfmdriver Health Check
     [Documentation]    Runs VFC ztevnfmdriver Health check
     ${resp}=    Run VFC Get Request   ${VFC_ZTEVNFDRIVER_ENDPOINT}   ${VFC_ZTEVNFDRIVER_HEALTH_CHECK_PATH}
     Should Be Equal As Integers   ${resp.status_code}   200

Run VFC Get Request
     [Documentation]    Runs VFC Get request
     [Arguments]    ${endpoint}   ${data_path}
     ${session}=    Create Session   session   ${endpoint}
     ${resp}=   Get Request   session   ${data_path}
     Should Be Equal As Integers   ${resp.status_code}   200
     Log    Received response from MultiCloud ${resp.text}
     [Return]    ${resp}
