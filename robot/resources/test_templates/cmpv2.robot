*** Settings ***
Documentation    CMPv2 test cases
Library         OperatingSystem
Library         RequestsLibrary
Library         Collections
Library         ONAPLibrary.JSON
Library         ONAPLibrary.Utilities
Library         ONAPLibrary.Templating    WITH NAME    Templating
Resource        pnf_registration_without_SO_template.robot
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
VES Client send single VES event
    [Arguments]  ${event}   ${ves_host}   ${ves_port}  ${pnf_sim_host}  ${pnf_sim_port}  ${http_reposnse_code}=202
    ${pnf_sim_endpoint}=            Set Variable                http://${pnf_sim_host}:${pnf_sim_port}
    ${ves_url}=                     Set Variable                ${GLOBAL_DCAE_VES_HTTPS_PROTOCOL}://${ves_host}:${ves_port}/${VES_data_path}
    ${single_event}=                Create Dictionary           event=${event}              ves_url=${ves_url}
    Templating.Create Environment   pnf                         ${GLOBAL_TEMPLATE_FOLDER}
    ${data}=                        Templating.Apply Template   pnf                         ${pnf_simulator_single_event}   ${single_event}
    ${pnf_sim_endpoint}=            Set Variable                http://${pnf_sim_host}:${pnf_sim_port}
    ${session}=                     Create Session              pnf_sim                     ${pnf_sim_endpoint}
    ${headers}=                     Create Dictionary            Accept=application/json    Content-Type=application/json
    ${post_resp}=                   Post Request                pnf_sim                     ${single_event_data_path}       data=${data}        headers=${headers}
    Log                             PNF registration request ${data}
    Should Be Equal As Strings      ${post_resp.status_code}    ${http_reposnse_code}
    Log                             VES has accepted event with status code ${post_resp.status_code}
    [Return]                        ${post_resp}


Usecase Teardown
    Undeploy Service                    ${mongo-dep}
    Undeploy Service                    ${ves-client-dep}
    Undeploy Service                    ves-collector-cmpv2-dep
    Undeploy Service                    ves-collector-cmpv2-wrong-sans-dep
    Delete Blueprint From Inventory     ${serviceTypeIdMongo}
    Delete Blueprint From Inventory     ${serviceTypeIdPnfSimulator}