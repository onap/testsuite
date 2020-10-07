*** Settings ***
Documentation     5G Bulk PM Usecase functionality

Library           RequestsLibrary
Library           OperatingSystem
Library           Collections
Library           String
Library           JSONLibrary
Library           ONAPLibrary.JSON
Library           ONAPLibrary.Utilities
Library           ONAPLibrary.Templating    WITH NAME    Templating
Resource          ../resources/dcae/deployment.robot
Resource          ../resources/dcae/inventory.robot
Resource          ../resources/global_properties.robot
Resource          ../resources/test_templates/cmpv2.robot
Suite Teardown    Usecase Teardown

*** Variables ***
${MONGO_BLUEPRINT_PATH}                  ${EXECDIR}/robot/assets/cmpv2/k8s-mongo.yaml
${MONGO_EXPRESS_BLUEPRINT_PATH}          ${EXECDIR}/robot/assets/cmpv2/k8s-mongo-express.yaml
${PNF_SIMULATOR_BLUEPRINT_PATH}          ${EXECDIR}/robot/assets/cmpv2/k8s-pnf-simulator.yaml
${VES_INPUTS}                            deployment/VesTlsCmpv2Inputs.jinja
${pnf_ves_integration_request}           ves/pnf_registration_request.jinja
${NEXUS3}                                ${GLOBAL_INJECTED_NEXUS_DOCKER_REPO}

*** Test Cases ***

Deploying PNF Simulator
    [Tags]                              CMPv2
    ${serviceTypeIdMongo}               Load Blueprint To Inventory        ${MONGO_BLUEPRINT_PATH}              mongo
    ${serviceTypeIdMongoExpress}        Load Blueprint To Inventory        ${MONGO_EXPRESS_BLUEPRINT_PATH}      mongo-express
    ${serviceTypeIdPnfSimulator}        Load Blueprint To Inventory        ${PNF_SIMULATOR_BLUEPRINT_PATH}      pnf-simulator
    Set Suite Variable                  ${serviceTypeIdMongo}
    Set Suite Variable                  ${serviceTypeIdMongoExpress}
    Set Suite Variable                  ${serviceTypeIdPnfSimulator}
    ${deployment_data}=                 Set Variable                       {"serviceTypeId": "${serviceTypeIdMongo}"}
    Deploy Service                      ${deployment_data}                 mongo-dep                            2 minutes
    ${deployment_data}=                 Set Variable                       {"serviceTypeId": "${serviceTypeIdMongoExpress}"}
#   ${resp}=                            Get Blueprint From Inventory       pnf-simulator
#   ${json}=                            Set Variable                       ${resp.json()}
#    ${image}                            Get Regexp Matches                 ${json['items'][0]['blueprintTemplate']}               nexus3(.)*?(?=\\")
#    ${image}                            Replace String                     ${image}[0]      nexus3.onap.org:10001                 ${NEXUS3}
#    ${deployment_data}=                 Set Variable                       {"serviceTypeId": "${serviceTypeIdPnfSimulator}", "inputs": {"tag_version": "${image}"}}
    ${deployment_data}=                 Set Variable                       {"serviceTypeId": "${serviceTypeIdPnfSimulator}", "inputs": {"tag_version": "kuzmicki/pnf-simulator:1.0.6"}}
    Deploy Service                      ${deployment_data}                 pnf-simulator-dep                    4 minutes

Deploying VES collector with CMPv2
    [Tags]                              CMPv2
    ${resp}=                            Get Blueprint From Inventory       k8s-ves
    ${json}=                            Set Variable                       ${resp.json()}
    ${serviceTypeIdVes}                 Set Variable                       ${json['items'][0]['typeId']}
    ${image}                            Get Regexp Matches                 ${json['items'][0]['blueprintTemplate']}             nexus3(.)*?(?=\')
    ${image}                            Replace String                     ${image}[0]      nexus3.onap.org:10001               ${NEXUS3}
    ${arguments}=                       Create Dictionary                  serviceTypeId=${serviceTypeIdVes}
    Set To Dictionary                   ${arguments}                       image                                                ${image}
    Set To Dictionary                   ${arguments}                       external_port_tls                                    32226
    Set To Dictionary                   ${arguments}                       service_component_name_override                      dcae-ves-collector-cmpv2-cert
    Set To Dictionary                   ${arguments}                       external_cert_sans                                   dcae-ves-collector-cmpv2-cert:ves-collector-cmpv2-cert:ves-cmpv2-cert
    Templating.Create Environment       deployment                         ${GLOBAL_TEMPLATE_FOLDER}
    ${deployment_data}=                 Templating.Apply Template          deployment                                           ${VES_INPUTS}            ${arguments}
    Deploy Service                      ${deployment_data}                 ves-collector-cmpv2-dep                    4 minutes

Send registration request to CMPv2 VES
    [Tags]                                      CMPv2
     ${pnf_correlation_id}=                     Generate Random String              20                                      [LETTERS][NUMBERS]
     ${PNF_entry_dict}=                         Create Dictionary                   correlation_id=${pnf_correlation_id}    PNF_IPv4_address=13.13.13.13    PNF_IPv6_address=2001:0db8:0:0:0:0:1428:57ab
     Wait Until Keyword Succeeds                10x                                 5s                                      Check VES_PNFREG_OUTPUT topic presence in MR
     Create PNF initial entry in A&AI           ${PNF_entry_dict}
     Templating.Create Environment              ves                                 ${GLOBAL_TEMPLATE_FOLDER}
     ${template}=                               Templating.Apply Template           ves                                     ${pnf_ves_integration_request}   ${PNF_entry_dict}
     Pnf simulator send single VES event        ${template}                         dcae-ves-collector-cmpv2-cert           8443                             pnf-simulator              5000
     Verify PNF Integration Request in A&AI     ${PNF_entry_dict}

