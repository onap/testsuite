*** Settings ***
Documentation     Create availability zone in A&AI.

Resource    aai_interface.robot
Library    OperatingSystem
Library    Collections
Library    ONAPLibrary.Templating    WITH NAME    Templating
Library    ONAPLibrary.AAI    WITH NAME    AAI


*** Variables ***
${AZ_ROOT_PATH}      /cloud-infrastructure/cloud-regions/cloud-region
${AZ_ZONE_PATH}      /availability-zones/availability-zone

${AAI_ADD_AVAILABILITY_ZONE_BODY}    aai/add_availability_zone_body.jinja

*** Keywords ***
Create Availability Zone If Not Exists
    [Documentation]    Creates availability zone in A&AI if it doesn't exist
    [Arguments]    ${cloud-owner}  ${cloud-region-id}  ${availability_zone_name}=${GLOBAL_AAI_AVAILABILITY_ZONE_NAME}
    ${auth}=  Create List  ${GLOBAL_AAI_USERNAME}    ${GLOBAL_AAI_PASSWORD}
    ${get_resp}=    AAI.Run Get Request     ${AAI_FRONTEND_ENDPOINT}    ${GLOBAL_AAI_INDEX_PATH}${AZ_ROOT_PATH}/${cloud-owner}/${cloud-region-id}${AZ_ZONE_PATH}/${availability_zone_name}        auth=${auth}
    Return From Keyword If    '${get_resp.status_code}' == '200'
    Create Availability Zone  ${availability_zone_name}  ${cloud-owner}  ${cloud-region-id}

Create Availability Zone
    [Documentation]    Creates availability zone in A&AI
    [Arguments]    ${availability_zone_name}  ${cloud-owner}  ${cloud-region-id}
    ${arguments}=    Create Dictionary     availability_zone_name=${availability_zone_name}
    Templating.Create Environment    aai    ${GLOBAL_TEMPLATE_FOLDER}
    ${data}=   Templating.Apply Template    aai   ${AAI_ADD_AVAILABILITY_ZONE_BODY}    ${arguments}
    ${auth}=  Create List  ${GLOBAL_AAI_USERNAME}    ${GLOBAL_AAI_PASSWORD}
    ${put_resp}=   AAI.Run Put Request     ${AAI_FRONTEND_ENDPOINT}    ${GLOBAL_AAI_INDEX_PATH}${AZ_ROOT_PATH}/${cloud-owner}/${cloud-region-id}${AZ_ZONE_PATH}/${availability_zone_name}     ${data}        auth=${auth}
    ${status_string}=    Convert To String    ${put_resp.status_code}
    Should Match Regexp    ${status_string}     ^(201|200)$

Delete Availability Zone If Exists
    [Documentation]    Removes availability zone
    [Arguments]    ${cloud-owner}  ${cloud-region-id}  ${availability_zone_name}=${GLOBAL_AAI_AVAILABILITY_ZONE_NAME}
    ${auth}=  Create List  ${GLOBAL_AAI_USERNAME}    ${GLOBAL_AAI_PASSWORD}
    ${get_resp}=    AAI.Run Get Request     ${AAI_FRONTEND_ENDPOINT}    ${GLOBAL_AAI_INDEX_PATH}${AZ_ROOT_PATH}/${cloud-owner}/${cloud-region-id}${AZ_ZONE_PATH}/${availability_zone_name}        auth=${auth}
    Run Keyword If    '${get_resp.status_code}' == '200'    Delete Availability Zone     ${availability_zone_name}  ${cloud-owner}  ${cloud-region-id}   ${get_resp.json()}

Delete Availability Zone
    [Arguments]    ${availability_zone_name}  ${cloud-owner}  ${cloud-region-id}  ${json}
    ${resource_version}=   Catenate   ${json['resource-version']}
    ${auth}=  Create List  ${GLOBAL_AAI_USERNAME}    ${GLOBAL_AAI_PASSWORD}
    ${put_resp}=    AAI.Run Delete Request    ${AAI_FRONTEND_ENDPOINT}    ${GLOBAL_AAI_INDEX_PATH}${AZ_ROOT_PATH}/${cloud-owner}/${cloud-region-id}${AZ_ZONE_PATH}/${availability_zone_name}    ${resource_version}        auth=${auth}
    Should Be Equal As Strings  ${put_resp.status_code}         204

Get Availability Zone
    [Documentation]   Return availability zone
    [Arguments]    ${availability_zone_name}  ${cloud-owner}  ${cloud-region-id}
    ${auth}=  Create List  ${GLOBAL_AAI_USERNAME}    ${GLOBAL_AAI_PASSWORD}
    ${resp}=    AAI.Run Get Request     ${AAI_FRONTEND_ENDPOINT}    ${GLOBAL_AAI_INDEX_PATH}${AZ_ROOT_PATH}/${cloud-owner}/${cloud-region-id}${AZ_ZONE_PATH}/${availability_zone_name}        auth=${auth}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]  ${resp.json()}
