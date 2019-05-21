*** Settings ***
Documentation	  The main interface for interacting with Policy. It handles low level stuff like managing the http request library and Policy required fields
Library	          RequestsClientCert
Library 	      RequestsLibrary
Library           String
Library           JSONUtils
Library           Collections
Library           Collections
Library           SSHLibrary
Library           OperatingSystem
Resource          json_templater.robot
Resource          global_properties.robot
Resource          ssh/files.robot

*** Variables ***
${POLICY_HEALTH_CHECK_PATH}        /healthcheck
${POLICY_ENDPOINT}     ${GLOBAL_POLICY_SERVER_PROTOCOL}://${GLOBAL_INJECTED_POLICY_IP_ADDR}:${GLOBAL_POLICY_SERVER_PORT}
${POLICY_HEALTHCHECK_ENDPOINT}     ${GLOBAL_POLICY_SERVER_PROTOCOL}://${GLOBAL_INJECTED_POLICY_HEALTHCHECK_IP_ADDR}:${GLOBAL_POLICY_HEALTHCHECK_PORT}
${POLICY_TEMPLATES}        robot/assets/templates/policy
${DROOLS_ENDPOINT}     ${GLOBAL_POLICY_SERVER_PROTOCOL}://${GLOBAL_INJECTED_POLICY_IP_ADDR}:${GLOBAL_DROOLS_SERVER_PORT}
${POLICY_API_IP}    ${GLOBAL_INJECTED_POLICY_API_IP_ADDR}
${POLICY_PAP_IP}    ${GLOBAL_INJECTED_POLICY_PAP_IP_ADDR}
${POLICY_DISTRIBUTION_IP}   ${GLOBAL_INJECTED_POLICY_DISTRIBUTION_IP_ADDR}
${POLICY_PDPX_IP}       ${GLOBAL_INJECTED_POLICY_PDPX_IP_ADDR}
${POLICY_APEX_PDP_IP}       ${GLOBAL_INJECTED_POLICY_APEX_PDP_IP_ADDR}
${POLICY_HEALTHCHECK_USERNAME}		${GLOBAL_POLICY_HEALTHCHECK_USERNAME}
${POLICY_HEALTHCHECK_PASSWORD}		${GLOBAL_POLICY_HEALTHCHECK_PASSWORD}


*** Keywords ***

Run Policy Health Check
     [Documentation]    Runs Policy Health check
     ${auth}=    Create List    ${GLOBAL_POLICY_USERNAME}    ${GLOBAL_POLICY_PASSWORD}
     Log    Creating session ${POLICY_ENDPOINT}
     ${session}=    Create Session 	policy 	${POLICY_HEALTHCHECK_ENDPOINT}   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}= 	Get Request 	policy 	${POLICY_HEALTH_CHECK_PATH}     headers=${headers}
     Log    Received response from policy ${resp.text}
     Should Be Equal As Strings 	${resp.status_code} 	200
     Should Be True 	${resp.json()['healthy']}
     @{ITEMS}=    Copy List    ${resp.json()['details']}
     :FOR    ${ELEMENT}    IN    @{ITEMS}
     \    Should Be Equal As Strings 	${ELEMENT['code']} 	200
     \    Should Be True    ${ELEMENT['healthy']}

Run Drools Get Request
     [Documentation]    Runs Drools Get Request
     [Arguments]    ${data_path}
     ${auth}=    Create List    ${GLOBAL_DROOLS_USERNAME}    ${GLOBAL_DROOLS_PASSWORD}
     Log    Creating session ${POLICY_ENDPOINT}
     ${session}=    Create Session      policy  ${DROOLS_ENDPOINT}   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Get Request     policy  ${data_path}     headers=${headers}
     Log    Received response from policy ${resp.text}
     Should Be Equal As Strings         ${resp.status_code}     200
     [Return]   ${resp}

Run Policy Put Request
     [Documentation]    Runs Policy Put request
     [Arguments]    ${data_path}  ${data}
     Log    Creating session ${POLICY_ENDPOINT}
     ${session}=    Create Session 	policy 	${POLICY_ENDPOINT}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json    Authorization=Basic ${GLOBAL_POLICY_AUTH}   ClientAuth=${GLOBAL_POLICY_CLIENTAUTH}    Environment=TEST
     ${resp}= 	Put Request 	policy 	${data_path}     data=${data}    headers=${headers}
     Log    Received response from policy ${resp.text}
     [Return]    ${resp}

Run Policy Get Request
     [Documentation]    Runs Policy Get request
     [Arguments]    ${data_path}
     Log    Creating session ${POLICY_ENDPOINT}
     ${session}=    Create Session 	policy 	${POLICY_ENDPOINT}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json    Authorization=Basic ${GLOBAL_POLICY_AUTH}   ClientAuth=${GLOBAL_POLICY_CLIENTAUTH}    Environment=TEST
     ${resp}= 	Get Request 	policy   ${data_path}     headers=${headers}
     Log    Received response from policy ${resp.text}

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


Run Policy Post Request
     [Documentation]    Runs Policy Post request
     [Arguments]    ${data_path}  ${data}
     Log    Creating session ${POLICY_ENDPOINT}
     ${session}=    Create Session 	policy 	${POLICY_ENDPOINT}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json    Authorization=Basic ${GLOBAL_POLICY_AUTH}   ClientAuth=${GLOBAL_POLICY_CLIENTAUTH}    Environment=TEST
     ${resp}= 	Post Request 	policy   ${data_path}     data=${data}    headers=${headers}
     Log    Received response from policy ${resp.text}
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


Run Policy Delete Request
     [Documentation]    Runs Policy Delete request
     [Arguments]    ${data_path}  ${data}
     Log    Creating session ${POLICY_ENDPOINT}
     ${session}=    Create Session 	policy 	${POLICY_ENDPOINT}
     ${headers}=    Create Dictionary     Accept=application/json    Content-Type=application/json    Authorization=Basic ${GLOBAL_POLICY_AUTH}   ClientAuth=${GLOBAL_POLICY_CLIENTAUTH}    Environment=TEST
     ${resp}= 	Delete Request 	policy 	${data_path}    data=${data}    headers=${headers}
     Log    Received response from policy ${resp.text}
     [Return]    ${resp}

Run Policy Get Configs Request
    [Documentation]    Runs Policy Get Configs request
    [Arguments]    ${data_path}  ${data}
    Log    Creating session ${POLICY_ENDPOINT}
    ${session}=    Create Session 	policy 	${POLICY_ENDPOINT}
    ${headers}=    Create Dictionary     Accept=application/json    Content-Type=application/json    Authorization=Basic ${GLOBAL_POLICY_AUTH}   ClientAuth=${GLOBAL_POLICY_CLIENTAUTH}
    ${resp}= 	Post Request 	policy 	${data_path}    data=${data}    headers=${headers}
    Log    Received response from policy ${resp.text}
    [Return]    ${resp}



Update vVFWCL Policy Old
    [Arguments]   ${resource_id}
    Run Keyword and Ignore Error    Delete vFWCL Policy
    Sleep    20s
    Log To Console   Create vFWCL Policy
    Create vFWCL Policy     ${resource_id}
    Sleep    5s
    Log To Console   Push vFWCL Policy
    Push vFWCL Policy
    Sleep    20s
    Log To Console   Reboot Drools
    Reboot Drools
    Sleep    20s
    Log To Console   Validate vFWCL Policy
    Validate the vFWCL Policy Old

Update vVFWCL Policy
    [Arguments]   ${resource_id}
    Log To Console   Create vFWCL Monitoring Policy
    Create vFirewall Monitoring Policy
    Sleep   5s
    Log To Console   Create vFWCL Operational Policy
    ${op_policy_version}=   Create vFirewall Operational Policy   ${resource_id}
    Sleep   5s
    Log To Console   Push vFWCL To PDP Group
    Push vFirewall Policies To PDP Group    ${op_policy_version}
    Sleep    20s
    Log To Console   Validate vFWCL Policy
    Validate the vFWCL Policy


Delete vFWCL Policy
     ${data}=   OperatingSystem.Get File    ${POLICY_TEMPLATES}/FirewallPolicy_delete.template
     ${resp}=   Run Policy Delete Request    /pdp/api/deletePolicy    ${data}
     Should Be Equal As Strings 	${resp.status_code} 	200

Create vFWCL Policy
    [Arguments]   ${resource_id}
    ${dict}=   Create Dictionary   RESOURCE_ID=${resource_id}
    ${data}=   Fill JSON Template File    ${POLICY_TEMPLATES}/FirewallPolicy_update.template   ${dict}
    ${resp}=   Run Policy Put Request    /pdp/api/updatePolicy    ${data}
    Should Be Equal As Strings 	${resp.status_code} 	200

Push vFWCL Policy
     ${dict}=   Create Dictionary
     ${data}=   Fill JSON Template File    ${POLICY_TEMPLATES}/FirewallPolicy_push.template   ${dict}
     ${resp}=   Run Policy Put Request    /pdp/api/pushPolicy    ${data}
     Should Be Equal As Strings 	${resp.status_code} 	200

Reboot Drools
    ${stop}=   Catenate   docker exec -t -u policy drools bash -c "source /opt/app/policy/etc/profile.d/env.sh; policy stop"
    ${start}=   Catenate   docker exec -t -u policy drools bash -c "source /opt/app/policy/etc/profile.d/env.sh; policy start"
    Wait Until Keyword Succeeds    120    5 sec    Open Connection And Log In    ${GLOBAL_INJECTED_POLICY_IP_ADDR}    root    ${GLOBAL_VM_PRIVATE_KEY}
    Write    ${stop}
    ${status}   ${stdout}=	 Run Keyword And Ignore Error    SSHLibrary.Read Until Regexp    has stopped
    Log   ${status}: stdout=${stdout}
    ${ctrlc}=    Evaluate   '\x03'
    Run Keyword If   '${status}' == 'FAIL'   Write   ${ctrlc}
    Sleep    5s
    Write    ${start}
    ${stdout}=   SSHLibrary.Read Until Regexp    is running
    Log   stdout=${stdout}
    Should Contain     ${stdout}    is running

Validate the vFWCL Policy Old
    ${resp}=   Run Drools Get Request   /policy/pdp/engine/controllers/amsterdam/drools
    Should Be Equal As Strings 	${resp.status_code} 	200
    ${resp}=   Run Drools Get Request   /policy/pdp/engine/controllers/amsterdam/drools/facts/closedloop-amsterdam/org.onap.policy.controlloop.Params
    Should Be Equal As Strings 	${resp.status_code} 	200

Validate the vFWCL Policy
    ${resp}=   Run Policy Pap Get Request   /policy/pap/v1/pdps
    Log    Received response from policy ${resp.text}
    Should Be Equal As Strings         ${resp.status_code}     200

Create vFirewall Monitoring Policy
     ${dict}=   Create Dictionary
     ${data}=   Fill JSON Template File    ${POLICY_TEMPLATES}/vFirewall_policy_monitoring_input_tosca.template    ${dict}
     ${resp}=   Run Policy Api Post Request    /policy/api/v1/policytypes/onap.policies.monitoring.cdap.tca.hi.lo.app/versions/1.0.0/policies     ${data}
     Should Be Equal As Strings 	${resp.status_code} 	200

Create vFirewall Operational Policy
     [Arguments]   ${resource_id}
     ${dict}=   Create Dictionary   RESOURCE_ID=${resource_id}
     ${content_data}    OperatingSystem.Get File    ${POLICY_TEMPLATES}/vFirewall_policy_operational_content.yaml
     ${content_data}=    Replace String Using Regexp   ${content_data}    __RESOURCE_ID__     ${resource_id}
     ${encoded_content_data}=    Evaluate    urllib.quote_plus('''${content_data}''')   urllib
     ${content_dictionary}=   Create Dictionary    URL_ENCODED_CONTENT    ${encoded_content_data}
     ${data_2}=   Fill JSON Template File    ${POLICY_TEMPLATES}/vFirewall_policy_operational_url_enc_content_input.template   ${content_dictionary}
     Log To Console    ${data_2}
     ${resp}=   Run Policy Api Post Request    /policy/api/v1/policytypes/onap.policies.controlloop.Operational/versions/1.0.0/policies    ${data_2}
     #
     # pre-encoded content version
     #${data}=   Fill JSON Template File    ${POLICY_TEMPLATES}/vFirewall_policy_operational_input.template    ${dict}
     #${resp}=   Run Policy Api Post Request    /policy/api/v1/policytypes/onap.policies.controlloop.Operational/versions/1.0.0/policies    ${data}
     #
     Should Be Equal As Strings         ${resp.status_code}     200
     [Return]    ${resp.json()['policy-version']}

Push vFirewall Policies To PDP Group
     [Arguments]    ${op_policy_version}
     ${dict}=   Create Dictionary    OP_POLICY_VERSION=${op_policy_version}
     ${data}=   Fill JSON Template File    ${POLICY_TEMPLATES}/vFirewall_push.template    ${dict}
     #${resp}=   Run Policy Post Request    /policy/pap/v1/pdps/policies   ${data}
     ${resp}=   Run Policy Pap Post Request    /policy/pap/v1/pdps/policies   ${data}
     #Should Be Equal As Strings 	${resp.status_code} 	200

Run Policy API Healthcheck
     [Documentation]    Runs Policy Api Health check
     ${auth}=    Create List    ${POLICY_HEALTHCHECK_USERNAME}    ${POLICY_HEALTHCHECK_PASSWORD}
     Log    Creating session ${GLOBAL_POLICY_SERVER_PROTOCOL}://${POLICY_API_IP}:${GLOBAL_POLICY_HEALTHCHECK_PORT}
     ${session}=    Create Session      policy  ${GLOBAL_POLICY_SERVER_PROTOCOL}://${POLICY_API_IP}:${GLOBAL_POLICY_HEALTHCHECK_PORT}   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Get Request     policy  /policy/api/v1/healthcheck     headers=${headers}
     Log    Received response from policy ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     200
     Should Be Equal As Strings    ${resp.json()['code']}  200

Run Policy PAP Healthcheck
     [Documentation]    Runs Policy PAP Health check
     ${auth}=    Create List   ${POLICY_HEALTHCHECK_USERNAME}    ${POLICY_HEALTHCHECK_PASSWORD}
     Log    Creating session ${GLOBAL_POLICY_SERVER_PROTOCOL}://${POLICY_PAP_IP}:${GLOBAL_POLICY_HEALTHCHECK_PORT}
     ${session}=    Create Session      policy  ${GLOBAL_POLICY_SERVER_PROTOCOL}://${POLICY_PAP_IP}:${GLOBAL_POLICY_HEALTHCHECK_PORT}   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Get Request     policy  /policy/pap/v1/healthcheck     headers=${headers}
     Log    Received response from policy ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     200
     Should Be Equal As Strings    ${resp.json()['code']}  200

Run Policy Distribution Healthcheck
     [Documentation]    Runs Policy Distribution Health check
     ${auth}=    Create List    ${POLICY_HEALTHCHECK_USERNAME}    ${POLICY_HEALTHCHECK_PASSWORD}
     Log    Creating session ${GLOBAL_POLICY_SERVER_PROTOCOL}://${POLICY_DISTRIBUTION_IP}:${GLOBAL_POLICY_HEALTHCHECK_PORT}
     ${session}=    Create Session      policy  ${GLOBAL_POLICY_SERVER_PROTOCOL}://${POLICY_DISTRIBUTION_IP}:${GLOBAL_POLICY_HEALTHCHECK_PORT}   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Get Request     policy  /healthcheck     headers=${headers}
     Log    Received response from policy ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     200
     Should Be Equal As Strings    ${resp.json()['code']}  200

Run Policy XACML PDP Healthcheck
     [Documentation]    Runs Policy Xacml PDP Health check
     ${auth}=    Create List    ${POLICY_HEALTHCHECK_USERNAME}    ${POLICY_HEALTHCHECK_PASSWORD}
     Log    Creating session ${GLOBAL_POLICY_SERVER_PROTOCOL}://${POLICY_PDPX_IP}:${GLOBAL_POLICY_HEALTHCHECK_PORT}
     ${session}=    Create Session      policy  ${GLOBAL_POLICY_SERVER_PROTOCOL}://${POLICY_PDPX_IP}:${GLOBAL_POLICY_HEALTHCHECK_PORT}   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Get Request     policy  /policy/pdpx/v1/healthcheck     headers=${headers}
     Log    Received response from policy ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     200
     Should Be Equal As Strings    ${resp.json()['code']}  200

Run Policy APEX PDP Healthcheck
     [Documentation]    Runs Policy Apex PDP Health check
     ${auth}=    Create List    ${POLICY_HEALTHCHECK_USERNAME}    ${POLICY_HEALTHCHECK_PASSWORD}
     Log    Creating session ${GLOBAL_POLICY_SERVER_PROTOCOL}://${POLICY_APEX_PDP_IP}:${GLOBAL_POLICY_HEALTHCHECK_PORT}
     ${session}=    Create Session      policy  ${GLOBAL_POLICY_SERVER_PROTOCOL}://${POLICY_APEX_PDP_IP}:${GLOBAL_POLICY_HEALTHCHECK_PORT}   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Get Request     policy  /policy/apex-pdp/v1/healthcheck     headers=${headers}
     Log    Received response from policy ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     200
     Should Be Equal As Strings    ${resp.json()['code']}  200

