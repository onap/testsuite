*** Settings ***

Library           RequestsLibrary
Resource          ../../resources/dcaemod_interface.robot


*** Variables ***

${SESSIONNAME}            nifi-api
${COMPONENT_SPEC_NAME}    dobre-dziewczyny

*** Testcases ***

Configuring DCAE mod
    [tags]              dcaemod
    [Documentation]


    ${session}=  Create Session   ${SESSIONNAME}  http://dcaemod.simpledemo.onap.org
    ${headers}=  Create Dictionary  content-type=application/json

    Onboard Component Spec  ${SESSIONNAME}  ${headers}
    Add Registry Client  ${SESSIONNAME}  ${headers}
    Add Distribution Target  ${SESSIONNAME}  ${headers}
    ${processGroupId}=  Create Process Group  ${SESSIONNAME}  ${headers}  ${COMPONENT_SPEC_NAME}
    Create Processor  ${SESSIONNAME}  ${headers}  ${processGroupId}
    Save Flow By Version Controlling  ${SESSIONNAME}  ${headers}  ${processGroupId}  ${COMPONENT_SPEC_NAME}
    Distribute The Flow  ${SESSIONNAME}  ${headers}  ${processGroupId}
    Deploy Blueprint From Inventory  ${COMPONENT_SPEC_NAME}_${COMPONENT_SPEC_NAME}  ${headers}