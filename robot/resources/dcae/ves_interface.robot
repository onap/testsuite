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
    Wait Until Keyword Succeeds  10x  5s   Topic Validate    ${topic_name}   ${expected_text}

Activate DMAAP Topics
    [Documentation]   Currently first event routed to empty DMAAP topic is gone, so there is need to "activate" topics for testing pourposes
    Send Event to VES Collector    ${ves7_valid_json}
    Send Event to VES Collector    ${FaultSupervision_json}
    Send Event to VES Collector    ${Heartbeat_json}
    Send Event to VES Collector    ${PerformanceAssurance_json}
    Send Event to VES Collector    ${Provisioning_json}
    Sleep   30s
