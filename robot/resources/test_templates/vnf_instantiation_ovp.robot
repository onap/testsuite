*** Settings ***
Documentation   This test can be used for an arbitrary VNF.
Resource        ../vid/vid_interface.robot
Resource        ../vid/create_vid_vnf.robot
Resource        ../sdnc_interface.robot

Library         ONAPLibrary.Openstack
Library         SeleniumLibrary
Library         Collections
Library         ONAPLibrary.Utilities
Library         ONAPLibrary.JSON
Library         ONAPLibrary.ServiceMapping    WITH NAME    ServiceMapping

*** Keywords ***
Instantiate VNF
    [Documentation]   Log into VID, create service instance, vnf instance, and module. This handles an arbitrary, single VNF service w/ volume modules.
    [Arguments]    ${customer_name}    ${service}    ${service_type}    ${service_name}    ${service_model_type}    ${vnf_type}    ${vf_modules}   ${catalog_resources}    ${product_family}    ${tenant_name}    ${lcp_region}    ${cloud_owner}    ${project_name}   ${owning_entity}    ${api_type}    ${line_of_business}=LOB-Demonstration    ${platform}=Platform-Demonstration
    ${uuid}=    Generate UUID4
    ${list}=    Create List
    ${report_data}=    Create List
    Setup Browser
    Login To VID GUI    api_type=${api_type}

    Log    Creating ${service_name} in VID    console=yes
    ${service_instance_id}=   Wait Until Keyword Succeeds    900s   5s    Create VID Service Instance    ${customer_name}   ${service_model_type}    ${service_type}     ${service_name}   ${project_name}   ${owning_entity}

    Validate Service Instance    ${service_instance_id}    ${service_type}     ${customer_name}
    ServiceMapping.Set Directory    default    ${GLOBAL_SERVICE_MAPPING_DIRECTORY}
    ${vnflist}=    ServiceMapping.Get Service Vnf Mapping    default    ${service}
    ${vnf_name_index}=   Set Variable  0
    ${vf_module_name_list}=    Create List
    ${uuid}=    Evaluate    str("${uuid}")[:8]

    ##### INSTANTIATING VNF IN VID #####
    :FOR   ${vnf}   IN   @{vnflist}
    # APPC max is 50 characters
    \   ${vnf_name}=    Catenate    Ete_${vnf}_${uuid}_${vnf_name_index}
    \   ${generic_vnf_type}=    Set Variable    ${service_name}/${vnf_type} ${vnf_name_index}
    \   ${vnf_name_index}=   Evaluate   ${vnf_name_index} + 1
    \   Log    Creating VNF ${vnf_name} in VID    console=yes
    \   Wait Until Keyword Succeeds    900s   5s    Create VID VNF    ${service_instance_id}    ${vnf_name}    ${product_family}    ${lcp_region}    ${tenant_name}    ${vnf_type}   ${CUSTOMER_NAME}    line_of_business=${line_of_business}    platform=${platform}    cloud_owner_uc=${cloud_owner}

    #### Calling Keyword To Create Each Module ####
    \   ${report_data}=    Loop and Create Modules in VID    ${vf_modules}    ${vnf_name}    ${generic_vnf_type}    ${service_instance_id}    ${lcp_region}    ${tenant_name}    ${cloud_owner}    ${customer_name}    ${vnf}    ${catalog_resources}

    [Return]     ${report_data}

Loop and Create Modules in VID
    [Documentation]    Loops through the VF modules in a VNF and instantiates in VID
    [Arguments]    ${vf_modules}    ${vnf_name}    ${generic_vnf_type}    ${service_instance_id}    ${lcp_region}    ${tenant_name}    ${cloud_owner}    ${customer_name}    ${vnf}    ${resources}
    ${temp_list_for_report}    Create List

    ### Base Module
    :FOR    ${module}    IN      @{vf_modules}
    \       ${vf_module_type}=    Get From Dictionary    ${module}    name
    \       ${template_name}=    Get Heat Template Name From Catalog Resource    ${resources}    ${vnf}    ${vf_module_type}
    \       ${preload_file}    ${isBase}=    Retrieve Module Preload and isBase    ${template_name}
    \       ${temp_dict_for_report} =    Run Keyword If    "${isBase}"=="true"    Create Module in VID    ${vnf_name}    ${template_name}    ${vf_module_type}    ${generic_vnf_type}    ${preload_file}    ${service_instance_id}    ${lcp_region}    ${tenant_name}    ${customer_name}    ${cloud_owner}
    \       Run Keyword If    "${isBase}"=="true"    Append To List    ${temp_list_for_report}    ${temp_dict_for_report}

    ### Incremental Modules
    :FOR    ${module}    IN      @{vf_modules}
    \       ${vf_module_type}=    Get From Dictionary    ${module}    name
    \       ${template_name}=    Get Heat Template Name From Catalog Resource    ${resources}    ${vnf}    ${vf_module_type}
    \       ${preload_file}    ${isBase}=    Retrieve Module Preload and isBase    ${template_name}
    \       ${temp_dict_for_report} =    Run Keyword If    "${isBase}"=="false"    Create Module in VID    ${vnf_name}    ${template_name}    ${vf_module_type}    ${generic_vnf_type}    ${preload_file}    ${service_instance_id}    ${lcp_region}    ${tenant_name}    ${customer_name}    ${cloud_owner}
    \       Run Keyword If    "${isBase}"=="false"    Append To List    ${temp_list_for_report}    ${temp_dict_for_report}

    [Return]     ${temp_list_for_report}

Create Module in VID
    [Arguments]    ${vnf_name}    ${template_name}    ${vf_module_type}    ${generic_vnf_type}    ${preload_file}    ${service_instance_id}    ${lcp_region}    ${tenant_name}    ${customer_name}    ${cloud_owner}

    ${vf_module_name}=    Catenate    Vfmodule_${vnf_name}_${template_name}
    ${vf_module_name}=    Remove String        ${vf_module_name}    .yaml    .yml
    ${Module_name}=    Set Variable
    ${api_type}=          Retrieve Manifest Data      api_type

    Create Preload From JSON    ${BUILD_DIR}/preloads/${preload_file}     ${api_type}    ${vf_module_name}     ${vf_module_type}    ${vnf_name}    ${generic_vnf_type}

    ${temp_dict_for_report}    Create Dictionary    stack_name=${vf_module_name}    template_name=${BUILD_DIR}/templates/${template_name}    preload_name=${BUILD_DIR}/preloads/${preload_file}

    Log    Creating ${vf_module_name} in VID    console=yes
    ${vf_module_id}=   Create VID VNF module    ${service_instance_id}    ${vf_module_name}    ${lcp_region}    ${tenant_name}     ${vf_module_type}   ${customer_name}   ${vnf_name}    cloud_owner_uc=${cloud_owner}
    [Return]    ${temp_dict_for_report}

Retrieve Module Preload and isBase
    [Arguments]    ${file_name}
    ${json}=        OperatingSystem.Get File    ${BUILD_DIR}/vnf-details.json
    ${object}=      Evaluate    json.loads('''${json}''')    json
    :FOR   ${vnf}   IN   @{object["modules"]}
    \    ${module_present}=     set variable    True
    \    ${file_name_m}=        set variable    ${vnf["filename"]}
    \    ${preload_name}=       set variable if    '${file_name_m}' == '${file_name}'    ${vnf["preload"]}
    \    ${isBase}=             set variable if    '${file_name_m}' == '${file_name}'    ${vnf["isBase"]}
    \    Exit For Loop If       '${file_name_m}' == '${file_name}'
    \    ${module_present}=     set variable    False
    Return From Keyword If      ${module_present}==True    ${preload_name}    ${isBase}
    Fail    msg=ERROR: A module with the file name: ${file_name} is not present.

##### Getting The Heat Template Name From the Module ID, using the catalog data #####
Get Heat Template Name From Catalog Resource
    [Documentation]    Searching through the catalog resources looking for the heat template name
    [Arguments]   ${resources}   ${vnf}    ${module_id}

    ${keys}=    Get Dictionary Keys    ${resources}
    ${artifact_ids}=    Get Artifact IDs From CSAR    ${resources}   ${vnf}    ${module_id}

    :FOR   ${key}   IN    @{keys}
    \    ${cr}=   Get From Dictionary    ${resources}    ${key}
    \    ${artifacts}=    Set Variable    ${cr['allArtifacts']}
    \    ${artifactName}=    Get Artifact Name From Artifacts    ${artifacts}    ${artifact_ids}
    \    Return From Keyword If    "${artifactName}" != "NOTFOUND"    ${artifactName}

Get Artifact Name From Artifacts
    [Arguments]   ${artifacts}    ${artifact_ids}

    ${keys}=    Get Dictionary Keys    ${artifacts}

    :FOR    ${key}     IN     @{keys}
    \       ${artifact}=    Get From Dictionary    ${artifacts}    ${key}
    \       ${artifactType}=    Get From Dictionary    ${artifact}    artifactType
    \       ${csar_id}=    Set Variable    ''
    \       ${csar_id}=    Run Keyword If    "${artifactType}"=="HEAT"   Get From Dictionary    ${artifact}    artifactUUID
    \       ${artifactName}=    Run Keyword If    $csar_id in $artifact_ids    Get From Dictionary    ${artifact}    artifactName
    \       Return From Keyword If    $csar_id in $artifact_ids    ${artifactName}

    [Return]    NOTFOUND

Get Artifact IDs From CSAR
    [Documentation]    Looking for the artifact ID for a given module
    [Arguments]   ${resources}   ${vnf}    ${module_id}

    ${keys}=    Get Dictionary Keys    ${resources}

    :FOR   ${key}   IN    @{keys}
    \    ${cr}=   Get From Dictionary    ${resources}    ${key}
    \    ${groups}=    Set Variable    ${cr['groups']}
    \    ${artifact_ids}=    Get Artifact IDs From Module    ${groups}    ${module_id}
    \    Return From Keyword If    ${artifact_ids} is not None    ${artifact_ids}

    ${empty_list}=    Create List

    [Return]    ${empty_list}

Get Artifact IDs From Module
    [Arguments]    ${groups}    ${module_id}

    :FOR    ${group}     IN     @{groups}
    \       ${invariant_name}=    Get From Dictionary    ${group}    invariantName
    \       ${artifact_ids}=    Create List
    \       ${artifact_ids}=    Run Keyword If    "${invariant_name}"== "${module_id}"    Get From Dictionary    ${group}    artifactsUuid
    \       Return From Keyword If    ${artifact_ids} is not None    ${artifact_ids}

    ${empty_list}=    Create List

    [Return]    ${empty_list}
##### End of catalog manipulation #####
