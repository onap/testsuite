*** Settings ***

Library           RequestsLibrary
Resource          ../../resources/dcaemod_interface.robot


*** Variables ***

${SESSION}         nifi-api

*** Testcases ***

Configuring DCAE mod
    [tags]              dcaemod
    [Documentation]


    ${session}=  Create Session   ${SESSION}  http://dcaemod.simpledemo.onap.org

    ${headers_1}=  Create Dictionary  content-type=application/json  Cache-Control=no-cache
    ${headers_2}=  Create Dictionary  content-type=application/json

    #Onboard Component Spec  nifi-api  ${headers_1}
    #Add Registry Client  ${SESSION}  ${headers_1}
    #Add Distribution Target  ${SESSION}  ${headers_1}
    ${processGroupId}=  Create Process Group  ${SESSION}  ${headers_1}  ${headers_2}  Dummy-app
    #Create Processor  ${SESSION}  ${headers_1}  ${processGroupId}
    #Create Flow By Version Controlling  ${SESSION}  ${headers_1}  ${headers_2}  ${processGroupId}  Dummy-app
    #Distribute The Flow  ${SESSION}  ${headers_1}  ${headers_2}  ${processGroupId}