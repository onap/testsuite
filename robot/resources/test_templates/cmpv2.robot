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
${HELM_RELEASE}   kubectl --namespace onap get pods | sed 's/ .*//' | grep robot | sed 's/-.*//'
${CMPv2_helm_values}   ${EXECDIR}/robot/assets/cmpv2
${VES_Client_helm_charts}   {EXECDIR}/robot/assets/helm/ves-client

*** Keywords ***

Suite setup
    [Arguments]  ${PNF_entry_dict}
    Send VES integration request    ${PNF_entry_dict}
    ${command_output} =                 Run And Return Rc And Output        ${HELM_RELEASE}
    Should Be Equal As Integers         ${command_output[0]}                0
    Set Global Variable   ${ONAP_HELM_RELEASE}   ${command_output[1]}
    Install VES Client
    Install VES collector with CMPv2
    VES collector with CMPv2 and wrong SANs

Install VES Client
    ${override} =                       Set Variable                       -f ${CMPv2_helm_values}/ves_client_values_cmpv2.yaml --debug
    Install helm charts from folder     ${VES_Client_helm_charts}           ${ONAP_HELM_RELEASE}-ves-client                 set_values_override=${override}

Install VES collector with CMPv2
    ${override} =                       Set Variable                       -f ${CMPv2_helm_values}/vves_correct_sans_cmpv2.yaml --debug
    Install helm charts                 chart-museum                       dcae-ves-collector         ${ONAP_HELM_RELEASE}-dcae-ves-cmpv2-cert-corect-sans           3 min      ${override}

VES collector with CMPv2 and wrong SANs
    ${override} =                       Set Variable                       -f ${CMPv2_helm_values}/vves_wrong_sans_cmpv2.yaml --debug
    Install helm charts                 chart-museum                       dcae-ves-collector         ${ONAP_HELM_RELEASE}-dcae-ves-cmpv2-cert-wrong-san           3 min      ${override}

VES Client send single VES event
    [Arguments]  ${event}   ${ves_host}   ${ves_port}  ${pnf_sim_host}  ${pnf_sim_port}  ${http_reposnse_code}=202
    ${pnf_sim_endpoint}=            Set Variable                http://${pnf_sim_host}.onap:${pnf_sim_port}
    ${ves_url}=                     Set Variable                ${GLOBAL_DCAE_VES_HTTPS_PROTOCOL}://${ves_host}:${ves_port}/${VES_data_path}
    ${single_event}=                Create Dictionary           event=${event}              ves_url=${ves_url}
    Templating.Create Environment   pnf                         ${GLOBAL_TEMPLATE_FOLDER}
    ${data}=                        Templating.Apply Template   pnf                         ${pnf_simulator_single_event}   ${single_event}
    ${session}=                     Create Session              pnf_sim                     ${pnf_sim_endpoint}
    ${headers}=                     Create Dictionary            Accept=application/json    Content-Type=application/json
    ${post_resp}=                   Post Request                pnf_sim                     ${single_event_data_path}       data=${data}        headers=${headers}
    Log                             PNF registration request ${data}
    Should Be Equal As Strings      ${post_resp.status_code}    ${http_reposnse_code}
    Log                             VES has accepted event with status code ${post_resp.status_code}
    [Return]                        ${post_resp}

Usecase Teardown
    Uninstall helm charts               ${ONAP_HELM_RELEASE}-ves-client
    Uninstall helm charts               ${ONAP_HELM_RELEASE}-dcae-ves-cmpv2-cert-corect-sans
    Uninstall helm charts               ${ONAP_HELM_RELEASE}-dcae-ves-cmpv2-cert-wrong-sans
