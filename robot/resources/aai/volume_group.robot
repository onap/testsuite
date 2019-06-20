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
Validate Volume Group
    [Arguments]    ${service_instance_name}    ${service_type}  ${customer_id}
	${resp}=    Run A&AI Get Request      ${INDEX_PATH}${CUSTOMER_SPEC_PATH}${customer_id}${SERVICE_SUBSCRIPTIONS}${service_type}${SERVICE_INSTANCE}${service_instance_name}
    Dictionary Should Contain Value	${resp.json()['service-instance'][0]}    ${service_instance_name}