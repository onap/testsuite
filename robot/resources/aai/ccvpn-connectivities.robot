*** Settings ***
Documentation     Operations on connectivities in AAI for CCVPN use case, using earliest API version where it is implemented and latest API version where it is not implemented

Resource    ../json_templater.robot
Resource    aai_interface.robot
Resource    api_version_properties.robot
Library    OperatingSystem
Library    Collections


*** Variables ***
${AAI_CONN_ROOT_PATH}      /network/connectivities/connectivity
${AAI_CONN_EXAMPLES_PATH}      /examples/connectivities
${AAI_CONN_NODES_PATH}      /nodes/connectivities
${AAI_ADD_CONNECTIVITY_BODY}=    robot/assets/templates/aai/add-connectivity.template
${AAI_API_NA_INDEX_PATH}=  ${AAI_BEIJING_INDEX_PATH}
${AAI_API_IMPL_INDEX_PATH}=  ${AAI_CASABLANCA_INDEX_PATH}

*** Keywords ***
Create Connectivity If Not Exists
    [Documentation]    Creates Connectivity in AAI if it doesn't exist
    [Arguments]    ${connectivity-id}
    ${get_resp}=    Run AAI Get Request     ${AAI_API_IMPL_INDEX_PATH}${AAI_CONN_ROOT_PATH}/${connectivity-id}
    Return From Keyword If    '${get_resp.status_code}' == '200'
    Create Connectivity  ${connectivity-id}

Create Connectivity
    [Documentation]    Creates Connectivity in AAI
    [Arguments]    ${connectivity-id}
    ${arguments}=    Create Dictionary     connectivity-id=${connectivity-id}
    ${data}=    Fill JSON Template File    ${AAI_ADD_CONNECTIVITY_BODY}    ${arguments}
    ${put_resp}=    Run AAI Put Request     ${AAI_API_IMPL_INDEX_PATH}${AAI_CONN_ROOT_PATH}/${connectivity-id}     ${data}
    ${status_string}=    Convert To String    ${put_resp.status_code}
    Should Match Regexp    ${status_string}     ^(201|200)$

Delete Connectivity If Exists
    [Documentation]    Removes Connectivity from AAI if it exists
    [Arguments]    ${connectivity-id}
    ${get_resp}=    Run AAI Get Request     ${AAI_API_IMPL_INDEX_PATH}${AAI_CONN_ROOT_PATH}/${connectivity-id}
    Run Keyword If    '${get_resp.status_code}' == '200'    Delete Connectivity     ${connectivity-id}   ${get_resp.json()}

Delete Connectivity
    [Documentation]    Removes Connectivity from AAI
    [Arguments]    ${connectivity-id}  ${json}
    ${resource_version}=   Catenate   ${json['resource-version']}
    ${put_resp}=    Run AAI Delete Request    ${AAI_API_IMPL_INDEX_PATH}${AAI_CONN_ROOT_PATH}/${connectivity-id}    ${resource_version}
    Should Be Equal As Strings  ${put_resp.status_code}         204

Get Connectivity
    [Documentation]   Return Connectivity
    [Arguments]    ${connectivity-id}
    ${resp}=    Run AAI Get Request     ${AAI_API_IMPL_INDEX_PATH}${AAI_CONN_ROOT_PATH}/${connectivity-id}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]  ${resp.json()}

Get Nodes Query Connectivity
    [Documentation]   Return Nodes query Connectivity
    [Arguments]    ${connectivity-id}
    ${resp}=    Run AAI Get Request     ${AAI_API_IMPL_INDEX_PATH}${AAI_CONN_NODES_PATH}?connectivity-id=${connectivity-id}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]  ${resp.json()}

Get Example Connectivity
    [Documentation]   Return Example Connectivity
    ${resp}=    Run AAI Get Request     ${AAI_API_IMPL_INDEX_PATH}${AAI_CONN_EXAMPLES_PATH}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]  ${resp.json()}

Confirm No Connectivity
    [Documentation]   Confirm No Connectivity
    [Arguments]    ${connectivity-id}
    ${resp}=    Run AAI Get Request     ${AAI_API_IMPL_INDEX_PATH}${AAI_CONN_ROOT_PATH}/${connectivity-id}
    Should Be Equal As Strings  ${resp.status_code}     404

Confirm API Not Implemented Connectivity
    [Documentation]   Confirm latest API version where Connectivity is not implemented
    [Arguments]    ${connectivity-id}
    ${resp}=    Run AAI Get Request     ${AAI_API_NA_INDEX_PATH}${AAI_CONN_ROOT_PATH}/${connectivity-id}
    Should Be Equal As Strings  ${resp.status_code}     400

