*** Settings ***

Library           RequestsLibrary
Resource          ../../resources/dcaemod_interface.robot


*** Variables ***

${robotVar} =            FooBarBaz


*** Testcases ***

Configuring DCAE mod
    [tags]              dcaemod
    [Documentation]


    ${session}=  Create Session   nifi-api  http://dcaemod.simpledemo.onap.org

    ${headers_1}=  Create Dictionary  content-type=application/json  Cache-Control=no-cache
    ${headers_2}=  Create Dictionary  content-type=application/json

    #Onboard Component Spec  nifi-api  ${headers_1}
    Add Registry Client  nifi-api  ${headers_1}
    Add Distribution Target  nifi-api  ${headers_1}
    ${processGroupId}=  Create Process Group  nifi-api  ${headers_1}  ${headers_2}  Dummy-app
    Create Processor  nifi-api  ${headers_1}  ${processGroupId}
    Create Flow By Version Controlling  nifi-api  ${headers_1}  ${headers_2}  ${processGroupId}  Dummy-app
    Distribute The Flow  ${alias}  ${headers_1}  ${headers_2}  ${processGroupId}