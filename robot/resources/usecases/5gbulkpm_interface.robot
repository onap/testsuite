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
${DMAAP_BC_ENDPOINT}                                ${GLOBAL_BC_SERVER_PROTOCOL}://${GLOBAL_INJECTED_BC_IP_ADDR}:${GLOBAL_BC_HTTPS_SERVER_PORT}
${VES_HEALTH_CHECK_PATH}                            ${GLOBAL_DCAE_VES_PROTOCOL}://${GLOBAL_INJECTED_DCAE_VES_HOST}:${GLOBAL_DCAE_VES_SERVER_PORT}
${CIENT_USERNAME}                                   dcae@dcae.onap.org
${CLIENT_PASSWORD}                                  demo123456!

*** Keywords ***
Publish Event To VES Collector
    [Arguments]         ${url}                  ${evtpath}              ${httpheaders}      ${evtdata}
    ${session}=         Create Session          ves                     ${url}
    ${resp}=            Post Request            ves                     ${evtpath}          data=${evtdata}   headers=${httpheaders}
    [return]            ${resp}

Post 5G Bulk PM Configuration
    [Arguments]         ${url}                  ${evtpath}              ${httpheaders}      ${evtdata}
    ${session}=         Create Session          dmaapbc                 ${url}
    ${resp}=            Post Request            dmaapbc                 ${evtpath}          data=${evtdata}   headers=${httpheaders}

Get Message Router Topic Data
    ${auth}=            Create List              ${CIENT_USERNAME}      ${CLIENT_PASSWORD}
    ${session}=         Create Session           mr                     ${MR_ENDPOINT}       auth=${auth}
    ${resp}=            Get Request              mr                     ${MR_TOPIC_UR_PATH}
    [Return]            ${resp}

GetCall
    [Arguments]         ${url}                   ${path}
    ${session}=         Create Session           request                ${url}
    ${resp}=            Get Request              request                ${path}
    [Return]            ${resp}

PostCall
    [Arguments]         ${url}                  ${evtpath}              ${headers}          ${evtdata}
    ${session}=         Create Session          request                 ${url}
    ${resp}=            Post Request            request                 ${evtpath}          data=${evtdata}   headers=${headers}
    [return]            ${resp}

PutCall
    [Arguments]         ${server}               ${endpoint}             ${data}
    ${session}=         Create Session 	        request                 ${server}
    ${headers}=         Create Dictionary       Content-Type=application/json
    ${resp}=            Put Request             request                 ${endpoint}         data=${data}     headers=${headers}
    [Return]            ${resp}

Undeploy
    [Arguments]         ${server}               ${endpoint}
    ${session}=         Create Session 	        request                 ${server}
    ${resp}=            Delete Request          request                 ${endpoint}
    [Return]            ${resp}

Deployment Status
    [Arguments]                         ${server}                       ${endpoint}              ${deployment}      ${operationId}
    ${resp}=                            GetCall                         ${server}                /${endpoint}/${deployment}/operation/${operationId}
    Log                                 ${resp.json()}
    ${status}                           Evaluate                        ${resp.json()}.get('status')
    Should Be Equal As Strings          ${status}                       succeeded

xNF PM File Validate
    [Arguments]                         ${value}
    ${resp}=                            Get Message Router Topic Data
    Should Contain                      ${resp.text}                    ${value}

