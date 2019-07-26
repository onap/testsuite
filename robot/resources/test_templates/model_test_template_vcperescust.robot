*** Settings ***
Documentation     Distribute models for vcpe
Library           OperatingSystem
Library            ArchiveLibrary
Library           Collections
Library           String
Library           DateTime
Library           ONAPLibrary.ServiceMapping    WITH NAME    ServiceMapping
Resource          ../sdc_interface.robot

*** Variables ***
${SDC_ASSETS_DIRECTORY}    ${GLOBAL_HEAT_TEMPLATES_FOLDER}
${SDC_ZIP_DIRECTORY}    ${SDC_ASSETS_DIRECTORY}/temp

*** Keywords ***
Model Distribution For vCPEResCust Directory
    [Arguments]    ${service}   ${catalog_service_name}=    ${cds}=
    ServiceMapping.Set Directory    default    ${GLOBAL_SERVICE_MAPPING_DIRECTORY}
    ${directory_list}=    ServiceMapping.Get Service Folder Mapping    default    ${service}
    ${ziplist}=    Create List
    ${uuid}=    Get Current Date
    ${service_name}=    Catenate    ${service}    ${uuid}
    ${shortened_uuid}=     Evaluate    str("${service_name}")[:23]
    ${catalog_service_name}=   Set Variable If   '${catalog_service_name}' ==''   ${shortened_uuid}   ${catalog_service_name}
    :FOR   ${directory}    IN    @{directory_list}
    \    ${zipname}=   Replace String    ${directory}    /    _
    \    ${zip}=    Catenate    ${SDC_ZIP_DIRECTORY}/${zipname}.zip
    \    ${folder}=    Catenate    ${SDC_ASSETS_DIRECTORY}/${directory}
    \    OperatingSystem.Create Directory    ${SDC_ASSETS_DIRECTORY}/temp
    \    Create Zip From Files In Directory        ${folder}    ${zip}
    \    Append To List    ${ziplist}    ${zip}
    ${catalog_service_name}    ${catalog_resource_name}    ${vf_modules}    ${catalog_resource_ids}   ${catalog_service_id}   ${catalog_resources}   Distribute vCPEResCust Model From SDC    ${ziplist}    ${catalog_service_name}    ${cds}   ${service}
    Download CSAR    ${catalog_service_id}   
    [Return]    ${catalog_service_name}    ${catalog_resource_name}    ${vf_modules}   ${catalog_resources}