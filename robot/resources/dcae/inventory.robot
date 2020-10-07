*** Settings ***
Documentation	  The main interface for interacting with 5G Bulkpm.
Library 	      RequestsLibrary
Library           OperatingSystem
Library           String
Library           ONAPLibrary.Templating    WITH NAME    Templating


*** Variables ***
${INVENTORY_SERVER}                 ${GLOBAL_INVENTORY_SERVER_PROTOCOL}://${GLOBAL_INVENTORY_SERVER_NAME}:${GLOBAL_INVENTORY_SERVER_PORT}
${INVENTORY_ENDPOINT}               /dcae-service-types
${BLUEPRINT_TEMPLATE}               inventory/blueprintTemplate.jinja
*** Keywords ***

Load Blueprint To Inventory
    [Arguments]                         ${blueprint_path}                   ${typeName}
    ${blueprint}=                       OperatingSystem.Get File            ${blueprint_path}
    ${arguments}=                       Create Dictionary                   blueprintTemplate=${blueprint}              typeName=${typeName}
    Templating.Create Environment       inventory                           ${GLOBAL_TEMPLATE_FOLDER}
    ${data}=                            Templating.Apply Template           inventory                                   ${BLUEPRINT_TEMPLATE}           ${arguments}
    ${headers}=                         Create Dictionary                   content-type=application/json
    ${session}=                         Create Session                      inventory_session                           ${INVENTORY_SERVER}
    ${resp}=                            Post Request                        inventory_session                           ${INVENTORY_ENDPOINT}           data=${data}             headers=${headers}
    ${serviceTypeId}=                   Set Variable                        ${resp.json().get('typeId')}
    [Return]                            ${serviceTypeId}

Delete Blueprint From Inventory
    [Arguments]                         ${serviceTypeId}
    ${session}=                         Create Session                      inventory_session                           ${INVENTORY_SERVER}
    ${resp}=                            Delete Request                      inventory_session                           ${INVENTORY_ENDPOINT}/${serviceTypeId}
    [Return]                            ${resp}

Get Blueprint From Inventory
    [Arguments]                         ${typeName}
    ${headers}=                         Create Dictionary                   content-type=application/json
    ${session}=                         Create Session                      inventory_session                           ${INVENTORY_SERVER}
    ${resp}=                            Get Request                         inventory_session                           ${INVENTORY_ENDPOINT}?typeName=${typeName}      headers=${headers}
    [Return]                            ${resp}