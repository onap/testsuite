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
    Set Global Variable  ${IS_REGISTRY_CLIENT_SET}  True
    Add Distribution Target
    Set Global Variable  ${IS_DISTRIBUTION_TARGET_SET}  True
    ${processGroupId} =  Create Process Group  ${COMPONENT_SPEC_NAME}
    Set Global Variable  ${IS_PROCESS_GROUP_SET}  True
    Set Global Variable  ${PROCESS_GROP_ID}  ${processGroupId}
    Create Processor  ${processGroupId}
    Save Flow By Version Controlling  ${COMPONENT_SPEC_NAME}  ${processGroupId}
    Distribute The Flow  ${processGroupId}
    Set Global Variable  ${IS_FLOW_DISTRIBUTED_SET}  True
    Deploy Blueprint From Inventory  ${COMPONENT_SPEC_NAME}_${COMPONENT_SPEC_NAME}
    Set Global Variable  ${IS_BP_DEPLOYED_SET}  True