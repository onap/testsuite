*** Settings ***
Documentation	  Validate A&AI Serivce Instance

Resource          aai_interface.robot
Library    Collections
Library    OperatingSystem
Library    RequestsLibrary
Library    ONAPLibrary.JSON
Library    ONAPLibrary.Templating    WITH NAME    Templating
Library    ONAPLibrary.AAI    WITH NAME    AAI
Resource          ../stack_validation/validate_vlb.robot
Resource          ../stack_validation/validate_vfw.robot
Resource          ../stack_validation/validate_vvg.robot
Resource          ../aai/aai_interface.robot

*** Variables ***
${INDEX PATH}     /aai/v11
${GENERIC_QUERY_PATH}  /search/generic-query?
${SYSTEM USER}    robot-ete
${CUSTOMER SPEC PATH}    /business/customers/customer/
${SERVICE SUBSCRIPTIONS}    /service-subscriptions/service-subscription/
${SERVICE INSTANCE}    /service-instances?service-instance-id=
${SERVCE INSTANCE TEMPLATE}    aai/service_subscription.jinja

${GENERIC_VNF_PATH_TEMPLATE}   /network/generic-vnfs/generic-vnf/\${vnf_id}/vf-modules/vf-module/\${vf_module_id}
${GENERIC_VNF_QUERY_TEMPLATE}   /network/generic-vnfs/generic-vnf/\${vnf_id}/vf-modules/vf-module?vf-module-name=\${vf_module_name}

*** Keywords ***
Validate Service Instance
    [Documentation]    Query and Validates A&AI Service Instance
    [Arguments]    ${service_instance_name}    ${service_type}  ${customer_name}
    ${auth}=  Create List  ${GLOBAL_AAI_USERNAME}    ${GLOBAL_AAI_PASSWORD}
    ${cust_resp}=    AAI.Run Get Request      ${AAI_FRONTEND_ENDPOINT}    ${INDEX PATH}/business/customers?subscriber-name=${customer_name}        auth=${auth
	${resp}=    AAI.Run Get Request      ${AAI_FRONTEND_ENDPOINT}    ${INDEX PATH}${CUSTOMER SPEC PATH}${cust_resp.json()['customer'][0]['global-customer-id']}${SERVICE SUBSCRIPTIONS}${service_type}${SERVICE INSTANCE}${service_instance_name}        auth=${auth
    Dictionary Should Contain Value	${resp.json()['service-instance'][0]}    ${service_instance_name}

Validate Generic VNF
    [Documentation]    Query and Validates A&AI Service Instance
    [Arguments]    ${vnf_name}  ${vnf_type}    ${service_instance_id}
    ${auth}=  Create List  ${GLOBAL_AAI_USERNAME}    ${GLOBAL_AAI_PASSWORD}
    ${generic_vnf}=    AAI.Run Get Request      ${AAI_FRONTEND_ENDPOINT}    ${INDEX PATH}/network/generic-vnfs/generic-vnf?vnf-name=${vnf_name}        auth=${auth
    Dictionary Should Contain Value	${generic_vnf.json()}    ${vnf_name}
    ${returned_vnf_type}=    Get From Dictionary    ${generic_vnf.json()}    vnf-type
    Should Contain	${returned_vnf_type}    ${vnf_type}
    ${vnf_id}=    Get From Dictionary    ${generic_vnf.json()}    vnf-id
    ${generic_vnf}=    AAI.Run Get Request      ${AAI_FRONTEND_ENDPOINT}    ${INDEX PATH}/network/generic-vnfs/generic-vnf/${vnf_id}?depth=all        auth=${auth
    [Return]    ${generic_vnf.json()}

Validate VF Module
    [Documentation]    Query and Validates A&AI Service Instance
    [Arguments]    ${vf_module_name}    ${stack_type}
	Run Keyword If    '${stack_type}'=='vLB'    Validate vLB Stack    ${vf_module_name}
	Run Keyword If    '${stack_type}'=='vFW'    Validate Firewall Stack    ${vf_module_name}
	Run Keyword If    '${stack_type}'=='vVG'    Validate vVG Stack    ${vf_module_name}