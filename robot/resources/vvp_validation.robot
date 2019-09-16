*** Settings ***
Documentation     The main interface for interacting with SDC. It handles low level stuff like managing the http request library and DCAE required fields
Library           OperatingSystem
Library           ONAPLibrary.SO    WITH NAME    SO
Library           ONAPLibrary.HeatVNFValidation    WITH NAME    HeatVNFValidation
Library           ONAPLibrary.VVPValidation.HeatValidationScripts    WITH NAME    VVPValidation

*** Variables ***
${CLOUD_CONFIG_PATH}        /cloudSite

*** Keywords ***
Run VVP Validation Scripts
    [Documentation]   Creates virtualenv and clones VVP scripts to build_dir, executes VVP validation scripts against a template directory, results stored in output directory.
    [Arguments]    ${build_dir}    ${heat_template_directory}    ${output_directory}

    VVPValidation.validate    ${build_dir}    ${heat_template_directory}    ${output_directory}

Run VNF Instantiation Report
    [Documentation]   Validates that a stack was created correctly, used for OVP portal submission.
    [Arguments]    ${region_id}    ${vnf_details}    ${os_password}    ${vnf_name}
    ${auth}=  Create List  ${GLOBAL_SO_CATDB_USERNAME}    ${GLOBAL_SO_PASSWORD}
    ${get_resp}=    SO.Run Get Request    ${GLOBAL_SO_CATDB_ENDPOINT}    ${CLOUD_CONFIG_PATH}/${region_id}   auth=${auth}

    ${object}=      Evaluate    json.loads('''${get_resp.text}''')     json
    ${auth_url} =    Set Variable    ${object["identityService"]["identity_url"]}
    ${user_id} =    Set Variable    ${object["identityService"]["mso_id"]}
    ${region_id} =    Set Variable    ${object["region_id"]}
    ${tenant_id} =    Set Variable    ${object["identityService"]["admin_tenant"]}
    ${identity_server_type}=    Set Variable    ${object["identityService"]["identity_server_type"]}
    ${identity_server_type}=    Set Variable If    '${identity_server_type}' == 'KEYSTONE_V3'    v3    v2.0

    Set Global Variable    ${GLOBAL_INJECTED_OPENSTACK_KEYSTONE_API_VERSION}    ${identity_server_type}
    Set Global Variable    ${GLOBAL_INJECTED_KEYSTONE}    ${auth_url}
    Set Global Variable    ${GLOBAL_INJECTED_OPENSTACK_PROJECT_NAME}    ${tenant_id}

    Run Openstack Auth Request    mytest    username=${user_id}    password=${os_password}

    ${token}=      Get Openstack Token      mytest
    ${orchestration_url}=    Get Openstack Service Url    mytest    orchestration

    ${report}=    HeatVNFValidation.validate    ${orchestration_url}    ${token}    ${vnf_details}    ${vnf_name}

    ${status}=    Get From Dictionary    ${report}    summary

    ${json_string}=    evaluate    json.dumps(${report}, indent=4)    json
    OperatingSystem.Create File    ${OUTPUTDIR}/summary/stack_report.json    content=${json_string}

    Run Keyword If    '${status}' == 'FAILED'    Fail    Stack Validation Failed
    [Return]    ${report}
