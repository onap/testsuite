*** Settings ***
Documentation	  Validate A&AI Serivce Instance

Resource          aai_interface.robot
Library    Collections

*** Variables ***
${INDEX_PATH}     /aai/v11
${CUSTOMER_SPEC_PATH}    /business/customers/customer/
${SERVICE_SUBSCRIPTIONS}    /service-subscriptions/service-subscription/
${SERVICE_INSTANCE}    /service-instances?service-instance-name=

*** Keywords ***
Validate Network
    [Documentation]    Query and Validates A&AI Service Instance
    [Arguments]    ${service_instance_name}    ${service_type}  ${customer_id}
	${resp}=    Run A&AI Get Request      ${INDEX_PATH}${CUSTOMER_SPEC_PATH}${customer_id}${SERVICE_SUBSCRIPTIONS}${service_type}${SERVICE_INSTANCE}${service_instance_name}
    Dictionary Should Contain Value	${resp.json()['service-instance'][0]}    ${service_instance_name}



*** Keywords ***
Create Network
    [Documentation]    Query and Validates A&AI Service Instance
    [Arguments]    ${customer_id}
    ${json_string}=    Catenate     { "service-type": "VDNS" , "service-subscriptions":[{"service-instance-id":"instanceid123","service-instance-name":"VDNS"}]}
	${put_resp}=    Run A&AI Put Request     ${INDEX_PATH}${CUSTOMER_SPEC_PATH}${customer_id}${SERVICE_SUBSCRIPTIONS}/VDNS    ${json_string}
    Should Be Equal As Strings 	${put_resp.status_code} 	201
	[Return]  ${put_resp.status_code}

