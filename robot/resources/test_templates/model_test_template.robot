*** Settings ***
Documentation     Model distribution
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
${SDC_TOSCA_ONBOARDING_PACKAGES_DIRECTORY}    ${GLOBAL_TOSCA_ONBOARDING_PACKAGES_FOLDER}
${SDC_CSAR_DIRECTORY}   ${SDC_TOSCA_ONBOARDING_PACKAGES_DIRECTORY}/temp

*** Keywords ***
Model Distribution For Directory With Teardown
    [Arguments]    ${service}   ${catalog_service_name}=    ${cds}=False
    ${catalog_service_name}    ${catalog_resource_name}    ${vf_modules}   ${catalog_resources}    ${catalog_resource_ids}   ${catalog_service_id}=    Model Distribution For Directory    ${service}   ${catalog_service_name}    ${cds}
    [Teardown]    Teardown Models    ${catalog_service_id}    ${catalog_resource_ids}

Model Distribution For Directory
    [Arguments]    ${service}   ${catalog_service_name}=    ${cds}=False  ${instantiationType}=A-la-carte  ${resourceType}=VF
    ServiceMapping.Set Directory    default    ${GLOBAL_SERVICE_MAPPING_DIRECTORY}
    ${directory_list}=    ServiceMapping.Get Service Folder Mapping    default    ${service}
    ${ziplist}=    Create List
    ${uuid}=    Get Current Date
    ${service_name}=    Catenate    ${service}    ${uuid}
    # ':' is not an allowed character in the service_name. '-' is allowed
    S{service_name}=    Replace String    ${service_name}    :   -
    ${shortened_uuid}=     Evaluate    str("${service_name}")[:23]
    ${catalog_service_name}=   Set Variable If   '${catalog_service_name}' ==''   ${shortened_uuid}   ${catalog_service_name}
    Run Keyword If  '${resourceType}'=='PNF'  Create CSARSs in SDC Onboarding Packages Directory  ${directory_list}  ${ziplist}
    ...  ELSE  Create ZIPs in SDC ZIP Directory  ${directory_list}  ${ziplist}
    ${catalog_service_name}    ${catalog_resource_name}    ${vf_modules}    ${catalog_resource_ids}   ${catalog_service_id}   ${catalog_resources}   Distribute Model From SDC    ${ziplist}    ${catalog_service_name}    ${cds}   ${service}  instantiationType=${instantiationType}  resourceType=${resourceType}
    Download CSAR    ${catalog_service_id}   
    [Return]    ${catalog_service_name}    ${catalog_resource_name}    ${vf_modules}   ${catalog_resources}    ${catalog_resource_ids}   ${catalog_service_id}

Create ZIPs in SDC ZIP Directory
    [Arguments]  ${directory_list}  ${ziplist}
    :FOR   ${directory}    IN    @{directory_list}
    \    ${zipname}=   Replace String    ${directory}    /    _
    \    ${zip}=    Catenate    ${SDC_ZIP_DIRECTORY}/${zipname}.zip
    \    ${folder}=    Catenate    ${SDC_ASSETS_DIRECTORY}/${directory}
    \    OperatingSystem.Create Directory    ${SDC_ASSETS_DIRECTORY}/temp
    \    Create Zip From Files In Directory        ${folder}    ${zip}
    \    Append To List    ${ziplist}    ${zip}
    [Return]  ${ziplist}

Create CSARSs in SDC Onboarding Packages Directory
    [Arguments]  ${directory_list}  ${ziplist}
    :FOR   ${directory}    IN    @{directory_list}
    \    ${zipname}=   Replace String    ${directory}    /    _
    \    ${csar}=    Catenate    ${SDC_CSAR_DIRECTORY}/${zipname}.csar
    \    ${folder}=    Catenate    ${SDC_TOSCA_ONBOARDING_PACKAGES_DIRECTORY}/${directory}
    \    OperatingSystem.Create Directory    ${SDC_TOSCA_ONBOARDING_PACKAGES_DIRECTORY}/temp
    \    Create Zip From Files In Directory        ${folder}    ${csar}    sub_directories=${true}
    \    Append To List    ${ziplist}    ${csar}
    [Return]  ${ziplist}

TOSCA Based PNF Model Distribution For Directory
    [Arguments]    ${service}   ${catalog_service_name}=
    ServiceMapping.Set Directory    default    ${GLOBAL_SERVICE_MAPPING_DIRECTORY}
    ${directory_list}=    ServiceMapping.Get Service Folder Mapping    default    ${service}
    ${csarlist}=    Create List
    ${uuid}=    Get Current Date
    ${service_name}=    Catenate    ${service}    ${uuid}
    ${shortened_uuid}=     Evaluate    str("${service_name}")[:23]
    ${catalog_service_name}=   Set Variable If   '${catalog_service_name}' ==''   ${shortened_uuid}   ${catalog_service_name}
    :FOR   ${directory}    IN    @{directory_list}
    \    ${zipname}=   Replace String    ${directory}    /    _
    \    ${csar}=    Catenate    ${SDC_CSAR_DIRECTORY}/${zipname}.csar
    \    ${folder}=    Catenate    ${SDC_TOSCA_ONBOARDING_PACKAGES_DIRECTORY}/${directory}
    \    OperatingSystem.Create Directory    ${SDC_TOSCA_ONBOARDING_PACKAGES_DIRECTORY}/temp
    \    Create Zip From Files In Directory        ${folder}    ${csar}    sub_directories=${true}
    \    Append To List    ${csarlist}    ${csar}
    ${catalog_service_name}    ${catalog_resource_name}    ${catalog_resource_ids}   ${catalog_service_id}   ${catalog_resources}   Distribute Model From SDC    ${csarlist}    ${catalog_service_name}   ${service}    resourceType=PNF
    Download CSAR    ${catalog_service_id}
    [Return]    ${catalog_service_name}    ${catalog_resource_name}    ${catalog_resources}

Teardown Models
    [Documentation]    Clean up at the end of the test
    [Arguments]     ${catalog_service_id}    ${catalog_resource_ids}
    Return From Keyword If    '${catalog_service_id}' == ''
    :FOR    ${catalog_resource_id}   IN   @{catalog_resource_ids}
    \   ${resourece_json}=   Mark SDC Catalog Resource Inactive    ${catalog_resource_id}
    ${service_json}=   Mark SDC Catalog Service Inactive    ${catalog_service_id}
    ${services_json}=   Delete Inactive SDC Catalog Services
    ${resources_json}=    Delete Inactive SDC Catalog Resources
