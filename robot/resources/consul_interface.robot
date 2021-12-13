*** Settings ***
Documentation     The main interface for interacting with Consul.
Library           RequestsLibrary
Library           Collections
Library           String
Resource          global_properties.robot

*** Variables ***
${CONSUL_ENDPOINT}              http://consul-server-ui:8500
#${CONSUL_ENDPOINT}              ${GLOBAL_CONSUL_SERVER_PROTOCOL}://${GLOBAL_CONSUL_SERVER_NAME}:${GLOBAL_CONSUL_SERVER_PORT}



*** Keywords ***
Run Consul Get Request
    [Documentation]    Runs Consul Tcagen2 Get Request
    [Arguments]    ${data_path}
    ${session}=    Create Session      consul  ${CONSUL_ENDPOINT}
    ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
    ${resp}=   Get Request     consul  ${data_path}     headers=${headers}
    Log    Received response from tcagen2 ${resp.text}
    Should Be Equal As Strings         ${resp.status_code}     200
    [Return]   ${resp}

Run Consul Put Request
    [Documentation]    Runs Consul Tcagen2 Put request
    [Arguments]    ${data_path}  ${data}
    ${session}=    Create Session      consul  ${CONSUL_ENDPOINT}
    ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
    ${resp}=   Put Request     consul  ${data_path}     data=${data}    headers=${headers}
    Log    Received response from consul ${resp.text}
    [Return]    ${resp}

Update Tca ControlLoopName
    [Arguments]   ${resource_id}
    ${closedLoopControlName}=    Set Variable    ControlLoop-vFirewall-${resource_id}
    Log    Obtained closedLoopControlName ${closedLoopControlName}
    ${resp}=   Run Consul Get Request   /v1/kv/dcae-tcagen2
    Should Be Equal As Strings  ${resp.status_code}     200
    ${base64Obj}=   Set Variable    ${resp.json()[0]["Value"]}
    ${binObj}=   Evaluate   base64.b64decode("${base64Obj}")   modules=base64
    ${escaped}=   Replace String    ${binObj}   \\   \\\\
    ${dict}=    Evaluate   json.loads('${escaped}')    json
    ${tca_policy}=    Set Variable    ${dict['tca.policy']}
    ${mdf_tca_policy}=    Replace String Using Regexp   ${tca_policy}    ControlLoop-vFirewall[^"]*    ${closedLoopControlName}
    #Set To Dictionary    ${dict['app_preferences']}    tca_policy=${mdf_tca_policy}
    Set To Dictionary    ${dict}    tca.policy=${mdf_tca_policy}
    ${json}=   Evaluate   json.dumps(${dict})     json
    ${resp}=   Run Consul Put Request   /v1/kv/dcae-tcagen2    data=${json}
    Should Be Equal As Strings  ${resp.status_code}     200
