*** Settings ***
Documentation     The main interface for interacting with MultiCloud
Library           RequestsLibrary
Library            Collections

Resource          global_properties.robot

*** Variables ***
${MC_HEALTH_CHECK_PATH}        /api/multicloud/v0/swagger.json
${MC_PIKE_HEALTH_CHECK_PATH}   /api/multicloud-pike/v0/swagger.json
${MC_PROMETHEUS_HEALTH_CHECK_PATH}   /api/multicloud-pike/v0/swagger.json
${MC_STARLINGX_HEALTH_CHECK_PATH}   /api/multicloud-starlingx/v0/swagger.json
${MC_TC_HEALTH_CHECK_PATH}   /api/multicloud-titaniumcloud/v1/swagger.json
${MC_VIO_HEALTH_CHECK_PATH}   /api/multicloud-vio/v0/swagger.json
${MC_K8S_HEALTH_CHECK_PATH}   /v1/healthcheck
${MC_FCAPS_HEALTH_CHECK_PATH}   /api/multicloud-fcaps/v1/healthcheck

${MC_ENDPOINT}     ${GLOBAL_MC_SERVER_PROTOCOL}://${GLOBAL_INJECTED_MC_IP_ADDR}:${GLOBAL_MC_SERVER_PORT}
${MC_PIKE_ENDPOINT}     ${GLOBAL_MC_PIKE_SERVER_PROTOCOL}://${GLOBAL_INJECTED_MC_PIKE_IP_ADDR}:${GLOBAL_MC_PIKE_SERVER_PORT}
${MC_PROMETHEUS_ENDPOINT}     ${GLOBAL_MC_PROMETHEUS_SERVER_PROTOCOL}://${GLOBAL_INJECTED_MC_PROMETHEUS_IP_ADDR}:${GLOBAL_MC_PROMETHEUS_SERVER_PORT}
${MC_STARLINGX_ENDPOINT}     ${GLOBAL_MC_STARLINGX_SERVER_PROTOCOL}://${GLOBAL_INJECTED_MC_STARLINGX_IP_ADDR}:${GLOBAL_MC_STARLINGX_SERVER_PORT}
${MC_TC_ENDPOINT}     ${GLOBAL_MC_TC_SERVER_PROTOCOL}://${GLOBAL_INJECTED_MC_TC_IP_ADDR}:${GLOBAL_MC_TC_SERVER_PORT}
${MC_VIO_ENDPOINT}     ${GLOBAL_MC_VIO_SERVER_PROTOCOL}://${GLOBAL_INJECTED_MC_VIO_IP_ADDR}:${GLOBAL_MC_VIO_SERVER_PORT}
${MC_K8S_ENDPOINT}     ${GLOBAL_MC_K8S_SERVER_PROTOCOL}://${GLOBAL_INJECTED_MC_K8S_IP_ADDR}:${GLOBAL_MC_K8S_SERVER_PORT}
${MC_FCAPS_ENDPOINT}     ${GLOBAL_MC_FCAPS_SERVER_PROTOCOL}://${GLOBAL_INJECTED_MC_FCAPS_IP_ADDR}:${GLOBAL_MC_FCAPS_SERVER_PORT}

*** Keywords ***
Run MultiCloud Health Check
     [Documentation]    Runs MultiCloud Health check
     ${resp}=    Run MultiCloud Get Request  ${MC_ENDPOINT}  ${MC_HEALTH_CHECK_PATH}
     Should Be Equal As Integers   ${resp.status_code}   200

Run MultiCloud-pike Health Check
     [Documentation]    Runs MultiCloud-pike Health check
     ${resp}=    Run MultiCloud Get Request  ${MC_PIKE_ENDPOINT}  ${MC_PIKE_HEALTH_CHECK_PATH}
     Should Be Equal As Integers   ${resp.status_code}   200

Run MultiCloud-starlingx Health Check
     [Documentation]    Runs MultiCloud-starlingx Health check
     ${resp}=    Run MultiCloud Get Request  ${MC_STARLINGX_ENDPOINT}  ${MC_STARLINGX_HEALTH_CHECK_PATH}
     Should Be Equal As Integers   ${resp.status_code}   200

Run MultiCloud-titanium_cloud Health Check
     [Documentation]    Runs MultiCloud-titanium_cloud Health check
     ${resp}=    Run MultiCloud Get Request  ${MC_TC_ENDPOINT}  ${MC_TC_HEALTH_CHECK_PATH}
     Should Be Equal As Integers   ${resp.status_code}   200

Run MultiCloud-vio Health Check
     [Documentation]    Runs MultiCloud-vio Health check
     ${resp}=    Run MultiCloud Get Request  ${MC_VIO_ENDPOINT}  ${MC_VIO_HEALTH_CHECK_PATH}
     Should Be Equal As Integers   ${resp.status_code}   200

Run MultiCloud-k8s Health Check
     [Documentation]    Runs MultiCloud-k8s Health check
     ${resp}=    Run MultiCloud Get Request  ${MC_K8S_ENDPOINT}  ${MC_K8S_HEALTH_CHECK_PATH}
     Should Be Equal As Integers   ${resp.status_code}   200

Run MultiCloud-prometheus Health Check
     [Documentation]    Runs MultiCloud-prometheus Health check
     ${resp}=    Run MultiCloud Get Request  ${MC_PROMETHEUS_ENDPOINT}   ${MC_PROMETHEUS_HEALTH_CHECK_PATH}
     Should Be Equal As Integers   ${resp.status_code}   200

Run MultiCloud-fcaps Health Check
     [Documentation]    Runs MultiCloud-fcaps Health check
     ${resp}=    Run MultiCloud Get Request   ${MC_FCAPS_ENDPOINT}   ${MC_FCAPS_HEALTH_CHECK_PATH}
     Should Be Equal As Integers   ${resp.status_code}   200

Run MultiCloud Get Request
     [Documentation]    Runs MultiCloud Get request
     [Arguments]    ${endpoint}   ${data_path}
     ${session}=    Create Session   session   ${endpoint}
     ${resp}=   Get Request   session   ${data_path}
     Should Be Equal As Integers   ${resp.status_code}   200
     Log    Received response from MultiCloud ${resp.text}
     [Return]    ${resp}
