*** Settings ***

Library           RequestsLibrary
Library           Collections
Resource          ../../resources/dcaemod_interface.robot
Suite Setup       Usecase Setup
Suite Teardown    Usecase Teardown
Test Teardown     Specific Teardown


*** Variables ***

${COMPSPEC_WITH_CONFIG_VOLUME}     dcaemod/compspec_with_config_volume.jinja
${COMPSPEC_WITHOUT_CONFIG_VOLUME}  dcaemod/compspec_without_config_volume.jinja

*** Testcases ***

Deploy DCAE Simple Application Without Config Map In Config Spec Json
    [tags]              dcaemod
    [Documentation]

    ${dict_values} =  Create Dictionary  comp_spec_name=lala
    ${compSpecName} =  Set Variable  ${dict_values['comp_spec_name']}
    Set Test Variable  ${processGroupName}  app

    Onboard Component Spec  ${COMPSPEC_WITHOUT_CONFIG_VOLUME}  ${dict_values}  ${compSpecName}
    ${processGroupId} =  Create Process Group  ${processGroupName}
    Set Suite Variable  ${IS_PROCESS_GROUP_SET}  True
    Set Suite Variable  ${PROCESS_GROUP_ID}  ${processGroupId}

    Create Processor  ${processGroupId}  ${compSpecName}
    Save Flow By Version Controlling  ${processGroupName}  ${processGroupId}
    Distribute The Flow  ${processGroupId}
    Set Suite Variable  ${IS_FLOW_DISTRIBUTED}  True

    ${typeId}  ${blueprintName} =  Deploy Blueprint From Inventory  ${processGroupName}  ${compSpecName}
    Set Suite Variable  ${IS_SERVICE_DEPLOYED}  True
    Set Suite Variable  ${TYPE_ID}  ${typeId}
    Set Suite Variable  ${BLUEPRINT_NAME}  ${blueprintName}


Deploy DCAE Simple Application With Config Map In Config Spec Json But Not Present In K8s
    #[tags]              dcaemod

     ${dict_values} =  Create Dictionary  comp_spec_name=Withcv
     ...                                  volume_mount_path=/opt/app/etc/config
     ...                                  volume_name=test_config_volume
     ${compSpecName} =  Set Variable  ${dict_values['comp_spec_name']}
     ${volumeMountPath} =  Set Variable  ${dict_values['volume_mount_path']}
     ${volumeName} =  Set Variable  ${dict_values['volume_name']}

     Onboard Component Spec  ${COMPSPEC_WITH_CONFIG_VOLUME}  ${dict_values}  ${compSpecName}

     ${processGroupId} =  Create Process Group  Sylwia12
     Set Test Variable  ${is_process_group_set}  True
     Create Processor  ${processGroupId}  ${compSpecName}
     Save Flow By Version Controlling  Sylwia12  ${processGroupId}
     Distribute The Flow  ${processGroupId}
     Set Test Variable  ${is_flow_distributed_set}  True
     ${typeId}  ${blueprintName} =  Deploy Blueprint From Inventory  Sylwia12  ${compSpecName}
     Set Test Variable  ${is_bp_deployed_set}  True

    ${podYaml} =  Get Pod Yaml  ${compSpecName}
    Verify If Volume Is Mounted  ${podYaml}  ${volumeMountPath}  ${volumeName}
    Verify If Config Map Is Mounted As Volume  ${podYaml}  ${volumeName}
    ${mountedFolderContent} =  Get Content Of Mounted Folder Inside Container  ${compSpecName}  ${volumeMountPath}
    Verify If Mounted Folder Is Empty  ${mountedFolderContent}


Deploy DCAE Simple Application With Config Map In Config Spec Json AND Present In K8s
    #[tags]              dcaemod

     ${dict_values} =  Create Dictionary  name=Withcv
     ${compSpecName} =  Set Variable  ${dict_values['name']}
     Onboard Component Spec  ${COMPSPEC_WITH_CONFIG_VOLUME}  ${dict_values}  ${compSpecName}

     ${processGroupId} =  Create Process Group  Sylwia12
     Set Test Variable  ${is_process_group_set}  True
     Create Processor  ${processGroupId}  ${compSpecName}
     Save Flow By Version Controlling  Sylwia12  ${processGroupId}
     Distribute The Flow  ${processGroupId}
     Set Test Variable  ${is_flow_distributed_set}  True
     ${typeId}  ${blueprintName} =  Deploy Blueprint From Inventory  Sylwia12  ${compSpecName}
     Set Test Variable  ${is_bp_deployed_set}  True

