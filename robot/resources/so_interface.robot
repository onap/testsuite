*** Settings ***
Documentation     The main interface for interacting with MSO. It handles low level stuff like managing the http request library and MSO required fields
Library 	      RequestsLibrary
Library	          ONAPLibrary.Utilities
Library           OperatingSystem
Library           Collections
Resource          global_properties.robot
Resource          ../resources/json_templater.robot
*** Variables ***
${MSO_HEALTH_CHECK_PATH}    /manage/health
${MSO_ENDPOINT}     ${GLOBAL_MSO_SERVER_PROTOCOL}://${GLOBAL_INJECTED_SO_IP_ADDR}:${GLOBAL_MSO_SERVER_PORT}
${SO_APIHAND_ENDPOINT}     ${GLOBAL_MSO_SERVER_PROTOCOL}://${GLOBAL_INJECTED_SO_APIHAND_IP_ADDR}:${GLOBAL_MSO_APIHAND_SERVER_PORT}
${SO_ASDCHAND_ENDPOINT}     ${GLOBAL_MSO_SERVER_PROTOCOL}://${GLOBAL_INJECTED_SO_ASDCHAND_IP_ADDR}:${GLOBAL_MSO__ASDCHAND_SERVER_PORT}
${SO_BPMN_ENDPOINT}     ${GLOBAL_MSO_SERVER_PROTOCOL}://${GLOBAL_INJECTED_SO_BPMN_IP_ADDR}:${GLOBAL_MSO_BPMN_SERVER_PORT}
${SO_CATDB_ENDPOINT}     ${GLOBAL_MSO_SERVER_PROTOCOL}://${GLOBAL_INJECTED_SO_CATDB_IP_ADDR}:${GLOBAL_MSO__CATDB_SERVER_PORT}
${SO_OPENSTACK_ENDPOINT}     ${GLOBAL_MSO_SERVER_PROTOCOL}://${GLOBAL_INJECTED_SO_OPENSTACK_IP_ADDR}:${GLOBAL_MSO_OPENSTACK_SERVER_PORT}
${SO_REQDB_ENDPOINT}     ${GLOBAL_MSO_SERVER_PROTOCOL}://${GLOBAL_INJECTED_SO_REQDB_IP_ADDR}:${GLOBAL_MSO_REQDB_SERVER_PORT}
${SO_SDNC_ENDPOINT}     ${GLOBAL_MSO_SERVER_PROTOCOL}://${GLOBAL_INJECTED_SO_SDNC_IP_ADDR}:${GLOBAL_MSO_SDNC_SERVER_PORT}
${SO_VFC_ENDPOINT}     ${GLOBAL_MSO_SERVER_PROTOCOL}://${GLOBAL_INJECTED_SO_VFC_IP_ADDR}:${GLOBAL_MSO_VFC_SERVER_PORT}
${SO_VNFM_ENDPOINT}     ${GLOBAL_MSO_SERVER_PROTOCOL}://${GLOBAL_INJECTED_SO_VNFM_IP_ADDR}:${GLOBAL_MSO_VNFM_SERVER_PORT}

*** Keywords ***
Run SO Global Health Check
    Run SO Container Health Check    API_HANDLER  ${SO_APIHAND_ENDPOINT}
    Run SO Container Health Check    ASDC_HANDLER  ${SO_ASDCHAND_ENDPOINT}
    Run SO Container Health Check    BPMN_INFRA    ${SO_BPMN_ENDPOINT}
    Run SO Container Health Check    CATALOG_DB    ${SO_CATDB_ENDPOINT}
    Run SO Container Health Check    OPENSTACK_INFRA   ${SO_OPENSTACK_ENDPOINT}
    Run SO Container Health Check    REQUEST_DB    ${SO_REQDB_ENDPOINT}
    Run SO Container Health Check    SDNC_INFRA  ${SO_SDNC_ENDPOINT}
    Run SO Container Health Check    VFC_INFRA  ${SO_VFC_ENDPOINT}
    Run SO Container Health Check    VNFM_INFRA  ${SO_VNFM_ENDPOINT}


Run SO Container Health Check
    [Documentation]    Runs an MSO global health check
    [Arguments]    ${so_endpoint_label}    ${so_endpoint}
    ${auth}=  Create List  ${GLOBAL_MSO_USERNAME}    ${GLOBAL_MSO_PASSWORD}
    ${session}=    Create Session 	mso 	${so_endpoint}
    ${uuid}=    Generate UUID4
    ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json   X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}
    ${resp}= 	Get Request 	mso 	${MSO_HEALTH_CHECK_PATH}     headers=${headers}
    Should Be Equal As Strings 	${resp.status_code} 	200

Run MSO Get ModelInvariantId
    [Documentation]    Runs an MSO Get ModelInvariantID for ClosedLoop Policies
    [Arguments]    ${service_model_name}   ${vf_module_label}=NULL
    ${param_dict}=    Create Dictionary    serviceModelName    ${service_model_name}
    ${param}=   Evaluate   urllib.urlencode(${param_dict})    urllib
    ${data_path}=   Catenate   SEPARATOR=     /ecomp/mso/catalog/v2/serviceVnfs?  ${param}
    ${resp}=    Run MSO Catalog Get Request    ${data_path}
    Log    ${resp.json()}
    # ${resp.json()['serviceVnfs'][0]['vfModules'][0]['vfModuleLabel'] should be 'base_vpkg'
    ${model_invariant_id}=   Set Variable   NULL
    @{ITEMS}=    Copy List    ${resp.json()['serviceVnfs']}
    :FOR    ${ELEMENT}    IN    @{ITEMS}
    \    Log    ${ELEMENT['vfModules']}
    \    ${model_invariant_id}  Set Variable If   ('${vf_module_label}' in '${ELEMENT['vfModules'][0]['vfModuleLabel']}')   ${ELEMENT['modelInfo']['modelInvariantUuid']}  NULL
    \    Exit For Loop If  '${model_invariant_id}' != 'NULL'
    Should Not Be Equal As Strings    ${model_invariant_id}    NULL
    [Return]   ${model_invariant_id}

Run MSO Get Request
    [Documentation]    Runs an MSO get request
    [Arguments]    ${data_path}    ${accept}=application/json
    ${auth}=  Create List  ${GLOBAL_MSO_USERNAME}    ${GLOBAL_MSO_PASSWORD}
    Log    Creating session ${MSO_ENDPOINT}
    ${session}=    Create Session 	mso 	${MSO_ENDPOINT}    auth=${auth}
    ${uuid}=    Generate UUID4
    ${headers}=  Create Dictionary     Accept=${accept}    Content-Type=application/json    X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}
    ${resp}= 	Get Request 	mso 	${data_path}     headers=${headers}
    Log    Received response from mso ${resp.text}
    [Return]    ${resp}

Run MSO Catalog Get Request
    [Documentation]    Runs an MSO get request
    [Arguments]    ${data_path}    ${accept}=application/json
    ${auth}=  Create List  ${GLOBAL_MSO_CATDB_USERNAME}    ${GLOBAL_MSO_PASSWORD}
    Log    Creating session ${SO_CATDB_ENDPOINT}
    ${session}=    Create Session 	so_catdb   ${SO_CATDB_ENDPOINT}    auth=${auth}
    ${uuid}=    Generate UUID4
    ${headers}=  Create Dictionary     Accept=${accept}    Content-Type=application/json    X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}
    ${resp}= 	Get Request 	so_catdb  	${data_path}     headers=${headers}
    Log    Received response from so_catdb ${resp.text}
    [Return]    ${resp}


Poll MSO Get Request
    [Documentation]    Runs an MSO get request until a certain status is received. valid values are COMPLETE
    [Arguments]    ${data_path}     ${status}
    ${auth}=  Create List  ${GLOBAL_MSO_USERNAME}    ${GLOBAL_MSO_PASSWORD}
    Log    Creating session ${MSO_ENDPOINT}
    ${session}=    Create Session 	mso 	${MSO_ENDPOINT}    auth=${auth}
    ${uuid}=    Generate UUID4
    ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json    X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}
    #do this until it is done
    :FOR    ${i}    IN RANGE    20
    \    ${resp}= 	Get Request 	mso 	${data_path}     headers=${headers}
    \    Should Not Contain    ${resp.text}    FAILED
    \    Log    ${resp.json()['request']['requestStatus']['requestState']}
    \    ${exit_loop}=    Evaluate    "${resp.json()['request']['requestStatus']['requestState']}" == "${status}"
    \    Exit For Loop If  ${exit_loop}
    \    Sleep    15s
    Log    Received response from mso ${resp.text}
    [Return]    ${resp}

Run MSO Post request
    [Documentation]    Runs an MSO post request
    [Arguments]  ${data_path}  ${data}
    ${auth}=  Create List  ${GLOBAL_MSO_USERNAME}    ${GLOBAL_MSO_PASSWORD}
    Log    Creating session ${MSO_ENDPOINT}
    ${session}=    Create Session 	mso 	${MSO_ENDPOINT}    auth=${auth}
    ${uuid}=    Generate UUID4
    ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json    X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}
	${resp}= 	Post Request 	mso 	${data_path}     data=${data}   headers=${headers}
	Log    Received response from mso ${resp.text}
	[Return]  ${resp}

Run SO Catalog Post request
    [Documentation]    Runs an SO post request
    [Arguments]  ${data_path}  ${data}   ${so_port}=
    ${auth}=  Create List  ${GLOBAL_MSO_CATDB_USERNAME}    ${GLOBAL_MSO_PASSWORD}
    Log    Creating session ${SO_CATDB_ENDPOINT}
    ${session}=    Create Session       so_catdb     ${SO_CATDB_ENDPOINT}    auth=${auth}
    ${uuid}=    Generate UUID4
    ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json    X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}
    ${resp}=        Post Request    so_catdb     ${data_path}     data=${data}   headers=${headers}
    Log    Received response from so_catdb ${resp.text}
    [Return]  ${resp}

Run SO Catalog Put request
    [Documentation]    Runs an SO put request
    [Arguments]  ${data_path}  ${data}   ${so_port}=
    ${auth}=  Create List  ${GLOBAL_MSO_CATDB_USERNAME}    ${GLOBAL_MSO_PASSWORD}
    Log    Creating session ${SO_CATDB_ENDPOINT}
    ${session}=    Create Session       so_catdb     ${SO_CATDB_ENDPOINT}    auth=${auth}
    ${uuid}=    Generate UUID4
    ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json    X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}
    ${resp}=        Put Request    so_catdb     ${data_path}     data=${data}   headers=${headers}
    Log    Received response from so_catdb ${resp.text}
    [Return]  ${resp}

Run MSO Delete request
    [Documentation]    Runs an MSO Delete request
    [Arguments]  ${data_path}  ${data}
    ${auth}=    Create List    ${GLOBAL_MSO_USERNAME}    ${GLOBAL_MSO_PASSWORD}
    Log    Creating session ${MSO_ENDPOINT}
    ${session}=    Create Session    mso    ${MSO_ENDPOINT}    auth=${auth}
    ${uuid}=    Generate UUID4
    ${headers}=    Create Dictionary    Accept=application/json    Content-Type=application/json    X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}
    ${resp}=    Delete Request    mso    ${data_path}    ${data}    headers=${headers}
    Log    Received response from mso ${resp.text}
    [Return]    ${resp}
