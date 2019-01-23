*** Settings ***
Documentation     Create availability zone in A&AI.

Resource    ../json_templater.robot
Resource    aai_interface.robot
Library    OperatingSystem
Library    Collections


*** Variables ***
${INDEX_PATH}     /aai/v14
${ROOT_PATH}      /cloud-infrastructure/cloud-regions/cloud-region
${ZONE_PATH}      /availability-zones/availability-zone

${SYSTEM USER}    robot-ete
${AAI_ADD_AVAILABILITY_ZONE_BODY}=    robot/assets/templates/aai/add_availability_zone_body.template

*** Keywords ***
Create Availability Zone If Not Exists
    [Documentation]    Creates availability zone in A&AI if it doesn't exist
    [Arguments]    ${cloud-owner}  ${cloud-region-id}  ${availability_zone_name}=${GLOBAL_AAI_AVAILABILITY_ZONE_NAME}
    ${get_resp}=    Run A&AI Get Request     ${INDEX_PATH}${ROOT_PATH}/${cloud-owner}/${cloud-region-id}${ZONE_PATH}/${availability_zone_name}
    Return From Keyword If    '${get_resp.status_code}' == '200'
    Create Availability Zone  ${availability_zone_name}  ${cloud-owner}  ${cloud-region-id}

Create Availability Zone
    [Documentation]    Creates availability zone in A&AI
    [Arguments]    ${availability_zone_name}  ${cloud-owner}  ${cloud-region-id}
    ${arguments}=    Create Dictionary     availability_zone_name=${availability_zone_name}
    ${data}=    Fill JSON Template File    ${AAI_ADD_AVAILABILITY_ZONE_BODY}    ${arguments}
    ${put_resp}=    Run A&AI Put Request     ${INDEX_PATH}${ROOT_PATH}/${cloud-owner}/${cloud-region-id}${ZONE_PATH}/${availability_zone_name}     ${data}
    ${status_string}=    Convert To String    ${put_resp.status_code}
    Should Match Regexp    ${status_string}     ^(201|200)$

Delete Availability Zone If Exists
    [Documentation]    Removes availability zone
    [Arguments]    ${cloud-owner}  ${cloud-region-id}  ${availability_zone_name}=${GLOBAL_AAI_AVAILABILITY_ZONE_NAME}
    ${get_resp}=    Run A&AI Get Request     ${INDEX_PATH}${ROOT_PATH}/${cloud-owner}/${cloud-region-id}${ZONE_PATH}/${availability_zone_name}
    Run Keyword If    '${get_resp.status_code}' == '200'    Delete Availability Zone     ${availability_zone_name}  ${cloud-owner}  ${cloud-region-id}   ${get_resp.json()}

Delete Availability Zone
    [Arguments]    ${availability_zone_name}  ${cloud-owner}  ${cloud-region-id}  ${json}
    ${resource_version}=   Catenate   ${json['resource-version']}
    ${put_resp}=    Run A&AI Delete Request    ${INDEX_PATH}${ROOT_PATH}/${cloud-owner}/${cloud-region-id}${ZONE_PATH}/${availability_zone_name}    ${resource_version}
    Should Be Equal As Strings  ${put_resp.status_code}         204

Get Availability Zone
    [Documentation]   Return availability zone
    [Arguments]    ${availability_zone_name}  ${cloud-owner}  ${cloud-region-id}
    ${resp}=    Run A&AI Get Request     ${INDEX_PATH}${ROOT_PATH}/${cloud-owner}/${cloud-region-id}${ZONE_PATH}/${availability_zone_name}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]  ${resp.json()}