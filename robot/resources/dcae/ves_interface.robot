Documentation	  The main interface for interacting with VES Collector
Library 	      RequestsLibrary
Library           OperatingSystem
Library           String

*** Variables ***
${INVENTORY_SERVER}                                 ${GLOBAL_INVENTORY_SERVER_PROTOCOL}://${GLOBAL_INVENTORY_SERVER_NAME}:${GLOBAL_INVENTORY_SERVER_PORT}
${DEPLOYMENT_SERVER}                                ${GLOBAL_DEPLOYMENT_HANDLER_SERVER_PROTOCOL}://${GLOBAL_DEPLOYMENT_HANDLER_SERVER_NAME}:${GLOBAL_DEPLOYMENT_HANDLER_SERVER_PORT}
${DR_ENDPOINT}                                      ${GLOBAL_DMAAP_DR_PROV_SERVER_PROTOCOL}://${GLOBAL_INJECTED_DMAAP_DR_PROV_IP_ADDR}:${GLOBAL_DMAAP_DR_PROV_SERVER_PORT}
${DMAAP_BC_SERVER}                                  ${GLOBAL_BC_SERVER_PROTOCOL}://${GLOBAL_INJECTED_BC_IP_ADDR}:${GLOBAL_BC_HTTPS_SERVER_PORT}
${VES_HEALTH_CHECK_PATH}                            ${GLOBAL_DCAE_VES_HTTPS_PROTOCOL}://${GLOBAL_INJECTED_DCAE_VES_HOST}:${GLOBAL_DCAE_VES_HTTPS_SERVER_PORT}
${MR_PUBLISH_TEMPLATE}                              mr/mr_publish.jinja
${ves7_valid_json}                                  ${EXECDIR}/robot/assets/dcae/ves7_valid.json
${FaultSupervision_json}                            ${EXECDIR}/robot/assets/dcae/ves_stdnDefined_3GPP-FaultSupervision.json
${Heartbeat_json}                                   ${EXECDIR}/robot/assets/dcae/ves_stdnDefined_3GPP-Heartbeat.json
${PerformanceAssurance_json}                        ${EXECDIR}/robot/assets/dcae/ves_stdnDefined_3GPP-PerformanceAssurance.json
${Provisioning_json}                                ${EXECDIR}/robot/assets/dcae/ves_stdnDefined_3GPP-Provisioning.json
${MR_TOPIC_CHECK_PATH}                              /topics
${DR_SUB_CHECK_PATH}                                /internal/prov
${MR_TOPIC_URL_PATH}                                /events/unauthenticated.SEC_FAULT_OUTPUT/CG1/C1
${MR_FAULTSUPERVISION_TOPIC_URL_PATH}               /events/unauthenticated.SEC_3GPP_FAULTSUPERVISION_OUTPUT/CG1/C1
${MR_HEARTBEAT_TOPIC_URL_PATH}                      /events/unauthenticated.SEC_3GPP_HEARTBEAT_OUTPUT/CG1/C1
${MR_PERFORMANCEASSURANCE_TOPIC_URL_PATH}           /events/unauthenticated.SEC_3GPP_PERFORMANCEASSURANCE_OUTPUT/CG1/C1
${MR_PROVISIONING_TOPIC_URL_PATH}                   /events/unauthenticated.SEC_3GPP_PROVISIONING_OUTPUT/CG1/C1
${DMAAP_BC_MR_CLIENT_PATH}                          /webapi/mr_clients
${DMAAP_BC_MR_CLUSTER_PATH}                         /webapi/mr_clusters
${VES_LISTENER_PATH}                                /eventListener/v7

*** Keywords ***


Send Event to VES Collector
    [Documentation]  keyword wich is used to send events through VES Collector Event Listener path
    [Arguments]                         ${event}
    ${headers}=                         Create Dictionary                   content-type=application/json
    ${event_from_file}=                 OperatingSystem.Get File            ${event}
    ${auth}=                            Create List                         ${GLOBAL_DCAE_VES_USERNAME}     ${GLOBAL_DCAE_VES_PASSWORD}
    ${session}=                         Create Session                      ves                             ${VES_HEALTH_CHECK_PATH}      auth=${auth}
    ${resp}=                            Post Request                        ves                             ${VES_LISTENER_PATH}          data=${event_from_file}   headers=${headers}
    Should Be Equal As Strings          ${resp.status_code}                 202

Topic Validate
    [Documentation]   Keyword checks content of DMAAP topic and evaluate it's content with desired value
    [Arguments]                         ${topic_name}   ${expected_text}
    ${timestamp}=                       Get Current Date
    ${dict}=                            Create Dictionary                           timestamp=${timestamp}
    Templating.Create Environment       mr                                          ${GLOBAL_TEMPLATE_FOLDER}
    ${data}=                            Templating.Apply Template                   mr                                  ${MR_PUBLISH_TEMPLATE}              ${dict}
    ${resp}=                            Run MR Auth Get Request                     ${topic_name}                ${GLOBAL_DCAE_USERNAME}             ${GLOBAL_DCAE_PASSWORD}
    Should Contain                      ${resp.text}                                ${expected_text}

Send Event to VES & Validate Topic
    [Documentation]   Keyword is a test template which alows to send event through VES Collector and check if ivent is routed to proper DMAAP topic
    [Arguments]                         ${event}   ${topic_name}   ${expected_text}
    Send Event to VES Collector         ${event}
    Wait Until Keyword Succeeds  10x  1s   Topic Validate    ${topic_name}   ${expected_text}

Activate DMAAP Topics
    [Documentation]   Currently first event routed to empty DMAAP topic is gone, so there is need to "activate" topics for testing pourposes
    Wait Until Keyword Succeeds  10x  5s   Send Event to VES & Validate Topic      ${ves7_valid_json}   ${MR_TOPIC_URL_PATH}   Fault_Vscf:Acs-Ericcson_PilotNumberPoolExhaustion
    Wait Until Keyword Succeeds  10x  5s   Send Event to VES & Validate Topic      ${FaultSupervision_json}   ${MR_FAULTSUPERVISION_TOPIC_URL_PATH}   ves_stdnDefined_3GPP-FaultSupervision
    Wait Until Keyword Succeeds  10x  5s   Send Event to VES & Validate Topic      ${Heartbeat_json}   ${MR_HEARTBEAT_TOPIC_URL_PATH}   ves_stdnDefined_3GPP-Heartbeat
    Wait Until Keyword Succeeds  10x  5s   Send Event to VES & Validate Topic      ${PerformanceAssurance_json}   ${MR_PERFORMANCEASSURANCE_TOPIC_URL_PATH}   ves_stdnDefined_3GPP-PerformanceAssurance
    Wait Until Keyword Succeeds  10x  5s   Send Event to VES & Validate Topic      ${Provisioning_json}   ${MR_PROVISIONING_TOPIC_URL_PATH}   ves_stdnDefined_3GPP-Provisioning
    Sleep   10s
