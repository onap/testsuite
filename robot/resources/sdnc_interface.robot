*** Settings ***
Documentation     The main interface for interacting with SDN-GC. It handles low level stuff like managing the http request library and SDN-GC required fields
Library 	      RequestsLibrary
Library	          ONAPLibrary.Utilities
Library 	    SeleniumLibrary
Library        OperatingSystem
Library         Collections
Library      String
Library           ONAPLibrary.ServiceMapping    WITH NAME     ServiceMapping
Library           ONAPLibrary.PreloadData    WITH NAME     Preload
Library           ONAPLibrary.Templating    WITH NAME     Templating
Library           ONAPLibrary.SDNC        WITH NAME     SDNC
Resource          global_properties.robot
Resource        browser_setup.robot


*** Variables ***
${PRELOAD_VNF_TOPOLOGY_OPERATION_PATH}  /operations/VNF-API:preload-vnf-topology-operation
${PRELOAD_NETWORK_TOPOLOGY_OPERATION_PATH}  /operations/VNF-API:preload-network-topology-operation
${PRELOAD_GR_TOPOLOGY_OPERATION_PATH}     /operations/GENERIC-RESOURCE-API:preload-vf-module-topology-operation
${PRELOAD_VNF_CONFIG_PATH}  /config/VNF-API:preload-vnfs/vnf-preload-list
${PRELOAD_TOPOLOGY_OPERATION_BODY}  sdnc
${SDNC_INDEX_PATH}    /restconf
${SDNCGC_HEALTHCHECK_OPERATION_PATH}  /operations/SLI-API:healthcheck
${SDNC_REST_ENDPOINT}    ${GLOBAL_SDNC_SERVER_PROTOCOL}://${GLOBAL_INJECTED_SDNC_IP_ADDR}:${GLOBAL_SDNC_REST_PORT}
${SDNC_ADMIN_ENDPOINT}    ${GLOBAL_SDNC_SERVER_PROTOCOL}://${GLOBAL_INJECTED_SDNC_PORTAL_IP_ADDR}:${GLOBAL_SDNC_ADMIN_PORT}
${SDNC_ADMIN_SIGNUP_URL}    ${SDNC_ADMIN_ENDPOINT}/signup
${SDNC_ADMIN_LOGIN_URL}    ${SDNC_ADMIN_ENDPOINT}/login
${SDNC_ADMIN_VNF_PROFILE_URL}    ${SDNC_ADMIN_ENDPOINT}/mobility/getVnfProfile

*** Keywords ***
Run SDNC Health Check
    [Documentation]    Runs an SDNC healthcheck
    ${resp}= 	SDNC.Run Post Request 	${SDNC_REST_ENDPOINT} 	${SDNC_INDEX PATH}${SDNCGC_HEALTHCHECK_OPERATION_PATH}     data=${None}    auth=${GLOBAL_SDNC_AUTHENTICATION}
    Should Be Equal As Strings 	${resp.status_code} 	200
    Should Be Equal As Strings 	${resp.json()['output']['response-code']} 	200

Preload Vcpe Networks
    Preload Network    cpe_public    10.2.0.2	 10.2.0.1
    Preload Network    cpe_signal    10.4.0.2    10.4.0.1
    Preload Network    brg_bng    10.3.0.2    10.3.0.1
    Preload Network    bng_mux    10.1.0.10    10.1.0.1
    Preload Network    mux_gw    10.5.0.10    10.5.0.1

Preload Network
    [Arguments]    ${network_role}     ${subnet_start_ip}    ${subnet_gateway}
    ${name_suffix}=    Generate Timestamp
    ${network_name}=     Catenate    SEPARATOR=_    net	    ${network_role}	    ${name_suffix}
    ${subnet_name}=     Catenate    SEPARATOR=_    net	    ${network_role}	    subnet    ${name_suffix}
    ${parameters}=     Create Dictionary    network_role=${network_role}    service_type=vCPE    network_type=Generic NeutronNet    network_name=${network_name}    subnet_start_ip=${subnet_start_ip}    subnet_gateway=${subnet_gateway}
    Templating.Create Environment    sdnc    ${GLOBAL_TEMPLATE_FOLDER}
    ${data}=   Templating.Apply Template    sdnc   ${PRELOAD_TOPOLOGY_OPERATION_BODY}/template.network.jinja   ${parameters}
    ${post_resp}= 	SDNC.Run Post Request 	${SDNC_REST_ENDPOINT} 	${SDNC_INDEX_PATH}${PRELOAD_NETWORK_TOPOLOGY_OPERATION_PATH}     data=${data}    auth=${GLOBAL_SDNC_AUTHENTICATION}
    [Return]    ${network_name}   ${subnet_name}

Preload Vcpe vGW
    [Arguments]    ${brg_mac}    ${cpe_network_name}   ${cpe_subnet_name}    ${mux_gw_net}    ${mux_gw_subnet}
    ${name_suffix}=    Generate Timestamp
    ${parameters}=     Create Dictionary    pub_key=${GLOBAL_INJECTED_PUBLIC_KEY}    brg_mac=${brg_mac}    cpe_public_net=${cpe_network_name}     cpe_public_subnet=${cpe_subnet_name}    mux_gw_net=${mux_gw_net}	mux_gw_subnet=${mux_gw_subnet}    suffix=${name_suffix}    oam_onap_net=oam_network_2No2        oam_onap_subnet=oam_network_2No2        public_net_id=${GLOBAL_INJECTED_PUBLIC_NET_ID}
    Templating.Create Environment    sdnc    ${GLOBAL_TEMPLATE_FOLDER}
    ${data}=   Templating.Apply Template    sdnc   ${PRELOAD_TOPOLOGY_OPERATION_BODY}/template.vcpe_vgw_vfmodule.jinja   ${parameters}
    ${post_resp}= 	SDNC.Run Post Request 	${SDNC_REST_ENDPOINT} 	${SDNC_INDEX_PATH}${PRELOAD_VNF_TOPOLOGY_OPERATION_PATH}     data=${data}    auth=${GLOBAL_SDNC_AUTHENTICATION}

Preload Vcpe vGW Gra
    [Arguments]    ${brg_mac}	${cpe_public_network_name}   ${cpe_public_subnet_name}    ${mux_gw_net}    ${mux_gw_subnet}
    ${name_suffix}=    Generate Timestamp
    ${parameters}=     Create Dictionary    pub_key=${GLOBAL_INJECTED_PUBLIC_KEY}    brg_mac=${brg_mac}    cpe_public_net=${cpe_public_network_name}     cpe_public_subnet=${cpe_public_subnet_name}    mux_gw_net=${mux_gw_net}	mux_gw_subnet=${mux_gw_subnet}    suffix=${name_suffix}    oam_onap_net=oam_network_2No2        oam_onap_subnet=oam_network_2No2        public_net_id=${GLOBAL_INJECTED_PUBLIC_NET_ID}
    Templating.Create Environment    sdnc    ${GLOBAL_TEMPLATE_FOLDER}
    ${data}=   Templating.Apply Template    sdnc   ${PRELOAD_TOPOLOGY_OPERATION_BODY}/template.vcpe_gwgra_vfmodule.jinja   ${parameters}
    ${post_resp}= 	SDNC.Run Post Request 	${SDNC_REST_ENDPOINT} 	${SDNC_INDEX_PATH}${PRELOAD_GR_TOPOLOGY_OPERATION_PATH}     data=${data}    auth=${GLOBAL_SDNC_AUTHENTICATION}

Preload Generic VfModule
    [Arguments]    ${service_instance_id}	${vnf_model}   ${model_customization_name}    ${short_model_customization_name}	    ${cpe_public_network_name}=None   ${cpe_public_subnet_name}=None   ${cpe_signal_network_name}=None   ${cpe_signal_subnet_name}=None
    ${name_suffix}=    Generate Timestamp
    ${vfmodule_name}=     Catenate    SEPARATOR=_    vf	    ${short_model_customization_name}	    ${name_suffix}
    #TODO this became a mess, need to fix
    ${parameters}=     Create Dictionary    pub_key=${GLOBAL_INJECTED_PUBLIC_KEY}    suffix=${name_suffix}    mr_ip_addr=${GLOBAL_INJECTED_MR_IP_ADDR}    mr_ip_port=${GLOBAL_MR_SERVER_PORT}
    Set To Dictionary    ${parameters}    oam_onap_net=oam_network_2No2        oam_onap_subnet=oam_network_2No2    cpe_public_net=${cpe_public_network_name}     cpe_public_subnet=${cpe_public_subnet_name}    
    Set To Dictionary    ${parameters}    cpe_signal_subnet=${cpe_signal_subnet_name}    cpe_signal_net=${cpe_signal_network_name}    public_net_id=${GLOBAL_INJECTED_PUBLIC_NET_ID}
    # vnf_type and generic_vnf_type are identical
    Set To Dictionary    ${parameters}    vnf_type=${model_customization_name}    generic_vnf_type=${model_customization_name}    generic_vnf_name=${model_customization_name}    vnf_name=${vfmodule_name}    
    Set To Dictionary    ${parameters}    service_type=${service_instance_id}    sdnc_oam_ip=${GLOBAL_INJECTED_SDNC_IP_ADDR}
	${post_resp}=    SDNC.Preload Vfmodule    ${SDNC_REST_ENDPOINT}    ${SDNC_INDEX_PATH}${PRELOAD_VNF_TOPOLOGY_OPERATION_PATH}    ${GLOBAL_TEMPLATE_FOLDER}    ${PRELOAD_TOPOLOGY_OPERATION_BODY}/template.vcpe_infra_vfmodule.jinja    ${parameters}
    [Return]    ${post_resp}
	    
Preload Vnf
    [Arguments]    ${service_type_uuid}    ${generic_vnf_name}    ${generic_vnf_type}     ${vf_module_name}    ${vf_modules}    ${vnf}   ${uuid}    ${service}
    ${base_vf_module_type}=    Catenate
    ${closedloop_vf_module}=    Create Dictionary
    ServiceMapping.Set Directory    default    ${GLOBAL_SERVICE_MAPPING_DIRECTORY}
    ${templates}=    ServiceMapping.Get Service Template Mapping    default    ${service}    ${vnf}
    :FOR    ${vf_module}    IN      @{vf_modules}
    \       ${vf_module_type}=    Get From Dictionary    ${vf_module}    name
    #     need to pass in vnf_index if non-zero
    \       ${dict}   Run Keyword If    "${generic_vnf_name}".endswith('0')      Get From Mapping With Index    ${templates}    ${vf_module}   0
            ...    ELSE IF  "${generic_vnf_name}".endswith('1')      Get From Mapping With Index    ${templates}    ${vf_module}   1
            ...    ELSE IF  "${generic_vnf_name}".endswith('2')      Get From Mapping With Index    ${templates}    ${vf_module}   2
            ...    ELSE   Get From Mapping    ${templates}    ${vf_module}
    #     skip this iteration if no template 
    \       ${test_dict_length} =  Get Length  ${dict}
    \       Continue For Loop If   ${test_dict_length} == 0
    \       ${filename}=    Get From Dictionary    ${dict}    template
    \       ${base_vf_module_type}=   Set Variable If    '${dict['isBase']}' == 'true'     ${vf_module_type}    ${base_vf_module_type}
    \       ${closedloop_vf_module}=   Set Variable If    '${dict['isBase']}' == 'false'     ${vf_module}    ${closedloop_vf_module}
    \       ${vf_name}=     Update Module Name    ${dict}    ${vf_module_name}
    #    Admin portal update no longer 
    #\       Preload Vnf Profile    ${vf_module_type}
    \       Preload One Vnf Topology    ${service_type_uuid}    ${generic_vnf_name}    ${generic_vnf_type}     ${vf_name}    ${vf_module_type}    ${service}    ${filename}   ${uuid}
    [Return]    ${base_vf_module_type}   ${closedloop_vf_module}

Update Module Name
    [Arguments]    ${dict}    ${vf_module_name}
    Return From Keyword If    'prefix' not in ${dict}    ${vf_module_name}
    Return From Keyword If    '${dict['prefix']}' == ''    ${vf_module_name}
    ${name}=    Replace String   ${vf_module_name}   Vfmodule_    ${dict['prefix']}
    [Return]    ${name}

Get From Mapping With Index
    [Documentation]    Retrieve the appropriate prelad template entry for the passed vf_module
    [Arguments]    ${templates}    ${vf_module}   ${vnf_index}=0
    ${vf_module_name}=    Get From DIctionary    ${vf_module}    name
    :FOR    ${template}   IN   @{templates}
    \    Return From Keyword If    '${template['name_pattern']}' in '${vf_module_name}' and ('${template['vnf_index']}' == '${vnf_index}')     ${template}
    ${result}=    Create Dictionary
    [Return]    ${result}

Get From Mapping
    [Documentation]    Retrieve the appropriate prelad template entry for the passed vf_module
    [Arguments]    ${templates}    ${vf_module}
    ${vf_module_name}=    Get From DIctionary    ${vf_module}    name
    :FOR    ${template}   IN   @{templates}
    \    Return From Keyword If    '${template['name_pattern']}' in '${vf_module_name}'     ${template}
    ${result}=    Create Dictionary
    [Return]    ${result}

Preload One Vnf Topology
    [Arguments]    ${service_type_uuid}    ${generic_vnf_name}    ${generic_vnf_type}       ${vf_module_name}    ${vf_module_type}    ${service}    ${filename}   ${uuid}
    Return From Keyword If    '${filename}' == ''
    ${parameters}=    Get Template Parameters    ${generic_vnf_name}    ${filename}   ${uuid}    ${service}
    Set To Dictionary   ${parameters}   generic_vnf_name=${generic_vnf_name}     generic_vnf_type=${generic_vnf_type}  service_type=${service_type_uuid}    vf_module_name=${vf_module_name}    vf_module_type=${vf_module_type}
    Templating.Create Environment    sdnc    ${GLOBAL_TEMPLATE_FOLDER}
    ${data}=   Templating.Apply Template    sdnc   ${PRELOAD_TOPOLOGY_OPERATION_BODY}/preload.jinja    ${parameters}
    ${post_resp}= 	SDNC.Run Post Request 	${SDNC_REST_ENDPOINT} 	${SDNC_INDEX_PATH}${PRELOAD_VNF_TOPOLOGY_OPERATION_PATH}     data=${data}    auth=${GLOBAL_SDNC_AUTHENTICATION}
    Should Be Equal As Strings 	${post_resp.json()['output']['response-code']} 	200
    ${get_resp}= 	SDNC.Run Get Request 	${SDNC_REST_ENDPOINT}    ${SDNC_INDEX_PATH}${PRELOAD_VNF_CONFIG_PATH}/${vf_module_name}/${vf_module_type}     auth=${GLOBAL_SDNC_AUTHENTICATION}

Get Template Parameters
    [Arguments]   ${generic_vnf_name}    ${template}    ${uuid}    ${service}
    ${hostid}=    Get Substring    ${uuid}    -4
    ${ecompnet}=    Evaluate    (${GLOBAL_BUILD_NUMBER}%128)+128

    ${valuemap}=   Get Globally Injected Parameters
    # update the value map with unique values.
    Set To Dictionary   ${valuemap}   uuid=${uuid}   hostid=${hostid}    ecompnet=${ecompnet}    generic_vnf_name=${generic_vnf_name}

    #
    # Mash together the defaults dict with the test case dict to create the set of
    # preload parameters
    #
    Preload.Set Directory    preload    ./demo/preload_data
    ${defaults}=       Get Default Preload Data    preload
    ${template}=    Get Preload Data    preload    ${service}    ${template}
    # add all of the defaults to template...
    @{keys}=    Get Dictionary Keys    ${defaults}
    :FOR   ${key}   IN   @{keys}
    \    ${value}=   Get From Dictionary    ${defaults}    ${key}
    \    Set To Dictionary    ${template}  ${key}    ${value}

    #
    # Get the vnf_parameters to preload
    #
    ${vnf_parameters}=   Resolve VNF Parameters Into Array   ${valuemap}   ${template}
    ${vnf_parameters_json}=   Evaluate    json.dumps(${vnf_parameters})    json
    ${parameters}=   Create Dictionary   vnf_parameters=${vnf_parameters_json}
    [Return]    ${parameters}

Resolve VNF Parameters Into Array
    [Arguments]   ${valuemap}    ${from}
    ${vnf_parameters}=   Create List
    ${keys}=    Get Dictionary Keys    ${from}
    :FOR   ${key}   IN  @{keys}
    \    ${value}=    Get From Dictionary    ${from}   ${key}
    \    ${value}=    Templating.Template String    ${value}    ${valuemap}
    \    ${parameter}=   Create Dictionary   vnf-parameter-name=${key}    vnf-parameter-value=${value}
    \    Append To List    ${vnf_parameters}   ${parameter}
    [Return]   ${vnf_parameters}

Preload Vnf Profile
    [Arguments]    ${vnf_name}
    Login To SDNC Admin GUI
    Go To    ${SDNC_ADMIN_VNF_PROFILE_URL}
    Click Button    xpath=//button[@data-target='#add_vnf_profile']
    Input Text    xpath=//input[@id='nf_vnf_type']    ${vnf_name}
    Input Text    xpath=//input[@id='nf_availability_zone_count']    999
    Input Text    xpath=//input[@id='nf_equipment_role']    robot-ete-test
    Click Button    xpath=//button[contains(.,'Submit')]
    Page Should Contain  VNF Profile
    Input Text    xpath=//div[@id='vnf_profile_filter']//input    ${vnf_name}
    Page Should Contain  ${vnf_name}

Delete Vnf Profile
    [Arguments]    ${vnf_name}
    Login To SDNC Admin GUI
    Go To    ${SDNC_ADMIN_VNF_PROFILE_URL}
    Page Should Contain  VNF Profile
    Input Text    xpath=//div[@id='vnf_profile_filter']//input    ${vnf_name}
    Page Should Contain  ${vnf_name}
    Click Button    xpath=//button[contains(@onclick, '${vnf_name}')]
    Page Should Contain    Are you sure you want to delete VNF_PROFILE
    Click Button    xpath=//button[contains(text(), 'Yes')]
    Page Should Not Contain  ${vnf_name}

Login To SDNC Admin GUI
    [Documentation]   Login To SDNC Admin GUI
    ## Setup Browser is now being managed by the test case
    ## Setup Browser
    Go To    ${SDNC_ADMIN_SIGNUP_URL}
    ##Maximize Browser Window
    Set Selenium Speed    ${GLOBAL_SELENIUM_DELAY}
    Set Browser Implicit Wait    ${GLOBAL_SELENIUM_BROWSER_IMPLICIT_WAIT}
    Log    Logging in to ${SDNC_ADMIN_LOGIN_URL}
    Handle Proxy Warning
    Title Should Be    AdminPortal
    ${uuid}=    Generate UUID4
    ${shortened_uuid}=     Evaluate    str("${uuid}")[:12]
    ${email}=        Catenate    ${shortened_uuid}@robotete.com
    Input Text    xpath=//input[@id='nf_email']    ${email}
    Input Password    xpath=//input[@id='nf_password']    ${shortened_uuid}
    Click Button    xpath=//button[@type='submit']
    Wait Until Page Contains    User created   20s
    Go To    ${SDNC_ADMIN_LOGIN_URL}
    Input Text    xpath=//input[@id='email']    ${email}
    Input Password    xpath=//input[@id='password']    ${shortened_uuid}
    Click Button    xpath=//button[@type='submit']
    Title Should Be    SDN-C AdminPortal
    Log    Logged in to ${SDNC_ADMIN_LOGIN_URL}
