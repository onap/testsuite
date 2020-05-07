*** Settings ***
Documentation     This test template encapsulates the VNF Orchestration use case.

Library             OperatingSystem
Library             ArchiveLibrary
Library           Collections

Library             ONAPLibrary.Templating    WITH NAME    Templating
Resource            ../global_properties.robot
Resource            ../vnfsdk_interface.robot
Resource            ../sdc_interface.robot

*** Variables ***
${VNFSDK_TEST}   vnfsdk/vnfsdk_validation_request.jinja



*** Variables ***
${VNFSDK_TOSCA_ONBOARDING_PACKAGES_DIRECTORY}    ${GLOBAL_TOSCA_ONBOARDING_PACKAGES_FOLDER}/vnfsdk
${VNFSDK_CSAR_DIRECTORY}   ${VNFSDK_TOSCA_ONBOARDING_PACKAGES_DIRECTORY}/temp
@{empty_list}
*** Keywords ***

Validate Onboarding Package
    [Arguments]   ${package_folder}   ${scenario}=onap-dublin  ${test_suite_name}=validation  ${test_case_name}=csar-validate  ${pnf}=TRUE  ${integrity_check}=FALSE  ${secured_package}=FALSE  ${negative_test_case}=TRUE  ${failed_vnfreqNames}=@{empty_list}  ${sdc_response}=@{empty_list}  ${secure_type}=CMS  ${sdc_cert}=sdc-valid
    Disable Warnings
    Create Directory   ${VNFSDK_CSAR_DIRECTORY}
    ${onboarding_package_path}=   Run Keyword If  "${secured_package}"=='FALSE'   Create CSAR Package  ${package_folder}  ${integrity_check}  ${sdc_cert}
                    ...  ELSE  Create Secured CSAR Package   ${package_folder}  ${integrity_check}  ${secure_type}  ${sdc_cert}
    Validate Onboarding Package In SDC  ${onboarding_package_path}  ${package_folder}   ${sdc_cert}  ${negative_test_case}  ${sdc_response}  ${sdc_cert}
    Run Keyword If  "${negative_test_case}"=='FALSE'   Validate Valid Onboarding Package  ${package_folder}  ${onboarding_package_path}  ${scenario}  ${test_suite_name}  ${test_case_name}  ${pnf}  ${secured_package}
    ...  ELSE  Validate Not Valid Onboarding Package  ${package_folder}  ${onboarding_package_path}  ${scenario}  ${test_suite_name}  ${test_case_name}  ${pnf}  ${failed_vnfreqNames}  ${secured_package}

Create CSAR Package
    [Arguments]  ${package_folder}   ${integrity_check}  ${cert}
    ${csar} =   Run Keyword If   "${integrity_check}"=='FALSE'  Create CSAR Package without integrity check  ${package_folder}
    ...  ELSE  Create CSAR Package with integrity check   ${package_folder}  ${integrity_check}  ${cert}
    [Return]  ${csar}

Create CSAR Package without integrity check
    [Arguments]  ${package_folder}
    Empty Directory  ${VNFSDK_CSAR_DIRECTORY}
    ${csar}=    Catenate    ${VNFSDK_CSAR_DIRECTORY}/${package_folder}.csar
    Copy File   ${GLOBAL_TOSCA_ONBOARDING_PACKAGES_FOLDER}/vnfsdk/${package_folder}.csar  ${csar}
    [Return]  ${csar}

Create CSAR Package with integrity check
    [Arguments]  ${package_folder}  ${integrity_check}  ${cert}
    Empty Directory  ${VNFSDK_CSAR_DIRECTORY}
    ${csar}=    Catenate    ${VNFSDK_CSAR_DIRECTORY}/${package_folder}.csar
    Copy Directory   ${GLOBAL_TOSCA_ONBOARDING_PACKAGES_FOLDER}/vnfsdk/${package_folder}  ${VNFSDK_CSAR_DIRECTORY}
    ${meta}=  OperatingSystem.Get File   ${VNFSDK_CSAR_DIRECTORY}/${package_folder}/TOSCA-Metadata/TOSCA.meta
    ${cert_name}=  Get Regexp Matches  ${meta}  (?<=\ETSI-Entry-Certificate: )(.*)
    Copy File  /tmp/package-robot-${cert}.cert   ${VNFSDK_CSAR_DIRECTORY}/${package_folder}/${cert_name}[0]
    ${files} = 	List Files In Directory 	 ${VNFSDK_CSAR_DIRECTORY}/${package_folder} 	*.mf  absolute
    Sign csar manifest file   ${integrity_check}  ${cert}  ${files}[0]
    ${rc} =     Run and Return RC   cd ${VNFSDK_CSAR_DIRECTORY}/${package_folder}; zip -r ${csar} *
    Should Be Equal As Integers         ${rc}    0
    Remove Directory 	${VNFSDK_CSAR_DIRECTORY}/${package_folder}	recursive=True
    [Return]  ${csar}

Sign csar manifest file
    [Arguments]  ${integrity_check}  ${cert}  ${manifest}
     ${rc} =   Run Keyword If  "${integrity_check}"=='CMS_with_cert'   Run and Return RC   openssl cms -sign -signer /tmp/package-robot-${cert}.cert -inkey /tmp/package-private-robot-${cert}.key -outform PEM -binary -in ${manifest} >> ${manifest}
     ...  ELSE   Run and Return RC   openssl cms -sign -signer /tmp/package-robot-${cert}.cert -inkey /tmp/package-private-robot-${cert}.key -outform PEM -binary -nocerts -in ${manifest} >> ${manifest}
     Should Be Equal As Integers         ${rc}    0

Create Secured CSAR Package
    [Arguments]  ${package_folder}  ${integrity_check}  ${secure_type}  ${sdc_cert}
    ${zip}=  Run Keyword If   "${secure_type}"=='CMS'  Create Secured CSAR ZIP Package with CMS   ${package_folder}  ${integrity_check}  ${sdc_cert}
                    ...  ELSE  Create Secured CSAR ZIP Package with CMS and CERT    ${package_folder}  ${integrity_check}  ${sdc_cert}
    [Return]  ${zip}

Create Secured CSAR ZIP Package with CMS
    [Arguments]   ${package_folder}  ${integrity_check}  ${cert}
    ${zip}=   Catenate   ${VNFSDK_CSAR_DIRECTORY}/${package_folder}.zip
    ${cms}=   Catenate   ${VNFSDK_CSAR_DIRECTORY}/${package_folder}.cms
    ${csar}=  Create CSAR Package   ${package_folder}  ${integrity_check}  ${cert}
    ${rc} =     Run and Return RC   openssl cms -sign -signer /tmp/package-robot-${cert}.cert -inkey /tmp/package-private-robot-${cert}.key -outform PEM -binary -in ${csar} -out ${cms}
    Should Be Equal As Integers         ${rc}    0
    ${rc} =     Run and Return RC   cd ${VNFSDK_CSAR_DIRECTORY}; zip -r ${zip} *
    Should Be Equal As Integers         ${rc}    0
    [Return]  ${zip}

Create Secured CSAR ZIP Package with CMS and CERT
    [Arguments]   ${package_folder}  ${integrity_check}  ${cert}
    ${zip}=   Catenate   ${VNFSDK_CSAR_DIRECTORY}/${package_folder}.zip
    ${cms}=   Catenate   ${VNFSDK_CSAR_DIRECTORY}/${package_folder}.cms
    ${csar}=  Create CSAR Package   ${package_folder}  ${integrity_check}  ${cert}
    Copy File  /tmp/package-robot-${cert}.cert   ${VNFSDK_CSAR_DIRECTORY}/${package_folder}.cert
    ${rc} =     Run and Return RC   openssl cms -sign -signer /tmp/package-robot-${cert}.cert -inkey /tmp/package-private-robot-${cert}.key -outform PEM -binary -nocerts -in ${csar} -out ${cms}
    Should Be Equal As Integers         ${rc}    0
    ${rc} =     Run and Return RC   cd ${VNFSDK_CSAR_DIRECTORY}; zip -r ${zip} *
    Should Be Equal As Integers         ${rc}    0
    [Return]  ${zip}

Validate Valid Onboarding Package
    [Arguments]  ${package_folder}  ${onboarding_package_path}  ${scenario}  ${test_suite_name}  ${test_case_name}  ${pnf}  ${secured_package}
    ${onboarding_package_name}=  Run Keyword If  "${secured_package}"=='FALSE'  Catenate  ${package_folder}.csar
                    ...  ELSE  Catenate  ${package_folder}.zip
    ${result}=  Run VNFSDK Validate Request  ${onboarding_package_name}   ${onboarding_package_path}  ${scenario}  ${test_suite_name}  ${test_case_name}  ${pnf}
    Log  ${result.json()}
    ${json}=  Set Variable  ${result.json()}
    ${status}=  Set Variable  ${json[0]['results']['criteria']}
    Should Be Equal As Strings  ${status}     PASS

Run VNFSDK Validate Request
    [Arguments]  ${onboarding_package_name}  ${onboarding_package_path}  ${scenario}  ${test_suite_name}  ${test_case_name}  ${pnf}
    ${arguments}=    Create Dictionary     scenario=${scenario}  onboarding_package_path=${onboarding_package_path}   test_suite_name=${test_suite_name}   test_case_name=${test_case_name}   pnf=${pnf}   file_name=${onboarding_package_name}
    Templating.Create Environment    vnfsdk    ${GLOBAL_TEMPLATE_FOLDER}
    ${executions}=    Templating.Apply Template    vnfsdk    ${VNFSDK_TEST}     ${arguments}
    ${fileData}=  Get Binary File  ${onboarding_package_path}
    ${fileDir}  ${fileName}=  Split Path   ${onboarding_package_path}
    ${file_part}=  Create List   ${fileName}  ${fileData}  application/octet-stream
    ${executions_parts}=  Create List  ${executions}
    ${fileParts}=  Create Dictionary
    Set to Dictionary  ${fileParts}  file=${file_part}
    Set to Dictionary  ${fileParts}  executions=${executions}
    ${resp}=  Run VNFSDK Post Request   /onapapi/vnfsdk-marketplace/v1/vtp/executions     ${fileParts}
    [Return]  ${resp}

Validate Not Valid Onboarding Package
    [Arguments]  ${package_folder}  ${onboarding_package_path}  ${scenario}  ${test_suite_name}  ${test_case_name}  ${pnf}  ${failed_req_list}  ${secured_package}
    ${onboarding_package_name}=  Run Keyword If  "${secured_package}"=='FALSE'  Catenate  ${package_folder}.csar
                    ...  ELSE  Catenate  ${package_folder}.zip
    ${result}=  Run VNFSDK Validate Request  ${onboarding_package_name}   ${onboarding_package_path}  ${scenario}  ${test_suite_name}  ${test_case_name}  ${pnf}
    Log  ${result.json()}
    ${json}=  Set Variable  ${result.json()}
    ${status}=  Set Variable  ${json[0]['results']['criteria']}
    Should Be Equal As Strings  ${status}     FAILED
    ${status_req_list}=  Set Variable  ${json[0]['results']['results']}
    ${failed_req_from_test_run}=    Create List
    :FOR    ${status_req}     IN      @{status_req_list}
    \    ${req_status}=  Get From Dictionary   ${status_req}     passed
    \    Run Keyword If  "${req_status}"=='False'  Add Failed Requirement To List  ${status_req}   ${failed_req_from_test_run}  vnfreqName
    Log  ${failed_req_from_test_run}
    Lists Should Be Equal   ${failed_req_from_test_run}    ${failed_req_list}

Add Failed Requirement To List
    [Arguments]  ${status_req}   ${failed_req}  ${param_name}
    ${req}=    Get From Dictionary   ${status_req}     ${param_name}
    Append To List    ${failed_req}    ${req}

Get And Comapre Error Responses From SDC API
    [Arguments]  ${resp}    ${sdc_response}
    ${json}=  Set Variable  ${resp.json()}
    ${sdc_response_list}    Set Variable   ${json['errors']['uploadFile']}
    ${failed_req_from_test_run}=    Create List
    :FOR    ${message_item}     IN      @{sdc_response_list}
    \    ${req_status}=  Get From Dictionary   ${message_item}     level
    \    Run Keyword If  "${req_status}"=='ERROR'  Add Failed Requirement To List  ${message_item}   ${failed_req_from_test_run}  message
    Log  ${failed_req_from_test_run}
    Lists Should Be Equal   ${failed_req_from_test_run}    ${sdc_response}

Validate Onboarding Package In SDC
    [Arguments]  ${onboarding_package_path}  ${package_folder}  ${sdc_validation}  ${negative_test_case}  ${sdc_response}  ${sdc_cert}
    ${license_model_id}   ${license_model_version_id}=    Add SDC License Model
    ${license_temp_date}=   Get Current Date
    ${license_start_date}=   Get Current Date     result_format=%m/%d/%Y
    ${license_end_date}=     Add Time To Date   ${license_temp_date}    365 days    result_format=%m/%d/%Y
    ${key_group_id}=    Add SDC License Group    ${license_model_id}   ${license_model_version_id}  ${license_start_date}  ${license_end_date}
    ${pool_id}=    Add SDC Entitlement Pool    ${license_model_id}   ${license_model_version_id}  ${license_start_date}  ${license_end_date}
    ${feature_group_id}=    Add SDC Feature Group    ${license_model_id}    ${key_group_id}    ${pool_id}  ${license_model_version_id}
    ${license_agreement_id}=    Add SDC License Agreement    ${license_model_id}    ${feature_group_id}   ${license_model_version_id}
    Submit SDC License Model    ${license_model_id}   ${license_model_version_id}
    ${license_model_resp}=    Get SDC License Model    ${license_model_id}   ${license_model_version_id}
    ${software_product_id}   ${software_product_version_id}=    Add SDC Software Product    ${license_agreement_id}    ${feature_group_id}    ${license_model_resp['vendorName']}    ${license_model_id}    ${license_model_version_id}    ${package_folder}
    ${resp}=  Upload SDC Heat Package    ${software_product_id}    ${onboarding_package_path}   ${software_product_version_id}
    Run Keyword If  "${negative_test_case}"=='TRUE' or "${sdc_cert}"=='sdc-invalid'   Get And Comapre Error Responses From SDC API  ${resp}    ${sdc_response}
    ...  ELSE  Validate SDC Software Product    ${software_product_id}  ${software_product_version_id}
