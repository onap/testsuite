*** Settings ***
Documentation     Testsuite for Modeling and Instantiating a VNF, for submission to the OVP Portal
Test Teardown     Write OVP Summary
Test Setup        Create OVP Summary

Library           OperatingSystem
Library           Process
Library           ArchiveLibrary
Library           Collections
Library           String
Library           DateTime
Library           ONAPLibrary.Utilities
Library           RequestsLibrary
Library           ONAPLibrary.ServiceMapping    WITH NAME     ServiceMapping
Library           ONAPLibrary.SDNC              WITH NAME     SDNC
Library           ONAPLibrary.SO                WITH NAME    SO

Resource          ../resources/vid/create_service_instance.robot
Resource          ../resources/vid/vid_interface.robot
Resource          ../resources/vid/create_vid_vnf.robot
Resource          ../resources/vid/teardown_vid.robot
Resource          ../resources/aai/service_instance.robot
Resource          ../resources/sdnc_interface.robot
Resource          ../resources/sdc_interface.robot
Resource          ../resources/test_templates/vnf_orchestration_test_template.robot
Resource          ../resources/global_properties.robot
Resource          ../resources/vvp_validation.robot


*** Variables ***
${OVP_BUILD_TAG}    vnf-validation-${GLOBAL_BUILD_NUMBER}
${OVP_VERSION}      2019.09

${SDC_ASSETS_DIRECTORY}    ${GLOBAL_HEAT_TEMPLATES_FOLDER}

${SDNC_REST_ENDPOINT}    ${GLOBAL_SDNC_SERVER_PROTOCOL}://${GLOBAL_INJECTED_SDNC_IP_ADDR}:${GLOBAL_SDNC_REST_PORT}

${SDNC_INDEX_PATH}    /restconf
${PRELOAD_VNF_TOPOLOGY_OPERATION_PATH}  /operations/VNF-API:preload-vnf-topology-operation
${PRELOAD_GR_TOPOLOGY_OPERATION_PATH}  /operations/GENERIC-RESOURCE-API:preload-vf-module-topology-operation 

${GR_API_PRELOAD_URI}    ${SDNC_INDEX_PATH}${PRELOAD_GR_TOPOLOGY_OPERATION_PATH}
${VNF_API_PRELOAD_URI}    ${SDNC_INDEX_PATH}${PRELOAD_VNF_TOPOLOGY_OPERATION_PATH}

${VID_ENDPOINT}    ${GLOBAL_VID_SERVER_PROTOCOL}://${GLOBAL_INJECTED_VID_IP_ADDR}:${GLOBAL_VID_SERVER_PORT}
${VID_LOGIN_URL}                ${VID_ENDPOINT}${VID_ENV}/login.htm
${VID_ENV}            /vid

${BUILD_DIR}=    /tmp/vnfdata.${GLOBAL_BUILD_NUMBER}


#***************** Test Case Variables *********************
${STACK_NAME}
${STACK_NAMES}
${SERVICE_INSTANCE_ID}

*** Test Cases ***
VNF Instantiation
    [Documentation]    Instantiate Generic VNF
    [Tags]    instantiate_vnf_ovp
    [Timeout]    3000

    #### Executing VVP Validation Scripts ####
    Set To Dictionary    ${VVP_TESTCASE_DICT}    result=IN_PROGRESS
    Set To Dictionary    ${VVP_TESTCASE_DICT}    portal_key_file=validation-scripts.json
    ${vvp_status}    ${__}=    Run Keyword And Ignore Error    Run VVP Validation Scripts    ${BUILD_DIR}/templates/
    Run Keyword If    '${vvp_status}' == 'PASS'
    ...  set to dictionary    ${VVP_TESTCASE_DICT}    result=PASS
    ...  ELSE
    ...  Fail Test    ${VVP_TESTCASE_DICT}

    Create Zip From Files In Directory    ${BUILD_DIR}/templates/    ${BUILD_DIR}/heat.zip
    ${result} =    Run Process    sha256sum     ${BUILD_DIR}/heat.zip
    @{sha} =    Split String    ${result.stdout}
    Set Global Variable    ${VNF_CHKSUM}    ${sha[0]}

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
    ${stack_validation_status}    ${__}=    Run Keyword And Ignore Error    Run VNF Instantiation Report    ${region_id}    ${vnf_details}    ${BUILD_DIR}    ${os_password}

    Run Keyword If    '${stack_validation_status}' == 'PASS'
    ...  set to dictionary    ${STACKVALIDATION_TESTCASE_DICT}    result=PASS
    ...  ELSE
    ...  Fail Test    ${STACKVALIDATION_TESTCASE_DICT}


*** Keywords ***
Instantiate VNF
    [Documentation]   Log into VID, create service instance, vnf instance, and module.
    [Arguments]    ${customer_name}    ${service}    ${service_type}    ${service_name}    ${service_model_type}    ${vnf_type}    ${vf_modules}   ${catalog_resources}    ${product_family}    ${tenant_name}    ${lcp_region}    ${cloud_owner}    ${project_name}   ${owning_entity}    ${api_type}    ${line_of_business}=LOB-Demonstration    ${platform}=Platform-Demonstration
    ${uuid}=    Generate UUID4
    ${list}=    Create List
    ${report_data}=    Create List
    Set Test Variable    ${STACK_NAMES}   ${list}
    Setup Browser
    Login To VID GUI With API Type    ${api_type}

    Log To Console    Creating ${service_name} in VID
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
    \   Log To Console    Creating VNF ${vnf_name} in VID
    \   Wait Until Keyword Succeeds    900s   5s    Create VNF Instance in VID    ${service_instance_id}    ${vnf_name}    ${product_family}    ${lcp_region}    ${tenant_name}    ${vnf_type}   ${CUSTOMER_NAME}    line_of_business=${line_of_business}    platform=${platform}    cloud_owner_uc=${cloud_owner}

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
    Append To List   ${STACK_NAMES}   ${vf_module_name}
    ${Module_name}=    Set Variable    
    ${api_type}=          Retrieve Manifest Data      api_type

    Create Preload    ${BUILD_DIR}/preloads/${preload_file}     ${api_type}    ${vf_module_name}     ${vf_module_type}    ${vnf_name}    ${generic_vnf_type}

    ${temp_dict_for_report}    Create Dictionary    stack_name=${vf_module_name}    template_name=${template_name}    preload_name=${preload_file}

    Log To Console    Creating ${vf_module_name} in  VID
    ${vf_module_id}=   Create VID VNF module VVP    ${service_instance_id}    ${vf_module_name}    ${lcp_region}    ${tenant_name}     ${vf_module_type}   ${customer_name}   ${vnf_name}    ${template_name}    cloud_owner_uc=${cloud_owner}
    [Return]    ${temp_dict_for_report}

Create VNF Instance in VID
    [Documentation]    Creates a VNF instance using VID for passed instance id with the passed service instance name.
    [Arguments]    ${service_instance_id}    ${service_instance_name}    ${product_family}    ${lcp_region}    ${tenant}   ${vnf_type}   ${customer}   ${line_of_business}=LOB-Demonstration   ${platform}=Platform-Demonstration    ${cloud_owner_uc}=CLOUDOWNER
    Go To VID HOME
    Click Link       xpath=//div[@heading = 'Search for Existing Service Instances']/a
    Wait Until Page Contains    Please search by    timeout=${GLOBAL_VID_UI_TIMEOUT_MEDIUM}

    # If we don't wait for this control to be enabled, the submit results in a 'not found' pop-up (UnexpectedAlertPresentException)
    Input Text When Enabled    //input[@name='selectedServiceInstance']    ${service_instance_id}
    Select From List By Label    //select[@ng-model='selectedserviceinstancetype']    Service Instance Id
    Select From List By Label    //select[@ng-model='selectedCustomer']    ${customer}
    Log To Console    Creating service instance ${service_instance_id} in VID
    Click On Button When Enabled    //button[contains(text(),'Submit')]
    Wait Until Page Contains Element    link=View/Edit    timeout=300s
    Click Element     xpath=//a[contains(text(), 'View/Edit')]
    Wait Until Page Contains    View/Edit Service Instance     timeout=300s
    # in slower environment the background load of data from AAI takes time so that the button is not populated yet
    Sleep   20s
    Log To Console    Adding node instance ${vnf_type} in VID
    Click On Button When Enabled    //button[contains(text(),'Add node instance')]
    Capture Page Screenshot
    #01681d02-2304-4c91-ab2d 0
    # This is where firefox breaks. Th elink never becomes visible when run with the script.
    ${dataTestsId}=    Catenate   AddVNFOption-${vnf_type}
    Sleep   10s
    Click Element    xpath=//a[contains(text(), '${vnf_type}')]
    Wait Until Page Contains Element    xpath=//input[@parameter-id='instanceName']    ${GLOBAL_VID_UI_TIMEOUT_MEDIUM}
    Wait Until Element Is Enabled    xpath=//input[@parameter-id='instanceName']    ${GLOBAL_VID_UI_TIMEOUT_MEDIUM}
    ## Without this sleep, the input text below gets immediately wiped out.
    ## Wait Until Angular Ready just sleeps for its timeout value
    Sleep    10s
    Input Text    xpath=//input[@parameter-id='instanceName']    ${service_instance_name}

    Select From List By Label     xpath=//select[@parameter-id='productFamily']    ${product_family}
    # Fix for Dublin
    Select From List By Label    xpath=//select[@parameter-id='lcpRegion']    ${lcp_region} (${cloud_owner_uc})

    Select From List By Label    xpath=//select[@parameter-id='tenant']    ${tenant}
    Select From List When Enabled   //select[@parameter-id='lineOfBusiness']    ${line_of_business}
    Select From List By Label    xpath=//select[@parameter-id='platform']    ${platform}
    Capture Page Screenshot
    Log To Console    Submitting VNF instance ${vnf_type} in VID
    Click On Button When Enabled    //button[contains(text(),'Confirm')]
    Wait Until Element Contains    xpath=//pre[@class = 'log ng-binding']    requestState    timeout=300s
    ${response text}=    Get Text    xpath=//pre[@class = 'log ng-binding']
    Should Not Contain    ${response text}    FAILED
    Click On Button When Enabled    //button[contains(text(),'Close')]
    ${instance_id}=    Parse Instance Id     ${response text}
    Wait Until Page Contains    ${service_instance_name}    timeout=300s
    [Return]     ${instance_id}


Create VID VNF module VVP
    [Documentation]   Overriding this function for now. Needed to parameterize the cloud_owner parameter and add volume support.

    [Arguments]    ${service_instance_id}    ${vf_module_name}    ${lcp_region}    ${TENANT}    ${VNF_TYPE}   ${customer}   ${vnf_name}    ${template_name}    ${cloud_owner_uc}=CLOUDOWNER
    Go To VID HOME
    Click Link       xpath=//div[@heading = 'Search for Existing Service Instances']/a
    Wait Until Page Contains    Please search by    timeout=${GLOBAL_VID_UI_TIMEOUT_MEDIUM}
    Wait Until Page Contains Element    xpath=//div[@class='statusLine aaiHidden']    timeout=${GLOBAL_VID_UI_TIMEOUT_MEDIUM}

     # If we don't wait for this control to be enabled, the submit results in a 'not found' pop-up (UnexpectedAlertPresentException)
    Input Text When Enabled    //input[@name='selectedServiceInstance']    ${service_instance_id}
    Select From List By Label    //select[@ng-model='selectedserviceinstancetype']    Service Instance Id
    Select From List By Label    //select[@ng-model='selectedCustomer']    ${customer}
    Click On Button When Enabled    //button[contains(text(),'Submit')]
    Wait Until Page Contains Element    link=View/Edit    timeout=${GLOBAL_VID_UI_TIMEOUT_MEDIUM}
    Click Element     link=View/Edit

    Wait Until Keyword Succeeds   300s   5s   Wait For Add VF Module
    
    ### Optionally checking if Volume Group option is there ###
    
    ## first checking if the VNF has ANY volume modules
    ${volume_status}   ${value}   Run Keyword And Ignore Error   Wait Until Element Is Visible    //button[contains(text(),'Add Volume Group')]   timeout=15s
    Run Keyword If   '${volume_status}' == 'PASS'    Click Element     xpath=//div[contains(.,'${vnf_name}')]/div/button[contains(.,'Add Volume Group')]
    
    ## now checking that this specific module has volumes
    ${volume_module_status}   ${value}   Run Keyword And Ignore Error   Wait Until Element Is Visible    link=${VNF_TYPE}   timeout=15s
    ${vf_module_volume_name}=    Remove String        ${template_name}    .yaml    .yml
    ${vf_module_volume_name}=    Set Variable If    '${volume_module_status}' == 'PASS'    ${vf_module_volume_name}_volume    None
    Run Keyword If   '${volume_module_status}' == 'PASS'    Log To Console    Volumes found for ${vf_module_name}
    Run Keyword If   '${volume_module_status}' == 'PASS'    Fill Module Form And Submit    ${vf_module_volume_name}    ${lcp_region}    ${TENANT}     ${VNF_TYPE}     cloud_owner_uc=${cloud_owner_uc}
    ## sleep to give VID a chance to update Volume Group
    Run Keyword If   '${volume_module_status}' == 'PASS'    Sleep     30s
    
    ### end volume stuff ###

    Log To Console    Instantiating heat template ${template_name}
    Click Element     xpath=//div[contains(.,'${vnf_name}')]/div/button[contains(.,'Add VF-Module')]
    ${instance_id}=     Fill Module Form And Submit    ${vf_module_name}    ${lcp_region}    ${TENANT}    ${VNF_TYPE}    cloud_owner_uc=${cloud_owner_uc}    volume_group=${vf_module_volume_name}
    [Return]     ${instance_id}    

Fill Module Form And Submit
    [Documentation]   Separating this so volume module can use as well.
    [Arguments]     ${vf_module_name}    ${lcp_region}     ${tenant}    ${vnf_type}    ${cloud_owner_uc}=CLOUDOWNER    ${volume_group}=None

    # This is where firefox breaks. Th elink never becomes visible when run with the script.
    Click Element    link=${vnf_type}
    Wait Until Page Contains Element    xpath=//input[@parameter-id='instanceName']    ${GLOBAL_VID_UI_TIMEOUT_SHORT}
    Wait Until Element Is Enabled    xpath=//input[@parameter-id='instanceName']    ${GLOBAL_VID_UI_TIMEOUT_SHORT}

    ## Without this sleep, the input text below gets immediately wiped out.
    ## Wait Until Angular Ready just sleeps for its timeout value
    Sleep    10s
    Input Text    xpath=//input[@parameter-id='instanceName']    ${vf_module_name}
    Select From List By Label    xpath=//select[@parameter-id='lcpRegion']    ${lcp_region} (${cloud_owner_uc})
    Select From List By Label    xpath=//select[@parameter-id='tenant']    ${tenant}

    ### Volume Stuff ###
    ${status}   ${value}   Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath=//select[@parameter-id='availableVolumeGroup']       15s
    Run Keyword If   '${status}' == 'PASS'    Select From List By Label    xpath=//select[@parameter-id='availableVolumeGroup']    ${volume_group}
    ### End Volume Stuff

    ${status}   ${value}   Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath=//input[@parameter-id='sdncPreload']       ${GLOBAL_VID_UI_TIMEOUT_SHORT}
    Run Keyword If   '${status}' == 'PASS'    Wait Until Element Is Enabled    xpath=//input[@parameter-id='sdncPreload']       ${GLOBAL_VID_UI_TIMEOUT_SHORT}
    Run Keyword If   '${status}' == 'PASS'    Select Checkbox    xpath=//input[@parameter-id='sdncPreload']
    Capture Page Screenshot
    Log To Console    Submitting vf module instance ${vf_module_name} in VID
    Click On Button When Enabled    //button[contains(text(),'Confirm')]
    Wait Until Element Contains    xpath=//pre[@class = 'log ng-binding']    requestState    timeout=300s
    ${response text}=    Get Text    xpath=//pre[@class = 'log ng-binding']
    Click On Button When Enabled    //button[contains(text(),'Close')]
    ${instance_id}=    Parse Instance Id     ${response text}

    ${request_id}=    Parse Request Id     ${response text}
    ${auth}=    Create List  ${GLOBAL_SO_USERNAME}    ${GLOBAL_SO_PASSWORD}
    ${resp}=    SO.Run Polling Get Request    ${GLOBAL_SO_ENDPOINT}    ${GLOBAL_SO_STATUS_PATH}${request_id}    auth=${auth}
    [Return]     ${instance_id}

Create Preload
    [Arguments]    ${preload_file}     ${api_type}    ${vf_module_name}     ${vf_module_type}    ${vnf_name}    ${generic_vnf_type}
    Log To Console    Uploading ${preload_file} to SDNC

    ${preload_vnf}=    Run keyword if  "${api_type}"=="gr_api"
    ...  Preload GR API    ${vf_module_name}     ${vf_module_type}    ${vnf_name}    ${generic_vnf_type}    ${preload_file}
    ...  ELSE
    ...  Preload VNF API    ${vf_module_name}     ${vf_module_type}    ${vnf_name}    ${generic_vnf_type}    ${preload_file}

    ${uri}=    Set Variable If     "${api_type}"=="gr_api"    ${GR_API_PRELOAD_URI}    ${VNF_API_PRELOAD_URI}

    ${post_resp}=    SDNC.Run Post Request   ${SDNC_REST_ENDPOINT}   ${uri}     data=${preload_vnf}    auth=${GLOBAL_SDNC_AUTHENTICATION}
    Should Be Equal As Strings    ${post_resp.json()['output']['response-code']}    200
    [Return]    ${post_resp}

Preload GR API
    [Documentation]   Retrieves a preload JSON file and fills in service instance values
    [Arguments]    ${vnf_name}     ${vnf_type}    ${generic_vnf_name}    ${generic_vnf_type}    ${preload_path}

    ${json}=    OperatingSystem.Get File    ${preload_path}
    ${object}=    Evaluate    json.loads('''${json}''')    json
    ${req_dict}    Create Dictionary    vnf-name=${generic_vnf_name}    vnf-type=${generic_vnf_type}
    set to dictionary    ${object["input"]["preload-vf-module-topology-information"]}    vnf-topology-identifier-structure=${req_dict}
    ${req_dict_new}    Create Dictionary    vf-module-name=${vnf_name}
    set to dictionary    ${object["input"]["preload-vf-module-topology-information"]["vf-module-topology"]}    vf-module-topology-identifier=${req_dict_new}
    ${req_json}    Evaluate    json.dumps(${object})    json
    [Return]    ${req_json}

Preload VNF API
    [Documentation]   Retrieves a preload JSON file and fills in service instance values
    [Arguments]    ${vnf_name}     ${vnf_type}    ${generic_vnf_name}    ${generic_vnf_type}    ${preload_path}
 
    ${json}=    OperatingSystem.Get File    ${preload_path}
    ${object}=    Evaluate    json.loads('''${json}''')    json
    ${req_dict}    Create Dictionary    vnf-name=${vnf_name}    vnf-type=${vnf_type}    generic-vnf-type=${generic_vnf_type}    generic-vnf-name=${generic_vnf_name}
    set to dictionary    ${object["input"]["vnf-topology-information"]}    vnf-topology-identifier=${req_dict}
 
    ${req_json}    Evaluate    json.dumps(${object})    json
    [Return]    ${req_json}

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

### OVP Package Creation ###
Create OVP Summary
    ${start_time} =             Get Current Date
    ${SUMMARY_DIRECTORY}=       Set Variable    ${OUTPUTDIR}/summary
    ${VNF_CHKSUM}=              Set Variable    ""
    Create Directory            ${SUMMARY_DIRECTORY}
    ${empty_list1}=             Create List
    ${empty_list2}=             Create List
    ${empty_list3}=             Create List

    ${VVP_TESTCASE_DICT}=    Create Dictionary
    Set To Dictionary    ${VVP_TESTCASE_DICT}                   objective=onap heat template validation
    Set To Dictionary    ${VVP_TESTCASE_DICT}                   sub_testcase=${empty_list1}
    Set To Dictionary    ${VVP_TESTCASE_DICT}                   mandatory=true
    Set To Dictionary    ${VVP_TESTCASE_DICT}                   name=onap-vvp.validate.heat
    Set To Dictionary    ${VVP_TESTCASE_DICT}                   result=NOT_STARTED

    ${INSTANTIATION_TESTCASE_DICT}=    Create Dictionary
    Set To Dictionary    ${INSTANTIATION_TESTCASE_DICT}         objective=onap vnf lifecycle validation
    Set To Dictionary    ${INSTANTIATION_TESTCASE_DICT}         sub_testcase=${empty_list2}
    Set To Dictionary    ${INSTANTIATION_TESTCASE_DICT}         mandatory=true
    Set To Dictionary    ${INSTANTIATION_TESTCASE_DICT}         name=onap-vvp.lifecycle_validate.heat
    Set To Dictionary    ${INSTANTIATION_TESTCASE_DICT}         result=NOT_STARTED
    Set To Dictionary    ${INSTANTIATION_TESTCASE_DICT}         portal_key_file=log.html

    ${STACKVALIDATION_TESTCASE_DICT}=    Create Dictionary
    Set To Dictionary    ${STACKVALIDATION_TESTCASE_DICT}       objective=onap vnf openstack validation
    Set To Dictionary    ${STACKVALIDATION_TESTCASE_DICT}       sub_testcase=${empty_list3}
    Set To Dictionary    ${STACKVALIDATION_TESTCASE_DICT}       mandatory=true
    Set To Dictionary    ${STACKVALIDATION_TESTCASE_DICT}       name=onap-vvp.openstack_validate.heat
    Set To Dictionary    ${STACKVALIDATION_TESTCASE_DICT}       result=NOT_STARTED

    Set Global Variable    ${VNF_CHKSUM}
    Set Global Variable    ${SUMMARY_DIRECTORY}
    Set Global Variable    ${VVP_TESTCASE_DICT}
    Set Global Variable    ${INSTANTIATION_TESTCASE_DICT}
    Set Global Variable    ${STACKVALIDATION_TESTCASE_DICT}
    Set Global Variable    ${start_time}

Fail Test
    [Arguments]    ${testcase}    ${subtest}=None

    set to dictionary    ${testcase}    result=FAIL
    Run Keyword If     ${subtest} != None    set to dictionary    ${subtest}    result=FAIL
    Run Keyword If     ${subtest} != None    Append To List    ${testcase["sub_testcase"]}    ${subtest}

    Fail    Testsuite failed

Write OVP Summary
    ${stop_time} =   Get Current Date
    ${diff_time} =   Subtract Date From Date     ${stop_time}     ${start_time}
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
### End OVP Package Creation ###

Login To VID GUI With API Type
    [Documentation]   Logs in to VID GUI.
    [Arguments]    ${api_type}=vnf_api
    # Setup Browser Now being managed by test case
    ##Setup Browser
    Go To    ${VID_LOGIN_URL}
    #Maximize Browser Window
    Set Selenium Speed    ${GLOBAL_SELENIUM_DELAY}
    Set Browser Implicit Wait    ${GLOBAL_SELENIUM_BROWSER_IMPLICIT_WAIT}
    Log    Logging in to ${VID_ENDPOINT}${VID_ENV}
    Title Should Be    Login
    Input Text    xpath=//input[@id='loginId']    ${GLOBAL_VID_USERNAME}
    Input Password    xpath=//input[@id='password']    ${GLOBAL_VID_PASSWORD}
    Click Button    xpath=//input[@id='loginBtn']
    Wait Until Page Contains  Welcome to VID    ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT}
    Run Keyword If    "${api_type}"=="vnf_api"    Select From List By Label    //select[@id='selectTestApi']    VNF_API (old)
    Run Keyword If    "${api_type}"=="gr_api"    Select From List By Label    //select[@id='selectTestApi']    GR_API (new)    
    Log    Logged in to ${VID_ENDPOINT}${VID_ENV}

Retrieve Manifest Data
    [Arguments]     ${required_key}
    ${json}=        OperatingSystem.Get File    ${BUILD_DIR}/vnf-details.json
    ${object}=      Evaluate    json.loads('''${json}''')     json
    Dictionary Should Contain Key     ${object}     ${required_key}     msg=ERROR: key "${required_key}" not found in the manifest.
    [Return]        ${object["${required_key}"]}
