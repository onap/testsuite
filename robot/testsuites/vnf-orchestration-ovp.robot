*** Settings ***
Documentation     The main driver for instantiating a generic VNF
Test Teardown     Write OVP Summary
Test Setup        Create OVP Summary

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
    Set To Dictionary    ${VVP_TESTCASE_DICT}    result=IN_PROGRESS
    Set To Dictionary    ${VVP_TESTCASE_DICT}    portal_key_file=report.json
    ${vvp_status}    ${__}=    Run Keyword And Ignore Error    Run VVP Validation Scripts    ${BUILD_DIR}    ${BUILD_DIR}/templates/    ${OUTPUTDIR}/summary
    Run Keyword If    '${vvp_status}' == 'PASS'
    ...  set to dictionary    ${VVP_TESTCASE_DICT}    result=PASS
    ...  ELSE
    ...  Fail Test    ${VVP_TESTCASE_DICT}

    Create Zip From Files In Directory    ${BUILD_DIR}/templates/    ${BUILD_DIR}/heat.zip
    ${result} =    Run Process    sha256sum     ${BUILD_DIR}/heat.zip
    @{sha} =    Split String    ${result.stdout}
    Set Test Variable    ${VNF_CHKSUM}    ${sha[0]}

    Log To Console      Starting VNF Orchestration

    #### Creating Runtime Service Mapping Data From Manifest ####
    ${new_vnf_name}=    Add Service Mapping

    #### Runtime Service Name ####
    #${new_vnf_service_name}=   Set Variable    ${GLOBAL_BUILD_NUMBER}_${new_vnf_name}
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

    Log To Console      Executing VNF Orchestration With Parameters:
    Log To Console      VNF Name: ${new_vnf_name}
    Log To Console      VNF Name Runtime: ${new_vnf_service_name}
    Log To Console      API: ${api_type}
    Log To Console      Subscriber: ${subscriber}
    Log To Console      Service Type: ${service_type}
    Log To Console      Tenant Name: ${tenant_name}
    Log To Console      Region: ${region_id}
    Log To Console      Cloud Owner: ${cloud_owner}
    Log To Console      Project Name: ${project_name}
    Log To Console      Owning Entity: ${owning_entity}
    Log To Console      Platform: ${platform}
    Log To Console      Line Of Business: ${line_of_business}

    #### Copying Heat Templates To Assett Directory ####
    #### TODO These need to be deleted ####
    Copy Files    ${BUILD_DIR}/templates/*    ${SDC_ASSETS_DIRECTORY}/${new_vnf_name}/

    #### SDC Stuff ####
    ${model_and_distribute_testcase}=    Create Dictionary
    Set To Dictionary    ${model_and_distribute_testcase}    name=model-and-distribute
    Set To Dictionary    ${model_and_distribute_testcase}    result=IN_PROGRESS

    Log To Console    Starting Service Creation...
    ${sdc_status}    ${distribution_return}=    Run Keyword And Ignore Error    Model Distribution For Directory    ${new_vnf_name}    ${new_vnf_service_name}
    
    Run Keyword If    '${sdc_status}' == 'PASS'
    ...  set to dictionary    ${model_and_distribute_testcase}    result=PASS
    ...  ELSE
    ...  Fail Test    ${INSTANTIATION_TESTCASE_DICT}    ${model_and_distribute_testcase}
    Append To List    ${INSTANTIATION_TESTCASE_DICT["sub_testcase"]}    ${model_and_distribute_testcase}


    ${catalog_service_name}=     Get From List    ${distribution_return}     0
    ${catalog_resource_name}=    Get From List    ${distribution_return}     1
    ${vf_modules}=               Get From List    ${distribution_return}     2   
    ${catalog_resources}=        Get From List    ${distribution_return}     3    
    ${catalog_resource_ids}=     Get From List    ${distribution_return}     4
    ${catalog_service_id}=       Get From List    ${distribution_return}     5

    #### VID Stuff ####
    Log To Console    Starting VID Instantiation

    ${instantiate_testcase}=    Create Dictionary
    Set To Dictionary    ${instantiate_testcase}    name=instantiation
    Set To Dictionary    ${instantiate_testcase}    result=IN_PROGRESS
    ${vid_status}    ${vnf_details}=    Run Keyword And Ignore Error     Instantiate VNF    ${subscriber}    ${new_vnf_name}    ${service_type}    ${new_vnf_service_name}    ${catalog_service_name}    ${catalog_resource_name}    ${vf_modules}   ${catalog_resources}    ${service_type}    ${tenant_name}    ${region_id}    ${cloud_owner}     ${project_name}   ${owning_entity}    ${api_type}    platform=${platform}    line_of_business=${line_of_business}
    
    Run Keyword If    '${vid_status}' == 'PASS'
    ...  set to dictionary    ${instantiate_testcase}    result=PASS
    ...  ELSE
    ...  Fail Test    ${INSTANTIATION_TESTCASE_DICT}    ${instantiate_testcase}
    Append To List    ${INSTANTIATION_TESTCASE_DICT["sub_testcase"]}    ${instantiate_testcase}

    set to dictionary    ${INSTANTIATION_TESTCASE_DICT}    result=PASS

    # sleeping after instantiation, seems to occasionally have some issues if running validation immediately
    Log To Console    Sleeping for 30 seconds
    Sleep    30

    #### Heat Stack Validation ####
    ${stack_validation_testcase}=    Create Dictionary
    Set To Dictionary    ${STACKVALIDATION_TESTCASE_DICT}    name=stack_validation
    Set To Dictionary    ${STACKVALIDATION_TESTCASE_DICT}    result=IN_PROGRESS
    Set To Dictionary    ${STACKVALIDATION_TESTCASE_DICT}    portal_key_file=stack_report.json
    ${stack_validation_status}    ${__}=    Run Keyword And Ignore Error    Run VNF Instantiation Report    ${region_id}    ${vnf_details}    ${os_password}    ${new_vnf_name}

    Run Keyword If    '${stack_validation_status}' == 'PASS'
    ...  set to dictionary    ${STACKVALIDATION_TESTCASE_DICT}    result=PASS
    ...  ELSE
    ...  Fail Test    ${STACKVALIDATION_TESTCASE_DICT}

*** Keywords ***
Add Service Mapping
    [Documentation]    Adding service mapping for this VNF at runtime. This replicates service_mapping.json.
    ${json}=    OperatingSystem.Get File    ${BUILD_DIR}/vnf-details.json
    ${object}=    Evaluate    json.loads('''${json}''')    json

    ${vnf_name}=    Set Variable    ${object["vnf_name"]}

    ${module_list}=    Set Variable    ${object["modules"]}
    Log To Console    ${module_list}
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

Create OVP Summary
    ${SUMMARY_DIRECTORY}=                Set Variable    ${OUTPUTDIR}/summary
    ${START_TIME}=                       Get Current Date
    ${VVP_TESTCASE_DICT}=                Create Dictionary
    ${INSTANTIATION_TESTCASE_DICT}=      Create Dictionary
    ${STACKVALIDATION_TESTCASE_DICT}=    Create Dictionary
    ${empty_list1}=                      Create List
    ${empty_list2}=                      Create List
    ${empty_list3}=                      Create List

    Set To Dictionary    ${VVP_TESTCASE_DICT}                   objective=onap heat template validation
    Set To Dictionary    ${VVP_TESTCASE_DICT}                   sub_testcase=${empty_list1}
    Set To Dictionary    ${VVP_TESTCASE_DICT}                   mandatory=true
    Set To Dictionary    ${VVP_TESTCASE_DICT}                   name=onap-vvp.validate.heat
    Set To Dictionary    ${VVP_TESTCASE_DICT}                   result=NOT_STARTED

    Set To Dictionary    ${INSTANTIATION_TESTCASE_DICT}         objective=onap vnf lifecycle validation
    Set To Dictionary    ${INSTANTIATION_TESTCASE_DICT}         sub_testcase=${empty_list2}
    Set To Dictionary    ${INSTANTIATION_TESTCASE_DICT}         mandatory=true
    Set To Dictionary    ${INSTANTIATION_TESTCASE_DICT}         name=onap-vvp.lifecycle_validate.heat
    Set To Dictionary    ${INSTANTIATION_TESTCASE_DICT}         result=NOT_STARTED
    Set To Dictionary    ${INSTANTIATION_TESTCASE_DICT}         portal_key_file=log.html

    Set To Dictionary    ${STACKVALIDATION_TESTCASE_DICT}       objective=onap vnf openstack validation
    Set To Dictionary    ${STACKVALIDATION_TESTCASE_DICT}       sub_testcase=${empty_list3}
    Set To Dictionary    ${STACKVALIDATION_TESTCASE_DICT}       mandatory=true
    Set To Dictionary    ${STACKVALIDATION_TESTCASE_DICT}       name=onap-vvp.openstack_validate.heat
    Set To Dictionary    ${STACKVALIDATION_TESTCASE_DICT}       result=NOT_STARTED

    Create Directory                     ${SUMMARY_DIRECTORY}

    Set Test Variable                    ${START_TIME}
    Set Test Variable                    ${SUMMARY_DIRECTORY}
    Set Test Variable                    ${VVP_TESTCASE_DICT}
    Set Test Variable                    ${INSTANTIATION_TESTCASE_DICT}
    Set Test Variable                    ${STACKVALIDATION_TESTCASE_DICT}

Fail Test
    [Arguments]    ${testcase}    ${subtest}=None

    set to dictionary    ${testcase}    result=FAIL
    Run Keyword If     ${subtest} != None    set to dictionary    ${subtest}    result=FAIL
    Run Keyword If     ${subtest} != None    Append To List    ${testcase["sub_testcase"]}    ${subtest}

    Fail    Testsuite failed

Write OVP Summary
    ${stop_time} =   Get Current Date
    ${diff_time} =   Subtract Date From Date     ${stop_time}     ${START_TIME}
    ${output_dict}=    Create Dictionary

    ${testcase_list}=    Create List
    Append To List    ${testcase_list}    ${VVP_TESTCASE_DICT}
    Append To List    ${testcase_list}    ${INSTANTIATION_TESTCASE_DICT}
    Append To List    ${testcase_list}    ${STACKVALIDATION_TESTCASE_DICT}

    Set To Dictionary    ${output_dict}    testcases_list=${testcase_list}
    Set To Dictionary    ${output_dict}    version=${OVP_VERSION}
    Set To Dictionary    ${output_dict}    build_tag=${OVP_BUILD_TAG}
    Set To Dictionary    ${output_dict}    test_date=${start_time}
    Set To Dictionary    ${output_dict}    duration=${diff_time}
    Set To Dictionary    ${output_dict}    vnf_type=heat
    Set To Dictionary    ${output_dict}    vnf_checksum=${VNF_CHKSUM}

    ${json_string}=    evaluate    json.dumps(${output_dict}, indent=4)    json
    OperatingSystem.Create File    ${SUMMARY_DIRECTORY}/results.json    content=${json_string}

    Remove Directory    ${BUILD_DIR}    recursive=True
