*** Settings ***
Documentation     Operations on connectivities in A&AI for CCVPN use case.

Resource    ../json_templater.robot
Resource    aai_interface.robot
Library    OperatingSystem
Library    Collections


*** Variables ***
${CONN_ROOT_PATH}      /network/connectivities/connectivity
${AAI_ADD_CONNECTIVITY_BODY}=    robot/assets/templates/aai/add-connectivity.template

*** Keywords ***
Create Connectivity If Not Exists
    [Documentation]    Creates Connectivity in A&AI if it doesn't exist
    [Arguments]    ${connectivity-id}
    ${get_resp}=    Run A&AI Get Request     ${GLOBAL_AAI_CASABLANCA_INDEX_PATH}${CONN_ROOT_PATH}/${connectivity-id}
    Return From Keyword If    '${get_resp.status_code}' == '200'
    Create Connectivity  ${connectivity-id}

Create Connectivity
    [Documentation]    Creates Connectivity in A&AI
    [Arguments]    ${connectivity-id}
    ${arguments}=    Create Dictionary     connectivity-id=${connectivity-id}
    ${data}=    Fill JSON Template File    ${AAI_ADD_CONNECTIVITY_BODY}    ${arguments}
    ${put_resp}=    Run A&AI Put Request     ${GLOBAL_AAI_CASABLANCA_INDEX_PATH}${CONN_ROOT_PATH}/${connectivity-id}     ${data}
    ${status_string}=    Convert To String    ${put_resp.status_code}
    Should Match Regexp    ${status_string}     ^(201|200)$

Delete Connectivity If Exists
    [Documentation]    Removes Connectivity from AAI if it exists
    [Arguments]    ${connectivity-id}
    ${get_resp}=    Run A&AI Get Request     ${GLOBAL_AAI_CASABLANCA_INDEX_PATH}${CONN_ROOT_PATH}/${connectivity-id}
    Run Keyword If    '${get_resp.status_code}' == '200'    Delete Connectivity     ${connectivity-id}   ${get_resp.json()}

Delete Connectivity
    [Documentation]    Removes Connectivity from AAI
    [Arguments]    ${connectivity-id}  ${json}
    ${resource_version}=   Catenate   ${json['resource-version']}
    ${put_resp}=    Run A&AI Delete Request    ${GLOBAL_AAI_CASABLANCA_INDEX_PATH}${CONN_ROOT_PATH}/${connectivity-id}    ${resource_version}
    Should Be Equal As Strings  ${put_resp.status_code}         204

Get Connectivity
    [Documentation]   Return Connectivity
    [Arguments]    ${connectivity-id}
    ${resp}=    Run A&AI Get Request     ${GLOBAL_AAI_CASABLANCA_INDEX_PATH}${CONN_ROOT_PATH}/${connectivity-id}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]  ${resp.json()}

Confirm No Connectivity
    [Documentation]   Confirm No Connectivity
    [Arguments]    ${connectivity-id}
    ${resp}=    Run A&AI Get Request     ${GLOBAL_AAI_CASABLANCA_INDEX_PATH}${CONN_ROOT_PATH}/${connectivity-id}
    Should Be Equal As Strings  ${resp.status_code}     404

Confirm Not Beijing Connectivity
    [Documentation]   Confirm Not Beijing Connectivity
    [Arguments]    ${connectivity-id}
    ${resp}=    Run A&AI Get Request     ${GLOBAL_AAI_BEIJING_INDEX_PATH}${CONN_ROOT_PATH}/${connectivity-id}
    Should Be Equal As Strings  ${resp.status_code}     400
