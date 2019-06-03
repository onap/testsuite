*** Settings ***
Documentation     The main interface for interacting with OOF: SNIRO and Homing Service
Library           RequestsLibrary
Library	          UUID
Library           OperatingSystem
Library	          String
Library           DateTime
Library           Collections
Library           ONAPLibrary.JSON
Resource          global_properties.robot
Resource          json_templater.robot

*** Variables ***
${OOF_HOMING_HEALTH_CHECK_PATH}       /v1/plans/healthcheck
${OOF_SNIRO_HEALTH_CHECK_PATH}        /api/oof/v1/healthcheck
${OOF_CMSO_HEALTH_CHECK_PATH}        /cmso/v1/health?checkInterfaces=true

${OOF_CMSO_TEMPLATE_FOLDER}   robot/assets/templates/cmso
${OOF_CMSO_UTC}   %Y-%m-%dT%H:%M:%SZ
${OOF_HOMING_PLAN_FOLDER}    robot/assets/templates/optf-has
${OOF_OSDF_TEMPLATE_FOLDER}   robot/assets/templates/optf-osdf

${OOF_HOMING_ENDPOINT}    ${GLOBAL_OOF_SERVER_PROTOCOL}://${GLOBAL_INJECTED_OOF_HOMING_IP_ADDR}:${GLOBAL_OOF_HOMING_SERVER_PORT}
${OOF_SNIRO_ENDPOINT}     ${GLOBAL_OOF_SERVER_PROTOCOL}://${GLOBAL_INJECTED_OOF_SNIRO_IP_ADDR}:${GLOBAL_OOF_SNIRO_SERVER_PORT}
${OOF_CMSO_ENDPOINT}      ${GLOBAL_OOF_CMSO_PROTOCOL}://${GLOBAL_INJECTED_OOF_CMSO_IP_ADDR}:${GLOBAL_OOF_CMSO_SERVER_PORT}

${OOF_HOMING_AUTH}       Basic YWRtaW4xOnBsYW4uMTU=

*** Keywords ***
Run OOF-Homing Health Check
     [Documentation]    Runs OOF-Homing Health check
     ${resp}=    Run OOF-Homing Get Request    ${OOF_HOMING_HEALTH_CHECK_PATH}
     Should Be Equal As Integers   ${resp.status_code}   200

Run OOF-Homing Get Request
     [Documentation]    Runs OOF-Homing Get request
     [Arguments]    ${data_path}
     ${session}=    Create Session   session   ${OOF_HOMING_ENDPOINT}
     ${resp}=   Get Request   session   ${data_path}
     Should Be Equal As Integers   ${resp.status_code}   200
     Log    Received response from OOF-Homing ${resp.text}
     [Return]    ${resp}

RUN OOF-Homing SendPlanWithWrongVersion
    [Documentation]    It sends a POST request to conductor
    ${session}=    Create Session   optf-cond      ${OOF_HOMING_ENDPOINT}
    ${data}=         Get Binary File     ${OOF_HOMING_PLAN_FOLDER}${/}plan_with_wrong_version.json
    &{headers}=      Create Dictionary    Authorization=${OOF_HOMING_Auth}    Content-Type=application/json  Accept=application/json
    ${resp}=         Post Request        optf-cond   /v1/plans     data=${data}     headers=${headers}
    Log               *********************
    Log               response = ${resp}
    Log               body = ${resp.text}
    ${generatedPlanId}=    Convert To String      ${resp.json()['id']}
    Set Global Variable     ${generatedPlanId}
    Log              generatedPlanId = ${generatedPlanId}
    Should Be Equal As Integers    ${resp.status_code}    201
    Sleep    10s    Wait Plan Resolution

Run OOF-SNIRO Health Check
     [Documentation]    Runs OOF-SNIRO Health check
     ${resp}=    Run OOF-SNIRO Get Request    ${OOF_SNIRO_HEALTH_CHECK_PATH}
     Should Be Equal As Integers   ${resp.status_code}   200

Run OOF-SNIRO Get Request
     [Documentation]    Runs OOF-SNIRO Get request
     [Arguments]    ${data_path}
     ${session}=    Create Session   session   ${OOF_SNIRO_ENDPOINT}
     ${resp}=   Get Request   session   ${data_path}
     Should Be Equal As Integers   ${resp.status_code}   200
     Log    Received response from OOF-SNIRO ${resp.text}
     [Return]    ${resp}


Run OOF-CMSO Health Check
     [Documentation]    Runs OOF-CMSO Health check
     ${resp}=    Run OOF-CMSO Get Request    ${OOF_CMSO_HEALTH_CHECK_PATH}
     Should Be Equal As Integers   ${resp.status_code}   200

Run OOF-CMSO Get Request
     [Documentation]    Runs OOF-CMSO Get request
     [Arguments]    ${data_path}
     ${auth}=  Create List  ${GLOBAL_OOF_CMSO_USERNAME}    ${GLOBAL_OOF_CMSO_PASSWORD}
     ${session}=    Create Session   session   ${OOF_CMSO_ENDPOINT}   auth=${auth}
     ${resp}=   Get Request   session   ${data_path}
     Should Be Equal As Integers   ${resp.status_code}   200
     Log    Received response from OOF-CMSO ${resp.text}
     [Return]    ${resp}

Run OOF-CMSO Post Scheduler
    [Documentation]    Runs a scheduler POST request
    [Arguments]   ${data_path}   ${data}={}
    ${auth}=  Create List  ${GLOBAL_OOF_CMSO_USERNAME}    ${GLOBAL_OOF_CMSO_PASSWORD}
    ${session}=    Create Session   session   ${OOF_CMSO_ENDPOINT}   auth=${auth}
    ${headers}=  Create Dictionary   Accept=application/json    Content-Type=application/json
    ${resp}= 	Post Request 	session 	${data_path}     headers=${headers}   data=${data}
    Log    Received response from scheduler ${resp.text}
    [Return]    ${resp}

Run OOF-CMSO Future Schedule
   [Documentation]   Runs CMSO Future Schedule ETE test. One VNF, One Change Window
   [Arguments]    ${request_file}=OneVnfOneChangeWindow.json.template   ${workflow}=Replace   ${minutesFromNow}=3
   ${uuid}=   Generate UUID
   ${resp}=   OOF-CMSO Create Schedule   ${uuid}   ${request_file}   workflow=${workflow}   minutesFromNow=${minutesFromNow}
   Should Be Equal as Strings    ${resp.status_code}    202
   Wait Until Keyword Succeeds    600s    30s    OOF-CMSO Wait For Pending Approval   ${uuid}
   OOF-CMSO Send Tier2 Approval   ${uuid}   jf9860    Accepted
   Wait Until Keyword Succeeds    600s    30s    OOF-CMSO Wait for Schedule to Complete   Completed   ${uuid}


OOF-CMSO Create Schedule
    [Documentation]   Creates a CMSO future schedule request for the passed template.
    [Arguments]   ${uuid}   ${request_file}    ${workflow}    ${minutesFromNow}=5
    ${testid}=   Catenate   ${uuid}
    ${testid}=   Get Substring   ${testid}   -4
    ${dict}=   Create Dictionary   serviceInstanceId=${uuid}   parent_service_model_name=${uuid}
	${map}=   Create Dictionary   uuid=${uuid}   callbackUrl=http://localhost:8080    testid=${testid}   workflow=${workflow}      userId=oof@oof.onap.org
	${nodelist}=   Create List   node1   node2   node3   node4
	${nn}=    Catenate    1
    # Support up to 4 ChangeWindows
    :FOR   ${i}   IN RANGE   1    4
    \  ${today}=    Evaluate   ((${i}-1)*1440)+${minutesFromNow}
    \  ${tomorrow}   Evaluate   ${today}+1440
    \  ${last_time}   Evaluate  ${today}+30
    \  ${start_time}=    Get Current Date   UTC  + ${today} minutes   result_format=${OOF_CMSO_UTC}
    \  ${end_time}=    Get Current Date   UTC   + ${tomorrow} minutes   result_format=${OOF_CMSO_UTC}
    \  Set To Dictionary    ${map}   start_time${i}=${start_time}   end_time${i}=${end_time}
    ${requestList}=   Create List
	:FOR   ${vnf}   IN    @{nodelist}
	\   Set To Dictionary    ${map}   node${nn}   ${vnf}
	\   ${nn}=   Evaluate    ${nn}+1
	\   Set To DIctionary   ${dict}   vnfName=${vnf}
    \   ${requestInfo}=   Fill JSON Template File    ${OOF_CMSO_TEMPLATE_FOLDER}/VidCallbackData.json.template   ${dict}
    \   Append To List   ${requestList}   ${requestInfo}
    ${callBackDataMap}=  Create Dictionary   requestType=Update   requestDetails=${requestList}
    ${callbackDataString}=   OOF-CMSO Json Escape    ${callbackDataMap}
    Set To Dictionary   ${map}   callbackData=${callbackDataString}
    ${data}=   Fill JSON Template File    ${OOF_CMSO_TEMPLATE_FOLDER}/${request_file}   ${map}
    ${resp}=   Run OOF-CMSO Post Scheduler   cmso/v1/schedules/${uuid}   data=${data}
    [Return]   ${resp}



OOF-CMSO Wait For Pending Approval
     [Documentation]    Gets the schedule identified by the uuid and checks if it is in the Pending Approval state
     [Arguments]   ${uuid}     ${status}=Pending Approval
     ${resp}=   Run OOF-CMSO Get Request   cmso/v1/schedules/${uuid}
     ${json}=   Catenate   ${resp.json()}
     Dictionary Should Contain Item    ${resp.json()}    status    ${status}

OOF-CMSO Send Tier2 Approval
    [Documentation]    Sends an approval post request for the given schedule using the UUID and User given and checks that request worked
    [Arguments]   ${uuid}   ${user}   ${status}
    ${approval}=   Create Dictionary   approvalUserId=${user}   approvalType=Tier 2   approvalStatus=${status}
    ${resp}=   Run OOF-CMSO Post Scheduler   cmso/v1/schedules/${uuid}/approvals   data=${approval}
    Should Be Equal As Strings    ${resp.status_code}   204

OOF-CMSO Wait for Schedule to Complete
    [Arguments]   ${status}   ${uuid}
    ${resp}=   Run OOF-CMSO Get Request   cmso/v1/schedules/${uuid}
    Dictionary Should Contain Item   ${resp.json()}   status   Completed

OOF-CMSO Json Escape
    [Arguments]    ${json}
    ${json_string}=    Evaluate    json.dumps(${json})    json
    ${escaped}=   Replace String    ${json_string}   "   \\"
    [Return]   ${escaped}

Run OOF-OSDF Post Request
    [Documentation]    Runs a scheduler POST request
    [Arguments]   ${data_path}   ${auth}    ${data}={}     

    ${session}=    Create Session   session   ${OOF_OSDF_ENDPOINT}   auth=${auth}
    ${headers}=  Create Dictionary   Accept=application/json    Content-Type=application/json
    ${resp}= 	Post Request 	session 	${data_path}     headers=${headers}   data=${data}
    Log    Received response from osdf ${resp.text}
    [Return]    ${resp}


Run OOF-OSDF Post Homing
   [Documentation]    Runs a osdf homing request
    ${auth}=  Create List  ${GLOBAL_OOF_OSDF_USERNAME}    ${GLOBAL_OOF_OSDF_PASSWORD}
    ${data}=         Get Binary File     ${OOF_OSDF_TEMPLATE_FOLDER}${/}placement_request.json
    ${resp}=   Run OOF-OSDF Post Request  /api/oof/placement/v1       auth=${auth}    data=${data}
    Should Be Equal As Strings    ${resp.status_code}   204

Run OOF-OSDF Post PCI-OPT
    [Documentation]    Runs a osdf PCI-OPT request
    ${auth}=  Create List  ${GLOBAL_OOF_PCI_USERNAME}    ${GLOBAL_OOF_PCI_PASSWORD}
    ${data}=         Get Binary File     ${OOF_OSDF_TEMPLATE_FOLDER}${/}pci-opt-request.json
    ${resp}=   Run OOF-OSDF Post Request  /api/oof/pci/v1   auth=${auth}    data=${data}    
    Should Be Equal As Strings    ${resp.status_code}   204
