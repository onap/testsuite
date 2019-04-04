*** Settings ***
Documentation     Operations on customers in AAI for BBS use case,
...               using earliest API version where it is implemented
...               and latest API version where it is not implemented

Resource    ../json_templater.robot
Resource    aai_interface.robot
Resource    csit-api-version-properties.robot
Resource    csit-relationship-list.robot
Resource    csit-subobject.robot
Library    OperatingSystem
Library    Collections


*** Variables ***
${AAI_CUST_CONTAINER_PATH}=  /customers
${AAI_CUST_SUBOBJECT_PATH}=  /customer
${AAI_CUST_UNIQUE_KEY}=      global-customer-id
${AAI_CUST_CSIT_BODY}=       robot/assets/templates/aai/csit-customer.template
${AAI_CUST_ROOT_PATH}=       ${AAI_BUSINESS_PATH}${AAI_CUST_CONTAINER_PATH}${AAI_CUST_SUBOBJECT_PATH}
${AAI_CUST_API_NA_INDEX_PATH}=    ${AAI_UNSUPPORTED_INDEX_PATH}
${AAI_CUST_API_IMPL_INDEX_PATH}=  ${AAI_DUBLIN_INDEX_PATH}
# ${AAI_CUST_API_IMPL_INDEX_PATH}=  ${AAI_CASABLANCA_INDEX_PATH}

*** Keywords ***
Create Customer If Not Exists
    [Documentation]    Creates Customer in AAI if it doesn't exist
    [Arguments]    ${global_customer_id}  ${subscriber_name}  ${subscriber_type}
    ${get_resp}=    Get SubObject  ${AAI_CUST_API_IMPL_INDEX_PATH}${AAI_BUSINESS_PATH}  ${AAI_CUST_CONTAINER_PATH}  ${AAI_CUST_SUBOBJECT_PATH}  ${AAI_CUST_UNIQUE_KEY}  ${global_customer_id}
    Return From Keyword If    '${get_resp.status_code}' == '200'
    Create Customer  ${global_customer_id}  ${subscriber_name}  ${subscriber_type}

Create Customer
    [Documentation]    Creates Customer in AAI
    [Arguments]    ${global_customer_id}  ${subscriber_name}  ${subscriber_type}
    ${arguments}=    Create Dictionary     global_customer_id=${global_customer_id}  subscriber_name=${subscriber_name}  subscriber_type=${subscriber_type}
    ${put_resp}=    Create SubObject  ${AAI_CUST_API_IMPL_INDEX_PATH}${AAI_BUSINESS_PATH}  ${AAI_CUST_CONTAINER_PATH}  ${AAI_CUST_SUBOBJECT_PATH}  ${global_customer_id}  ${AAI_CUST_CSIT_BODY}  ${arguments}

Delete Customer If Exists
    [Documentation]    Removes Customer from AAI if it exists
    [Arguments]    ${global_customer_id}
    ${get_resp}=    Get SubObject  ${AAI_CUST_API_IMPL_INDEX_PATH}${AAI_BUSINESS_PATH}  ${AAI_CUST_CONTAINER_PATH}  ${AAI_CUST_SUBOBJECT_PATH}  ${AAI_CUST_UNIQUE_KEY}  ${global_customer_id}
    Run Keyword If    '${get_resp.status_code}' == '200'    Delete Customer     ${global_customer_id}   ${get_resp.json()}

Delete Customer
    [Documentation]    Removes Customer from AAI
    [Arguments]    ${global_customer_id}  ${json}
    ${del_resp}=    Delete SubObject  ${AAI_CUST_API_IMPL_INDEX_PATH}${AAI_BUSINESS_PATH}  ${AAI_CUST_CONTAINER_PATH}  ${AAI_CUST_SUBOBJECT_PATH}  ${global_customer_id}  ${json}

Get Customer
    [Documentation]   Return Customer
    [Arguments]    ${global_customer_id}
    ${get_resp}=    Get SubObject  ${AAI_CUST_API_IMPL_INDEX_PATH}${AAI_BUSINESS_PATH}  ${AAI_CUST_CONTAINER_PATH}  ${AAI_CUST_SUBOBJECT_PATH}  ${AAI_CUST_UNIQUE_KEY}  ${global_customer_id}
    Should Be Equal As Strings  ${get_resp.status_code}     200
    [Return]  ${get_resp.json()}

Get Valid Customer URL
    [Documentation]   Return Valid Customer URL
    [Arguments]    ${global_customer_id}
    ${resp}=    Get Valid SubObject URL  ${AAI_CUST_API_IMPL_INDEX_PATH}${AAI_BUSINESS_PATH}  ${AAI_CUST_CONTAINER_PATH}  ${AAI_CUST_SUBOBJECT_PATH}  ${global_customer_id}
    [Return]  ${resp}

Get Nodes Query Customer
    [Documentation]   Return Nodes query Customer
    [Arguments]    ${global_customer_id}
    ${get_resp}=    Confirm Nodes Query SubObjects  ${AAI_CUST_API_IMPL_INDEX_PATH}  ${AAI_CUST_CONTAINER_PATH}  ${AAI_CUST_UNIQUE_KEY}  ${global_customer_id}
    [Return]  ${get_resp.json()}

Get Example Customer
    [Documentation]   Return Example Customer
    ${get_resp}=    Confirm Examples Query SubObjects  ${AAI_CUST_API_IMPL_INDEX_PATH}  ${AAI_CUST_CONTAINER_PATH}
    [Return]  ${get_resp.json()}

Confirm No Customer
    [Documentation]   Confirm No Customer
    [Arguments]    ${global_customer_id}
    ${get_resp}=    Get SubObject  ${AAI_CUST_API_IMPL_INDEX_PATH}${AAI_BUSINESS_PATH}  ${AAI_CUST_CONTAINER_PATH}  ${AAI_CUST_SUBOBJECT_PATH}  ${AAI_CUST_UNIQUE_KEY}  ${global_customer_id}
    Should Be Equal As Strings  ${get_resp.status_code}     404

Confirm API Not Implemented Customer
    [Documentation]   Confirm latest API version where Customer is not implemented
    [Arguments]    ${global_customer_id}
    ${resp}=    Confirm API Not Implemented SubObject  ${AAI_CUST_API_NA_INDEX_PATH}${AAI_BUSINESS_PATH}  ${AAI_CUST_CONTAINER_PATH}  ${AAI_CUST_SUBOBJECT_PATH}  ${global_customer_id}

Add Customer Relationship
    [Documentation]    Adds Relationship to existing Customer in AAI
    [Arguments]    ${global_customer_id}  ${related_class_name}  ${related_object_url}
    ${put_resp}=    Add Relationship     ${AAI_CUST_API_IMPL_INDEX_PATH}${AAI_CUST_ROOT_PATH}/${global_customer_id}  ${related_class_name}  ${related_object_url}

Get Customer RelationshipList
    [Documentation]   Return relationship-list from Customer
    [Arguments]    ${global_customer_id}
    ${resp}=    Get RelationshipList     ${AAI_CUST_API_IMPL_INDEX_PATH}${AAI_CUST_ROOT_PATH}/${global_customer_id}
    [Return]  ${resp}

Get Customer With RelationshipList
    [Documentation]   Return Customer with relationship-list
    [Arguments]    ${global_customer_id}
    ${resp}=    Get Object With Depth     ${AAI_CUST_API_IMPL_INDEX_PATH}${AAI_CUST_ROOT_PATH}/${global_customer_id}
    [Return]  ${resp}

