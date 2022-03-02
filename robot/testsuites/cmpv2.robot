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
Resource          ../resources/global_properties.robot
Resource          ../resources/test_templates/cmpv2.robot
Suite Setup       Suite setup  ${initial entry}
Suite Teardown    Usecase Teardown

*** Variables ***
${MONGO_BLUEPRINT_PATH}                  ${EXECDIR}/robot/assets/cmpv2/k8s-mongo-ves-client.yaml
${PNF_SIMULATOR_BLUEPRINT_PATH}          ${EXECDIR}/robot/assets/cmpv2/k8s-ves-client.yaml
${VES_INPUTS}                            deployment/VesTlsCmpv2Inputs.jinja
${pnf_ves_integration_request}           ves/pnf_registration_request.jinja
${NEXUS3}                                ${GLOBAL_INJECTED_NEXUS_DOCKER_REPO}
&{initial entry}                         correlation_id=dummy    PNF_IPv4_address=11.11.11.1    PNF_IPv6_address=2001:0db8:0:0:0:0:1428:57ab

*** Test Cases ***

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
     VES Client send single VES event           ${template}                         dcae-ves-collector-cmpv2-cert           8443                             ves-client-cmpv2              5000
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
    ${resp}=                                   VES Client send single VES event        ${template}                         dcae-ves-collector-cmpv2-cert-wrong-sans      8443                             ves-client-cmpv2              5000     421
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
    ${resp}=                                   VES Client send single VES event        ${template}                         dcae-ves-collector           8443                             ves-client-cmpv2              5000     421
    Should Contain                              ${resp.json().get('message')}                               certificate_unknown

