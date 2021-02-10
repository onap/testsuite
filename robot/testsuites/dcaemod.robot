*** Settings ***

Library           RequestsLibrary
Library           Collections
Library           OperatingSystem
Resource          ../../resources/dcaemod_interface.robot
Suite Setup       Usecase Setup
Suite Teardown    Usecase Teardown
Test Teardown     Test Teardown - Delete Process Group And Blueprint And Deployment


*** Variables ***

${CONFIG_MAP_FILE}                            /tmp/sample-config
${COMPSPEC_WITH_CONFIG_VOLUME}                dcaemod/compspec_with_config_volume.jinja
${COMPSPEC_WITHOUT_CONFIG_VOLUME}             dcaemod/compspec_without_config_volume.jinja

*** Test Cases ***

Deploy DCAE Simple Application Without Config Map In Config Spec Json
    [tags]              dcaemod

    ${dict_values} =  Create Dictionary  comp_spec_name=nginx1
    ${compSpecName} =  Set Variable  ${dict_values['comp_spec_name']}
    Set Test Variable  ${processGroupName}  nginx1

    Deploy DCAE Simple Application  ${COMPSPEC_WITHOUT_CONFIG_VOLUME}  ${dict_values}  ${compSpecName}  ${processGroupName}

Deploy DCAE Simple Application With Config Map In Config Spec Json But Not Present In K8s
    [tags]              dcaemod

     ${dict_values} =  Create Dictionary  comp_spec_name=nginx2
     ...                                  volume_mount_path=/opt/app/etc/config
     ...                                  config_map_name=test-config-volume
     ${compSpecName} =  Set Variable  ${dict_values['comp_spec_name']}
     ${volumeMountPath} =  Set Variable  ${dict_values['volume_mount_path']}
     ${configMapName} =  Set Variable  ${dict_values['config_map_name']}
     Set Test Variable  ${processGroupName}  nginx2

     Deploy DCAE Simple Application  ${COMPSPEC_WITH_CONFIG_VOLUME}  ${dict_values}  ${compSpecName}  ${processGroupName}
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
     ${configMapDir}  ${configMapFile} =  Split Path  ${CONFIG_MAP_FILE}

     Create File  ${CONFIG_MAP_FILE}  ${content}
     Create Config Map From File  ${configMapName}  ${CONFIG_MAP_FILE}
     Deploy DCAE Simple Application  ${COMPSPEC_WITH_CONFIG_VOLUME}  ${dict_values}  ${compSpecName}  ${processGroupName}
     Verify If Mounted Folder Contains File  ${compSpecName}  ${configMapFile}  ${volumeMountPath}
     Verify File Content  ${compSpecName}  ${volumeMountPath}/${CONFIG_MAP_FILE}  ${content}

    [Teardown]  Run Keywords  Test Teardown - Delete Process Group And Blueprint And Deployment  AND  Delete Config Map With Mounted Config File
