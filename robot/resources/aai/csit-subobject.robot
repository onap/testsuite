*** Settings ***
Documentation     Framework for operations on sub-object in AAI,
...    using specified base URL path including API version where it is implemented
...    and specified sub-object URL path, object templates and parameters

Resource    ../json_templater.robot
Resource    aai_interface.robot
Resource    csit-api-version-properties.robot
Library    OperatingSystem
Library    Collections


*** Variables ***


*** Keywords ***
Create SubObject
    [Documentation]    Creates sub-object in existing object in AAI
    [Arguments]    ${api_version_base_object_url}  ${container_path}  ${subobject_path}  ${uniquekey_value}  ${subobject_template}  ${subobject_params}
    ${data}=    Fill JSON Template File    ${subobject_template}    ${subobject_params}
    ${put_resp}=    Run A&AI Put Request  ${api_version_base_object_url}${container_path}${subobject_path}/${uniquekey_value}  ${data}
    Log    Put response ${put_resp.text}
    ${status_string}=    Convert To String    ${put_resp.status_code}
    Should Match Regexp    ${status_string}     ^(201|200)$

Delete SubObject
    [Documentation]    Removes SubObject from existing object in AAI
    [Arguments]    ${api_version_base_object_url}  ${container_path}  ${subobject_path}  ${uniquekey_value}  ${json}
    ${resource_version}=   Catenate   ${json['resource-version']}
    ${del_resp}=    Run A&AI Delete Request  ${api_version_base_object_url}${container_path}${subobject_path}/${uniquekey_value}  ${resource_version}
    Log    Put response ${del_resp.text}
    Should Be Equal As Strings  ${del_resp.status_code}         204

Get SubObjects
    [Documentation]   Return list of sub-objects of the object in AAI
    [Arguments]    ${api_version_base_object_url}  ${container_path}
    ${get_resp}=    Run A&AI Get Request  ${api_version_base_object_url}/${container_path}
    Log    Returning response ${get_resp.json()}
    [Return]  ${get_resp.json()}

Get SubObject
    [Documentation]   Return individual sub-object of the object in AAI
    [Arguments]    ${api_version_base_object_url}  ${container_path}  ${subobject_path}  ${search_key}  ${search_value}
    ${get_resp}=    Run A&AI Get Request  ${api_version_base_object_url}${container_path}${subobject_path}?${search_key}=${search_value}
    Log    Returning response ${get_resp.text}
    [Return]  ${get_resp}

Confirm Nodes Query SubObjects
    [Documentation]   Return Nodes query sub-objects
    [Arguments]    ${api_version_base_url}  ${container_path}  ${search_key}  ${search_value}
    ${nodes_resp}=    Run A&AI Get Request     ${api_version_base_url}${AAI_NODES_PATH}${container_path}?${search_key}=${search_value}
    Should Be Equal As Strings  ${nodes_resp.status_code}     200
    Log    Returning response ${nodes_resp.text}
    [Return]  ${nodes_resp}

Confirm Examples Query SubObjects
    [Documentation]   Return Examples query sub-objects
    [Arguments]    ${api_version_base_url}  ${container_path}
    ${eg_resp}=    Run A&AI Get Request     ${api_version_base_url}${AAI_EXAMPLES_PATH}${container_path}
    Should Be Equal As Strings  ${eg_resp.status_code}     200
    Log    Returning response ${eg_resp.text}
    [Return]  ${eg_resp}

Get Valid SubObject URL
    [Documentation]   Return Valid SubObject URL
    [Arguments]    ${api_version_base_object_url}  ${container_path}  ${subobject_path}  ${uniquekey_value}
    ${resp}=    Run A&AI Get Request  ${api_version_base_object_url}${container_path}${subobject_path}/${uniquekey_value}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]  ${api_version_base_object_url}${container_path}${subobject_path}/${uniquekey_value}

Confirm API Not Implemented SubObject
    [Documentation]   Confirm latest API version where SubObject is not implemented
    [Arguments]    ${api_version_base_object_url}  ${container_path}  ${subobject_path}  ${uniquekey_value}
    ${resp}=    Run A&AI Get Request  ${api_version_base_object_url}${container_path}${subobject_path}/${uniquekey_value}
    Should Be Equal As Strings  ${resp.status_code}     400

