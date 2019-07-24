*** Settings ***
Documentation     Executes the PNF registration  test cases including setup and teardown
Test Timeout      3m

Resource         ../resources/test_templates/pnf_registration_without_SO_template.robot


*** Test Cases ***

Create A&AI antry without SO and succesfully registrate PNF, PNF entry contains: correlation ID, PNF_IPv4_address and PNF_IPv6_address
     [Documentation]  This test is checking creation A&AI entry without SO and succesfull PNF registration
     [Tags]   pnf_registrate   ete
     ${PNF_entry_dict}=  Create Dictionary  correlation_id=ABCDEFG1234567  PNF_IPv4_address=13.13.13.13  PNF_IPv6_address=2001:0db8:0:0:0:0:1428:57ab
     Log  Initial PNF entry ${PNF_entry_dict}
     Create A&AI antry without SO and succesfully registrate PNF  ${PNF_entry_dict}
     [Teardown]  Cleanup PNF entry in A&AI  ${PNF_entry_dict}