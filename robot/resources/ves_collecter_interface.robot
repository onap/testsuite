*** Settings ***
Documentation     The main interface for interacting with VES Collector. It handles low level stuff like managing the http request library and DCAE required fields
Library 	  RequestsLibrary
Library           OperatingSystem
Library           UUID
Library           Collections
Library           JSONUtils
Library      	  String
Library           StringTemplater

Resource          global_properties.robot
Resource          json_templater.robot
Resource          mr_interface.robot


*** Variables ***
#${VES_COLLECTER_PATH}    /VES_COLLECTOR_PATH
${VES_COLLECTER_PATH}    /eventListener/v5
#${VES_ENDPOINT}     ${GLOBAL_DCAE_SERVER_PROTOCOL}://${GLOBAL_INJECTED_DCAE_IP_ADDR}:${GLOBAL_DCAE_SERVER_PORT}
${VES_ENDPOINT}     http://192.168.31.95:8080

*** Keywords ***
Send VES Event
    [Documentation]    Sends a VES Event to DCAE Collector
    [Arguments]    ${filename}
    Log    Creating session ${VES_ENDPOINT}
    ${auth}=  Create List  test   test
    #${session}=    Create Session 	dcae 	${VES_ENDPOINT}     auth=${auth}
    ${session}=    Create Session 	dcae 	${VES_ENDPOINT}
    ${uuid}=    Generate UUID
    ${headers}=  Create Dictionary     X-ECOMP-Client-Version=ONAP-R2   Accept=application/json    Content-Type=application/json    X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}
    ${data_template}=    OperatingSystem.Get File    ./robot/assets/templates/ves_event.template
    &{parameters}=   Create Dictionary   testparam=testvalue
    #Set To Dictionary   ${parameters}   generic_vnf_name=${generic_vnf_name}     generic_vnf_type=${generic_vnf_type}  service_type=${service_type_uuid}    vf_module_name=${vf_module_name}    vf_module_type=${vf_module_type}
    Set To Dictionary   ${parameters}   generic_vnf_name=generic_vnf_name     generic_vnf_type=generic_vnf_type  service_type=service_type_uuid    vf_module_name=vf_module_name    vf_module_type=vf_module_type
    ${data}=    Fill JSON Template    ${data_template}    ${parameters}
    Log   ${data}
    ${resp}= 	Post Request 	dcae 	${VES_COLLECTER_PATH}     headers=${headers}   data=${data}
    Log    Received response from ves_collector ${resp.status_code}
    Should Be Equal As Strings 	${resp.status_code} 	200
    ${vnfName}=  Catenate   vFWCntlLoopHealth1
    ${requestAction}=  Catenate   ModifyConfig
    ${responseStatus}=  Catenate   ACCEPTED 
    Wait Until Keyword Succeeds   60   15    Check VES-TCA Event on DMaaP   ${vnfName}
    Wait Until Keyword Succeeds   60   15    Check TCA-POLICY Event on DMaaP   ${vnfName}
    Wait Until Keyword Succeeds   60   15    Check POLICY-APPC Event on DMaaP   ${requestAction}   ${responseStatus}
    Wait Until Keyword Succeeds   60   15    Check POLICY-CL-MGT Event on DMaaP   ${vnfName} 
Check VES-TCA Event on DMaaP
    [Arguments]   ${vnfName}
    ${resp}=    Run MR Get Request   events/unauthenticated.SEC_MEASUREMENT_OUTPUT/groupR19/CR1?timeout=5000
    Should Be Equal As Strings 	${resp.status_code} 	200
    Should Contain   ${resp.text}   ${vnfName}
    Log To Console   -
    Log To Console   Successful VES-TCA Event on DMaaP
Check TCA-POLICY Event on DMaaP
    [Arguments]   ${vnfName}
    ${resp}=    Run MR Get Request   events/unauthenticated.DCAE_CL_OUTPUT/groupR19/CR1?timeout=5000
    Should Be Equal As Strings 	${resp.status_code} 	200
    Should Contain   ${resp.text}   ${vnfName}
    Log To Console   Successful TCA-POLICY Event on DMaaP
Check POLICY-APPC Event on DMaaP
    [Arguments]   ${requestAction}   ${responseStatus}
    ${resp}=    Run MR Get Request   events/APPC-CL/groupR19/CR1?timeout=5000
    Should Be Equal As Strings 	${resp.status_code} 	200
    Should Contain   ${resp.text}   ${requestAction}
    Log To Console   Successful POLICY-APPC Event on DMaaP
    Should Contain   ${resp.text}   ${responseStatus}
    Log To Console   Successful APPC-POLICY Event on DMaaP
Check POLICY-CL-MGT Event on DMaaP
    [Arguments]   ${vnfName} 
    ${resp}=    Run MR Get Request   events/POLICY-CL-MGT/groupR19/CR1?timeout=5000
    Should Be Equal As Strings 	${resp.status_code} 	200
    Should Contain   ${resp.text}   ${vnfName}
    Log To Console   Successful POLICY-CL-MGT Event on DMaaP
Get Template Parameters
    [Arguments]    ${template}    ${uuid}
    #${rest}   ${suite}=    Split String From Right    ${SUITE NAME}   .   1
    ${suite}=   Catenate    Closed-Loop
    ${uuid}=    Catenate    ${uuid}
    ${hostid}=    Get Substring    ${uuid}    -4
    ${ecompnet}=    Evaluate    (${GLOBAL_BUILD_NUMBER}%128)+128


    # Initialize the value map with the properties generated from the Robot VM /opt/config folder
    ${valuemap}=   Copy Dictionary    ${GLOBAL_INJECTED_PROPERTIES}

    # These should be deprecated by the above....
    Set To Dictionary   ${valuemap}   artifacts_version=${GLOBAL_INJECTED_ARTIFACTS_VERSION}
    Set To Dictionary   ${valuemap}   network=${GLOBAL_INJECTED_NETWORK}
    Set To Dictionary   ${valuemap}   public_net_id=${GLOBAL_INJECTED_PUBLIC_NET_ID}
    Set To Dictionary   ${valuemap}   cloud_env=${GLOBAL_INJECTED_CLOUD_ENV}
    Set To Dictionary   ${valuemap}   install_script_version=${GLOBAL_INJECTED_SCRIPT_VERSION}
    Set To Dictionary   ${valuemap}   vm_image_name=${GLOBAL_INJECTED_VM_IMAGE_NAME}
    Set To Dictionary   ${valuemap}   vm_flavor_name=${GLOBAL_INJECTED_VM_FLAVOR}


    # update the value map with unique values.
    Set To Dictionary   ${valuemap}   uuid=${uuid}   hostid=${hostid}    ecompnet=${ecompnet}

    #
    # Mash together the defaults dict with the test case dict to create the set of
    # preload parameters
    #
    ${suite_templates}=    Get From Dictionary    ${GLOBAL_PRELOAD_PARAMETERS}    ${suite}
    ${template}=    Get From Dictionary    ${suite_templates}    ${template}
    ${defaults}=    Get From Dictionary    ${GLOBAL_PRELOAD_PARAMETERS}    defaults
    # add all of the defaults to template...
    @{keys}=    Get Dictionary Keys    ${defaults}
    :for   ${key}   in   @{keys}
    \    ${value}=   Get From Dictionary    ${defaults}    ${key}
    \    Set To Dictionary    ${template}  ${key}    ${value}

    #
    # Get the vnf_parameters to preload
    #
    ${vnf_parameters}=   Resolve VNF Parameters Into Array   ${valuemap}   ${template}
    ${vnf_parameters_json}=   Evaluate    json.dumps(${vnf_parameters})    json
    ${parameters}=   Create Dictionary   vnf_parameters=${vnf_parameters_json}
    [Return]    ${parameters}
Resolve Values Into Dictionary
    [Arguments]   ${valuemap}    ${from}    ${to}
    ${keys}=    Get Dictionary Keys    ${from}
    :for   ${key}   in  @{keys}
    \    ${value}=    Get From Dictionary    ${from}   ${key}
    \    ${value}=    Template String    ${value}    ${valuemap}
    \    Set To Dictionary    ${to}    ${key}    ${value}
Resolve VNF Parameters Into Array
    [Arguments]   ${valuemap}    ${from}
    ${vnf_parameters}=   Create List
    ${keys}=    Get Dictionary Keys    ${from}
    :for   ${key}   in  @{keys}
    \    ${value}=    Get From Dictionary    ${from}   ${key}
    \    ${value}=    Template String    ${value}    ${valuemap}
    \    ${parameter}=   Create Dictionary   vnf-parameter-name=${key}    vnf-parameter-value=${value}
    \    Append To List    ${vnf_parameters}   ${parameter}
    [Return]   ${vnf_parameters}
