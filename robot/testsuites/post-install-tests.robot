*** Settings ***
Documentation     Testing Installation
...           Tests that confirm an installation is valid and not meant as recurring health test
...

Test Timeout      10 second

Resource          ../resources/aai/models.robot

*** Test Cases ***

Basic AAI Service Design Models Size Test
    [Tags]   aaimodels   postinstall
    [Timeout]   60
    Validate Size Of AAI Models
