*** Settings ***
Documentation	  The main interface for interacting with Policy. It handles low level stuff like managing the http request library and Policy required fields
Library 	      RequestsLibrary
Library           String
Library           Collections
Library           SSHLibrary
Library           OperatingSystem
Library           ONAPLibrary.Templating    WITH NAME    Templating
Resource          global_properties.robot
Resource          ssh/files.robot

*** Variables ***
${POLICY_NEW_HEALTHCHECK_PATH}        /policy/pap/v1/components/healthcheck
${POLICY_NEW_HEALTHCHECK_ENDPOINT}     ${GLOBAL_POLICY_SERVER_PROTOCOL}://${GLOBAL_INJECTED_POLICY_PAP_IP_ADDR}:${GLOBAL_POLICY_HEALTHCHECK_PORT}
${POLICY_TEMPLATES}        policy
${POLICY_API_IP}    ${GLOBAL_INJECTED_POLICY_API_IP_ADDR}
${POLICY_PAP_IP}    ${GLOBAL_INJECTED_POLICY_PAP_IP_ADDR}
${POLICY_PDPX_IP}       ${GLOBAL_INJECTED_POLICY_PDPX_IP_ADDR}
${POLICY_HEALTHCHECK_USERNAME}		${GLOBAL_POLICY_HEALTHCHECK_USERNAME}
${POLICY_HEALTHCHECK_PASSWORD}		${GLOBAL_POLICY_HEALTHCHECK_PASSWORD}
${json_path_policy}     /var/opt/ONAP/robot/assets/policy/
${POLICY_GET_POLICY_URI}        /policy/api/v1/policytypes/onap.policies.controlloop.operational.common.Drools/versions/1.0.0/policies/operational.modifyconfig/versions/1.0.0
${POLICY_CREATE_POLICY_URI}     /policy/api/v1/policytypes/onap.policies.controlloop.operational.common.Drools/versions/1.0.0/policies


*** Keywords ***

Run Policy Health Check
     [Documentation]    Runs Policy Health Check
     ${auth}=    Create List     ${GLOBAL_POLICY_HEALTHCHECK_USERNAME}   ${GLOBAL_POLICY_HEALTHCHECK_PASSWORD}
     Log    Creating session ${POLICY_NEW_HEALTHCHECK_ENDPOINT}
     ${session}=    Create Session  policy  ${POLICY_NEW_HEALTHCHECK_ENDPOINT}   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Get Request   policy  ${POLICY_NEW_HEALTHCHECK_PATH}    headers=${headers}
     Log    Received response from policy ${resp.text}
     Should Be Equal As Strings   ${resp.status_code}   200
     Should Be True   ${resp.json()['healthy']}

Run Policy Pap Get Request
     [Documentation]    Runs Policy Pap Get request
     [Arguments]    ${data_path}
     ${auth}=    Create List   ${POLICY_HEALTHCHECK_USERNAME}    ${POLICY_HEALTHCHECK_PASSWORD}
     Log    Creating session ${GLOBAL_POLICY_SERVER_PROTOCOL}://${POLICY_PAP_IP}:${GLOBAL_POLICY_HEALTHCHECK_PORT}
     ${session}=    Create Session      policy  ${GLOBAL_POLICY_SERVER_PROTOCOL}://${POLICY_PAP_IP}:${GLOBAL_POLICY_HEALTHCHECK_PORT}   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}= 	Get Request 	policy   ${data_path}     headers=${headers}
     Log    Received response from Policy Pap ${resp.text}
     [Return]   ${resp}

Run Policy Api Get Request
     [Documentation]    Runs Policy Api Get request
     [Arguments]    ${data_path}
     ${auth}=    Create List    ${POLICY_HEALTHCHECK_USERNAME}    ${POLICY_HEALTHCHECK_PASSWORD}
     ${session}=    Create Session      policy  ${GLOBAL_POLICY_SERVER_PROTOCOL}://${POLICY_API_IP}:${GLOBAL_POLICY_HEALTHCHECK_PORT}   auth=${auth}
     Log    Creating session ${GLOBAL_POLICY_SERVER_PROTOCOL}://${POLICY_API_IP}:${GLOBAL_POLICY_HEALTHCHECK_PORT}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}= 	Get Request 	policy   ${data_path}     headers=${headers}
     Log    Received response from policy API ${resp.text}
     [Return]    ${resp}

Run Policy Api Post Request
     [Documentation]    Runs Policy Api Post request
     [Arguments]    ${data_path}  ${data}
     ${auth}=    Create List    ${POLICY_HEALTHCHECK_USERNAME}    ${POLICY_HEALTHCHECK_PASSWORD}
     ${session}=    Create Session      policy  ${GLOBAL_POLICY_SERVER_PROTOCOL}://${POLICY_API_IP}:${GLOBAL_POLICY_HEALTHCHECK_PORT}   auth=${auth}
     Log    Creating session ${GLOBAL_POLICY_SERVER_PROTOCOL}://${POLICY_API_IP}:${GLOBAL_POLICY_HEALTHCHECK_PORT}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}= 	Post Request 	policy   ${data_path}     data=${data}    headers=${headers}
     Log    Received response from policy ${resp.text}
     [Return]    ${resp}

Run Policy Pap Post Request
     [Documentation]    Runs Policy Pap Post request
     [Arguments]    ${data_path}  ${data}
     ${auth}=    Create List    ${POLICY_HEALTHCHECK_USERNAME}    ${POLICY_HEALTHCHECK_PASSWORD}
     ${session}=    Create Session      policy  ${GLOBAL_POLICY_SERVER_PROTOCOL}://${POLICY_PAP_IP}:${GLOBAL_POLICY_HEALTHCHECK_PORT}   auth=${auth}
     Log    Creating session ${GLOBAL_POLICY_SERVER_PROTOCOL}://${POLICY_PAP_IP}:${GLOBAL_POLICY_HEALTHCHECK_PORT}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}= 	Post Request 	policy   ${data_path}     data=${data}    headers=${headers}
     Log    Received response from policy ${resp.text}
     [Return]    ${resp}

Undeploy Policy
     [Documentation]    Runs Policy PAP Undeploy a Policy from PDP Groups
     [Arguments]    ${policy_name}
     ${auth}=    Create List    ${POLICY_HEALTHCHECK_USERNAME}    ${POLICY_HEALTHCHECK_PASSWORD}
     ${session}=    Create Session      policy  ${GLOBAL_POLICY_SERVER_PROTOCOL}://${POLICY_PAP_IP}:${GLOBAL_POLICY_HEALTHCHECK_PORT}   auth=${auth}
     Log    Creating session ${GLOBAL_POLICY_SERVER_PROTOCOL}://${POLICY_PAP_IP}:${GLOBAL_POLICY_HEALTHCHECK_PORT}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Delete Request     policy  /policy/pap/v1/pdps/policies/${policy_name}     headers=${headers}
     Log    Received response from policy ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     202

Update vVFWCL Policy
    [Arguments]   ${resource_id}
    Log   Create vFWCL Monitoring Policy
    Create vFirewall Monitoring Policy    ${resource_id}
    Sleep   5s
    Log   Create vFWCL Operational Policy
    ${op_policy_version}=   Create vFirewall Operational Policy   ${resource_id}
    Sleep   5s
    Log   Push vFWCL To PDP Group
    Push vFirewall Policies To PDP Group    ${op_policy_version}
    Sleep    20s
    Log   Validate vFWCL Policy
    Validate the vFWCL Policy

Validate the vFWCL Policy
    ${resp}=   Run Policy Pap Get Request   /policy/pap/v1/pdps
    Log    Received response from policy PAP ${resp.text}
    Should Be Equal As Strings         ${resp.status_code}     200
    ${resp}=   Run Policy Api Get Request   /policy/api/v1/policytypes/onap.policies.monitoring.tcagen2
    Log    Received response from policy API policytypes ${resp.text}
    Should Be Equal As Strings         ${resp.status_code}     200

Create vFirewall Monitoring Policy
    [Arguments]   ${resource_id}
     ${dict}=   Create Dictionary   RESOURCE_ID=${resource_id}
    Templating.Create Environment    policy    ${GLOBAL_TEMPLATE_FOLDER}
     ${data}=   Templating.Apply Template    policy    ${POLICY_TEMPLATES}/vFirewall_policy_monitoring_input_tosca.jinja    ${dict}
     ${resp}=   Run Policy Api Post Request    /policy/api/v1/policytypes/onap.policies.monitoring.tcagen2/versions/1.0.0/policies     ${data}
     Should Be Equal As Strings 	${resp.status_code} 	200

Create vFirewall Operational Policy
    [Arguments]   ${resource_id}
    ${dict}=   Create Dictionary   RESOURCE_ID=${resource_id}
    Templating.Create Environment    policy    ${GLOBAL_TEMPLATE_FOLDER}
    ${data_2}=   Templating.Apply Template    policy    ${POLICY_TEMPLATES}/vFirewall_policy_operational_content_input.jinja   ${dict}
    Log    ${data_2}
    ${resp}=   Run Policy Api Post Request    /policy/api/v1/policytypes/onap.policies.controlloop.operational.common.Drools/versions/1.0.0/policies    ${data_2}
    Should Be Equal As Strings         ${resp.status_code}     200
    [Return]    ${resp.json()['version']}

Update vFWCL Operational and Monitoring Policies
    [Documentation]   Undeploy, Delete and Create Operational and Monitoring policies for vFWCL
    [Arguments]    ${model_invariant_id}
    Run Keyword And Ignore Error     Run Undeploy vFW Monitoring Policy
    Run Keyword And Ignore Error     Run Undeploy Policy
    # Need to wait a little for undeploy
    Validate the vFWCL Policy
    Run Keyword and Ignore Error     Run Delete vFW Monitoring Policy
    Run Keyword And Ignore Error     Run Delete vFW Operational Policy
    Update vVFWCL Policy     ${model_invariant_id}

Push vFirewall Policies To PDP Group
    [Arguments]    ${op_policy_version}
    ${dict}=   Create Dictionary    OP_POLICY_VERSION=${op_policy_version}
    Templating.Create Environment    policy    ${GLOBAL_TEMPLATE_FOLDER}
    ${data}=   Templating.Apply Template    policy    ${POLICY_TEMPLATES}/vFirewall_push.jinja    ${dict}
    ${resp}=   Run Policy Pap Post Request    /policy/pap/v1/pdps/policies   ${data}
    Should Be Equal As Strings    ${resp.status_code}     202

Run Create Policy Post Request
     [Documentation]    Runs Create Policy Post request
     #[Arguments]    ${data}
     ${auth}=    Create List    ${POLICY_HEALTHCHECK_USERNAME}    ${POLICY_HEALTHCHECK_PASSWORD}
     ${session}=    Create Session      policy  ${GLOBAL_POLICY_SERVER_PROTOCOL}://${POLICY_API_IP}:${GLOBAL_POLICY_HEALTHCHECK_PORT}   auth=${auth}
     Log    Creating session ${GLOBAL_POLICY_SERVER_PROTOCOL}://${POLICY_API_IP}:${GLOBAL_POLICY_HEALTHCHECK_PORT}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${json_policy}      Get Binary File          ${json_path_policy}create_policy.json
     ${resp}=   Post Request    policy   ${POLICY_CREATE_POLICY_URI}     data=${json_policy}    headers=${headers}
     Log    Received response from policy ${resp.text}
     [Return]    ${resp}
     Should Be Equal As Strings    ${resp.status_code}     200

Run Get Policy Get Request
     [Documentation]    Runs Get Policy request
     #[Arguments]    ${data}
     ${auth}=    Create List    ${POLICY_HEALTHCHECK_USERNAME}    ${POLICY_HEALTHCHECK_PASSWORD}
     ${session}=    Create Session      policy  ${GLOBAL_POLICY_SERVER_PROTOCOL}://${POLICY_API_IP}:${GLOBAL_POLICY_HEALTHCHECK_PORT}   auth=${auth}
     Log    Creating session ${GLOBAL_POLICY_SERVER_PROTOCOL}://${POLICY_API_IP}:${GLOBAL_POLICY_HEALTHCHECK_PORT}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Get Request    policy   ${POLICY_GET_POLICY_URI}     headers=${headers}
     Log    Received response from policy ${resp.text}
     [Return]    ${resp}
     Should Be Equal As Strings    ${resp.status_code}     200

Run Deploy Policy Pap Post Request
     [Documentation]    Runs Deploy Policy Pap Post request
     #[Arguments]    ${data_path}  ${data}
     ${auth}=    Create List    ${POLICY_HEALTHCHECK_USERNAME}    ${POLICY_HEALTHCHECK_PASSWORD}
     ${session}=    Create Session      policy  ${GLOBAL_POLICY_SERVER_PROTOCOL}://${POLICY_PAP_IP}:${GLOBAL_POLICY_HEALTHCHECK_PORT}   auth=${auth}
     Log    Creating session ${GLOBAL_POLICY_SERVER_PROTOCOL}://${POLICY_PAP_IP}:${GLOBAL_POLICY_HEALTHCHECK_PORT}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${json_deploy}     Get Binary File          ${json_path_policy}deploy_policy.json
     ${resp}=   Post Request    policy   /policy/pap/v1/pdps/policies     data=${json_deploy}    headers=${headers}
     Log    Received response from policy ${resp.text}
     [Return]    ${resp}
     Should Be Equal As Strings    ${resp.status_code}     202

Run Undeploy Policy
     [Documentation]    Runs Policy PAP Undeploy a Policy from PDP Groups
     #[Arguments]    ${policy_name}
     ${auth}=    Create List    ${POLICY_HEALTHCHECK_USERNAME}    ${POLICY_HEALTHCHECK_PASSWORD}
     ${session}=    Create Session      policy  ${GLOBAL_POLICY_SERVER_PROTOCOL}://${POLICY_PAP_IP}:${GLOBAL_POLICY_HEALTHCHECK_PORT}   auth=${auth}
     Log    Creating session ${GLOBAL_POLICY_SERVER_PROTOCOL}://${POLICY_PAP_IP}:${GLOBAL_POLICY_HEALTHCHECK_PORT}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Delete Request     policy  /policy/pap/v1/pdps/policies/operational.modifyconfig     headers=${headers}
     Log    Received response from policy ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     202

Run Undeploy vFW Monitoring Policy
     [Documentation]    Runs Policy PAP Undeploy vFW  Monitoring  Policy from PDP Groups
     #[Arguments]    ${policy_name}
     ${auth}=    Create List    ${POLICY_HEALTHCHECK_USERNAME}    ${POLICY_HEALTHCHECK_PASSWORD}
     ${session}=    Create Session      policy  ${GLOBAL_POLICY_SERVER_PROTOCOL}://${POLICY_PAP_IP}:${GLOBAL_POLICY_HEALTHCHECK_PORT}   auth=${auth}
     Log    Creating session ${GLOBAL_POLICY_SERVER_PROTOCOL}://${POLICY_PAP_IP}:${GLOBAL_POLICY_HEALTHCHECK_PORT}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Delete Request     policy  /policy/pap/v1/pdps/policies/onap.vfirewall.tca     headers=${headers}
     Log    Received response from policy ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     202


Run Delete vFW Monitoring Policy
     [Documentation]    Runs Policy API Undeploy a Monitoring Policy
     #[Arguments]    ${policy_name}
     ${auth}=    Create List    ${POLICY_HEALTHCHECK_USERNAME}    ${POLICY_HEALTHCHECK_PASSWORD}
     ${session}=    Create Session      policy  ${GLOBAL_POLICY_SERVER_PROTOCOL}://${POLICY_API_IP}:${GLOBAL_POLICY_HEALTHCHECK_PORT}   auth=${auth}
     Log    Creating session ${GLOBAL_POLICY_SERVER_PROTOCOL}://${POLICY_API_IP}:${GLOBAL_POLICY_HEALTHCHECK_PORT}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Delete Request     policy   /policy/api/v1/policytypes/onap.policies.monitoring.tcagen2/versions/1.0.0/policies/onap.vfirewall.tca/versions/1.0.0   headers=${headers}
     Log    Received response from policy ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     200

Run Delete vFW Operational Policy
     [Documentation]    Runs Policy API Delete Operational Policy
     #[Arguments]    ${policy_name}
     ${auth}=    Create List    ${POLICY_HEALTHCHECK_USERNAME}    ${POLICY_HEALTHCHECK_PASSWORD}
     ${session}=    Create Session      policy  ${GLOBAL_POLICY_SERVER_PROTOCOL}://${POLICY_API_IP}:${GLOBAL_POLICY_HEALTHCHECK_PORT}   auth=${auth}
     Log    Creating session ${GLOBAL_POLICY_SERVER_PROTOCOL}://${POLICY_API_IP}:${GLOBAL_POLICY_HEALTHCHECK_PORT}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Delete Request     policy   /policy/api/v1/policytypes/onap.policies.controlloop.operational.common.Drools/versions/1.0.0/policies/operational.modifyconfig/versions/1.0.0     headers=${headers}
     Log    Received response from policy ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     200

Run Delete Policy Request
     [Documentation]    Runs Policy Delete request
     #[Arguments]    ${data_path}  ${data}
     ${auth}=    Create List    ${POLICY_HEALTHCHECK_USERNAME}    ${POLICY_HEALTHCHECK_PASSWORD}
     ${session}=    Create Session      policy  ${GLOBAL_POLICY_SERVER_PROTOCOL}://${POLICY_API_IP}:${GLOBAL_POLICY_HEALTHCHECK_PORT}   auth=${auth}
     Log    Creating session ${GLOBAL_POLICY_SERVER_PROTOCOL}://${POLICY_API_IP}:${GLOBAL_POLICY_HEALTHCHECK_PORT}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Delete Request  policy  ${POLICY_GET_POLICY_URI}    headers=${headers}
     Log    Received response from policy ${resp.text}
     [Return]    ${resp}
     Should Be Equal As Strings    ${resp.status_code}     200
