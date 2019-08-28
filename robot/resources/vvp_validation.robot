*** Settings ***
Documentation     The main interface for interacting with SDC. It handles low level stuff like managing the http request library and DCAE required fields
Library           OperatingSystem
Library           ONAPLibrary.SO    WITH NAME    SO
Library           ONAPLibrary.HeatStackValidation    WITH NAME    HeatStackValidation

*** Variables ***
${VVP_REPO_URL}             https://gerrit.onap.org/r/vvp/validation-scripts
${VVP_REPO_BRANCH}          master

${VALIDATION_DIRECTORY}     /tmp/vnf_instantiation_report
${CLOUD_CONFIG_PATH}        /cloudSite

*** Keywords ***
Run VVP Validation Scripts
    [Arguments]    ${heat_template_directory}
    ${result} =    Run Process    pip3    install    virtualenv
    Log To Console    install virtualenv output: ${result.stderr}
    Log To Console    ${result.stdout}
    ${result} =    Run Process    virtualenv    -p    python3.7    testEnv
    Log To Console    install create Virtualenv output: ${result.stderr}
    Log To Console    ${result.stdout}
    ${result} =    Run Process    git    clone    -b     ${VVP_REPO_BRANCH}    ${VVP_REPO_URL}    vvp-validation-scripts
    Log To Console    git clone output: ${result.stderr}
    Log To Console    ${result.stdout}
    ${rc}   ${output}=    Run And Return Rc And Output    . testEnv/bin/activate; pip install -r vvp-validation-scripts/requirements.txt; cd vvp-validation-scripts/ice_validator/; pytest tests/ --template-directory=${heat_template_directory}
    Log To Console    validation scripts output: ${rc}
    Log To Console    ${output}
    Copy File    vvp-validation-scripts/ice_validator/output/report.json    ${summary_directory}/validation-scripts.json
    ${result} =    Run Process    rm    -rf    vvp-validation-scripts
    Log To Console    deleting vvp-validation-scripts.. ${result.stderr}
    Log To Console    ${result.stdout}
    ${result} =    Run Process    rm    -rf    testEnv
    Log To Console    deleting the test environment.. ${result.stderr}
    Log To Console    ${result.stdout}
    Run keyword if    ${rc} != 0    Fail    msg= VVP validation failed. Please correct the VNF templates.

Create Report Manifest Data
    [Arguments]    ${list_of_info}    ${BUILD_DIR}
    ${json}=    OperatingSystem.Get file    ${BUILD_DIR}/vnf-details.json
    ${object}=    Evaluate    json.loads('''${json}''')    json
    ${vnf_name}=    set variable    ${object["vnf_name"]}
    ${temp_List}    Create List
    :FOR   ${info}   IN   @{list_of_info}
    \    ${env_file}=    Replace String    ${info["template_name"]}    yaml    env
    \    ${env_file}=    Replace String    ${env_file}    yml    env
    \    ${template_append} =    Catenate    SEPARATOR=    ${BUILD_DIR}/templates/    ${info["template_name"]}
    \    ${preload_append} =    Catenate    SEPARATOR=    ${BUILD_DIR}/preloads/    ${info["preload_name"]}
    \    ${env_append} =    Catenate    SEPARATOR=    ${BUILD_DIR}/templates/    ${env_file}
    \    ${temp_dict}    Create Dictionary    stack_name=${info["stack_name"]}    template_name=${template_append}  preload_name=${preload_append}    env_name=${env_append}
    \    Append To List    ${temp_List}    ${temp_dict}
    ${req_dict}    Create Dictionary    VNF_Name=${vnf_name}    stacks=${temp_List}
    ${req_json}    Evaluate    json.dumps(${req_dict})    json
    OperatingSystem.Create File    ${OUTPUTDIR}/Manifest    content=${req_json}

Run VNF Instantiation Report
    [Arguments]    ${region_id}    ${vnf_details}    ${build_directory}    ${os_password}
    ${auth}=  Create List  ${GLOBAL_SO_CATDB_USERNAME}    ${GLOBAL_SO_PASSWORD}
    ${get_resp}=    SO.Run Get Request    ${GLOBAL_SO_CATDB_ENDPOINT}    ${CLOUD_CONFIG_PATH}/${region_id}   auth=${auth}

    ${object}=      Evaluate    json.loads('''${get_resp.text}''')     json
    ${auth_url} =    Set Variable    ${object["identityService"]["identity_url"]}
    #${auth_url} =    Catenate    SEPARATOR=    ${auth_url}    /auth/tokens
    ${user_id} =    Set Variable    ${object["identityService"]["mso_id"]}
    ${region_id} =    Set Variable    ${object["region_id"]}
    ${tenant_id} =    Set Variable    ${object["identityService"]["admin_tenant"]}
    ${identity_server_type}=    Set Variable    ${object["identityService"]["identity_server_type"]}
    ${identity_server_type}=    Set Variable If    '${identity_server_type}' == 'KEYSTONE_V3'    v3    v2.0

    Set Global Variable    ${GLOBAL_INJECTED_OPENSTACK_KEYSTONE_API_VERSION}    ${identity_server_type}
    Set Global Variable    ${GLOBAL_INJECTED_KEYSTONE}    ${auth_url}
    Set Global Variable    ${GLOBAL_INJECTED_OPENSTACK_PROJECT_NAME}    ${tenant_id}

    Run Openstack Auth Request    mytest    username=${user_id}    password=${os_password}

    ${catalog}=    Get Openstack Catalog    mytest
    ${token}=      Get Openstack Token      mytest
    ${orchestration_url}=    Get Openstack Service Url    mytest    orchestration

    Log To Console    ${catalog}
    Log To Console    ${token}
    Log To Console    ${orchestration_url}

    Create Report Manifest Data    ${vnf_details}    ${build_directory}

    ${report}=    HeatStackValidation.validate    ${orchestration_url}    ${token}    ${OUTPUTDIR}/Manifest

    ${status}=    Get From Dictionary    ${report}    summary

    ${json_string}=    evaluate    json.dumps(${report}, indent=4)    json
    OperatingSystem.Create File    ${summary_directory}/stack_report.json    content=${json_string}

    Run Keyword If    '${status}' == 'FAILED'    Fail    Stack Validation Failed
    [Return]    ${report}
