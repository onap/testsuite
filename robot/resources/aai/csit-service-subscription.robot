*** Settings ***
Documentation     Operations on service-subscriptions in AAI for BBS use case,
...               using earliest API version where it is implemented
...               and latest API version where it is not implemented.
...               Note that service-subscription is always a sub-object!

Resource    ../json_templater.robot
Resource    aai_interface.robot
Resource    csit-api-version-properties.robot
Resource    csit-relationship-list.robot
Resource    csit-subobject.robot
Library    OperatingSystem
Library    Collections


*** Variables ***
${AAI_SSUBS_CONTAINER_PATH}=  /service-subscriptions
${AAI_SSUBS_SUBOBJECT_PATH}=  /service-subscription
${AAI_SSUBS_UNIQUE_KEY}=      service-type
${AAI_SSUBS_CSIT_BODY}=       robot/assets/templates/aai/csit-service-subscription.template
${AAI_SSUBS_ROOT_PATH}=       ${AAI_BUSINESS_PATH}${AAI_SSUBS_CONTAINER_PATH}${AAI_SSUBS_SUBOBJECT_PATH}
${AAI_SSUBS_API_NA_INDEX_PATH}=    ${AAI_UNSUPPORTED_INDEX_PATH}
${AAI_SSUBS_API_IMPL_INDEX_PATH}=  ${AAI_DUBLIN_INDEX_PATH}
# ${AAI_SSUBS_API_IMPL_INDEX_PATH}=  ${AAI_CASABLANCA_INDEX_PATH}

*** Keywords ***
Create Service Subscription If Not Exists
    [Documentation]    Creates Service Subscription in AAI if it doesn't exist
    [Arguments]    ${api_version_base_object_url}  ${service_type}
    ${get_resp}=    Get SubObject  ${api_version_base_object_url}  ${AAI_SSUBS_CONTAINER_PATH}  ${AAI_SSUBS_SUBOBJECT_PATH}  ${AAI_SSUBS_UNIQUE_KEY}  ${service_type}
    Return From Keyword If    '${get_resp.status_code}' == '200'
    Create Service Subscription  ${api_version_base_object_url}  ${service_type}

Create Service Subscription
    [Documentation]    Creates Service Subscription in AAI
    [Arguments]    ${api_version_base_object_url}  ${service_type}
    ${arguments}=    Create Dictionary     service_type=${service_type}
    ${put_resp}=    Create SubObject  ${api_version_base_object_url}  ${AAI_SSUBS_CONTAINER_PATH}  ${AAI_SSUBS_SUBOBJECT_PATH}  ${service_type}  ${AAI_SSUBS_CSIT_BODY}  ${arguments}

Delete Service Subscription If Exists
    [Documentation]    Removes Service Subscription from AAI if it exists
    [Arguments]    ${api_version_base_object_url}  ${service_type}
    ${get_resp}=    Get SubObject  ${api_version_base_object_url}  ${AAI_SSUBS_CONTAINER_PATH}  ${AAI_SSUBS_SUBOBJECT_PATH}  ${AAI_SSUBS_UNIQUE_KEY}  ${service_type}
    Run Keyword If    '${get_resp.status_code}' == '200'    Delete Service Subscription     ${api_version_base_object_url}  ${service_type}   ${get_resp.json()}

Delete Service Subscription
    [Documentation]    Removes Service Subscription from AAI
    [Arguments]    ${api_version_base_object_url}  ${service_type}  ${json}
    ${del_resp}=    Delete SubObject  ${api_version_base_object_url}  ${AAI_SSUBS_CONTAINER_PATH}  ${AAI_SSUBS_SUBOBJECT_PATH}  ${service_type}  ${json}

Get Service Subscription
    [Documentation]   Return Service Subscription
    [Arguments]    ${api_version_base_object_url}  ${service_type}
    ${get_resp}=    Get SubObject  ${api_version_base_object_url}  ${AAI_SSUBS_CONTAINER_PATH}  ${AAI_SSUBS_SUBOBJECT_PATH}  ${AAI_SSUBS_UNIQUE_KEY}  ${service_type}
    Should Be Equal As Strings  ${get_resp.status_code}     200
    [Return]  ${get_resp.json()}

Get Valid Service Subscription URL
    [Documentation]   Return Valid Service Subscription URL
    [Arguments]    ${api_version_base_object_url}  ${service_type}
    ${resp}=    Get Valid SubObject URL  ${api_version_base_object_url}  ${AAI_SSUBS_CONTAINER_PATH}  ${AAI_SSUBS_SUBOBJECT_PATH}  ${service_type}
    [Return]  ${resp}

Get Nodes Query Service Subscription
    [Documentation]   Return Nodes query Service Subscription
    [Arguments]    ${service_type}
    ${get_resp}=    Confirm Nodes Query SubObjects  ${AAI_SSUBS_API_IMPL_INDEX_PATH}  ${AAI_SSUBS_CONTAINER_PATH}  ${AAI_SSUBS_UNIQUE_KEY}  ${service_type}
    [Return]  ${get_resp.json()}

Get Example Service Subscription
    [Documentation]   Return Example Service Subscription
    ${get_resp}=    Confirm Examples Query SubObjects  ${AAI_SSUBS_API_IMPL_INDEX_PATH}  ${AAI_SSUBS_CONTAINER_PATH}
    [Return]  ${get_resp.json()}

Confirm No Service Subscription
    [Documentation]   Confirm No Service Subscription
    [Arguments]    ${api_version_base_object_url}  ${service_type}
    ${get_resp}=    Get SubObject  ${api_version_base_object_url}  ${AAI_SSUBS_CONTAINER_PATH}  ${AAI_SSUBS_SUBOBJECT_PATH}  ${AAI_SSUBS_UNIQUE_KEY}  ${service_type}
    Should Be Equal As Strings  ${get_resp.status_code}     404

Confirm API Not Implemented Service Subscription
    [Documentation]   Confirm latest API version where Service Subscription is not implemented
    [Arguments]    ${service_type}
    ${resp}=    Confirm API Not Implemented SubObject  ${AAI_SSUBS_API_NA_INDEX_PATH}${AAI_BUSINESS_PATH}  ${AAI_SSUBS_CONTAINER_PATH}  ${AAI_SSUBS_SUBOBJECT_PATH}  ${service_type}

Add Service Subscription Relationship
    [Documentation]    Adds Relationship to existing Service Subscription in AAI
    [Arguments]    ${api_version_base_object_url}  ${service_type}  ${related_class_name}  ${related_object_url}
    ${put_resp}=    Add Relationship     ${api_version_base_object_url}${AAI_SSUBS_ROOT_PATH}/${service_type}  ${related_class_name}  ${related_object_url}

Get Service Subscription RelationshipList
    [Documentation]   Return relationship-list from Service Subscription
    [Arguments]    ${api_version_base_object_url}  ${service_type}
    ${resp}=    Get RelationshipList     ${api_version_base_object_url}${AAI_SSUBS_ROOT_PATH}/${service_type}
    [Return]  ${resp}

Get Service Subscription With RelationshipList
    [Documentation]   Return Service Subscription with relationship-list
    [Arguments]    ${api_version_base_object_url}  ${service_type}
    ${resp}=    Get Object With Depth     ${api_version_base_object_url}${AAI_SSUBS_ROOT_PATH}/${service_type}
    [Return]  ${resp}

