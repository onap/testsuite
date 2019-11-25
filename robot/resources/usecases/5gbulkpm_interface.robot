*** Settings ***
Documentation	  The main interface for interacting with 5G Bulkpm.
Library 	      RequestsLibrary
Library           OperatingSystem
Library           String
Library           DateTime
Library           SSHLibrary
Library           Process
Library           ONAPLibrary.JSON
Library           ONAPLibrary.Utilities

*** Variables ***
${INVENTORY_SERVER}                                 ${GLOBAL_INVENTORY_SERVER_PROTOCOL}://${GLOBAL_INVENTORY_SERVER_NAME}:${GLOBAL_INVENTORY_SERVER_PORT}
${DEPLOYMENT_SERVER}                                ${GLOBAL_DEPLOYMENT_HANDLER_SERVER_PROTOCOL}://${GLOBAL_DEPLOYMENT_HANDLER_SERVER_NAME}:${GLOBAL_DEPLOYMENT_HANDLER_SERVER_PORT}
${DR_ENDPOINT}                                      ${GLOBAL_DMAAP_DR_PROV_SERVER_PROTOCOL}://${GLOBAL_INJECTED_DMAAP_DR_PROV_IP_ADDR}:${GLOBAL_DMAAP_DR_PROV_SERVER_PORT}
${MR_ENDPOINT}                                      ${GLOBAL_MR_SERVER_PROTOCOL}://${GLOBAL_DMAAP_MESSAGE_ROUTER_SERVER_NAME}:${GLOBAL_DMAAP_MESSAGE_ROUTER_SERVER_PORT}
${DMAAP_BC_ENDPOINT}                                ${GLOBAL_BC_SERVER_PROTOCOL}://${GLOBAL_INJECTED_BC_IP_ADDR}:${GLOBAL_BC_HTTP_SERVER_PORT}
${VES_HEALTH_CHECK_PATH}                            ${GLOBAL_DCAE_VES_PROTOCOL}://${GLOBAL_INJECTED_DCAE_VES_HOST}:${GLOBAL_DCAE_VES_SERVER_PORT}

*** Keywords ***
Run DR Get Request
    [Arguments]         ${data_path}
    ${session}=         Create Session          session         ${DR_ENDPOINT}
    ${resp}=            Get Request             session         ${data_path}
    [Return]            ${resp}

Publish Event To VES Collector
    [Arguments]         ${url}                  ${evtpath}      ${httpheaders}    ${evtdata}
    ${session}=         Create Session          ves             ${url}
    ${resp}=            Post Request            ves             ${evtpath}     data=${evtdata}   headers=${httpheaders}
    [return]            ${resp}

Post 5G Bulk PM Configuration
    [Arguments]         ${url}                  ${evtpath}      ${httpheaders}    ${evtdata}
    ${session}=         Create Session          dmaapbc         ${url}
    ${resp}=            Post Request            dmaapbc         ${evtpath}     data=${evtdata}   headers=${httpheaders}

Get Message Router Topic Data
    ${session}=         Create Session           mr             ${MR_ENDPOINT}
    ${headers}=         Create Dictionary        Authorization=Basic ZGNhZUBkY2FlLm9uYXAub3JnOmRlbW8xMjM0NTYh
    ${resp}=            Get Request              mr             ${MR_TOPIC_UR_PATH}     ${headers}
    [Return]            ${resp}

GetURL
    [Arguments]         ${url}
    ${resp}=            Evaluate                requests.get('${url}')    requests
    [Return]            ${resp.text}

GetCall
    [Arguments]         ${url}
    ${resp}=            Evaluate                requests.get('${url}', verify=False)    requests
    [Return]            ${resp}

Get Json Data From File
    [Arguments]         ${jsonfile}
    ${data}=            OperatingSystem.Get File    ${jsonfile}
    [return]            ${data}

PostCall
    [Arguments]         ${url}     ${evtpath}   ${headers}    ${evtdata}
    ${session}=         Create Session 	        ves 	${url}
    ${resp}=            Post Request 	        ves 	${evtpath}     data=${evtdata}   headers=${headers}
    [return]            ${resp}

PutCall
    [Arguments]         ${url}                  ${data}
    ${headers}=         Create Dictionary       Content-Type=application/json
    ${resp}=            Evaluate                requests.put('${url}', data=${data}, headers=${headers}, verify=False, allow_redirects=False)    requests
    [Return]            ${resp}

DeleteCall
    [Arguments]         ${url}
    ${resp}=            Evaluate                requests.delete('${url}', verify=False)    requests
    [Return]            ${resp}

Deployment Status
    [Arguments]                         ${server}                          ${endpoint}              ${deployment}      ${operationId}
    ${resp}=                            GetCall                            ${server}/${endpoint}/${deployment}/operation/${operationId}
    Log                                 ${resp.json()}
    ${status}                           Evaluate                           ${resp.json()}.get('status')
    Should Be Equal As Strings          ${status}                          succeeded

xNF PM File Validate
    [Arguments]                         ${value}
    ${resp}=                            Get Message Router Topic Data
    Should Contain                      ${resp.text}                        ${value}

