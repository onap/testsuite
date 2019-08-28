*** Settings ***
Documentation     The main driver for instantiating a generic VNF
Test Teardown     Teardown Test

Library           OperatingSystem
Library           Process
Library           ArchiveLibrary
Library           Collections
Library           String
Library           DateTime
Library           ONAPLibrary.ServiceMapping    WITH NAME     ServiceMapping
Library           ONAPLibrary.Utilities
Resource          ../resources/test_templates/vnf_orchestration_test_template.robot
Resource          ../resources/test_templates/vnf_instantiation_ovp.robot
Resource          ../resources/global_properties.robot
Resource          ../resources/vvp_validation.robot

*** Variables ***
${OVP_BUILD_TAG}    vnf-validation-${GLOBAL_BUILD_NUMBER}
${OVP_VERSION}      2019.09
${VNF_CHKSUM}
${SDC_ASSETS_DIRECTORY}    ${GLOBAL_HEAT_TEMPLATES_FOLDER}

${BUILD_DIR}=    /tmp/vnfdata.${GLOBAL_BUILD_NUMBER}

*** Test Cases ***
VNF Instantiation
    [Documentation]    Instantiate Generic VNF
    [Tags]    instantiate_vnf_ovp
    [Timeout]    3000

    #### Executing VVP Validation Scripts ####
    Run VVP Validation Scripts    ${BUILD_DIR}    ${BUILD_DIR}/templates/    ${OUTPUTDIR}/summary

    #### Creating Runtime Service Mapping Data From Manifest ####
    ${new_vnf_name}=    Add Service Mapping

    #### Runtime Service Name ####
    ${new_vnf_service_name}=   Set Variable    ${new_vnf_name}_${GLOBAL_BUILD_NUMBER}
    
    #### Getting Manifest Data ####
    ${subscriber}=          Retrieve Manifest Data      subscriber
    ${service_type}=        Retrieve Manifest Data      service_type
    ${tenant_name}=         Retrieve Manifest Data      tenant_name
    ${region_id}=           Retrieve Manifest Data      region_id
    ${cloud_owner}=         Retrieve Manifest Data      cloud_owner
    ${project_name}=        Retrieve Manifest Data      project_name
    ${owning_entity}=       Retrieve Manifest Data      owning_entity
    ${platform}=            Retrieve Manifest Data      platform
    ${line_of_business}=    Retrieve Manifest Data      line_of_business
    ${api_type}=            Retrieve Manifest Data      api_type
    ${os_password}=         Retrieve Manifest Data      os_password

    #### Copying Heat Templates To Assett Directory ####
    Copy Files    ${BUILD_DIR}/templates/*    ${SDC_ASSETS_DIRECTORY}/${new_vnf_name}/

    Log    Modeling Service ${new_vnf_service_name}    console=yes
    ${catalog_service_name}    ${catalog_resource_name}    ${vf_modules}    ${catalog_resources}    ${catalog_resource_ids}    ${catalog_service_id}=    Model Distribution For Directory    ${new_vnf_name}    ${new_vnf_service_name}

    #### VID Stuff ####
    Log    Instantiating Service ${new_vnf_service_name}    console=yes
    ${vnf_details}=     Instantiate VNF    ${subscriber}    ${new_vnf_name}    ${service_type}    ${new_vnf_service_name}    ${catalog_service_name}    ${catalog_resource_name}    ${vf_modules}   ${catalog_resources}    ${service_type}    ${tenant_name}    ${region_id}    ${cloud_owner}     ${project_name}   ${owning_entity}    ${api_type}    platform=${platform}    line_of_business=${line_of_business}
    
    # sleeping after instantiation, seems to occasionally have some issues if running validation immediately
    Sleep    30

    Run VNF Instantiation Report    ${region_id}    ${vnf_details}    ${os_password}    ${new_vnf_name}

*** Keywords ***
Add Service Mapping
    [Documentation]    Adding service mapping for this VNF at runtime. This replicates service_mapping.json.
    ${json}=    OperatingSystem.Get File    ${BUILD_DIR}/vnf-details.json
    ${object}=    Evaluate    json.loads('''${json}''')    json

    ${vnf_name}=    Set Variable    ${object["vnf_name"]}

    ${module_list}=    Set Variable    ${object["modules"]}

    ${template_mapping_list}    Create List
    ${module_index}=     Set Variable    0

    :FOR     ${module}     IN     @{module_list}
    \   ${empty_dict}    Create Dictionary
    \   ${base}=    Set Variable    ${module["isBase"]}
    \   ${filename}=    Set Variable    ${module["filename"]}
    \   ${index}=    Set Variable If    '${base}'=='true'    0     ${module_index} + 1
    \   ${name}=    Remove String        ${filename}    .yaml    .yml
    \   ${preload}=    Set Variable    ${module["preload"]}
    \   set to dictionary    ${empty_dict}    isBase=${base}    template=""    vnf_index=${index}    name_pattern=${name}    preload_file=${preload}
    \   Append To List    ${template_mapping_list}    ${empty_dict}

    ${GLOBAL_SERVICE_TEMPLATE_MAPPING}    Create Dictionary
    ${GLOBAL_SERVICE_FOLDER_MAPPING}    Create Dictionary
    ${GLOBAL_SERVICE_VNF_MAPPING}    Create Dictionary
    ${GLOBAL_SERVICE_GEN_NEUTRON_NETWORK_MAPPING}    Create Dictionary
    ${GLOBAL_SERVICE_DEPLOYMENT_ARTIFACT_MAPPING}    Create Dictionary
    ${SERVICE_MAPPING}    Create Dictionary

    set to dictionary    ${GLOBAL_SERVICE_TEMPLATE_MAPPING}    ${vnf_name}=${template_mapping_list}

    ${folder_mapping_list}    Create List
    Append To List    ${folder_mapping_list}    ${vnf_name}
    set to dictionary    ${GLOBAL_SERVICE_FOLDER_MAPPING}    ${vnf_name}=${folder_mapping_list}

    ${service_mapping_list}    Create List
    Append To List    ${service_mapping_list}    ${vnf_name}
    set to dictionary    ${GLOBAL_SERVICE_VNF_MAPPING}    ${vnf_name}=${service_mapping_list}

    ${neutron_mapping_list}    Create List
    set to dictionary    ${GLOBAL_SERVICE_GEN_NEUTRON_NETWORK_MAPPING}    ${vnf_name}=${neutron_mapping_list}

    ${deployment_mapping_list}    Create List
    set to dictionary    ${GLOBAL_SERVICE_DEPLOYMENT_ARTIFACT_MAPPING}    ${vnf_name}=${deployment_mapping_list}

    set to dictionary    ${SERVICE_MAPPING}    GLOBAL_SERVICE_FOLDER_MAPPING=${GLOBAL_SERVICE_FOLDER_MAPPING}    GLOBAL_SERVICE_VNF_MAPPING=${GLOBAL_SERVICE_VNF_MAPPING}    GLOBAL_SERVICE_GEN_NEUTRON_NETWORK_MAPPING=${GLOBAL_SERVICE_GEN_NEUTRON_NETWORK_MAPPING}    GLOBAL_SERVICE_DEPLOYMENT_ARTIFACT_MAPPING=${GLOBAL_SERVICE_DEPLOYMENT_ARTIFACT_MAPPING}    GLOBAL_SERVICE_TEMPLATE_MAPPING=${GLOBAL_SERVICE_TEMPLATE_MAPPING}    GLOBAL_VALIDATE_NAME_MAPPING=

    ${json_string}=    evaluate    json.dumps(${SERVICE_MAPPING})    json
    OperatingSystem.Create File    ${GLOBAL_SERVICE_MAPPING_DIRECTORY}/${vnf_name}/service_mapping.json    ${json_string}    
    [Return]    ${vnf_name}

Retrieve Manifest Data
    [Arguments]     ${required_key}
    ${json}=        OperatingSystem.Get File    ${BUILD_DIR}/vnf-details.json
    ${object}=      Evaluate    json.loads('''${json}''')     json
    Dictionary Should Contain Key     ${object}     ${required_key}     msg=ERROR: key "${required_key}" not found in the manifest.
    [Return]        ${object["${required_key}"]}

Teardown Test
    Remove Directory    ${BUILD_DIR}    recursive=True
