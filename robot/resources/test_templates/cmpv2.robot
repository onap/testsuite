*** Settings ***
Documentation    CMPv2 test cases
Library         OperatingSystem
Library         RequestsLibrary
Library         Collections
Library         ONAPLibrary.JSON
Library         ONAPLibrary.Utilities
Library         ONAPLibrary.Templating    WITH NAME    Templating
Resource        ../resources/test_templates/cmpv2.robot
Resource        ../dcae/deployment.robot
Resource        ../dcae/inventory.robot
Resource        ../global_properties.robot


*** Variables ***
${pnf_simulator_single_event}=  ves/pnf_simulator_single_event.jinja
${VES_ENDPOINT}    ${GLOBAL_DCAE_VES_HTTPS_PROTOCOL}://${GLOBAL_INJECTED_DCAE_VES_HOST}:${GLOBAL_DCAE_VES_HTTPS_SERVER_PORT}
${VES_data_path}   eventListener/v7
${single_event_data_path}   /simulator/event
${users}  ${EXECDIR}/robot/assets/cmpv2/mongo-users.json


*** Keywords ***
Pnf simulator send single VES event  ${event}   ${ves_host}   ${ves_port}  ${pnf_sim_host}  ${pnf_sim_port}
    ${pnf_sim_endpoint}=  Set Variable  http://${pnf_sim_host}:${pnf_sim_port}
    ${ves_url}=  Set Variable   ${GLOBAL_DCAE_VES_HTTPS_PROTOCOL}://${ves_host}:${ves_port}/${VES_data_path}
    ${single_event}=  Create Dictionary   event=${event}   ves_url=${ves_url}
    Templating.Create Environment    pnf    ${GLOBAL_TEMPLATE_FOLDER}
    ${data}=   Templating.Apply Template    pnf    ${pnf_simulator_single_event}   ${single_event}
    ${pnf_sim_endpoint}=  Set Variable  http://${pnf_sim_host}:${pnf_sim_port}
    ${session}=    Create Session       pnf_sim     ${pnf_sim_host}
    ${headers}=  Create Dictionary   Accept=application/json    Content-Type=application/json
    ${post_resp}=       Post Request    pnf_sim     ${single_event_data_path}      data=${data}    headers=${headers}
    Log  PNF registration request ${data}
    Should Be Equal As Strings  ${post_resp.status_code}        202
    Log  VES has accepted event with status code ${post_resp.status_code}


Configure pnf simulator DB   ${mongo_host}   ${mongo_host_port}
    ${mongo_endpoint}=  Set Variable  http://${mongo_host}:${mongo_host_port}
    ${headers}=  Create Dictionary   Accept=application/json    Content-Type=application/json
    ${session}=    Create Session       mongo     ${mongo_endpoint}
    ${data}=  Create Dictionary   database=pnf_simulator
    ${post_resp}=       Post Request    mongo    /      files=${data}    headers=${headers}
    ${data}=  Create Dictionary   collection=simulatorConfig
    ${post_resp}=       Post Request    mongo    /db/pnf_simulator      files=${data}    headers=${headers}
    ${data}=  Create Dictionary   collection=flatTemplatesView
    ${post_resp}=       Post Request    mongo    /db/pnf_simulator      files=${data}    headers=${headers}
    ${data}=  Create Dictionary   collection=template
    ${post_resp}=       Post Request    mongo    /db/pnf_simulator      files=${data}    headers=${headers}
    ${data}=  Create Dictionary   document={"vesServerUrl": "https://dcae-ves-collector-external-cert:8443/eventListener/v7"}
    ${post_resp}=       Post Request    mongo    /db/pnf_simulator/simulatorConfig      files=${data}    headers=${headers}
    ${document}=        OperatingSystem.Get File           ${users}
    ${data}=  Create Dictionary   document=${document}
    ${post_resp}=       Post Request    mongo    /db/admin/system.users      files=${data}    headers=${headers}

Usecase Teardown
    Undeploy Service                    mongo-dep
    Undeploy Service                    mongo-express-dep
    Undeploy Service                    pnf-simulator-dep
    Undeploy Service                    ves-collector-cmpv2-dep
    Delete Blueprint From Inventory     ${serviceTypeIdMongo}
    Delete Blueprint From Inventory     ${serviceTypeIdMongoExpress}
    Delete Blueprint From Inventory     ${serviceTypeIdPnfSimulator}