*** Settings ***
Documentation	  Policy Closed Loop Test cases

Resource        ../stack_validation/policy_check_vfw.robot

Library    String
Library    Process
Library    ONAPLibrary.Templating
Library    ONAPLibrary.Utilities

*** Variables ***
${RESOURCE_PATH_CREATE}        /pdp/createPolicy
${RESOURCE_PATH_CREATE_PUSH}        /pdp/pushPolicy
${RESOURCE_PATH_CREATE_DELETE}        /pdp/deletePolicy
${RESOURCE_PATH_GET_CONFIG}    /pdp/getConfig
${CREATE_CONFIG_TEMPLATE}    policy/closedloop_configpolicy.jinja
${CREATE_OPS_TEMPLATE}    policy/closedloop_opspolicy.jinja
${PUSH_POLICY_TEMPLATE}   policy/closedloop_pushpolicy.jinja
${DEL_POLICY_TEMPLATE}   policy/closedloop_deletepolicy.jinja
${GECONFIG_VFW_TEMPLATE}    policy/closedloop_getconfigpolicy.jinja

# 'Normal' number of pg streams that will be set when policy is triggered
${VFWPOLICYRATE}    5

# Max nslookup requests per second before triggering event.
${VLBPOLICYRATE}    20

${CONFIG_POLICY_NAME}    vFirewall
${CONFIG_POLICY_TYPE}    Unknown
${OPS_POLICY_NAME}
${OPS_POLICY_TYPE}    BRMS_PARAM

# VFW low threshold
${Expected_Severity_1}    MAJOR
${Expected_Threshold_1}    300
${Expected_Direction_1}    LESS_OR_EQUAL

# VFW high threshold
${Expected_Severity_2}    CRITICAL
${Expected_Threshold_2}    700
${Expected_Direction_2}    GREATER_OR_EQUAL

# VDNS High threshold
${Expected_Severity_3}    MAJOR
${Expected_Threshold_3}    200
${Expected_Direction_3}    GREATER_OR_EQUAL

*** Keywords ***
VFW Policy
    Log    Suite name ${SUITE NAME} ${TEST NAME} ${PREV TEST NAME}
    Initialize VFW Policy
    ${stackname}   ${generic_vnfs}    ${server_id}    ${service_instance_id}    ${customer_name}    ${uris_to_delete}=   Orchestrate VNF vFW closedloop
    Policy Check FirewallCL Stack    ${stackname}    ${VFWPOLICYRATE}
    Delete VNF    ${None}     ${server_id}    ${customer_name}    ${service_instance_id}    ${stackname}    ${uris_to_delete}

VDNS Policy
    Initialize VDNS Policy
    ${stackname}   ${generic_vnfs}    ${server_id}    ${service_instance_id}    ${customer_name}    ${uris_to_delete}=   Orchestrate VNF vDNS closedloop
    ${dnsscaling}=   Policy Check vLB Stack    ${stackname}    ${VLBPOLICYRATE}
    Delete VNF    ${None}     ${server_id}    ${customer_name}    ${service_instance_id}    ${stackname}    ${uris_to_delete}

Initialize VFW Policy
     Get Configs VFW Policy

Initialize VDNS Policy
    Get Configs VDNS Policy

Get Configs VFW Policy
    [Documentation]    Get Config Policy for VFW
    ${getconfigpolicy}=    Catenate    .*${CONFIG_POLICY_NAME}*
    ${configpolicy_name}=    Create Dictionary    config_policy_name=${getconfigpolicy}
    Create Environment    cl    ${GLOBAL_TEMPLATE_FOLDER}
    ${output}=   Apply Template    cl    ${GECONFIG_VFW_TEMPLATE}    ${configpolicy_name}
    ${get_resp} =    Run Policy Get Configs Request    ${RESOURCE_PATH_GET_CONFIG}   ${output}
    Should Be Equal As Strings 	 ${get_resp.status_code}  200
    ${config}=    Catenate    ${get_resp.json()[0]["config"]}
    ${thresholds}=    Get Variable Value      ${config["content"]["tca_policy"]["metricsPerEventName"][0]["thresholds"]}

    # Extract object1 from Array
    Should Be Equal    ${thresholds[0]["severity"]}    ${Expected_Severity_1}
    Should Be Equal As Integers   ${thresholds[0]["thresholdValue"]}    ${Expected_Threshold_1}
    Should Be Equal   ${thresholds[0]["direction"]}    ${Expected_Direction_1}

    # Extract object2 from Array
    Should Be Equal    ${thresholds[1]["severity"]}    ${Expected_Severity_2}
    Should Be Equal As Integers   ${thresholds[1]["thresholdValue"]}    ${Expected_Threshold_2}
    Should Be Equal   ${thresholds[1]["direction"]}    ${Expected_Direction_2}

Get Configs VDNS Policy
    [Documentation]    Get Config Policy for VDNS
    ${getconfigpolicy}=    Catenate    .*MicroServicevDNS*
    ${configpolicy_name}=    Create Dictionary    config_policy_name=${getconfigpolicy}
    Create Environment    cl    ${GLOBAL_TEMPLATE_FOLDER}
    ${output}=   Apply Template    cl    ${GECONFIG_VFW_TEMPLATE}    ${configpolicy_name}
    ${get_resp} =    Run Policy Get Configs Request    ${RESOURCE_PATH_GET_CONFIG}   ${output}
    Should Be Equal As Strings  ${get_resp.status_code}  200
    ${config}=    Catenate    ${get_resp.json()[0]["config"]}
    ${thresholds}=    Get Variable Value      ${config["content"]["tca_policy"]["metricsPerEventName"][0]["thresholds"]}

    # Extract object1 from Array
    Should Be Equal    ${thresholds[0]["severity"]}    ${Expected_Severity_2}
    Should Be Equal As Integers   ${thresholds[0]["thresholdValue"]}    ${Expected_Threshold_1}
    Should Be Equal   ${thresholds[0]["direction"]}    ${Expected_Direction_3}

Teardown Closed Loop
    [Documentation]   Tear down a closed loop test case
    [Arguments]    ${customer_name}    ${catalog_service_id}    ${catalog_resource_ids}
    Terminate All Processes
    Teardown VNF    ${customer_name}    ${catalog_service_id}    ${catalog_resource_ids}
    Log     Teardown complete

Create Config Policy
    [Documentation]    Create Config Policy
    ${randompolicyname} =     Create Policy Name
    ${policyname1}=    Catenate   com.${randompolicyname}
    ${CONFIG_POLICY_NAME}=    Catenate    ${policyname1}
    ${configpolicy}=    Create Dictionary    policy_name=${CONFIG_POLICY_NAME}
    Create Environment    cl    ${GLOBAL_TEMPLATE_FOLDER}
    ${output}=   Apply Template    cl    ${CREATE_CONFIG_TEMPLATE}    ${configpolicy}
    ${put_resp} =    Run Policy Put Request    ${RESOURCE_PATH_CREATE}  ${output}
	Should Be Equal As Strings 	${put_resp.status_code} 	200

 Create Policy Name
     [Documentation]    Generate Policy Name
     [Arguments]    ${prefix}=ETE_
     ${random}=    Generate Random String    15    [LOWER][NUMBERS]
     ${policyname}=    Catenate    ${prefix}${random}
     [Return]    ${policyname}

Create Ops Policy
	[Documentation]    Create Opertional Policy
   	${randompolicyname} =     Create Policy Name
	${policyname1}=    Catenate   com.${randompolicyname}
	${OPS_POLICY_NAME}=    Catenate    ${policyname1}
 	${dict}=     Create Dictionary    policy_name=${OPS_POLICY_NAME}
    Create Environment    cl    ${GLOBAL_TEMPLATE_FOLDER}
    ${output}=   Apply Template    cl    ${CREATE_OPS_TEMPLATE}    ${dict}
    ${put_resp} =    Run Policy Put Request    ${RESOURCE_PATH_CREATE}  ${output}
    Log    ${put_resp}
    Should Be Equal As Strings 	${put_resp.status_code} 	200

Push Ops Policy
    [Documentation]    Push Ops Policy
    [Arguments]    ${policyname}    ${policytype}
    ${dict}=     Create Dictionary     policy_name=${policyname}    policy_type=${policytype}
    Create Environment    cl    ${GLOBAL_TEMPLATE_FOLDER}
    ${output}=   Apply Template    cl    ${PUSH_POLICY_TEMPLATE}     ${dict}
    ${put_resp} =    Run Policy Put Request    ${RESOURCE_PATH_CREATE_PUSH}  ${output}
    Should Be Equal As Strings 	${put_resp.status_code} 	200

Push Config Policy
    [Documentation]    Push Config Policy
    [Arguments]    ${policyname}    ${policytype}
    ${dict}=     Create Dictionary     policy_name=${policyname}    policy_type=${policytype}
    Create Environment    cl    ${GLOBAL_TEMPLATE_FOLDER}
    ${output}=   Apply Template    cl    ${PUSH_POLICY_TEMPLATE}     ${dict}
    ${put_resp} =    Run Policy Put Request    ${RESOURCE_PATH_CREATE_PUSH}  ${output}
    Should Be Equal As Strings 	${put_resp.status_code} 	200


Delete Config Policy
    [Documentation]    Delete Config Policy
    [Arguments]    ${policy_name}
    ${policyname3}=    Catenate   com.Config_BRMS_Param_${policyname}.1.xml
    ${dict}=     Create Dictionary     policy_name=${policyname3}
    Create Environment    cl    ${GLOBAL_TEMPLATE_FOLDER}
    ${output}=   Apply Template    cl    ${DEL_POLICY_TEMPLATE}     ${dict}
    ${put_resp} =    Run Policy Delete Request    ${RESOURCE_PATH_CREATE_DELETE}  ${output}
    Should Be Equal As Strings 	${put_resp.status_code} 	200

Delete Ops Policy
    [Documentation]    Delete Ops Policy
    [Arguments]    ${policy_name}
    ${policyname3}=    Catenate   com.Config_MS_com.vFirewall.1.xml
    ${dict}=     Create Dictionary     policy_name=${policyname3}
    Create Environment    cl    ${GLOBAL_TEMPLATE_FOLDER}
    ${output}=   Apply Template    cl    ${DEL_POLICY_TEMPLATE}     ${dict}
    ${put_resp} =    Run Policy Delete Request    ${RESOURCE_PATH_CREATE_DELETE}  ${output}
    Should Be Equal As Strings 	${put_resp.status_code} 	200

Orchestrate VNF vFW closedloop
	[Documentation]    VNF Orchestration for vFW
	Log    VNF Orchestration flow TEST NAME=${TEST NAME}
	${tenant_id}    ${tenant_name}=    Setup Orchestrate VNF    ${GLOBAL_AAI_CLOUD_OWNER}    SharedNode    OwnerType    v1    CloudZone
    ${uuid}=    Generate UUID4
	${vf_module_name_list}   ${generic_vnfs}    ${server_id}    ${service_instance_id}    ${catalog_resource_ids}   ${catalog_service_id}    ${uris_to_delete}=  Orchestrate VNF   ETE_CLP_${uuid}    vFWCL      vFWCL   ${tenant_id}    ${tenant_name}
	${customer_name}=    Catenate    ETE_CLP_${uuid}
	[Return]  ${vf_module_name_list}   ${generic_vnfs}    ${server_id}    ${service_instance_id}    ${customer_name}    ${uris_to_delete}

 Orchestrate VNF vDNS closedloop
	[Documentation]    VNF Orchestration for vLB
	Log    VNF Orchestration flow TEST NAME=${TEST NAME}
	${tenant_id}    ${tenant_name}=    Setup Orchestrate VNF    ${GLOBAL_AAI_CLOUD_OWNER}   SharedNode    OwnerType    v1    CloudZone
    ${uuid}=    Generate UUID4
	${vf_module_name_list}   ${generic_vnfs}    ${server_id}    ${service_instance_id}    ${catalog_resource_ids}   ${catalog_service_id}    ${uris_to_delete}=  Orchestrate VNF   ETE_CLP_${uuid}    vLB      vLB   ${tenant_id}    ${tenant_name}
	${customer_name}=    Catenate    ETE_CLP_${uuid}
	[Return]  ${vf_module_name_list}   ${generic_vnfs}    ${server_id}    ${service_instance_id}    ${customer_name}    ${uris_to_delete}

VFWCL High Test
	[Documentation]    Test Control Loop for High Traffic
        [Arguments]    ${pkg_host}
	Enable Streams V2    ${pkg_host}   10
        Log   Set number of streams to 10
	:FOR    ${i}    IN RANGE    12
	\   Sleep  15s
	\   ${resp}=   Get List Of Enabled Streams V2   ${pkg_host}
        \   ${stream_count}=   Set Variable   ${resp['stream-count']['streams']['active-streams']}
        \   Log   Number of streams: ${stream_count}
        \   Exit For Loop If   '${stream_count}'=='5'
        Should Be Equal As Integers  ${stream_count}   5

VFWCL Low Test
	[Documentation]    Test Control Loop for Low Traffic
        [Arguments]    ${pkg_host}
	Enable Streams V2     ${pkg_host}   1
        Log   Set number of streams to 1
	:FOR    ${i}    IN RANGE    12
	\   Sleep  15s
	\   ${resp}=   Get List Of Enabled Streams V2   ${pkg_host}
        \   ${stream_count}=   Set Variable   ${resp['stream-count']['streams']['active-streams']}
        \   Log   Number of streams: ${stream_count}
        \   Exit For Loop If   '${stream_count}'=='5'
        Should Be Equal As Integers  ${stream_count}   5

VFWCL Set To Medium
	[Documentation]    Set flows to Medium to turn off control loop
        [Arguments]    ${pkg_host}
	Enable Streams V2    ${pkg_host}   5
