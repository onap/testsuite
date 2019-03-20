*** Settings ***
Documentation     Tests the health of the POMBA containers: aai-context-builder, sdc-context-builder, service-decomposition, sdnc-context-builder and network-discovery-context-builder.
Library    Collections
Library         String
Library 	      RequestsLibrary
Resource        global_properties.robot

*** Variables ***
${POMBA_PATH}         /
${POMBA_AAICB_PATH}   /aaicontextbuilder/health
${POMBA_SDCCB_PATH}   /sdccontextbuilder/health
${POMBA_NDCB_PATH}    /ndcontextbuilder/health
${POMBA_SDNCCB_PATH}   /sdnccontextbuilder/health
${POMBA_SERVICEDECOMPOSITION_PATH}   /service-decomposition/health
${POMBA_AAICONTEXTBUILDER_ENDPOINT}    ${GLOBAL_POMBA_SERVER_PROTOCOL}://${GLOBAL_INJECTED_POMBA_AAI_CONTEXT_BUILDER_IP_ADDR}:${GLOBAL_POMBA_AAICONTEXTBUILDER_PORT}
${POMBA_SDCCONTEXTBUILDER_ENDPOINT}    ${GLOBAL_POMBA_SERVER_PROTOCOL}://${GLOBAL_INJECTED_POMBA_SDC_CONTEXT_BUILDER_IP_ADDR}:${GLOBAL_POMBA_SDCCONTEXTBUILDER_PORT}
${POMBA_NETWORKDISCCONTEXTBUILDER_ENDPOINT}    ${GLOBAL_POMBA_SERVER_PROTOCOL}://${GLOBAL_INJECTED_POMBA_NETWORK_DISC_CONTEXTBUILDER_IP_ADDR}:${GLOBAL_POMBA_NETWORKDISCCONTEXTBUILDER_PORT}
${POMBA_SERVICEDECOMPOSITION_ENDPOINT}    ${GLOBAL_POMBA_SERVER_PROTOCOL}://${GLOBAL_INJECTED_POMBA_SERVICE_DECOMPOSITION_IP_ADDR}:${GLOBAL_POMBA_SERVICEDECOMPOSITION_PORT}
${POMBA_SDNCCTXBUILDER_ENDPOINT}    ${GLOBAL_POMBA_SERVER_PROTOCOL}://${GLOBAL_INJECTED_POMBA_SDNC_CTX_BUILDER_IP_ADDR}:${GLOBAL_POMBA_SDNCCXTBUILDER_PORT}

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

Run Pomba Sdnc Context Builder Health Check
    [Documentation]   Tests Pomba Sdnc Context Builder interface
    ${resp}=    Run Pomba Sdnc Context Builder Get Request    ${POMBA_SDNCCB_PATH}
    Should Be Equal As Strings 	${resp.status_code} 	200

Run Pomba Sdnc Context Builder Get Request
    [Documentation]    Runs a Pomba Sdnc Context Builder request
    [Arguments]    ${data_path}
    Log    Creating session ${POMBA_SDNCCTXBUILDER_ENDPOINT}
    ${session}=    Create Session 	pomba-sdncctxbuilder 	${POMBA_SDNCCTXBUILDER_ENDPOINT}
    ${resp}= 	Get Request 	pomba-sdncctxbuilder 	${data_path}
    Log    Received response from pomba-sdncctxbuilder ${resp.text}
    [Return]    ${resp}