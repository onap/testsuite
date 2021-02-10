*** Settings ***

Library           RequestsLibrary
Resource          ../../resources/dcaemod_interface.robot


*** Variables ***

${sessionName}         nifi-api

*** Testcases ***

Configuring DCAE mod
    [tags]              dcaemod
    [Documentation]


    ${session}=  Create Session   ${sessionName}  http://dcaemod.simpledemo.onap.org


    #Onboard Component Spec  nifi-api
    Add Registry Client  ${sessionName}
    Add Distribution Target  ${sessionName}
    ${processGroupId}=  Create Process Group  ${sessionName}    Dummy
    Create Processor  ${sessionName}    ${processGroupId}
    Create Flow By Version Controlling  ${sessionName}    ${processGroupId}  Dummy
    Distribute The Flow  ${sessionName}   ${processGroupId}