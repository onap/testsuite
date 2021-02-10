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

    ${headers}=  Create Dictionary  content-type=application/json

    Onboard Component Spec  nifi-api  ${headers}
    #Add Registry Client  ${sessionName}  ${headers}
    #Add Distribution Target  ${sessionName}  ${headers}
    #${processGroupId}=  Create Process Group  ${sessionName}  ${headers}  Dummy
    #Create Processor  ${sessionName}  ${headers}  ${processGroupId}
    #Create Flow By Version Controlling  ${sessionName}  ${headers}  ${processGroupId}  Dummy
    #Distribute The Flow  ${sessionName}  ${headers}  ${processGroupId}