*** Settings ***
Documentation     Testing Installation 
...           Tests that confirm an installation is valid and not meant as recurring health test
...               

Test Timeout      10 second

Resource          ../resources/mr_interface.robot

*** Test Cases ***

Basic DMAAP Message Router ACL Update Test
    [Tags]    dmaapacl   postinstall
    [Timeout]   30
    Run MR Update Topic Acl

Basic AAI Service Design Models Size Test
    [Tags]   aaimodels   postinstall
    Validate Size Of AAI Models
