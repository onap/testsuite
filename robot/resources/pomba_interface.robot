*** Settings ***
Documentation     Tests the health of the POMBA containers: aai-context-builder, sdc-context-builder and network-discovery-context-builder.
Library    Collections
Library         String
Library 	      RequestsLibrary
Resource        global_properties.robot

*** Variables ***
${POMBA_PATH}         /
${POMBA_SDCCONTEXTBUILDER_ENDPOINT}    ${GLOBAL_POMBA_SERVER_PROTOCOL}://${GLOBAL_INJECTED_AAICONTEXTBUILDER_IP_ADDR}:${GLOBAL_LOG_AAICONTEXTBUILDER_PORT}
${POMBA_AAICONTEXTBUILDER_ENDPOINT}    ${GLOBAL_POMBA_SERVER_PROTOCOL}://${GLOBAL_INJECTED_SDCCONTEXTBUILDER_IP_ADDR}:${GLOBAL_SDCCONTEXTBUILDER_PORT}
${POMBA_NETWORKDISCCONTEXTBUILDER_ENDPOINT}    ${GLOBAL_POMBA_SERVER_PROTOCOL}://${GLOBAL_NETWORKDISCCONTEXTBUILDER_IP_ADDR}:${GLOBAL_NETWORKDISCCONTEXTBUILDER_PORT}

*** Keywords ***
Run Pomba Aai Context Builder Health Check
    [Documentation]   Tests Pomba Aai Context Builder interface
    ${resp}=    Run Pomba Aai Context Builder Get Request    ${POMBA_PATH}
    Should Be Equal As Strings 	${resp.status_code} 	200

Run Pomba Aai Context Builder Get Request
    [Documentation]    Runs a Pomba Aai Context Builder request
    [Arguments]    ${data_path}
    Log    Creating session ${POMBA_AAICONTEXTBUILDER_ENDPOINT}
    ${session}=    Create Session 	log-elasticsearch 	${POMBA_AAICONTEXTBUILDER_ENDPOINT}
    ${resp}= 	Get Request 	pomba-aaictxbuilder 	${data_path}
    Log    Received response from pomba-aaictxbuilder ${resp.text}
    [Return]    ${resp}

Run Pomba Sdc Context Builder Health Check
    [Documentation]   Tests Sdc Context Builder interface
    ${resp}=    Run Pomba Sdc Context Builder Get Request    ${POMBA_PATH}
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
    ${resp}=    Run Pomba Network Discovery Context Builder Get Request    ${POMBA_PATH}
    Should Be Equal As Strings 	${resp.status_code} 	200

Run Pomba Network Discovery Context Builder Get Request
    [Documentation]    Runs a Pomba Network Discovery Context Builder request
    [Arguments]    ${data_path}
    Log    Creating session ${POMBA_NETWORKDISCCONTEXTBUILDER_ENDPOINT}
    ${session}=    Create Session 	pomba-networkdiscovery 	${POMBA_NETWORKDISCCONTEXTBUILDER_ENDPOINT}
    ${resp}= 	Get Request 	pomba-networkdisconvery 	${data_path}
    Log    Received response from pomba-networkdiscovery ${resp.text}
    [Return]    ${resp}

