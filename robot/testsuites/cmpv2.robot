*** Settings ***
Documentation     CMPv2 Usecase functionality
Test Timeout      15m
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
Resource          ../resources/test_templates/pnf_registration_without_SO_template.robot
Suite Setup       Send VES integration request  ${initial entry}
Suite Teardown    Usecase Teardown

*** Variables ***
${MONGO_BLUEPRINT_PATH}                  ${EXECDIR}/robot/assets/cmpv2/k8s-mongo-ves-client.yaml
${PNF_SIMULATOR_BLUEPRINT_PATH}          ${EXECDIR}/robot/assets/cmpv2/k8s-ves-client.yaml
${VES_INPUTS}                            deployment/VesTlsCmpv2Inputs.jinja
${pnf_ves_integration_request}           ves/pnf_registration_request.jinja
${NEXUS3}                                ${GLOBAL_INJECTED_NEXUS_DOCKER_REPO}
&{initial entry}                              correlation_id=dummy    PNF_IPv4_address=11.11.11.1    PNF_IPv6_address=2001:0db8:0:0:0:0:1428:57ab


*** Test Cases ***

Deploying VES Client
    [Documentation]
     ...  This test case deploys VES Client with "enable_tls": set to false and "external_cert_use_external_tls" (CMPv2) set to true as DCAE applictaion
    [Tags]                              CMPv2
    ${rand}                             Generate Random String             5                                   [NUMBERS][LOWER]
    Set Suite Variable                  ${ves_client_hostname}             ves-client-${rand}
    ${serviceTypeIdMongo}               Load Blueprint To Inventory        ${MONGO_BLUEPRINT_PATH}              mongo-${rand}
    ${serviceTypeIdPnfSimulator}        Load Blueprint To Inventory        ${PNF_SIMULATOR_BLUEPRINT_PATH}      ves-client-${rand}
    Set Suite Variable                  ${serviceTypeIdMongo}
    Set Suite Variable                  ${serviceTypeIdPnfSimulator}
    ${deployment_data}=                 Set Variable                       {"serviceTypeId":"${serviceTypeIdMongo}", "inputs":{"service_component_name_override":"mongo-${ves_client_hostname}","service_component_type":"mongo-${ves_client_hostname}"}}
    Set Suite Variable                  ${mongo-dep}                       mongo-dep-${rand}
    Deploy Service                      ${deployment_data}                 ${mongo-dep}                            2 minutes
    ${resp}=                            Get Blueprint From Inventory       ves-client-${rand}
    ${json}=                            Set Variable                       ${resp.json()}
    ${image}                            Get Regexp Matches                 ${json['items'][0]['blueprintTemplate']}               nexus3(.)*?(?=\')
    ${image}                            Replace String                     ${image}[0]      nexus3.onap.org:10001                 ${NEXUS3}
    ${deployment_data}=                 Set Variable                       {"serviceTypeId":"${serviceTypeIdPnfSimulator}", "inputs":{"tag_version": "${image}", "service_component_name_override":"${ves_client_hostname}"}}
    Set Suite Variable                  ${ves-client-dep}                  ves-client-dep-${rand}
    Deploy Service                      ${deployment_data}                 ${ves-client-dep}                    4 minutes


Deploying VES collector with CMPv2
    [Documentation]
     ...  This test case deploys second VES instance with "enable_tls": set to true and "external_cert_use_external_tls" (CMPv2) set to true as DCAE applictaion
     ...  Both CMPv2 and AAF certificates are present
    [Tags]                              CMPv2
    ${resp}=                            Get Blueprint From Inventory       k8s-ves
    ${json}=                            Set Variable                       ${resp.json()}
    ${serviceTypeIdVes}                 Set Variable                       ${json['items'][0]['typeId']}
    ${image}                            Get Regexp Matches                 ${json['items'][0]['blueprintTemplate']}             nexus3(.)*?(?=\")
    ${image}                            Replace String                     ${image}[0]      nexus3.onap.org:10001               ${NEXUS3}
    ${arguments}=                       Create Dictionary                  serviceTypeId=${serviceTypeIdVes}
    Set To Dictionary                   ${arguments}                       image                                                ${image}
    Set To Dictionary                   ${arguments}                       external_port_tls                                    32226
    Set To Dictionary                   ${arguments}                       service_component_name_override                      dcae-ves-collector-cmpv2-cert
    Set To Dictionary                   ${arguments}                       external_cert_sans                                   dcae-ves-collector-cmpv2-cert,ves-collector-cmpv2-cert,ves-cmpv2-cert
    Templating.Create Environment       deployment                         ${GLOBAL_TEMPLATE_FOLDER}
    ${deployment_data}=                 Templating.Apply Template          deployment                                           ${VES_INPUTS}            ${arguments}
    Deploy Service                      ${deployment_data}                 ves-collector-cmpv2-dep                    4 minutes

Deploying VES collector with CMPv2 and wrong SANs
    [Documentation]
     ...  This test case deploys second VES instance with "enable_tls": set to true and "external_cert_use_external_tls" (CMPv2) set to true as DCAE applictaion, CMPv2 certificate has wrong SANs
     ...  Both CMPv2 and AAF certificates are present
    [Tags]                              CMPv2
    ${resp}=                            Get Blueprint From Inventory       k8s-ves
    ${json}=                            Set Variable                       ${resp.json()}
    ${serviceTypeIdVes}                 Set Variable                       ${json['items'][0]['typeId']}
    ${image}                            Get Regexp Matches                 ${json['items'][0]['blueprintTemplate']}             nexus3(.)*?(?=\")
    ${image}                            Replace String                     ${image}[0]      nexus3.onap.org:10001               ${NEXUS3}
    ${arguments}=                       Create Dictionary                  serviceTypeId=${serviceTypeIdVes}
    Set To Dictionary                   ${arguments}                       image                                                ${image}
    Set To Dictionary                   ${arguments}                       external_port_tls                                    32227
    Set To Dictionary                   ${arguments}                       service_component_name_override                      dcae-ves-collector-cmpv2-cert-wrong-sans
    Set To Dictionary                   ${arguments}                       external_cert_sans                                   wrong-sans
    Templating.Create Environment       deployment                         ${GLOBAL_TEMPLATE_FOLDER}
    ${deployment_data}=                 Templating.Apply Template          deployment                                           ${VES_INPUTS}            ${arguments}
    Deploy Service                      ${deployment_data}                 ves-collector-cmpv2-wrong-sans-dep                   4 minutes

Send registration request to CMPv2 VES
    [Documentation]
    ...  This test case triggers registration request from VES Client (where is present only CMPv2 certificate) to VES collector
    ...  with enabled CMPv2 (both CMPv2 and AAF certificates are present).
    ...  Test expects successful registration
     [Tags]                                      CMPv2
     ${pnf_correlation_id}=                     Generate Random String              20                                      [LETTERS][NUMBERS]
     ${PNF_entry_dict}=                         Create Dictionary                   correlation_id=${pnf_correlation_id}    PNF_IPv4_address=13.13.13.13    PNF_IPv6_address=2001:0db8:0:0:0:0:1428:57ab
     Wait Until Keyword Succeeds                10x                                 5s                                      Check VES_PNFREG_OUTPUT topic presence in MR
     Create PNF initial entry in A&AI           ${PNF_entry_dict}
     Templating.Create Environment              ves                                 ${GLOBAL_TEMPLATE_FOLDER}
     ${template}=                               Templating.Apply Template           ves                                     ${pnf_ves_integration_request}   ${PNF_entry_dict}
     VES Client send single VES event           ${template}                         dcae-ves-collector-cmpv2-cert           8443                             ${ves_client_hostname}              5000
     Verify PNF Integration Request in A&AI     ${PNF_entry_dict}

Send registration request to CMPv2 VES with wrong SAN-s
    [Documentation]
    ...  This test case triggers registration request from VES Client (where is present only CMPv2 certificate)  to VES collector
    ...  ith enabled CMPv2 (both CMPv2 and AAF certificates are present). CMPv2 certificate has wrong SANs.
    [Tags]                                     CMPv2
    ${pnf_correlation_id}=                      Generate Random String              20                                      [LETTERS][NUMBERS]
    ${PNF_entry_dict}=                         Create Dictionary                   correlation_id=${pnf_correlation_id}    PNF_IPv4_address=14.14.14.14    PNF_IPv6_address=2001:0db8:0:0:0:0:1428:57ab
    Templating.Create Environment              ves                                 ${GLOBAL_TEMPLATE_FOLDER}
    ${template}=                               Templating.Apply Template           ves                                     ${pnf_ves_integration_request}   ${PNF_entry_dict}
    ${resp}=                                   VES Client send single VES event        ${template}                         dcae-ves-collector-cmpv2-cert-wrong-sans      8443                             ${ves_client_hostname}              5000     421
    Should Contain                             ${resp.json().get('message')}                               wrong-sans

Send registration request to VES without CMPv2 certificate
    [Documentation]
    ...  This test case triggers registration request from VES Client (where is present only CMPv2 certificate)  to VES collector
    ...  with disabled CMPv2 (only AAF certificate is present - VES collector deployed during whole ONAP deploy).
    [Tags]                                     CMPv2
    ${pnf_correlation_id}=                      Generate Random String              20                                      [LETTERS][NUMBERS]
    ${PNF_entry_dict}=                         Create Dictionary                   correlation_id=${pnf_correlation_id}    PNF_IPv4_address=14.14.14.14    PNF_IPv6_address=2001:0db8:0:0:0:0:1428:57ab
    Templating.Create Environment              ves                                 ${GLOBAL_TEMPLATE_FOLDER}
    ${template}=                               Templating.Apply Template           ves                                     ${pnf_ves_integration_request}   ${PNF_entry_dict}
    ${resp}=                                   VES Client send single VES event        ${template}                         dcae-ves-collector           8443                             ${ves_client_hostname}              5000     421
    Should Contain                              ${resp.json().get('message')}                               certificate_unknown

