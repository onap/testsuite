*** Settings ***

Library           RequestsLibrary
Resource          ../../resources/dcaemod_interface.robot
Suite Teardown    Usecase Teardown


*** Variables ***

${COMPONENT_SPEC_NAME}    dobre-dziewczyny

*** Testcases ***

Configuring DCAE mod
    [tags]              dcaemod
    [Documentation]


    Onboard Component Spec
    Add Registry Client
    Add Distribution Target
    Create Process Group  ${COMPONENT_SPEC_NAME}
    Create Processor
    Save Flow By Version Controlling  ${COMPONENT_SPEC_NAME}
    Distribute The Flow
    Deploy Blueprint From Inventory  ${COMPONENT_SPEC_NAME}_${COMPONENT_SPEC_NAME}