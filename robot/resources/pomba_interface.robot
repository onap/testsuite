*** Settings ***
Documentation     Tests the health of the POMBA containers: aai-context-builder, sdc-context-builder,
Documentation     network-discovery-micro-service, Context-Aggregator, pomba-kibana, pomba-elasticsearch,
Documentation     service-decomposition, sdnc-context-builder and network-discovery-context-builder.
Library    Collections
Library         String
Library 	      RequestsLibrary
Resource        global_properties.robot

*** Variables ***
${POMBA_PATH}         /
${POMBA_AAICB_PATH}   /aaicontextbuilder/health
${POMBA_SDCCB_PATH}   /sdccontextbuilder/health
${POMBA_NDCB_PATH}    /ndcontextbuilder/health
${POMBA_NDMS_PATH}   /health
${POMBA_VALIDATIONSERVICE_PATH}   /health
${POMBA_KIBANA_PATH}   /
${POMBA_ELASTICSEARCH_PATH}   /

${POMBA_SERVICEDECOMPOSITION_PATH}   /service-decomposition/health
${POMBA_AAICONTEXTBUILDER_ENDPOINT}    ${GLOBAL_POMBA_SERVER_PROTOCOL_HTTP}://${GLOBAL_INJECTED_POMBA_AAI_CONTEXT_BUILDER_IP_ADDR}:${GLOBAL_POMBA_AAICONTEXTBUILDER_PORT}
${POMBA_SDCCONTEXTBUILDER_ENDPOINT}    ${GLOBAL_POMBA_SERVER_PROTOCOL_HTTP}://${GLOBAL_INJECTED_POMBA_SDC_CONTEXT_BUILDER_IP_ADDR}:${GLOBAL_POMBA_SDCCONTEXTBUILDER_PORT}
${POMBA_NETWORKDISCCONTEXTBUILDER_ENDPOINT}    ${GLOBAL_POMBA_SERVER_PROTOCOL_HTTP}://${GLOBAL_INJECTED_POMBA_NETWORK_DISC_CONTEXTBUILDER_IP_ADDR}:${GLOBAL_POMBA_NETWORKDISCCONTEXTBUILDER_PORT}
${POMBA_SERVICEDECOMPOSITION_ENDPOINT}    ${GLOBAL_POMBA_SERVER_PROTOCOL_HTTP}://${GLOBAL_INJECTED_POMBA_SERVICE_DECOMPOSITION_IP_ADDR}:${GLOBAL_POMBA_SERVICEDECOMPOSITION_PORT}
${POMBA_NETWORKDISCOVERY_MICROSERVICE_ENDPOINT}    ${GLOBAL_POMBA_SERVER_PROTOCOL_HTTPS}://${GLOBAL_INJECTED_POMBA_NETWORKDISCOVERY_MICROSERVICE_IP_ADDR}:${GLOBAL_POMBA_NETWORKDISCOVERY_MICROSERVICE_PORT}
${POMBA_VALIDATIONSERVICE_ENDPOINT}    ${GLOBAL_POMBA_SERVER_PROTOCOL_HTTP}://${GLOBAL_INJECTED_POMBA_VALIDATION_SERVICE_IP_ADDR}:${GLOBAL_POMBA_VALIDATIONSERVICE_PORT}
${POMBA_KIBANA_ENDPOINT}    ${GLOBAL_POMBA_SERVER_PROTOCOL_HTTP}://${GLOBAL_INJECTED_POMBA_KIBANA_IP_ADDR}:${GLOBAL_POMBA_KIBANA_PORT}
${POMBA_ELASTICSEARCH_ENDPOINT}    ${GLOBAL_POMBA_SERVER_PROTOCOL_HTTP}://${GLOBAL_INJECTED_POMBA_ELASTIC_SEARCH_IP_ADDR}:${GLOBAL_POMBA_ELASTICSEARCH_PORT}

*** Keywords ***
Run Pomba Aai Context Builder Health Check
    [Documentation]   Tests Pomba Aai Context Builder interface
    ${resp}=    Run Pomba Aai Context Builder Get Request    ${POMBA_AAICB_PATH}
    Should Be Equal As Strings 	${resp.status_code} 	200

Run Pomba Aai Context Builder Get Request
    [Documentation]    Runs a Pomba Aai Context Builder request
    [Arguments]    ${data_path}
    Log    Creating session ${POMBA_AAICONTEXTBUILDER_ENDPOINT}
    ${session}=    Create Session 	pomba-aaictxbuilder 	${POMBA_AAICONTEXTBUILDER_ENDPOINT}
    ${resp}= 	Get Request 	pomba-aaictxbuilder 	${data_path}
    Log    Received response from pomba-aaictxbuilder ${resp.text}
    [Return]    ${resp}

Run Pomba Sdc Context Builder Health Check
    [Documentation]   Tests Sdc Context Builder interface
    ${resp}=    Run Pomba Sdc Context Builder Get Request    ${POMBA_SDCCB_PATH}
    Should Be Equal As Strings 	${resp.status_code} 	200

Run Pomba Sdc Context Builder Get Request
    [Documentation]    Runs a Pomba Sdc Context Builder request
    [Arguments]    ${data_path}
    Log    Creating session ${POMBA_SDCCONTEXTBUILDER_ENDPOINT}
    ${session}=    Create Session 	pomba-sdcctxbuilder 	${POMBA_SDCCONTEXTBUILDER_ENDPOINT}
    ${resp}= 	Get Request 	pomba-sdcctxbuilder 	${data_path}
    Log    Received response from pomba-sdcctxbuilder ${resp.text}
    [Return]    ${resp}

Run Pomba Network Discovery Context Builder Health Check
    [Documentation]   Tests a Pomba Network Discovery Context Builder interface
    ${resp}=    Run Pomba Network Discovery Context Builder Get Request    ${POMBA_NDCB_PATH}
    Should Be Equal As Strings 	${resp.status_code} 	200

Run Pomba Network Discovery Context Builder Get Request
    [Documentation]    Runs a Pomba Network Discovery Context Builder request
    [Arguments]    ${data_path}
    Log    Creating session ${POMBA_NETWORKDISCCONTEXTBUILDER_ENDPOINT}
    ${session}=    Create Session 	pomba-networkdiscovery 	${POMBA_NETWORKDISCCONTEXTBUILDER_ENDPOINT}
    ${resp}= 	Get Request 	pomba-networkdiscovery 	${data_path}
    Log    Received response from pomba-networkdiscovery ${resp.text}
    [Return]    ${resp}

Run Pomba Service Decomposition Health Check
    [Documentation]   Tests Pomba Service Decomposition interface
    ${resp}=    Run Pomba Service Decomposition Get Request    ${POMBA_SERVICEDECOMPOSITION_PATH}
    Should Be Equal As Strings 	${resp.status_code} 	200

Run Pomba Service Decomposition Get Request
    [Documentation]    Runs a Pomba Service Decomposition request
    [Arguments]    ${data_path}
    Log    Creating session ${POMBA_SERVICEDECOMPOSITION_ENDPOINT}
    ${session}=    Create Session 	pomba-servicedecomposition 	${POMBA_SERVICEDECOMPOSITION_ENDPOINT}
    ${resp}= 	Get Request 	pomba-servicedecomposition 	${data_path}
    Log    Received response from pomba-servicedecomposition ${resp.text}
    [Return]    ${resp}

Run Pomba Network Discovery MicroService Health Check
    [Documentation]   Tests Pomba Network Discovery MicroService interface
    ${resp}=    Run Pomba Network Discovery MicroService Get Request    ${POMBA_NDMS_PATH}
    Should Be Equal As Strings 	${resp.status_code} 	200

Run Pomba Network Discovery MicroService Get Request
    [Documentation]    Runs a Pomba Network Discovery MicroService request
    [Arguments]    ${data_path}
    Log    Creating session ${POMBA_NETWORKDISCOVERY_MICROSERVICE_ENDPOINT}
    ${session}=    Create Session 	pomba-networkdiscovery 	${POMBA_NETWORKDISCOVERY_MICROSERVICE_ENDPOINT}
    ${resp}= 	Get Request 	pomba-networkdiscovery 	${data_path}
    Log    Received response from pomba-networkdiscovery ${resp.text}
    [Return]    ${resp}

Run Pomba Validation Service Health Check
    [Documentation]   Tests Pomba Validation Service interface
    ${resp}=    Run Pomba Validation Service Get Request    ${POMBA_VALIDATIONSERVICE_PATH}
    Should Be Equal As Strings 	${resp.status_code} 	200

Run Pomba Validation Service Get Request
    [Documentation]    Runs a Pomba Validation Service request
    [Arguments]    ${data_path}
    Log    Creating session ${POMBA_VALIDATIONSERVICE_ENDPOINT}
    ${session}=    Create Session 	pomba-validation-service 	${POMBA_VALIDATIONSERVICE_ENDPOINT}
    ${resp}= 	Get Request 	pomba-validation-service 	${data_path}
    Log    Received response from pomba-validation-service ${resp.text}
    [Return]    ${resp}

Run Pomba Kibana Health Check
    [Documentation]   Tests Pomba Kibana interface
    ${resp}=    Run Pomba Kibana Get Request    ${POMBA_KIBANA_PATH}
    Should Be Equal As Strings 	${resp.status_code} 	200

Run Pomba Kibana Get Request
    [Documentation]    Runs a Pomba Kibana request
    [Arguments]    ${data_path}
    Log    Creating session ${POMBA_KIBANA_ENDPOINT}
    ${session}=    Create Session 	pomba-kibana 	${POMBA_KIBANA_ENDPOINT}
    ${resp}= 	Get Request 	pomba-kibana 	${data_path}
    Log    Received response from pomba-kibana ${resp.text}
    [Return]    ${resp}

Run Pomba Elastic Search Health Check
    [Documentation]   Tests Pomba Elastic Search interface
    ${resp}=    Run Pomba Elastic Search Get Request    ${POMBA_ELASTICSEARCH_PATH}
    Should Be Equal As Strings 	${resp.status_code} 	200

Run Pomba Elastic Search Get Request
    [Documentation]    Runs a Pomba Elastic Search request
    [Arguments]    ${data_path}
    Log    Creating session ${POMBA_ELASTICSEARCH_ENDPOINT}
    ${session}=    Create Session 	pomba-es 	${POMBA_ELASTICSEARCH_ENDPOINT}
    ${resp}= 	Get Request 	pomba-es 	${data_path}
    Log    Received response from pomba-es ${resp.text}
    [Return]    ${resp}