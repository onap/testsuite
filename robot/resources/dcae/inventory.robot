*** Settings ***
Documentation	  The main interface for interacting with 5G Bulkpm.
Library 	      RequestsLibrary
Library           OperatingSystem
Library           String
Library           ONAPLibrary.Templating    WITH NAME    Templating
Resource          ../global_properties.robot


*** Variables ***
${INVENTORY_SERVER}                 ${GLOBAL_INVENTORY_SERVER_PROTOCOL}://${GLOBAL_INVENTORY_SERVER_NAME}:${GLOBAL_INVENTORY_SERVER_PORT}
${INVENTORY_ENDPOINT}               /dcae-service-types
${BLUEPRINT_TEMPLATE}               ${EXECDIR}/robot/assets/cmpv2/blueprintTemplate.json
*** Keywords ***

Load Blueprint To Inventory
    [Arguments]                         ${blueprint_path}                   ${typeName}
    Disable Warnings
    ${blueprint}=                       OperatingSystem.Get File            ${blueprint_path}
    ${templatejson}=                    Load JSON From File                 ${BLUEPRINT_TEMPLATE}
    ${templatejson}=                    Update Value To Json                ${templatejson}                            blueprintTemplate             ${blueprint}
    ${templatejson}=                    Update Value To Json                ${templatejson}                            typeName                      ${typeName}
    ${data}                             Convert JSON To String              ${templatejson}
    ${headers}=                         Create Dictionary                   content-type=application/json
    ${session}=                         Create Session                      inventory_session                           ${INVENTORY_SERVER}
    ${resp}=                            Post Request                        inventory_session                           ${INVENTORY_ENDPOINT}           data=${data}             headers=${headers}
    ${serviceTypeId}=                   Set Variable                        ${resp.json().get('typeId')}
    [Return]                            ${serviceTypeId}

Delete Blueprint From Inventory
    [Arguments]                         ${serviceTypeId}
    Disable Warnings
    ${session}=                         Create Session                      inventory_session                           ${INVENTORY_SERVER}
    ${resp}=                            Delete Request                      inventory_session                           ${INVENTORY_ENDPOINT}/${serviceTypeId}
    [Return]                            ${resp}

Get Blueprint From Inventory
    [Arguments]                         ${typeName}
    Disable Warnings
    ${headers}=                         Create Dictionary                   content-type=application/json
    ${session}=                         Create Session                      inventory_session                           ${INVENTORY_SERVER}
    ${resp}=                            Get Request                         inventory_session                           ${INVENTORY_ENDPOINT}?typeName=${typeName}      headers=${headers}
    Should Not Be Equal As Integers  ${resp.json().get('totalCount')}  0  msg=Blueprint ${typeName} does not exist in inventory!
    [Return]                            ${resp}


