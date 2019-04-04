*** Settings ***
Documentation     Operations on service-instances in AAI for BBS use case,
...               using earliest API version where it is implemented
...               and latest API version where it is not implemented.
...               Note that service-instance is always a sub-object!

Resource    ../json_templater.robot
Resource    aai_interface.robot
Resource    csit-api-version-properties.robot
Resource    csit-relationship-list.robot
Resource    csit-subobject.robot
Library    OperatingSystem
Library    Collections


*** Variables ***
${AAI_SINST_CONTAINER_PATH}=  /service-instances
${AAI_SINST_SUBOBJECT_PATH}=  /service-instance
${AAI_SINST_UNIQUE_KEY}=      service-instance-id
${AAI_SINST_CSIT_BODY}=       robot/assets/templates/aai/csit-service-instance.template
${AAI_SINST_ROOT_PATH}=       ${AAI_BUSINESS_PATH}${AAI_SINST_CONTAINER_PATH}${AAI_SINST_SUBOBJECT_PATH}
${AAI_SINST_API_NA_INDEX_PATH}=    ${AAI_UNSUPPORTED_INDEX_PATH}
${AAI_SINST_API_IMPL_INDEX_PATH}=  ${AAI_DUBLIN_INDEX_PATH}
# ${AAI_SINST_API_IMPL_INDEX_PATH}=  ${AAI_CASABLANCA_INDEX_PATH}

*** Keywords ***
Create Service Instance If Not Exists
    [Documentation]    Creates Service Instance in AAI if it doesn't exist
    [Arguments]    ${api_version_base_object_url}  ${service_instance_id}
    ${get_resp}=    Get SubObject  ${api_version_base_object_url}  ${AAI_SINST_CONTAINER_PATH}  ${AAI_SINST_SUBOBJECT_PATH}  ${AAI_SINST_UNIQUE_KEY}  ${service_instance_id}
    Return From Keyword If    '${get_resp.status_code}' == '200'
    Create Service Instance  ${api_version_base_object_url}  ${service_instance_id}

Create Service Instance
    [Documentation]    Creates Service Instance in AAI
    [Arguments]    ${api_version_base_object_url}  ${service_instance_id}
    ${arguments}=    Create Dictionary     service_instance_id=${service_instance_id}
    ${put_resp}=    Create SubObject  ${api_version_base_object_url}  ${AAI_SINST_CONTAINER_PATH}  ${AAI_SINST_SUBOBJECT_PATH}  ${service_instance_id}  ${AAI_SINST_CSIT_BODY}  ${arguments}

Delete Service Instance If Exists
    [Documentation]    Removes Service Instance from AAI if it exists
    [Arguments]    ${api_version_base_object_url}  ${service_instance_id}
    ${get_resp}=    Get SubObject  ${api_version_base_object_url}  ${AAI_SINST_CONTAINER_PATH}  ${AAI_SINST_SUBOBJECT_PATH}  ${AAI_SINST_UNIQUE_KEY}  ${service_instance_id}
    Run Keyword If    '${get_resp.status_code}' == '200'    Delete Service Instance     ${api_version_base_object_url}  ${service_instance_id}   ${get_resp.json()}

Delete Service Instance
    [Documentation]    Removes Service Instance from AAI
    [Arguments]    ${api_version_base_object_url}  ${service_instance_id}  ${json}
    ${del_resp}=    Delete SubObject  ${api_version_base_object_url}  ${AAI_SINST_CONTAINER_PATH}  ${AAI_SINST_SUBOBJECT_PATH}  ${service_instance_id}  ${json}

Get Service Instance
    [Documentation]   Return Service Instance
    [Arguments]    ${api_version_base_object_url}  ${service_instance_id}
    ${get_resp}=    Get SubObject  ${api_version_base_object_url}  ${AAI_SINST_CONTAINER_PATH}  ${AAI_SINST_SUBOBJECT_PATH}  ${AAI_SINST_UNIQUE_KEY}  ${service_instance_id}
    Should Be Equal As Strings  ${get_resp.status_code}     200
    [Return]  ${get_resp.json()}

Get Valid Service Instance URL
    [Documentation]   Return Valid Service Instance URL
    [Arguments]    ${api_version_base_object_url}  ${service_instance_id}
    ${resp}=    Get Valid SubObject URL  ${api_version_base_object_url}  ${AAI_SINST_CONTAINER_PATH}  ${AAI_SINST_SUBOBJECT_PATH}  ${service_instance_id}
    [Return]  ${resp}

Get Nodes Query Service Instance
    [Documentation]   Return Nodes query Service Instance
    [Arguments]    ${service_instance_id}
    ${get_resp}=    Confirm Nodes Query SubObjects  ${AAI_SINST_API_IMPL_INDEX_PATH}  ${AAI_SINST_CONTAINER_PATH}  ${AAI_SINST_UNIQUE_KEY}  ${service_instance_id}
    [Return]  ${get_resp.json()}

Get Example Service Instance
    [Documentation]   Return Example Service Instance
    ${get_resp}=    Confirm Examples Query SubObjects  ${AAI_SINST_API_IMPL_INDEX_PATH}  ${AAI_SINST_CONTAINER_PATH}
    [Return]  ${get_resp.json()}

Confirm No Service Instance
    [Documentation]   Confirm No Service Instance
    [Arguments]    ${api_version_base_object_url}  ${service_instance_id}
    ${get_resp}=    Get SubObject  ${api_version_base_object_url}  ${AAI_SINST_CONTAINER_PATH}  ${AAI_SINST_SUBOBJECT_PATH}  ${AAI_SINST_UNIQUE_KEY}  ${service_instance_id}
    Should Be Equal As Strings  ${get_resp.status_code}     404

Confirm API Not Implemented Service Instance
    [Documentation]   Confirm latest API version where Service Instance is not implemented
    [Arguments]    ${service_instance_id}
    ${resp}=    Confirm API Not Implemented SubObject  ${AAI_SINST_API_NA_INDEX_PATH}${AAI_BUSINESS_PATH}  ${AAI_SINST_CONTAINER_PATH}  ${AAI_SINST_SUBOBJECT_PATH}  ${service_instance_id}

Add Service Instance Relationship
    [Documentation]    Adds Relationship to existing Service Instance in AAI
    [Arguments]    ${api_version_base_object_url}  ${service_instance_id}  ${related_class_name}  ${related_object_url}
    ${put_resp}=    Add Relationship     ${api_version_base_object_url}${AAI_SINST_ROOT_PATH}/${service_instance_id}  ${related_class_name}  ${related_object_url}

Get Service Instance RelationshipList
    [Documentation]   Return relationship-list from Service Instance
    [Arguments]    ${api_version_base_object_url}  ${service_instance_id}
    ${resp}=    Get RelationshipList     ${api_version_base_object_url}${AAI_SINST_ROOT_PATH}/${service_instance_id}
    [Return]  ${resp}

Get Service Instance With RelationshipList
    [Documentation]   Return Service Instance with relationship-list
    [Arguments]    ${api_version_base_object_url}  ${service_instance_id}
    ${resp}=    Get Object With Depth     ${api_version_base_object_url}${AAI_SINST_ROOT_PATH}/${service_instance_id}
    [Return]  ${resp}

