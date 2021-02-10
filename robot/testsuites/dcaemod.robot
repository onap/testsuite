*** Settings ***

Library           RequestsLibrary
Library           Collections
Resource          ../../resources/dcaemod_interface.robot
Suite Teardown    Usecase Teardown


*** Variables ***

${PROCESS_GROUP_NAME}              dobre-dziewczyny
${COMPSPEC_WITH_CONFIG_VOLUME}     dcaemod/compspec_with_config_volume.jinja
${COMPSPEC_WITHOUT_CONFIG_VOLUME}  dcaemod/compspec_without_config_volume.jinja
*** Testcases ***

Deploy DCAE Simple Application Without Config Map In Config Spec Json
    [tags]              dcaemod
    [Documentation]

    ${dict_values} =  Create Dictionary  name=Withoutcv
    Onboard Component Spec  ${COMPSPEC_WITHOUT_CONFIG_VOLUME}  ${dict_values}
    Add Registry Client
    Set Global Variable  ${IS_REGISTRY_CLIENT_SET}  True
    Add Distribution Target
    Set Global Variable  ${IS_DISTRIBUTION_TARGET_SET}  True
    ${processGroupId} =  Create Process Group  ${PROCESS_GROUP_NAME}
    Set Global Variable  ${IS_PROCESS_GROUP_SET}  True
    Set Global Variable  ${PROCESS_GROUP_ID}  ${processGroupId}
    Create Processor  ${processGroupId}
    Save Flow By Version Controlling  ${PROCESS_GROUP_NAME}  ${processGroupId}
    Distribute The Flow  ${processGroupId}
    Set Global Variable  ${IS_FLOW_DISTRIBUTED_SET}  True
    ${typeId}  ${blueprintName} =  Deploy Blueprint From Inventory  ${PROCESS_GROUP_NAME}
    Set Global Variable  ${SERVICE_TYPE_ID}  ${typeId}
    Set Global Variable  ${BLUEPRINT_NAME}  ${blueprintName}
    Set Global Variable  ${IS_BP_DEPLOYED_SET}  True

Deploy DCAE Simple Application With Config Map In Config Spec Json But Not Present In K8s
    [tags]              dcaemod

     ${dict_values} =  Create Dictionary  name=Withcv
     Onboard Component Spec  ${COMPSPEC_WITH_CONFIG_VOLUME}  ${dict_values}

