*** Settings ***
Documentation	  The main interface for interacting with 5G Bulkpm.
Library 	      RequestsLibrary
Library           OperatingSystem
Library           String

*** Variables ***
${DEPLOYMENT_SERVER}                    ${GLOBAL_DEPLOYMENT_HANDLER_SERVER_PROTOCOL}://${GLOBAL_DEPLOYMENT_HANDLER_SERVER_NAME}:${GLOBAL_DEPLOYMENT_HANDLER_SERVER_PORT}
${DEPLOYMENT_ENDPOINT}                  dcae-deployments

*** Keywords ***
Deploy Service
    [Arguments]                         ${inputs}                   ${deployment_name}                      ${wait_time}=5 minute      ${check_deployment_status}=true
    Disable Warnings
    ${headers}=                         Create Dictionary           content-type=application/json
    ${deployment_data}=                 Set Variable                ${inputs}
    ${session}=                         Create Session              deployment_session                       ${DEPLOYMENT_SERVER}
    ${resp}=                            Put Request                 deployment_session                       /${DEPLOYMENT_ENDPOINT}/${deployment_name}         data=${deployment_data}     headers=${headers}
    ${operationLink}                    Set Variable                ${resp.json().get('links').get('status')}
    ${operationId}                      Fetch From Right            ${operationLink}                /
    Run Keyword If  "${check_deployment_status}"=="true"             Check Deployment Status   ${deployment_name}     ${operationId}   ${wait_time}
    Wait Until Keyword Succeeds         ${wait_time}                20 sec                                  Deployment Status       ${deployment_name}     ${operationId}
    [Return]                            ${operationId}

Check Deployment Status
    [Arguments]                         ${deployment_name}          ${operationId}                          ${wait_time}
    Wait Until Keyword Succeeds         ${wait_time}                20 sec                                  Deployment Status       ${deployment_name}     ${operationId}

Deployment Status
    [Arguments]         ${deployment_name}          ${operationId}
    Disable Warnings
    ${session}=         Create Session              deployment_session     ${DEPLOYMENT_SERVER}
    ${resp}=            Get Request                 deployment_session     /${DEPLOYMENT_ENDPOINT}/${deployment_name}/operation/${operationId}
    ${status}           Set Variable                ${resp.json().get('status')}
    Should Be Equal As Strings                      ${status}               succeeded
    [Return]            ${status}

Undeploy Service
    [Arguments]         ${deployment_name}
    Disable Warnings
    ${session}=         Create Session 	            deployment_session      ${DEPLOYMENT_SERVER}
    ${resp}=            Delete Request              deployment_session      /${DEPLOYMENT_ENDPOINT}/${deployment_name}
    [Return]            ${resp}
