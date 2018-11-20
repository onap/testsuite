*** Settings ***
Documentation	  Testing asdc.
Library    OperatingSystem
Library    RequestsLibrary
Library    Collections
Library 	      ExtendedSelenium2Library
Resource          ../resources/test_templates/model_test_template.robot

Test Template         Model Distribution For Directory
Test Teardown    Teardown Model Distribution

*** Variables ***

*** Test Cases ***
Distribute vLB Model    vLB
    [Tags]    ete    distribute
Distribute vFW Model    vFW
    [Tags]    ete    distribute
Distribute vFW Model    vFWCL
    [Tags]    ete    distribute
Distribute vVG Model    vVG
    [Tags]    ete    distribute
Distribute vCPEInfra    vCPEInfra
    [Tags]    ete    distribute
Distribute vCPEvBNG     vCPEvBNG
    [Tags]    ete    distribute
Distribute vCPEvBRGEMU  vCPEvBRGEMU
    [Tags]    ete    distribute
Distribute vCPEvGMUX    vCPEvGMUX
    [Tags]    ete    distribute
Distribute vCPEvGW      vCPEvGW
    [Tags]    ete    distribute
