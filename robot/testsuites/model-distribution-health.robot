*** Settings ***
Documentation     Testing SDC distribution.
Library    OperatingSystem
Library    RequestsLibrary
Library    Collections
Library               ExtendedSelenium2Library
Resource          ../resources/test_templates/model_test_template.robot


*** Variables ***
${ziplist}
${catalog_service_name}

*** Test Cases ***
Health Distribution Test
    ${ziplist2}    Create List   ${ziplist}
    Distribute Model From ASDC    ${ziplist2}    ${catalog_service_name}
    [Tags]    healthdist
