*** Settings ***
Documentation     Operations on customers in AAI for BBS use case,
...     using earliest API version where changes are implemented and
...     latest API version where changes are not implemented

Resource    ../json_templater.robot
Resource    aai_interface.robot
Resource    csit-api-version-properties.robot
Resource    csit-relationship-list.robot
Library    OperatingSystem
Library    Collections


*** Variables ***
${AAI_CUST_ROOT_PATH}      /business/customers/customer
${AAI_CUST_EXAMPLES_PATH}      /examples/customers
${AAI_CUST_NODES_PATH}      /nodes/customers
${AAI_CSIT_CUSTOMER_BODY}=    robot/assets/templates/aai/csit-customer.template
${AAI_CUST_API_NA_INDEX_PATH}=  ${AAI_BEIJING_INDEX_PATH}
${AAI_CUST_API_IMPL_INDEX_PATH}=  ${AAI_DUBLIN_INDEX_PATH}
# ${AAI_CUST_API_IMPL_INDEX_PATH}=  ${AAI_CASABLANCA_INDEX_PATH}

*** Keywords ***
Create Customer If Not Exists
    [Documentation]    Creates Customer in AAI if it doesn't exist
    [Arguments]    ${global_customer_id}  ${subscriber_name}  ${subscriber_type}
    ${get_resp}=    Run A&AI Get Request     ${AAI_CUST_API_IMPL_INDEX_PATH}${AAI_CUST_ROOT_PATH}/${global_customer_id}
    Return From Keyword If    '${get_resp.status_code}' == '200'
    Create Customer  ${global_customer_id}  ${subscriber_name}  ${subscriber_type}

Create Customer
    [Documentation]    Creates Customer in AAI
    [Arguments]    ${global_customer_id}  ${subscriber_name}  ${subscriber_type}
    ${arguments}=    Create Dictionary     global_customer_id=${global_customer_id}  subscriber_name=${subscriber_name}  subscriber_type=${subscriber_type}
    ${data}=    Fill JSON Template File    ${AAI_CSIT_CUSTOMER_BODY}    ${arguments}
    ${put_resp}=    Run A&AI Put Request     ${AAI_CUST_API_IMPL_INDEX_PATH}${AAI_CUST_ROOT_PATH}/${global_customer_id}     ${data}
    ${status_string}=    Convert To String    ${put_resp.status_code}
    Should Match Regexp    ${status_string}     ^(201|200)$

Delete Customer If Exists
    [Documentation]    Removes Customer from AAI if it exists
    [Arguments]    ${global_customer_id}
    ${get_resp}=    Run A&AI Get Request     ${AAI_CUST_API_IMPL_INDEX_PATH}${AAI_CUST_ROOT_PATH}/${global_customer_id}
    Run Keyword If    '${get_resp.status_code}' == '200'    Delete Customer     ${global_customer_id}   ${get_resp.json()}

Delete Customer
    [Documentation]    Removes Customer from AAI
    [Arguments]    ${global_customer_id}  ${json}
    ${resource_version}=   Catenate   ${json['resource-version']}
    ${put_resp}=    Run A&AI Delete Request    ${AAI_CUST_API_IMPL_INDEX_PATH}${AAI_CUST_ROOT_PATH}/${global_customer_id}    ${resource_version}
    Should Be Equal As Strings  ${put_resp.status_code}         204

Get Customer
    [Documentation]   Return Customer
    [Arguments]    ${global_customer_id}
    ${resp}=    Run A&AI Get Request     ${AAI_CUST_API_IMPL_INDEX_PATH}${AAI_CUST_ROOT_PATH}/${global_customer_id}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]  ${resp.json()}

Get Valid Customer URL
    [Documentation]   Return Valid Customer URL
    [Arguments]    ${global_customer_id}
    ${resp}=    Run A&AI Get Request     ${AAI_CUST_API_IMPL_INDEX_PATH}${AAI_CUST_ROOT_PATH}/${global_customer_id}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]  ${AAI_CUST_API_IMPL_INDEX_PATH}${AAI_CUST_ROOT_PATH}/${global_customer_id}

Get Nodes Query Customer
    [Documentation]   Return Nodes query Customer
    [Arguments]    ${global_customer_id}
    ${resp}=    Run A&AI Get Request     ${AAI_CUST_API_IMPL_INDEX_PATH}${AAI_CUST_NODES_PATH}?global-customer-id=${global_customer_id}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]  ${resp.json()}

Get Example Customer
    [Documentation]   Return Example Customer
    ${resp}=    Run A&AI Get Request     ${AAI_CUST_API_IMPL_INDEX_PATH}${AAI_CUST_EXAMPLES_PATH}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]  ${resp.json()}

Confirm No Customer
    [Documentation]   Confirm No Customer
    [Arguments]    ${global_customer_id}
    ${resp}=    Run A&AI Get Request     ${AAI_CUST_API_IMPL_INDEX_PATH}${AAI_CUST_ROOT_PATH}/${global_customer_id}
    Should Be Equal As Strings  ${resp.status_code}     404

# Not applicable to Customer as it appears in all known API versions
# Confirm API Not Implemented Customer
    # [Documentation]   Confirm latest API version where Customer is not implemented
    # [Arguments]    ${global_customer_id}
    # ${resp}=    Run A&AI Get Request     ${AAI_CUST_API_NA_INDEX_PATH}${AAI_CUST_ROOT_PATH}/${global_customer_id}
    # Should Be Equal As Strings  ${resp.status_code}     400

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

