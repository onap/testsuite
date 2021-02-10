*** Settings ***

Library           RequestsLibrary
Library           Collections
Library           OperatingSystem
Resource          ../../resources/dcaemod_interface.robot
Suite Setup       Usecase Setup
Suite Teardown    Usecase Teardown
Test Teardown     Test Teardown - Delete Process Group And Blueprint And Deployment


*** Variables ***

${COMPSPEC_WITH_CONFIG_VOLUME}     dcaemod/compspec_with_config_volume.jinja
${COMPSPEC_WITHOUT_CONFIG_VOLUME}  dcaemod/compspec_without_config_volume.jinja
${IS_PROCESS_GROUP_SET}            False
${IS_FLOW_DISTRIBUTED}             False
${IS_SERVICE_DEPLOYED}             False
${PROCESS_GROUP_ID}                ${EMPTY}
${TYPE_ID}                         ${EMPTY}
${BLUEPRINT_NAME}                  ${EMPTY}
${CONFIG_MAP_FILE}                 /tmp/sample-config

*** Test Cases ***

Deploy DCAE Simple Application Without Config Map In Config Spec Json
   # [tags]              dcaemod

    ${dict_values} =  Create Dictionary  comp_spec_name=nginx1
    ${compSpecName} =  Set Variable  ${dict_values['comp_spec_name']}
    Set Test Variable  ${processGroupName}  nginx1

    Onboard Component Spec  ${COMPSPEC_WITHOUT_CONFIG_VOLUME}  ${dict_values}  ${compSpecName}
    ${processGroupId} =  Create Process Group  ${processGroupName}
    Set Suite Variable  ${IS_PROCESS_GROUP_SET}  True
    Set Suite Variable  ${PROCESS_GROUP_ID}  ${processGroupId}

    Create Processor  ${PROCESS_GROUP_ID}  ${compSpecName}
    Save Flow By Version Controlling  ${processGroupName}  ${PROCESS_GROUP_ID}
    Distribute The Flow  ${PROCESS_GROUP_ID}
    Set Suite Variable  ${IS_FLOW_DISTRIBUTED}  True

    ${typeId}  ${blueprintName} =  Deploy Blueprint From Inventory  ${processGroupName}  ${compSpecName}
    Set Suite Variable  ${IS_SERVICE_DEPLOYED}  True
    Set Suite Variable  ${TYPE_ID}  ${typeId}
    Set Suite Variable  ${BLUEPRINT_NAME}  ${blueprintName}

Deploy DCAE Simple Application With Config Map In Config Spec Json But Not Present In K8s
    #[tags]              dcaemod

     ${dict_values} =  Create Dictionary  comp_spec_name=nginxtc
     ...                                  volume_mount_path=/opt/app/etc/config
     ...                                  config_map_name=test-config-volume
     ${compSpecName} =  Set Variable  ${dict_values['comp_spec_name']}
     ${volumeMountPath} =  Set Variable  ${dict_values['volume_mount_path']}
     ${configMapName} =  Set Variable  ${dict_values['config_map_name']}
     Set Test Variable  ${processGroupName}  nginxtc

     Onboard Component Spec  ${COMPSPEC_WITH_CONFIG_VOLUME}  ${dict_values}  ${compSpecName}
     ${processGroupId} =  Create Process Group  ${processGroupName}
     Set Suite Variable  ${IS_PROCESS_GROUP_SET}  True
     Set Suite Variable  ${PROCESS_GROUP_ID}  ${processGroupId}

     Create Processor  ${PROCESS_GROUP_ID}  ${compSpecName}
     Save Flow By Version Controlling  ${processGroupName}  ${PROCESS_GROUP_ID}
     Distribute The Flow  ${PROCESS_GROUP_ID}
     Set Suite Variable  ${IS_FLOW_DISTRIBUTED}  True

     ${typeId}  ${blueprintName} =  Deploy Blueprint From Inventory  ${processGroupName}  ${compSpecName}
     Set Suite Variable  ${IS_SERVICE_DEPLOYED}  True
     Set Suite Variable  ${TYPE_ID}  ${typeId}
     Set Suite Variable  ${BLUEPRINT_NAME}  ${blueprintName}

     ${podYaml} =  Get Pod Yaml  ${compSpecName}
     Verify If Volume Is Mounted  ${podYaml}  ${volumeMountPath}
     Verify If Config Map Is Mounted As Volume  ${podYaml}  ${configMapName}
     ${mountedFolderContent} =  Get Content Of Mounted Folder Inside Container  ${compSpecName}  ${volumeMountPath}
     Verify If Mounted Folder Is Empty  ${mountedFolderContent}


Deploy DCAE Simple Application With Config Map In Config Spec Json AND Present In K8s
    [tags]              dcaemod

     ${dict_values} =  Create Dictionary  comp_spec_name=nginx3
     ...                                  volume_mount_path=/opt/app/etc/config
     ...                                  config_map_name=test-config-volume
     ${compSpecName} =  Set Variable  ${dict_values['comp_spec_name']}
     ${volumeMountPath} =  Set Variable  ${dict_values['volume_mount_path']}
     ${configMapName} =  Set Variable  ${dict_values['config_map_name']}
     Set Test Variable  ${CONFIG_MAP_NAME}  ${configMapName}
     Set Test Variable  ${processGroupName}  nginx3
     ${content} =  Set Variable  Hello, world!
     Create File  ${CONFIG_MAP_FILE}  ${content}
     Create Config Map From File  ${configMapName}  ${volumeMountPath}

     Onboard Component Spec  ${COMPSPEC_WITH_CONFIG_VOLUME}  ${dict_values}  ${compSpecName}

     ${processGroupId} =  Create Process Group  ${processGroupName}
     Set Suite Variable  ${IS_PROCESS_GROUP_SET}  True
     Set Suite Variable  ${PROCESS_GROUP_ID}  ${processGroupId}

     Create Processor  ${PROCESS_GROUP_ID}  ${compSpecName}
     Save Flow By Version Controlling  ${processGroupName}  ${PROCESS_GROUP_ID}
     Distribute The Flow  ${PROCESS_GROUP_ID}
     Set Suite Variable  ${IS_FLOW_DISTRIBUTED}  True

     ${typeId}  ${blueprintName} =  Deploy Blueprint From Inventory  ${processGroupName}  ${compSpecName}
     Set Suite Variable  ${IS_SERVICE_DEPLOYED}  True
     Set Suite Variable  ${TYPE_ID}  ${typeId}
     Set Suite Variable  ${BLUEPRINT_NAME}  ${blueprintName}

     ${configMapDir}  ${configMapFile} =  Split Path  ${CONFIG_MAP_FILE}
     Verify If Mounted Folder Contains File  ${compSpecName}  ${configMapFile}  ${configMapDir}
     Verify File Content  ${compSpecName}  ${CONFIG_MAP_FILE}  ${content}

    [Teardown]  Delete Config Map With Mounted Config Fie
