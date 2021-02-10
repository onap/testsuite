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

    ${headers_1}=  Create Dictionary  content-type=application/json  Cache-Control=no-cache
    ${headers_2}=  Create Dictionary  content-type=application/json

    #Onboard Component Spec  nifi-api  ${headers_1}
    Add Registry Client  ${sessionName}  ${headers_1}
    Add Distribution Target  ${sessionName}  ${headers_1}
    ${processGroupId}=  Create Process Group  ${sessionName}  ${headers_1}  ${headers_2}  Dummy-app
    Create Processor  ${sessionName}  ${headers_1}  ${processGroupId}
    Create Flow By Version Controlling  ${sessionName}  ${headers_1}  ${headers_2}  ${processGroupId}  Dummy-app
    Distribute The Flow  ${sessionName}  ${headers_1}  ${headers_2}  ${processGroupId}