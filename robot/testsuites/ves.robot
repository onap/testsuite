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
Resource          ../../resources/dcae/ves_interface.robot
Resource          ../../resources/mr_interface.robot
Resource          ../../resources/dr_interface.robot

*** Variables ***
${MR_TOPIC_CHECK_PATH}              /topics
${DR_SUB_CHECK_PATH}                /internal/prov
${MR_TOPIC_URL_PATH}                /events/org.onap.dmaap.mr.PERFORMANCE_MEASUREMENTS/CG1/C1
${MR_TOPIC_URL_PATH_FOR_POST}       /events/org.onap.dmaap.mr.PERFORMANCE_MEASUREMENTS
${DMAAP_BC_MR_CLIENT_PATH}          /webapi/mr_clients
${DMAAP_BC_MR_CLUSTER_PATH}         /webapi/mr_clusters
${VES_LISTENER_PATH}                /eventListener/v7
${ves7_valid_json}                  ${EXECDIR}/robot/assets/dcae/ves7_valid.json


*** Test Cases ***

Send standard event to VES aand check if is routed to proper topic
    [Documentation]
     ...  This test case checks wheather fault event is send to proper DMAAP topic.
     ...  Fault event should be routed by VES Collector to PERFORMANCE_MEASUREMENTS topic on DMAAP MR .
    [Tags]     vescollector   ete
    ${expected_fault_on_mr}      Set Variable     Fault_Vscf:Acs-Ericcson_PilotNumberPoolExhaustion
    Send Event to VES & Validate Topic      ${ves7_valid_json}   ${MR_TOPIC_URL_PATH}   ${expected_fault_on_mr}


