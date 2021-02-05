*** Settings ***
Documentation     Suite for checking handling events by VES Collector

Library           RequestsLibrary
Library           OperatingSystem
Library           Collections
Library           String
Library           DateTime
Library           SSHLibrary
Library           JSONLibrary
Library           Process
Library           ONAPLibrary.JSON
Library           ONAPLibrary.Utilities
Resource          ../resources/dcae/ves_interface.robot
Resource          ../resources/mr_interface.robot
Resource          ../resources/dr_interface.robot
Suite Setup       Activate DMAAP Topics

*** Variables ***
${MR_TOPIC_CHECK_PATH}              /topics
${DR_SUB_CHECK_PATH}                /internal/prov
${MR_TOPIC_URL_PATH}                /events/unauthenticated.SEC_FAULT_OUTPUT/CG1/C1
${MR_FAULTSUPERVISION_TOPIC_URL_PATH}   /events/unauthenticated.SEC_3GPP_FAULTSUPERVISION_OUTPUT/CG1/C1
${MR_HEARTBEAT_TOPIC_URL_PATH}      /events/unauthenticated.SEC_3GPP_HEARTBEAT_OUTPUT/CG1/C1
${MR_PERFORMANCEASSURANCE_TOPIC_URL_PATH}      /events/unauthenticated.SEC_3GPP_PERFORMANCEASSURANCE_OUTPUT/CG1/C1
${MR_PROVISIONING_TOPIC_URL_PATH}      /events/unauthenticated.SEC_3GPP_PROVISIONING_OUTPUT/CG1/C1
${DMAAP_BC_MR_CLIENT_PATH}          /webapi/mr_clients
${DMAAP_BC_MR_CLUSTER_PATH}         /webapi/mr_clusters
${VES_LISTENER_PATH}                /eventListener/v7
${ves7_valid_json}                  ${EXECDIR}/robot/assets/dcae/ves7_valid.json
${FaultSupervision_json}            ${EXECDIR}/robot/assets/dcae/ves_stdnDefined_3GPP-FaultSupervision.json
${Heartbeat_json}                   ${EXECDIR}/robot/assets/dcae/ves_stdnDefined_3GPP-Heartbeat.json
${PerformanceAssurance_json}        ${EXECDIR}/robot/assets/dcae/ves_stdnDefined_3GPP-PerformanceAssurance.json
${Provisioning_json}                ${EXECDIR}/robot/assets/dcae/ves_stdnDefined_3GPP-Provisioning.json

*** Test Cases ***

Send standard event to VES and check if is routed to proper topic
    [Documentation]
     ...  This test case checks whether fault event is sent to proper DMAAP topic.
     ...  Fault event should be routed by VES Collector to unauthenticated.SEC_FAULT_OUTPUT topic on DMAAP MR.
    [Tags]     vescollector   ete
    ${expected_fault_on_mr}      Set Variable     Fault_Vscf:Acs-Ericcson_PilotNumberPoolExhaustion
    Send Event to VES & Validate Topic      ${ves7_valid_json}   ${MR_TOPIC_URL_PATH}   ${expected_fault_on_mr}

Send 3GPP Fault Supervision event to VES and check if is routed to proper topic
    [Documentation]
     ...  This test case checks whether fault event is sent to proper DMAAP topic.
     ...  Fault Supervision event should be routed by domain = "stndDefined" and stndDefinedNamespace = "3GPP-FaultSupervision".
     ...  Fault should be routed to mr topic unauthenticated.SEC_3GPP_FAULTSUPERVISION_OUTPUT
    [Tags]     vescollector   ete
    ${expected_fault_on_mr}      Set Variable     ves_stdnDefined_3GPP-FaultSupervision
    Send Event to VES & Validate Topic      ${FaultSupervision_json}   ${MR_FAULTSUPERVISION_TOPIC_URL_PATH}   ${expected_fault_on_mr}

Send 3GPP Heartbeat event to VES and check if is routed to proper topic
    [Documentation]
     ...  This test case checks whether fault event is sent to proper DMAAP topic.
     ...  Fault Supervision event should be routed by domain = "stndDefined" and stndDefinedNamespace = "3GPP-Heartbeat".
     ...  Fault should be routed to mr topic unauthenticated.SEC_3GPP_HEARTBEAT_OUTPUT
    [Tags]     vescollector   ete
    ${expected_fault_on_mr}      Set Variable     ves_stdnDefined_3GPP-Heartbeat
    Send Event to VES & Validate Topic      ${Heartbeat_json}   ${MR_HEARTBEAT_TOPIC_URL_PATH}   ${expected_fault_on_mr}

Send 3GPP Performance Assurance event to VES and check if is routed to proper topic
    [Documentation]
     ...  This test case checks whether fault event is sent to proper DMAAP topic.
     ...  Fault Supervision event should be routed by domain = "stndDefined" and stndDefinedNamespace = "3GPP-PerformanceAssurance".
     ...  Fault should be routed to mr topic unauthenticated.SEC_3GPP_PERFORMANCEASSURANCE_OUTPUT
    [Tags]     vescollector   ete
    ${expected_fault_on_mr}      Set Variable     ves_stdnDefined_3GPP-PerformanceAssurance
    Send Event to VES & Validate Topic      ${PerformanceAssurance_json}   ${MR_PERFORMANCEASSURANCE_TOPIC_URL_PATH}   ${expected_fault_on_mr}

Send 3GPP Provisioning event to VES and check if is routed to proper topic
    [Documentation]
     ...  This test case checks whether fault event is sent to proper DMAAP topic.
     ...  Fault Supervision event should be routed by domain = "stndDefined" and stndDefinedNamespace = "3GPP-Provisioning".
     ...  Fault should be routed to mr topic unauthenticated.SEC_3GPP_PROVISIONING_OUTPUT
    [Tags]     vescollector   ete
    ${expected_fault_on_mr}      Set Variable     ves_stdnDefined_3GPP-Provisioning
    Send Event to VES & Validate Topic      ${Provisioning_json}   ${MR_PROVISIONING_TOPIC_URL_PATH}   ${expected_fault_on_mr}
