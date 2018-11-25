*** Settings ***
Documentation	  Testing asdc.
Library    OperatingSystem
Library    RequestsLibrary
Library    Collections
Library 	      ExtendedSelenium2Library
Resource          ../resources/test_templates/model_test_template_vcperescust.robot

Test Template         Model Distribution For vCPEResCust Directory
#Test Teardown    Teardown Model Distribution

*** Variables ***

*** Test Cases ***
Distribute vCPEResCust Model    vCPEResCust
    [Tags]    distributevCPEResCust
