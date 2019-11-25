*** Settings ***
Documentation	  The main interface for interacting with 5G Bulkpm.
Library 	      RequestsLibrary
Library           OperatingSystem
Library           String

*** Variables ***
${INVENTORY_SERVER}                                 ${GLOBAL_INVENTORY_SERVER_PROTOCOL}://${GLOBAL_INVENTORY_SERVER_NAME}:${GLOBAL_INVENTORY_SERVER_PORT}
${DEPLOYMENT_SERVER}                                ${GLOBAL_DEPLOYMENT_HANDLER_SERVER_PROTOCOL}://${GLOBAL_DEPLOYMENT_HANDLER_SERVER_NAME}:${GLOBAL_DEPLOYMENT_HANDLER_SERVER_PORT}
${DR_ENDPOINT}                                      ${GLOBAL_DMAAP_DR_PROV_SERVER_PROTOCOL}://${GLOBAL_INJECTED_DMAAP_DR_PROV_IP_ADDR}:${GLOBAL_DMAAP_DR_PROV_SERVER_PORT}
${MR_ENDPOINT}                                      ${GLOBAL_MR_SERVER_PROTOCOL}://${GLOBAL_DMAAP_MESSAGE_ROUTER_SERVER_NAME}:${GLOBAL_DMAAP_MESSAGE_ROUTER_SERVER_PORT}
${DMAAP_BC_SERVER}                                  ${GLOBAL_BC_SERVER_PROTOCOL}://${GLOBAL_INJECTED_BC_IP_ADDR}:${GLOBAL_BC_HTTPS_SERVER_PORT}
${VES_HEALTH_CHECK_PATH}                            ${GLOBAL_DCAE_VES_PROTOCOL}://${GLOBAL_INJECTED_DCAE_VES_HOST}:${GLOBAL_DCAE_VES_SERVER_PORT}

*** Keywords ***
Undeploy Service
    [Arguments]         ${server}                   ${endpoint}
    ${session}=         Create Session 	            deployment                 ${server}
    ${resp}=            Delete Request              deployment                 ${endpoint}
    [Return]            ${resp}

Deployment Status
    [Arguments]         ${server}                   ${endpoint}            ${deployment}      ${operationId}
    ${session}=         Create Session              deployment-status      ${server}
    ${resp}=            Get Request                 deployment-status      /${endpoint}/${deployment}/operation/${operationId}
    ${status}           Set Variable                ${resp.json().get('status')}
    Should Be Equal As Strings                      ${status}               succeeded

xNF PM File Validate
    [Arguments]         ${value}
    ${resp}=            Run MR Auth Get Request     ${MR_TOPIC_URL_PATH}     ${GLOBAL_DCAE_USERNAME}      ${GLOBAL_DCAE_PASSWORD}
    Should Contain      ${resp.text}                ${value}

Usecase Teardown
    Undeploy Service                    ${DEPLOYMENT_SERVER}                 /${DEPLOYMENT_ENDPOINT}/pmmapper
    Undeploy Service                    ${INVENTORY_SERVER}                  ${INVENTORY_ENDPOINT}/${serviceTypeId-Pmmapper}
    Undeploy Service                    ${DEPLOYMENT_SERVER}                 /${DEPLOYMENT_ENDPOINT}/sftpserver
    Undeploy Service                    ${INVENTORY_SERVER}                  ${INVENTORY_ENDPOINT}/${serviceTypeId-Sftp}
    Undeploy Service                    ${DEPLOYMENT_SERVER}                  /${DEPLOYMENT_ENDPOINT}/datafile
    Undeploy Service                    ${INVENTORY_SERVER}                   ${INVENTORY_ENDPOINT}/${serviceTypeId-Dfc}