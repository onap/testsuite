*** Settings ***
Documentation     PNF Registration Handler (PRH) test cases
Resource        ../aai/aai_interface.robot
Resource        ../mr_interface.robot
Resource        ../json_templater.robot
Library         ONAPLibrary.Openstack
Library         OperatingSystem
Library         RequestsLibrary
Library         Collections
Library         ONAPLibrary.JSON
Library         ONAPLibrary.Utilities


*** Variables ***
${aai_so_registration_entry_template}=  robot/assets/templates/aai/add_pnf_registration_info.template
${pnf_ves_integration_request}=  robot/assets/templates/ves/pnf_registration_request.template
${DMAAP_MESSAGE_ROUTER_UNAUTHENTICATED_PNF_PATH}  /events/unauthenticated.PNF_READY/2/1
${VES_ENDPOINT}     ${GLOBAL_DCAE_VES_PROTOCOL}://${GLOBAL_INJECTED_DCAE_VES_HOST}:${GLOBAL_DCAE_VES_SERVER_PORT}
${VES_data_path}   /eventListener/v7


*** Keywords ***
Create A&AI antry without SO and succesfully registrate PNF
    [Documentation]   Test case template for create A&AI antry without SO and succesfully registrate PNF
    [Arguments]   ${PNF_entry_dict}
    Create PNF initial entry in A&AI  ${PNF_entry_dict}
    Send VES integration request  ${PNF_entry_dict}
    Verify PNF Integration Request in A&AI  ${PNF_entry_dict}

Create PNF initial entry in A&AI
    [Documentation]   Creates PNF initial entry in A&AI registry. Entry contains only correlation id (pnf-name)
    [Arguments]  ${PNF_entry_dict}
    ${template}=  Fill Json Template File  ${aai_so_registration_entry_template}  ${PNF_entry_dict}
    Log  Filled A&AI entry template ${template}
    ${correlation_id}=  Get From Dictionary  ${PNF_entry_dict}  correlation_id
    ${del_resp}=  Delete A&AI Entity  /network/pnfs/pnf/${PNF_entry_dict.correlation_id}
    Log  Removing existing entry "${PNF_entry_dict.correlation_id}" from A&AI registry
    ${put_resp}=  Run A&AI Put Request  /aai/v11/network/pnfs/pnf/${PNF_entry_dict.correlation_id}  ${template}
    Log  Adding new entry with correlation ID "${PNF_entry_dict.correlation_id}" to A&AI registry (empty IPv4 and IPv6 address)

Send VES integration request
    [Documentation]   Send VES integration request. Request contains correlation id (sourceName), oamV4IpAddress and oamV6IpAddress
    [Arguments]  ${PNF_entry_dict}
    ${template}=  Fill Json Template File  ${pnf_ves_integration_request}  ${PNF_entry_dict}
    ${post_resp}=  Run VES HTTP Post Request   ${template}
    Should Be Equal As Strings  ${post_resp.status_code}        202
    Log  VES integration request has been send

Verify PNF integration request in A&AI
    [Documentation]   Verify if PNF integration request entries are present in A&AI
    [Arguments]  ${PNF_entry_dict}
    Wait Until Keyword Succeeds  10x  5s  Query PNF A&AI updated entry  ${PNF_entry_dict}
    Log  PNF integration request in A&AI has been verified and contains all necessary entries

Verify PNF integration request in MR
    [Documentation]   Verify if PNF integration request entries are present in MR unauthenticated.PNF_READY/ topic
    [Arguments]  ${PNF_entry_dict}
    Wait Until Keyword Succeeds  10x  1s  Query PNF MR entry  ${PNF_entry_dict}
    Log  PNF integration request in MR has been verified and contains all necessary entries

Query PNF A&AI updated entry
    [Documentation]   Query PNF A&AI updated entry
    [Arguments]  ${PNF_entry_dict}
    ${get_resp}=  Run A&AI Get Request  /aai/v11/network/pnfs/pnf/${PNF_entry_dict.correlation_id}
    Should Be Equal As Strings  ${get_resp.status_code}        200
    ${json_resp}=  Set Variable  ${get_resp.json()}
    Log  JSON recieved from A&AI endpoint ${json_resp}
    Should Be Equal As Strings  ${json_resp["ipaddress-v4-oam"]}      ${PNF_entry_dict.PNF_IPv4_address}
    Should Be Equal As Strings  ${json_resp["ipaddress-v6-oam"]}       ${PNF_entry_dict.PNF_IPv6_address}
    Should Be Equal As Strings  ${json_resp["pnf-name"]}       ${PNF_entry_dict.correlation_id}
    Log  PNF integration request in A&AI has been verified and contains all necessary entries

Query PNF MR entry
    [Documentation]   Query PNF MR updated entry
    [Arguments]  ${PNF_entry_dict}
    ${get_resp}=  Run MR Get Request  ${DMAAP_MESSAGE_ROUTER_UNAUTHENTICATED_PNF_PATH}
    Should Be Equal As Strings  ${get_resp.status_code}        200
    ${json_resp_item}=  Get From List  ${get_resp.json()}  0
    ${json}=    evaluate    json.loads('${json_resp_item}')    json
    Log  JSON recieved from MR ${DMAAP_MESSAGE_ROUTER_UNAUTHENTICATED_PNF_PATH} endpoint ${json}
    Should Be Equal As Strings  ${json["ipaddress-v4-oam"]}      ${PNF_entry_dict.PNF_IPv4_address}
    Should Be Equal As Strings  ${json["ipaddress-v6-oam"]}       ${PNF_entry_dict.PNF_IPv6_address}
    Should Be Equal As Strings  ${json["correlationId"]}       ${PNF_entry_dict.correlation_id}
    Log  PNF integration request in MR has been verified and contains all necessary entries

Run VES HTTP Post Request
    [Documentation]    Runs a VES Post request
    [Arguments]     ${data}
    Disable Warnings
    ${session}=    Create Session       ves     ${VES_ENDPOINT}
    ${headers}=  Create Dictionary   Accept=application/json    Content-Type=application/json
    ${post_resp}=       Post Request    ves     ${VES_data_path}      data=${data}    headers=${headers}
    Log  PNF integration request ${data}
    Should Be Equal As Strings  ${post_resp.status_code}        202
    Log  VES has accepted event with status code ${post_resp.status_code}
    [Return]  ${post_resp}

Cleanup PNF entry in A&AI
    [Documentation]   Creates PNF initial entry in A&AI registry
    [Arguments]  ${PNF_entry_dict}
    ${del_resp}=  Delete A&AI Entity  /network/pnfs/pnf/${PNF_entry_dict.correlation_id}
    Log    Teardown complete
