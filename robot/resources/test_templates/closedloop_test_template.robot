*** Settings ***
Documentation	  Policy Closed Loop Test cases

Resource        ../policy_interface.robot
Resource        ../stack_validation/policy_check_vfw.robot
Resource        ../stack_validation/packet_generator_interface.robot
Resource        vnf_orchestration_test_template.robot

Library    String
Library    Process
Library    ONAPLibrary.Templating

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

#********** Test Case Variables ************
${DNSSCALINGSTACK}

*** Keywords ***
VFW Policy
    Log    Suite name ${SUITE NAME} ${TEST NAME} ${PREV TEST NAME}
    Initialize VFW Policy
    ${stackname}=   Orchestrate VNF vFW closedloop
    Policy Check FirewallCL Stack    ${stackname}    ${VFWPOLICYRATE}
    # there is none of this
    Delete VNF    ${None}     ${None}

VDNS Policy
    Initialize VDNS Policy
    ${stackname}=   Orchestrate VNF vDNS closedloop
    ${dnsscaling}=   Policy Check vLB Stack    ${stackname}    ${VLBPOLICYRATE}
    Set Test Variable   ${DNSSCALINGSTACK}   ${dnsscaling}
    # there is none of this
    Delete VNF    ${None}     ${None}

Initialize VFW Policy
#    Create Config Policy
#    Push Config Policy    ${CONFIG_POLICY_NAME}    ${CONFIG_POLICY_TYPE}
#    Create Ops Policy
#    Push Ops Policy    ${OPS_POLICY_NAME}    ${OPS_POLICY_TYPE}
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
    Terminate All Processes
    Teardown VNF
    Log     Teardown complete

Create Config Policy
    [Documentation]    Create Config Policy
    ${randompolicyname} =     Create Policy Name
    ${policyname1}=    Catenate   com.${randompolicyname}
    ${CONFIG_POLICY_NAME}=    Set Test Variable    ${policyname1}
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
	${OPS_POLICY_NAME}=    Set Test Variable    ${policyname1}
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
	${stack_name}=  Orchestrate VNF   ETE_CLP    vFWCL      vFWCL   ${tenant_id}    ${tenant_name}
	[Return]  ${stack_name}

 Orchestrate VNF vDNS closedloop
	[Documentation]    VNF Orchestration for vLB
	Log    VNF Orchestration flow TEST NAME=${TEST NAME}
	${tenant_id}    ${tenant_name}=    Setup Orchestrate VNF    ${GLOBAL_AAI_CLOUD_OWNER}   SharedNode    OwnerType    v1    CloudZone
	${stack_name}=  Orchestrate VNF   ETE_CLP    vLB      vLB   ${tenant_id}    ${tenant_name}
	[Return]  ${stack_name}

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
