*** Settings ***
Documentation     Operations on pnfs in AAI for BBS use case,
...     using earliest API version where changes are implemented and
...     latest API version where changes are not implemented

Resource    ../json_templater.robot
Resource    aai_interface.robot
Resource    csit-api-version-properties.robot
Resource    csit-relationship-list.robot
Library    OperatingSystem
Library    Collections


*** Variables ***
${AAI_PNF_ROOT_PATH}      /network/pnfs/pnf
${AAI_PNF_EXAMPLES_PATH}      /examples/pnfs
${AAI_PNF_NODES_PATH}      /nodes/pnfs
${AAI_CSIT_PNF_BODY}=    robot/assets/templates/aai/csit-pnf.template
${AAI_PNF_API_NA_INDEX_PATH}=  ${AAI_BEIJING_INDEX_PATH}
${AAI_PNF_API_IMPL_INDEX_PATH}=  ${AAI_DUBLIN_INDEX_PATH}
# ${AAI_PNF_API_IMPL_INDEX_PATH}=  ${AAI_CASABLANCA_INDEX_PATH}

*** Keywords ***
Create Pnf If Not Exists
    [Documentation]    Creates Pnf in AAI if it doesn't exist
    [Arguments]    ${pnf_name}  ${pnf_id}
    ${get_resp}=    Run A&AI Get Request     ${AAI_PNF_API_IMPL_INDEX_PATH}${AAI_PNF_ROOT_PATH}/${pnf_name}
    Return From Keyword If    '${get_resp.status_code}' == '200'
    Create Pnf  ${pnf_name}  ${pnf_id}

Create Pnf
    [Documentation]    Creates Pnf in AAI
    [Arguments]    ${pnf_name}  ${pnf_id}
    ${arguments}=    Create Dictionary     pnf_name=${pnf_name}  pnf_id=${pnf_id}
    ${data}=    Fill JSON Template File    ${AAI_CSIT_PNF_BODY}    ${arguments}
    ${put_resp}=    Run A&AI Put Request     ${AAI_PNF_API_IMPL_INDEX_PATH}${AAI_PNF_ROOT_PATH}/${pnf_name}     ${data}
    ${status_string}=    Convert To String    ${put_resp.status_code}
    Should Match Regexp    ${status_string}     ^(201|200)$

Delete Pnf If Exists
    [Documentation]    Removes Pnf from AAI if it exists
    [Arguments]    ${pnf_name}
    ${get_resp}=    Run A&AI Get Request     ${AAI_PNF_API_IMPL_INDEX_PATH}${AAI_PNF_ROOT_PATH}/${pnf_name}
    Run Keyword If    '${get_resp.status_code}' == '200'    Delete Pnf     ${pnf_name}   ${get_resp.json()}

Delete Pnf
    [Documentation]    Removes Pnf from AAI
    [Arguments]    ${pnf_name}  ${json}
    ${resource_version}=   Catenate   ${json['resource-version']}
    ${put_resp}=    Run A&AI Delete Request    ${AAI_PNF_API_IMPL_INDEX_PATH}${AAI_PNF_ROOT_PATH}/${pnf_name}    ${resource_version}
    Should Be Equal As Strings  ${put_resp.status_code}         204

Get Pnf
    [Documentation]   Return Pnf
    [Arguments]    ${pnf_name}
    ${resp}=    Run A&AI Get Request     ${AAI_PNF_API_IMPL_INDEX_PATH}${AAI_PNF_ROOT_PATH}/${pnf_name}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]  ${resp.json()}

Get Valid Pnf URL
    [Documentation]   Return Valid Pnf URL
    [Arguments]    ${pnf_name}
    ${resp}=    Run A&AI Get Request     ${AAI_PNF_API_IMPL_INDEX_PATH}${AAI_PNF_ROOT_PATH}/${pnf_name}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]  ${AAI_PNF_API_IMPL_INDEX_PATH}${AAI_PNF_ROOT_PATH}/${pnf_name}

Get Nodes Query Pnf
    [Documentation]   Return Nodes query Pnf
    [Arguments]    ${pnf_name}
    ${resp}=    Run A&AI Get Request     ${AAI_PNF_API_IMPL_INDEX_PATH}${AAI_PNF_NODES_PATH}?pnf-name=${pnf_name}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]  ${resp.json()}

Get Example Pnf
    [Documentation]   Return Example Pnf
    ${resp}=    Run A&AI Get Request     ${AAI_PNF_API_IMPL_INDEX_PATH}${AAI_PNF_EXAMPLES_PATH}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]  ${resp.json()}

Confirm No Pnf
    [Documentation]   Confirm No Pnf
    [Arguments]    ${pnf_name}
    ${resp}=    Run A&AI Get Request     ${AAI_PNF_API_IMPL_INDEX_PATH}${AAI_PNF_ROOT_PATH}/${pnf_name}
    Should Be Equal As Strings  ${resp.status_code}     404

# Not applicable to Pnf as it appears in all known API versions
# Confirm API Not Implemented Pnf
    # [Documentation]   Confirm latest API version where Pnf is not implemented
    # [Arguments]    ${pnf_name}
    # ${resp}=    Run A&AI Get Request     ${AAI_PNF_API_NA_INDEX_PATH}${AAI_PNF_ROOT_PATH}/${pnf_name}
    # Should Be Equal As Strings  ${resp.status_code}     400

Add Pnf Relationship
    [Documentation]    Adds Relationship to existing Pnf in AAI
    [Arguments]    ${pnf_name}  ${related_class_name}  ${related_object_url}
    ${put_resp}=    Add Relationship     ${AAI_PNF_API_IMPL_INDEX_PATH}${AAI_PNF_ROOT_PATH}/${pnf_name}  ${related_class_name}  ${related_object_url}

Get Pnf RelationshipList
    [Documentation]   Return relationship-list from Pnf
    [Arguments]    ${pnf_name}
    ${resp}=    Get RelationshipList     ${AAI_PNF_API_IMPL_INDEX_PATH}${AAI_PNF_ROOT_PATH}/${pnf_name}
    [Return]  ${resp}

Get Pnf With RelationshipList
    [Documentation]   Return Pnf with relationship-list
    [Arguments]    ${pnf_name}
    ${resp}=    Get Object With Depth     ${AAI_PNF_API_IMPL_INDEX_PATH}${AAI_PNF_ROOT_PATH}/${pnf_name}
    [Return]  ${resp}

