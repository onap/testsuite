*** Settings ***
Documentation	  Validate A&AI Serivce Instance

Resource          aai_interface.robot
Library    Collections
Library    ONAPLibrary.AAI    WITH NAME    AAI

*** Variables ***
${INDEX_PATH}     /aai/v11
${CUSTOMER_SPEC_PATH}    /business/customers/customer/
${SERVICE_SUBSCRIPTIONS}    /service-subscriptions/service-subscription/
${SERVICE_INSTANCE}    /service-instances?service-instance-name=

*** Keywords ***
Validate Network
    [Documentation]    Query and Validates A&AI Service Instance
    [Arguments]    ${service_instance_name}    ${service_type}  ${customer_id}
    ${auth}=  Create List  ${GLOBAL_AAI_USERNAME}    ${GLOBAL_AAI_PASSWORD}
	${resp}=    AAI.Run Get Request      ${AAI_FRONTEND_ENDPOINT}    ${INDEX_PATH}${CUSTOMER_SPEC_PATH}${customer_id}${SERVICE_SUBSCRIPTIONS}${service_type}${SERVICE_INSTANCE}${service_instance_name}        auth=${auth}
    Dictionary Should Contain Value	${resp.json()['service-instance'][0]}    ${service_instance_name}

Create Network
    [Documentation]    Query and Validates A&AI Service Instance
    [Arguments]    ${customer_id}
    ${auth}=  Create List  ${GLOBAL_AAI_USERNAME}    ${GLOBAL_AAI_PASSWORD}
    ${json_string}=    Catenate     { "service-type": "VDNS" , "service-subscriptions":[{"service-instance-id":"instanceid123","service-instance-name":"VDNS"}]}
	${put_resp}=    AAI.Run Put Request     ${AAI_FRONTEND_ENDPOINT}    ${INDEX_PATH}${CUSTOMER_SPEC_PATH}${customer_id}${SERVICE_SUBSCRIPTIONS}/VDNS    ${json_string}        auth=${auth}
    Should Be Equal As Strings 	${put_resp.status_code} 	201
	[Return]  ${put_resp.status_code}