*** Settings ***
Documentation     The main interface for interacting with ASDC. It handles low level stuff like managing the http request library and DCAE required fields
Library           OperatingSystem
Library            ArchiveLibrary
Library           Collections
Library           String
Library           DateTime
Library           ONAPLibrary.ServiceMapping
Resource          ../asdc_interface.robot

*** Variables ***
${ASDC_BASE_PATH}    /sdc1
${ASDC_DESIGNER_PATH}    /proxy-designer1#/dashboard
${ASDC_ASSETS_DIRECTORY}    ${GLOBAL_HEAT_TEMPLATES_FOLDER}
${ASDC_ZIP_DIRECTORY}    ${ASDC_ASSETS_DIRECTORY}/temp

#***************** Test Case Variables *********************
${CATALOG_RESOURCE_IDS}
${CATALOG_SERVICE_ID}

*** Keywords ***

Model Distribution For Directory
    [Arguments]    ${service}   ${catalog_service_name}=    ${cds}=
    Set Directory    default    ./demo/service_mapping
    ${directory_list}=    Get Service Folder Mapping    default    ${service}
    ${ziplist}=    Create List
    ${uuid}=    Get Current Date
    ${service_name}=    Catenate    ${service}    ${uuid}
    ${shortened_uuid}=     Evaluate    str("${service_name}")[:23]
    ${catalog_service_name}=   Set Variable If   '${catalog_service_name}' ==''   ${shortened_uuid}   ${catalog_service_name}
    :FOR   ${directory}    IN    @{directory_list}
    \    ${zipname}=   Replace String    ${directory}    /    _
    \    ${zip}=    Catenate    ${ASDC_ZIP_DIRECTORY}/${zipname}.zip
    \    ${folder}=    Catenate    ${ASDC_ASSETS_DIRECTORY}/${directory}
    \    OperatingSystem.Create Directory    ${ASDC_ASSETS_DIRECTORY}/temp
    \    Create Zip From Files In Directory        ${folder}    ${zip}
    \    Append To List    ${ziplist}    ${zip}
    ${catalog_service_name}    ${catalog_resource_name}    ${vf_modules}    ${catalog_resource_ids}   ${catalog_service_id}   ${catalog_resources}   Distribute Model From ASDC    ${ziplist}    ${catalog_service_name}    ${cds}   ${service}
    Set Test Variable   ${CATALOG_RESOURCE_IDS}   ${catalog_resource_ids}
    Set Test Variable   ${CATALOG_SERVICE_ID}   ${catalog_service_id}
    Set Test Variable   ${CATALOG_RESOURCES}   ${catalog_resources}
    Download CSAR    ${catalog_service_id}   
    [Return]    ${catalog_service_name}    ${catalog_resource_name}    ${vf_modules}   ${catalog_resources}




Teardown Model Distribution
    [Documentation]    Clean up at the end of the test
    Log   ${CATALOG_SERVICE_ID} ${CATALOG_RESOURCE_IDS}
    Teardown Models    ${CATALOG_SERVICE_ID}   ${CATALOG_RESOURCE_IDS}

Teardown Models
    [Documentation]    Clean up at the end of the test
    [Arguments]     ${catalog_service_id}    ${catalog_resource_ids}
    Return From Keyword If    '${catalog_service_id}' == ''
    :FOR    ${catalog_resource_id}   IN   @{catalog_resource_ids}
    \   ${resourece_json}=   Mark ASDC Catalog Resource Inactive    ${catalog_resource_id}
    ${service_json}=   Mark ASDC Catalog Service Inactive    ${catalog_service_id}
    ${services_json}=   Delete Inactive ASDC Catalog Services
    ${resources_json}=    Delete Inactive ASDC Catalog Resources
