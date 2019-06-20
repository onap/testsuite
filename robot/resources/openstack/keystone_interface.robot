*** Settings ***
Documentation     The main interface for interacting with Openstack Keystone API. It handles low level stuff like managing the authtoken and Openstack required fields
Library           ONAPLibrary.Openstack
Library 	      RequestsLibrary
Library	          ONAPLibrary.Utilities
Library	          Collections
Library           OperatingSystem
Library           String
Library	          ONAPLibrary.Templating
Resource    ../global_properties.robot
Resource    openstack_common.robot

*** Variables ***
${OPENSTACK_KEYSTONE_API_v3_VERSION}   /v3
${OPENSTACK_KEYSTONE_API_v2_VERSION}   /v2.0
${OPENSTACK_KEYSTONE_AUTH_v3_PATH}    /auth/tokens
${OPENSTACK_KEYSTONE_AUTH_v2_PATH}    /tokens
${OPENSTACK_KEYSTONE_AUTH_v2_BODY_FILE}    openstack/keystone_get_v2_auth.jinja
${OPENSTACK_KEYSTONE_AUTH_v3_BODY_FILE}    openstack/keystone_get_v3_auth.jinja
${OPENSTACK_KEYSTONE_TENANT_PATH}    /tenants

*** Keywords ***
Run Openstack Auth Request
    [Documentation]    Runs an Openstack Auth Request and returns the token and service catalog. you need to include the token in future request's x-auth-token headers. Service catalog describes what can be called
    [Arguments]    ${alias}    ${username}=    ${password}=
    ${username}    ${password}=   Set Openstack Credentials   ${username}    ${password}
    ${keystone_api_version}=    Run Keyword If    '${GLOBAL_INJECTED_OPENSTACK_KEYSTONE_API_VERSION}'==''    Get KeystoneAPIVersion 
    ...    ELSE    Set Variable   ${GLOBAL_INJECTED_OPENSTACK_KEYSTONE_API_VERSION}
    ${url}   ${path}=   Get Keystone Url And Path   ${keystone_api_version}
    ${session}=    Create Session 	keystone 	${url}    verify=True
    ${uuid}=    Generate UUID4
    ${data_path}   ${data}=   Run Keyword If   '${keystone_api_version}'=='v2.0'   Get KeyStoneAuthv2 Data   ${username}    ${password}    ${path}
    ...   ELSE   Get KeyStoneAuthv3 Data   ${username}    ${password}   ${path}
    ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json    X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}
    Log    Sending authenticate post request ${data_path} with headers ${headers} and data ${data}
    ${resp}= 	Post Request 	keystone 	${data_path}     data=${data}    headers=${headers}
    Should Be True    200 <= ${resp.status_code} < 300
    ${auth_token}=    Evaluate    ''
    ${auth_token}=    Run Keyword If    '${keystone_api_version}'=='v3'    Get From Dictionary    ${resp.headers}    X-Subject-Token
    Log    Keystone API Version is ${keystone_api_version}
    Save Openstack Auth    ${alias}    ${resp.text}    ${auth_token}    ${keystone_api_version}
    Log    Received response from keystone ${resp.text}

Get KeystoneAPIVersion
    [Documentation]    Get Keystone API version
    ${pieces}=    Url Parse    ${GLOBAL_INJECTED_KEYSTONE}
    ${url}=    Catenate    ${pieces.scheme}://${pieces.netloc}
    Log   Keystone URL is ${url}
    ${session}=    Create Session    keystone    ${url}    verify=True
    ${uuid}=    Generate UUID4
    ${headers}=    Create Dictionary    Accept=application/json    Content-Type=application/json    
    ${resp}=    Get Request    keystone  /   headers=${headers}
    Log    Received response from keystone ${resp.text}
    Should Be Equal As Strings    ${resp.status_code}    300
    ${versions}=   Get From Dictionary    ${resp.json()}   versions
    ${values}=   Get From Dictionary    ${versions}   values
    :FOR    ${value}    IN    @{values}
       \  ${status}=    Get Variable Value    ${value["status"]}
       \  Run Keyword If    '${status}'=='stable'   Exit For Loop
    ${href}=  Set Variable     ${value["links"][0]["href"]}
    ${keystone}=  Set Variable   ${GLOBAL_INJECTED_KEYSTONE}  
    ${version}=    Remove String  ${href}   ${keystone}  /
    Return From Keyword If   '${version}'=='v2.0' or '${version}'=='v3'    ${version}
    Fail   Keystone API version not found or not supported    
	
Get KeyStoneAuthv2 Data
    [Documentation]    Returns all the data for keystone auth v2 api
    [Arguments]    ${username}    ${password}    ${path}
    ${arguments}=    Create Dictionary    username=${username}    password=${password}   tenantId=${GLOBAL_INJECTED_OPENSTACK_TENANT_ID}
    Create Environment    keystone    ${GLOBAL_TEMPLATE_FOLDER}
    ${data}=    Apply Template    keystone    ${OPENSTACK_KEYSTONE_AUTH_v2_BODY_FILE}    ${arguments}
    ${data_path}=    Catenate    ${path}${OPENSTACK_KEYSTONE_AUTH_v2_PATH}
    [Return]    ${data_path}    ${data}

Get KeyStoneAuthv3 Data
    [Documentation]    Returns all the data for keystone auth v3 api
    [Arguments]    ${username}    ${password}    ${path}
    ${arguments}=    Create Dictionary    username=${username}    password=${password}   domain_id=${GLOBAL_INJECTED_OPENSTACK_DOMAIN_ID}    project_name=${GLOBAL_INJECTED_OPENSTACK_PROJECT_NAME}
    Create Environment    keystone    ${GLOBAL_TEMPLATE_FOLDER}
    ${data}=    Apply Template    keystone    ${OPENSTACK_KEYSTONE_AUTH_v3_BODY_FILE}    ${arguments}
    ${data_path}=    Catenate    ${path}${OPENSTACK_KEYSTONE_AUTH_v3_PATH}
    [Return]    ${data_path}    ${data}

Get Openstack Tenants
    [Documentation]    Returns all the openstack tenant info
    [Arguments]    ${alias}
    ${resp}=    Internal Get Openstack With Region    ${alias}    ${GLOBAL_OPENSTACK_KEYSTONE_SERVICE_TYPE}    region=    url_ext=${OPENSTACK_KEYSTONE_TENANT_PATH}    data_path=
    [Return]    ${resp.json()}

Get Openstack Tenant
    [Documentation]    Returns the openstack tenant info for the specified tenantid
    [Arguments]    ${alias}     ${tenant_id}
    ${resp}=    Internal Get Openstack With Region    ${alias}    ${GLOBAL_OPENSTACK_KEYSTONE_SERVICE_TYPE}    region=    url_ext=${OPENSTACK_KEYSTONE_TENANT_PATH}    data_path=/${tenant_id}
    [Return]    ${resp.json()}

Set Openstack Credentials
    [Arguments]    ${username}    ${password}
    Return From Keyword If    '${username}' != ''   ${username}    ${password}
    ${user}   ${pass}=   Get Openstack Credentials
    [Return]   ${user}   ${pass}

Get Openstack Credentials
    [Documentation]   Returns the Decripted Password and openstack username using same api_key.txt as SO
    ${DECRYPTED_OPENSTACK_PASSWORD}=   Run    echo -n ${GLOBAL_INJECTED_OPENSTACK_API_KEY} | xxd -r -p | openssl enc -aes-128-ecb -d -nosalt -K aa3871669d893c7fb8abbcda31b88b4f | tr -d '\x08'
    [Return]   ${GLOBAL_INJECTED_OPENSTACK_USERNAME}    ${DECRYPTED_OPENSTACK_PASSWORD}


Get Keystone Url And Path
    [Arguments]    ${keystone_api_version}
    [Documentation]    Handle arbitrary keystone identiit url. Add v2.0 if not present.
    ${url}    ${path}=    Run Keyword If    '${keystone_api_version}'=='v2.0'    Set API Version    ${OPENSTACK_KEYSTONE_API_v2_VERSION}
    ...    ELSE    Set API Version    ${OPENSTACK_KEYSTONE_API_v3_VERSION}
    Log    Path is ${url} ${path}
    [Return]   ${url}   ${path}

Set API Version
    [Documentation]    Decides the API version to be used
    [Arguments]    ${openstack_version}
    ${pieces}=   Url Parse   ${GLOBAL_INJECTED_KEYSTONE}
    ${url}=      Catenate   ${pieces.scheme}://${pieces.netloc}
    ${version}=  Evaluate   ''
    ${version}=  Set Variable If   '${openstack_version}' not in '${pieces.path}'   ${openstack_version}   ${version}
    ${path}=     Catenate   ${pieces.path}${version}
    [Return]   ${url}   ${path}
