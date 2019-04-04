*** Settings ***
Documentation     Operations on generic-vnfs in AAI for BBS use case,
...     using earliest API version where changes are implemented and
...     latest API version where changes are not implemented

Resource    ../json_templater.robot
Resource    aai_interface.robot
Resource    csit-api-version-properties.robot
Resource    csit-relationship-list.robot
Library    OperatingSystem
Library    Collections


*** Variables ***
${AAI_GVNF_ROOT_PATH}      /network/generic-vnfs/generic-vnf
${AAI_GVNF_EXAMPLES_PATH}      /examples/generic-vnfs
${AAI_GVNF_NODES_PATH}      /nodes/generic-vnfs
${AAI_CSIT_GVNF_BODY}=    robot/assets/templates/aai/csit-generic-vnf.template
${AAI_GVNF_API_NA_INDEX_PATH}=  ${AAI_BEIJING_INDEX_PATH}
${AAI_GVNF_API_IMPL_INDEX_PATH}=  ${AAI_DUBLIN_INDEX_PATH}
# ${AAI_GVNF_API_IMPL_INDEX_PATH}=  ${AAI_CASABLANCA_INDEX_PATH}

*** Keywords ***
Create GenericVnf If Not Exists
    [Documentation]    Creates GenericVnf in AAI if it doesn't exist
    [Arguments]    ${vnf_id}  ${vnf_type}
    ${get_resp}=    Run A&AI Get Request     ${AAI_GVNF_API_IMPL_INDEX_PATH}${AAI_GVNF_ROOT_PATH}/${vnf_id}
    Return From Keyword If    '${get_resp.status_code}' == '200'
    Create GenericVnf  ${vnf_id}  ${vnf_type}

Create GenericVnf
    [Documentation]    Creates GenericVnf in AAI
    [Arguments]    ${vnf_id}  ${vnf_type}
    ${arguments}=    Create Dictionary     vnf_id=${vnf_id}  vnf_type=${vnf_type}
    ${data}=    Fill JSON Template File    ${AAI_CSIT_GVNF_BODY}    ${arguments}
    ${put_resp}=    Run A&AI Put Request     ${AAI_GVNF_API_IMPL_INDEX_PATH}${AAI_GVNF_ROOT_PATH}/${vnf_id}     ${data}
    ${status_string}=    Convert To String    ${put_resp.status_code}
    Should Match Regexp    ${status_string}     ^(201|200)$

Delete GenericVnf If Exists
    [Documentation]    Removes GenericVnf from AAI if it exists
    [Arguments]    ${vnf_id}
    ${get_resp}=    Run A&AI Get Request     ${AAI_GVNF_API_IMPL_INDEX_PATH}${AAI_GVNF_ROOT_PATH}/${vnf_id}
    Run Keyword If    '${get_resp.status_code}' == '200'    Delete GenericVnf     ${vnf_id}   ${get_resp.json()}

Delete GenericVnf
    [Documentation]    Removes GenericVnf from AAI
    [Arguments]    ${vnf_id}  ${json}
    ${resource_version}=   Catenate   ${json['resource-version']}
    ${put_resp}=    Run A&AI Delete Request    ${AAI_GVNF_API_IMPL_INDEX_PATH}${AAI_GVNF_ROOT_PATH}/${vnf_id}    ${resource_version}
    Should Be Equal As Strings  ${put_resp.status_code}         204

Get GenericVnf
    [Documentation]   Return GenericVnf
    [Arguments]    ${vnf_id}
    ${resp}=    Run A&AI Get Request     ${AAI_GVNF_API_IMPL_INDEX_PATH}${AAI_GVNF_ROOT_PATH}/${vnf_id}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]  ${resp.json()}

Get Valid GenericVnf URL
    [Documentation]   Return Valid GenericVnf URL
    [Arguments]    ${vnf_id}
    ${resp}=    Run A&AI Get Request     ${AAI_GVNF_API_IMPL_INDEX_PATH}${AAI_GVNF_ROOT_PATH}/${vnf_id}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]  ${AAI_GVNF_API_IMPL_INDEX_PATH}${AAI_GVNF_ROOT_PATH}/${vnf_id}

Get Nodes Query GenericVnf
    [Documentation]   Return Nodes query GenericVnf
    [Arguments]    ${vnf_id}
    ${resp}=    Run A&AI Get Request     ${AAI_GVNF_API_IMPL_INDEX_PATH}${AAI_GVNF_NODES_PATH}?vnf-id=${vnf_id}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]  ${resp.json()}

Get Example GenericVnf
    [Documentation]   Return Example GenericVnf
    ${resp}=    Run A&AI Get Request     ${AAI_GVNF_API_IMPL_INDEX_PATH}${AAI_GVNF_EXAMPLES_PATH}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]  ${resp.json()}

Confirm No GenericVnf
    [Documentation]   Confirm No GenericVnf
    [Arguments]    ${vnf_id}
    ${resp}=    Run A&AI Get Request     ${AAI_GVNF_API_IMPL_INDEX_PATH}${AAI_GVNF_ROOT_PATH}/${vnf_id}
    Should Be Equal As Strings  ${resp.status_code}     404

# Not applicable to GenericVnf as it appears in all known API versions
# Confirm API Not Implemented GenericVnf
    # [Documentation]   Confirm latest API version where GenericVnf is not implemented
    # [Arguments]    ${vnf_id}
    # ${resp}=    Run A&AI Get Request     ${AAI_GVNF_API_NA_INDEX_PATH}${AAI_GVNF_ROOT_PATH}/${vnf_id}
    # Should Be Equal As Strings  ${resp.status_code}     400

Add GenericVnf Relationship
    [Documentation]    Adds Relationship to existing GenericVnf in AAI
    [Arguments]    ${vnf_id}  ${related_class_name}  ${related_object_url}
    ${put_resp}=    Add Relationship     ${AAI_GVNF_API_IMPL_INDEX_PATH}${AAI_GVNF_ROOT_PATH}/${vnf_id}  ${related_class_name}  ${related_object_url}

Get GenericVnf RelationshipList
    [Documentation]   Return relationship-list from GenericVnf
    [Arguments]    ${vnf_id}
    ${resp}=    Get RelationshipList     ${AAI_GVNF_API_IMPL_INDEX_PATH}${AAI_GVNF_ROOT_PATH}/${vnf_id}
    [Return]  ${resp}

Get GenericVnf With RelationshipList
    [Documentation]   Return GenericVnf with relationship-list
    [Arguments]    ${vnf_id}
    ${resp}=    Get Object With Depth     ${AAI_GVNF_API_IMPL_INDEX_PATH}${AAI_GVNF_ROOT_PATH}/${vnf_id}
    [Return]  ${resp}

