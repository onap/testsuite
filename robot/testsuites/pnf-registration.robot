*** Settings ***
Documentation     Executes the PNF registration  test cases including setup and teardown
Test Timeout      15m

Resource         ../resources/test_templates/pnf_registration_without_SO_template.robot
Library	        String



*** Test Cases ***

PNF Registration only DCAE part: AAI, VES, PRH, Kafka
     [Documentation]
     ...  This test case creates A&AI entry for PNF without SDC model distribution and service instantiation in SO.
     ...  Test case verify PNF Registration only in DCAE part: AAI, VES, PRH, Kafka.
     ...  During test case Robot adds PNF entry to A&AI that contains: correlation ID, PNF_IPv4_address and PNF_IPv6_address
     [Tags]   pnf_registrate   ete
     ${pnf_correlation_id}=    Generate Random String  20  [LETTERS][NUMBERS]
     ${PNF_entry_dict}=  Create Dictionary  correlation_id=${pnf_correlation_id}  PNF_IPv4_address=13.13.13.13  PNF_IPv6_address=2001:0db8:0:0:0:0:1428:57ab
     Log  Initial PNF entry ${PNF_entry_dict}
     Create A&AI entry without SO and succesfully registrate PNF  ${PNF_entry_dict}
     [Teardown]  Cleanup PNF entry in A&AI  ${PNF_entry_dict}



Instantiate PNF_macro service and succesfully registrate PNF
     [Documentation]
     ...  This test case creates TOSCA csar software package for PNF. Imports it as VSP package.
     ...  Cretaes PNF resource, cretaes Macro service, attach PNF resource and distributes it.
     ...  After sucesfull distribution, service recipe is added to SO ctalog db.
     ...  Next service is instantied with random PNF id. VES integration event is send with this PNF ID.
     ...  At the end of the service is checked in terms
     ...  - service completion
     ...  - PNF entry update about information from VES event
     [Tags]   pnf_registrate_macro_vnf_api   ete
     ${pnf_correlation_id}=    Generate Random String  20  [LETTERS][NUMBERS]
     ${PNF_entry_dict}=  Create Dictionary  correlation_id=${pnf_correlation_id}  PNF_IPv4_address=13.13.13.13  PNF_IPv6_address=2001:0db8:0:0:0:0:1428:57ab
     ${PNF_service_model}=  Set Variable  Demo_pNF_${pnf_correlation_id}
     Instantiate PNF_macro service and succesfully registrate PNF template   ${PNF_service_model}   ${PNF_entry_dict}   ${pnf_correlation_id}


Instantiate PNF service (using building blocks) and succesfully registrate PNF
     [Documentation]
     ...  This test case creates TOSCA csar software package for PNF. Imports it as VSP package.
     ...  Cretaes PNF resource, cretaes Macro service, attach PNF resource and distributes it.
     ...  Next service is instantied with random PNF id. VES integration event is send with this PNF ID.
     ...  At the end of the service is checked in terms
     ...  - service completion
     ...  - PNF entry update about information from VES event
     ...  - PNF orchestration status
     [Tags]   pnf_registrate     ete
     ${pnf_correlation_id}=    Generate Random String  20  [LETTERS][NUMBERS]
     ${PNF_entry_dict}=  Create Dictionary  correlation_id=${pnf_correlation_id}  PNF_IPv4_address=13.13.13.13  PNF_IPv6_address=2001:0db8:0:0:0:0:1428:57ab
     ${PNF_service_model}=  Set Variable  Demo_pNF_${pnf_correlation_id}
     Instantiate PNF_macro service and succesfully registrate PNF template   ${PNF_service_model}   ${PNF_entry_dict}   ${pnf_correlation_id}  building_block_flow=true
