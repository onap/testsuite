*** Settings ***
Documentation     Testing ecomp components are available via calls.
...
...                   Testing ecomp components are available via calls.
Resource          ../resources/dcae_interface.robot

*** Test Cases ***
Basic DCAE Health Check
    [Tags]    health
Run DCAE Health Check
