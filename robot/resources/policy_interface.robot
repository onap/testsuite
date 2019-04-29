*** Settings ***
Documentation	  The main interface for interacting with Policy. It handles low level stuff like managing the http request library and Policy required fields
Library	          RequestsClientCert
Library 	      RequestsLibrary
Library           String
Library           JSONUtils
Library           Collections      
Resource          global_properties.robot

*** Variables ***
${POLICY_HEALTH_CHECK_PATH}        /healthcheck
${POLICY_ENDPOINT}     ${GLOBAL_POLICY_SERVER_PROTOCOL}://${GLOBAL_INJECTED_POLICY_IP_ADDR}:${GLOBAL_POLICY_SERVER_PORT}
${POLICY_HEALTHCHECK_ENDPOINT}     ${GLOBAL_POLICY_SERVER_PROTOCOL}://${GLOBAL_INJECTED_POLICY_HEALTHCHECK_IP_ADDR}:${GLOBAL_POLICY_HEALTHCHECK_PORT}
${POLICY_TEMPLATES}        robot/assets/templates/policy
${DROOLS_ENDPOINT}     ${GLOBAL_POLICY_SERVER_PROTOCOL}://${GLOBAL_INJECTED_POLICY_IP_ADDR}:${GLOBAL_DROOLS_SERVER_PORT}

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

Run Policy Post Request
     [Documentation]    Runs Policy Post request
     [Arguments]    ${data_path}  ${data}
     Log    Creating session ${POLICY_ENDPOINT}
     ${session}=    Create Session 	policy 	${POLICY_ENDPOINT}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json    Authorization=Basic ${GLOBAL_POLICY_AUTH}   ClientAuth=${GLOBAL_POLICY_CLIENTAUTH}    Environment=TEST
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



Update vVFWCL Policy
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

Validate the vFWCL Policy
    ${resp}=   Run Drools Get Request   /policy/pdp/engine/controllers/amsterdam/drools
    Should Be Equal As Strings 	${resp.status_code} 	200
    ${resp}=   Run Drools Get Request   /policy/pdp/engine/controllers/amsterdam/drools/facts/closedloop-amsterdam/org.onap.policy.controlloop.Params
    Should Be Equal As Strings 	${resp.status_code} 	200


Create vFirewall Monitoring Policy
     ${dict}=   Create Dictionary
     ${data}=   Fill JSON Template File    ${POLICY_TEMPLATES}/vFirewall_policy_monitoring_input_tosca.template    ${dict}
     ${resp}=   Run Policy Post Request    /policy/api/v1/policytypes/onap.policies.monitoring.cdap.tca.hi.lo.app/versions/1.0.0/policies     ${data}
     Should Be Equal As Strings 	${resp.status_code} 	200


Create vFirewall Operational Policy
     [Arguments]   ${resource_id}
     ${dict}=   Create Dictionary   RESOURCE_ID=${resource_id}
     ${data}=   Fill JSON Template File    ${POLICY_TEMPLATES}/vFirewall_policy_operational_input.template    ${dict}
     ${resp}=   Run Policy Post Request    /policy/api/v1/policytypes/onap.policies.controlloop.Operational/versions/1.0.0/policies    ${data}
     Should Be Equal As Strings 	${resp.status_code} 	200


Push vFirewall Policies To PDP Group
     ${dict}=   Create Dictionary
     ${data}=   Fill JSON Template File    ${POLICY_TEMPLATES}/vFirewall_push.template    ${dict}
     ${resp}=   Run Policy Post Request    /policy/pap/v1/pdps/policies   ${data}
     Should Be Equal As Strings 	${resp.status_code} 	200

