*** Settings ***
Documentation     Create VNFC in AAI

Resource    ../json_templater.robot
Resource    aai_interface.robot
Library    OperatingSystem
Library    Collections


*** Variables ***
${INDEX_PATH}     /aai/v14
${ROOT_PATH}      /network/vnfcs/vnfc

${SYSTEM USER}    robot-ete
${AAI_ADD_VNFC_BODY}=    robot/assets/templates/aai/add_vnfc_body.template

*** Keywords ***
Create VNFC If Not Exists
    [Documentation]    Creates VNFC in A&AI if it doesn't exist
    [Arguments]    ${vnfc_name}    ${vnfc_nc}    ${vnfc_func}
    ${get_resp}=    Run A&AI Get Request     ${INDEX_PATH}${ROOT_PATH}/${vnfc_name}
    Return From Keyword If    '${get_resp.status_code}' == '200'
    Create VNFC    ${vnfc_name}    ${vnfc_nc}    ${vnfc_func}

Create VNFC
    [Documentation]    Creates VNFC in A&AI
    [Arguments]    ${vnfc_name}    ${vnfc_nc}    ${vnfc_func}
    ${arguments}=    Create Dictionary     vnfc_name=${vnfc_name}    vnfc_nc=${vnfc_nc}    vnfc_func=${vnfc_func}
    ${data}=    Fill JSON Template File    ${AAI_ADD_VNFC_BODY}    ${arguments}
    ${put_resp}=    Run A&AI Put Request     ${INDEX_PATH}${ROOT_PATH}/${vnfc_name}    ${data}
    ${status_string}=    Convert To String    ${put_resp.status_code}
    Should Match Regexp    ${status_string}     ^(201|200)$

Delete VNFC If Exists
    [Documentation]    Removes VNFC from AAI if it exists
    [Arguments]    ${vnfc_name}
    ${get_resp}=    Run A&AI Get Request     ${INDEX_PATH}${ROOT_PATH}/${vnfc_name}
    Run Keyword If    '${get_resp.status_code}' == '200'    Delete VNFC    ${vnfc_name}    ${get_resp.json()}

Delete VNFC
    [Documentation]    Removes VNFC from AAI
    [Arguments]    ${vnfc_name}    ${json}
    ${resource_version}=   Catenate   ${json['resource-version']}
    ${put_resp}=    Run A&AI Delete Request    ${INDEX_PATH}${ROOT_PATH}/${vnfc_name}    ${resource_version}
    Should Be Equal As Strings  ${put_resp.status_code}         204

Get VNFC
    [Documentation]    Return VNFC
    [Arguments]    ${vnfc_name}
    ${resp}=    Run A&AI Get Request     ${INDEX_PATH}${ROOT_PATH}/${vnfc_name}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]  ${resp.json()}