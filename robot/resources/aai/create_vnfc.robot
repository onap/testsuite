*** Settings ***
Documentation     Create VNFC in AAI

Resource    aai_interface.robot
Library    OperatingSystem
Library    Collections
Library    ONAPLibrary.Templating    WITH NAME    Templating
Library    ONAPLibrary.AAI    WITH NAME    AAI

*** Variables ***
${VNFC_ROOT_PATH}      /network/vnfcs/vnfc

${AAI_ADD_VNFC_BODY}=    aai/add_vnfc_body.jinja

*** Keywords ***
Create VNFC If Not Exists
    [Documentation]    Creates VNFC in A&AI if it doesn't exist
    [Arguments]    ${vnfc_name}    ${vnfc_nc}    ${vnfc_func}
    ${auth}=  Create List  ${GLOBAL_AAI_USERNAME}    ${GLOBAL_AAI_PASSWORD}
    ${get_resp}=    AAI.Run Get Request     ${AAI_FRONTEND_ENDPOINT}    ${GLOBAL_AAI_INDEX_PATH}${VNFC_ROOT_PATH}/${vnfc_name}        auth=${auth}
    Return From Keyword If    '${get_resp.status_code}' == '200'
    Create VNFC    ${vnfc_name}    ${vnfc_nc}    ${vnfc_func}

Create VNFC
    [Documentation]    Creates VNFC in A&AI
    [Arguments]    ${vnfc_name}    ${vnfc_nc}    ${vnfc_func}
    ${arguments}=    Create Dictionary     vnfc_name=${vnfc_name}    vnfc_nc=${vnfc_nc}    vnfc_func=${vnfc_func}
    Templating.Create Environment    aai    ${GLOBAL_TEMPLATE_FOLDER}
    ${data}=   Templating.Apply Template    aai   ${AAI_ADD_VNFC_BODY}    ${arguments}
    ${auth}=  Create List  ${GLOBAL_AAI_USERNAME}    ${GLOBAL_AAI_PASSWORD}
    ${put_resp}=    AAI.Run Put Request     ${AAI_FRONTEND_ENDPOINT}    ${GLOBAL_AAI_INDEX_PATH}${VNFC_ROOT_PATH}/${vnfc_name}    ${data}        auth=${auth}
    ${status_string}=    Convert To String    ${put_resp.status_code}
    Should Match Regexp    ${status_string}     ^(201|200)$

Delete VNFC If Exists
    [Documentation]    Removes VNFC from AAI if it exists
    [Arguments]    ${vnfc_name}
    ${auth}=  Create List  ${GLOBAL_AAI_USERNAME}    ${GLOBAL_AAI_PASSWORD}
    ${get_resp}=    AAI.Run Get Request     ${AAI_FRONTEND_ENDPOINT}    ${GLOBAL_AAI_INDEX_PATH}${VNFC_ROOT_PATH}/${vnfc_name}        auth=${auth}
    Run Keyword If    '${get_resp.status_code}' == '200'    Delete VNFC    ${vnfc_name}    ${get_resp.json()}

Delete VNFC
    [Documentation]    Removes VNFC from AAI
    [Arguments]    ${vnfc_name}    ${json}
    ${auth}=  Create List  ${GLOBAL_AAI_USERNAME}    ${GLOBAL_AAI_PASSWORD}
    ${resource_version}=   Catenate   ${json['resource-version']}
    ${put_resp}=    AAI.Run Delete Request    ${AAI_FRONTEND_ENDPOINT}    ${GLOBAL_AAI_INDEX_PATH}${VNFC_ROOT_PATH}/${vnfc_name}    ${resource_version}        auth=${auth}
    Should Be Equal As Strings  ${put_resp.status_code}         204

Get VNFC
    [Documentation]    Return VNFC
    [Arguments]    ${vnfc_name}
    ${auth}=  Create List  ${GLOBAL_AAI_USERNAME}    ${GLOBAL_AAI_PASSWORD}
    ${resp}=    AAI.Run Get Request     ${AAI_FRONTEND_ENDPOINT}    ${GLOBAL_AAI_INDEX_PATH}${VNFC_ROOT_PATH}/${vnfc_name}        auth=${auth}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]  ${resp.json()}
