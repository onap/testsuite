*** Settings ***
Documentation     The main interface for interacting with SDC. It handles low level stuff like managing the http request library and DCAE required fields
Library           RequestsLibrary
Library           ONAPLibrary.Utilities
Library           ONAPLibrary.JSON
Library           OperatingSystem
Library           Collections
Library           SeleniumLibrary
Library           String
Library           ArchiveLibrary
Library           ONAPLibrary.Openstack
Library           DateTime
Library           ONAPLibrary.ServiceMapping    WITH NAME     ServiceMapping
Library           ONAPLibrary.Templating    WITH NAME    Templating
Library           ONAPLibrary.SDC    WITH NAME    SDC
Resource          global_properties.robot
Resource          browser_setup.robot

*** Variables ***
${SDC_DESIGNER_USER_ID}    cs0008
${SDC_TESTER_USER_ID}    jm0007
${SDC_GOVERNOR_USER_ID}    gv0001
${SDC_OPS_USER_ID}    op0001
${SDC_HEALTH_CHECK_PATH}    /sdc1/rest/healthCheck
${SDC_VENDOR_LICENSE_MODEL_PATH}    /onboarding-api/v1.0/vendor-license-models
${SDC_VENDOR_SOFTWARE_PRODUCT_PATH}    /onboarding-api/v1.0/vendor-software-products
${SDC_VENDOR_KEY_GROUP_PATH}    /license-key-groups
${SDC_VENDOR_ENTITLEMENT_POOL_PATH}    /entitlement-pools
${SDC_VENDOR_FEATURE_GROUP_PATH}    /feature-groups
${SDC_VENDOR_LICENSE_AGREEMENT_PATH}    /license-agreements
${SDC_VENDOR_ACTIONS_PATH}    /actions
${SDC_VENDOR_SOFTWARE_UPLOAD_PATH}    /orchestration-template-candidate
${SDC_FE_CATALOG_RESOURCES_PATH}    /sdc1/feProxy/rest/v1/catalog/resources
${SDC_FE_CATALOG_SERVICES_PATH}    /sdc1/feProxy/rest/v1/catalog/services
${SDC_CATALOG_RESOURCES_PATH}    /sdc2/rest/v1/catalog/resources
${SDC_CATALOG_SERVICES_PATH}    /sdc2/rest/v1/catalog/services
${SDC_CATALOG_INACTIVE_RESOURCES_PATH}    /sdc2/rest/v1/inactiveComponents/resource
${SDC_CATALOG_RESOURCES_QUERY_PATH}    /sdc2/rest/v1/catalog/resources/resourceName
${SDC_CATALOG_INACTIVE_SERVICES_PATH}    /sdc2/rest/v1/inactiveComponents/service
${SDC_CATALOG_LIFECYCLE_PATH}    /lifecycleState
${SDC_CATALOG_SERVICE_RESOURCE_INSTANCE_PATH}    /resourceInstance
${SDC_CATALOG_SERVICE_RESOURCE_ARTIFACT_PATH}    /artifacts
${SDC_CATALOG_SERVICE_DISTRIBUTION_STATE_PATH}    /distribution-state
${SDC_CATALOG_SERVICE_DISTRIBUTION_PATH}    /distribution
${SDC_DISTRIBUTION_STATE_APPROVE_PATH}    /approve
${SDC_CATALOG_SERVICE_DISTRIBUTION_ACTIVATE_PATH}    /distribution/PROD/activate
${SDC_LICENSE_MODEL_TEMPLATE}    sdc/license_model.jinja
${SDC_KEY_GROUP_TEMPLATE}    sdc/key_group.jinja
${SDC_ENTITLEMENT_POOL_TEMPLATE}    sdc/entitlement_pool.jinja
${SDC_FEATURE_GROUP_TEMPLATE}    sdc/feature_group.jinja
${SDC_LICENSE_AGREEMENT_TEMPLATE}    sdc/license_agreement.jinja
${SDC_ACTION_TEMPLATE}    sdc/action.jinja
${SDC_SOFTWARE_PRODUCT_TEMPLATE}    sdc/software_product.jinja
${SDC_ARTIFACT_UPLOAD_TEMPLATE}    sdc/artifact_upload.jinja
${SDC_CATALOG_RESOURCE_TEMPLATE}    sdc/catalog_resource.jinja
${SDC_USER_REMARKS_TEMPLATE}    sdc/user_remarks.jinja
${SDC_CATALOG_SERVICE_TEMPLATE}    sdc/catalog_service.jinja
${SDC_RESOURCE_INSTANCE_TEMPLATE}    sdc/resource_instance.jinja
${SDC_RESOURCE_INSTANCE_VNF_PROPERTIES_TEMPLATE}    sdc/catalog_vnf_properties.jinja
${SDC_RESOURCE_INSTANCE_VNF_INPUTS_TEMPLATE}    sdc/catalog_vnf_inputs.jinja
${SDC_CATALOG_NET_RESOURCE_INPUT_TEMPLATE}    sdc/catalog_net_input_properties.jinja
${SDC_ALLOTTED_RESOURCE_CATALOG_RESOURCE_TEMPLATE}    sdc/catalog_resource_alloted_resource.jinja
${SDC_CATALOG_ALLOTTED_RESOURCE_PROPERTIES_TEMPLATE}    sdc/catalog_allotted_properties.jinja
${SDC_CATALOG_ALLOTTED_RESOURCE_INPUTS_TEMPLATE}    sdc/catalog_allotted_inputs.jinja
${SDC_CATALOG_DEPLOYMENT_ARTIFACT_PATH}     robot/assets/sdc/blueprints/
${SDC_FE_ENDPOINT}     ${GLOBAL_SDC_SERVER_PROTOCOL}://${GLOBAL_INJECTED_SDC_FE_IP_ADDR}:${GLOBAL_SDC_FE_PORT}
${SDC_BE_ENDPOINT}     ${GLOBAL_SDC_SERVER_PROTOCOL}://${GLOBAL_INJECTED_SDC_BE_IP_ADDR}:${GLOBAL_SDC_BE_PORT}
${SDC_BE_ONBOARD_ENDPOINT}     ${GLOBAL_SDC_SERVER_PROTOCOL}://${GLOBAL_INJECTED_SDC_BE_ONBOARD_IP_ADDR}:${GLOBAL_SDC_BE_ONBOARD_PORT}

*** Keywords ***
Distribute Model From SDC
    [Documentation]    Goes end to end creating all the SDC objects based ONAP model and distributing it to the systems. It then returns the service name, VF name and VF module name
    [Arguments]    ${model_zip_path}   ${catalog_service_name}=    ${cds}=False    ${service}=
    # For Testing use random service names
    #${random}=    Get Current Date
    #${catalog_service_id}=    Add SDC Catalog Service    ${catalog_service_name}_${random}
    ${catalog_service_id}=    Add SDC Catalog Service    ${catalog_service_name}
    ${catalog_resource_ids}=    Create List
    ${catalog_resources}=   Create Dictionary
    #####  TODO: Support for Multiple resources of one type in a service  ######
    #   The zip list is the resources - no mechanism to indicate more than 1 of the items in the zip list
    #   Get Service Vnf Mapping  has the logical mapping but it is not the same key as model_zip_path
    #   ${vnflist}=   Get Service Vnf Mapping    alias    ${service}
    #   Save the resource_id in a dictionary keyed by the resource name in the zipfile name (vFWDT_vFWSNK.zip or vFWDT_vPKG.zip)
    #   Create the resources but do not immediately add resource
    #   Add Resource to Service in a separate FOR loop
    ${resource_types}=   Create Dictionary

    :FOR    ${zip}     IN     @{model_zip_path}
    \    ${loop_catalog_resource_id}=    Setup SDC Catalog Resource    ${zip}    ${cds}
    #     zip can be vFW.zip or vFWDT_VFWSNK.zip
    \    ${resource_type_match}=    Get Regexp Matches    ${zip}   ${service}_(.*)\.zip    1
    #  Need to be able to distribute preload for vFWCL vFWSNK and vFWDT vFWSNK to prepend service to vnf_type
    \    ${resource_type_string}=   Set Variable If   len(${resource_type_match})==0    ${service}    ${service}${resource_type_match[0]}
    \    Set To Dictionary    ${resource_types}    ${resource_type_string}    ${loop_catalog_resource_id}   
    \    Append To List    ${catalog_resource_ids}   ${loop_catalog_resource_id}

    ServiceMapping.Set Directory    default    ${GLOBAL_SERVICE_MAPPING_DIRECTORY}
    ${vnflist}=    ServiceMapping.Get Service Vnf Mapping    default    ${service}

    # Spread the icons on the pallette starting on the left
    ${xoffset}=    Set Variable    ${0}

    :FOR  ${vnf}   IN   @{vnflist}
    \    ${loop_catalog_resource_resp}=    Get SDC Catalog Resource      ${resource_types['${vnf}']}
    \    Set To Dictionary    ${catalog_resources}   ${resource_types['${vnf}']}=${loop_catalog_resource_resp}
    \    ${catalog_resource_unique_name}=   Add SDC Resource Instance    ${catalog_service_id}    ${resource_types['${vnf}']}    ${loop_catalog_resource_resp['name']}    ${xoffset}
    \    ${xoffset}=   Set Variable   ${xoffset+100}
    #
    # do this here because the loop_catalog_resource_resp is different format after adding networks
    ${vf_module}=   Find Element In Array    ${loop_catalog_resource_resp['groups']}    type    org.openecomp.groups.VfModule
    #
    #  do network
    ${networklist}=    ServiceMapping.Get Service Neutron Mapping    default    ${service}
    ${generic_neutron_net_uuid}=   Get Generic NeutronNet UUID
    :FOR   ${network}   IN   @{networklist}
    \    ${loop_catalog_resource_id}=   Set Variable    ${generic_neutron_net_uuid}
    \    Append To List    ${catalog_resource_ids}   ${loop_catalog_resource_id}
    \    ${loop_catalog_resource_resp}=    Get SDC Catalog Resource    ${loop_catalog_resource_id}
    \    ${loop_catalog_resource_id}=   Add SDC Resource Instance    ${catalog_service_id}    ${loop_catalog_resource_id}    ${network}    ${xoffset}      ${0}    VL
    \    ${nf_role}=   Convert To Lowercase   ${network}
    \    Setup SDC Catalog Resource GenericNeutronNet Properties      ${catalog_service_id}    ${nf_role}   ${loop_catalog_resource_id}
    \    ${xoffset}=   Set Variable   ${xoffset+100}
    \    Set To Dictionary    ${catalog_resources}   ${loop_catalog_resource_id}=${loop_catalog_resource_resp}
    ${catalog_service_resp}=    Get SDC Catalog Service    ${catalog_service_id}
    #
    # do deployment artifacts
    #
    ${deploymentlist}=    ServiceMapping.Get Service Deployment Artifact Mapping    default    ${service}
    :FOR  ${deployment}  IN   @{deploymentlist}
    \    ${loop_catalog_resource_resp}=    Get SDC Catalog Resource    ${loop_catalog_resource_id}
    \    Setup SDC Catalog Resource Deployment Artifact Properties      ${catalog_service_id}   ${loop_catalog_resource_resp}  ${catalog_resource_unique_name}  ${deployment}
    Run Keyword If  ${cds} == True  Add CDS Parameters  ${catalog_service_name}
    Checkin SDC Catalog Service    ${catalog_service_id}
    Wait Until Keyword Succeeds    600s    15s    Request Certify SDC Catalog Service    ${catalog_service_id}
    Start Certify SDC Catalog Service    ${catalog_service_id}
    # on certify it gets a new id
    ${catalog_service_id}=    Certify SDC Catalog Service    ${catalog_service_id}
    Approve SDC Catalog Service    ${catalog_service_id}
        :FOR   ${DIST_INDEX}    IN RANGE   1
        \   Log     Distribution Attempt ${DIST_INDEX}
        \   Distribute SDC Catalog Service    ${catalog_service_id}
        \   ${catalog_service_resp}=    Get SDC Catalog Service    ${catalog_service_id}
        \   ${status}   ${_} =   Run Keyword And Ignore Error   Loop Over Check Catalog Service Distributed       ${catalog_service_resp['uuid']}
        \   Exit For Loop If   '${status}'=='PASS'
        Should Be Equal As Strings  ${status}  PASS
    [Return]    ${catalog_service_resp['name']}    ${loop_catalog_resource_resp['name']}    ${vf_module}   ${catalog_resource_ids}    ${catalog_service_id}   ${catalog_resources}

Distribute vCPEResCust Model From SDC
    [Documentation]    Goes end to end creating all the SDC objects for the vCPE ResCust Service model and distributing it to the systems. It then returns the service name, VF name and VF module name
    [Arguments]    ${model_zip_path}   ${catalog_service_name}=    ${cds}=    ${service}=
    # For testing use random service name
    #${random}=    Get Current Date
    ${uuid}=    Generate UUID4
    ${random}=     Evaluate    str("${uuid}")[:4]
    ${catalog_service_id}=    Add SDC Catalog Service    ${catalog_service_name}_${random}
    #   catalog_service_name already
    #${catalog_service_id}=    Add SDC Catalog Service    ${catalog_service_name}
    Log    ${\n}ServiceName: ${catalog_service_name}_${random}
    #${catalog_service_id}=    Add SDC Catalog Service    ${catalog_service_name}
    ${catalog_resource_ids}=    Create List
    ${catalog_resources}=   Create Dictionary
    :FOR    ${zip}     IN     @{model_zip_path}
    \    ${loop_catalog_resource_id}=    Setup SDC Catalog Resource    ${zip}    ${cds}
    \    Append To List    ${catalog_resource_ids}   ${loop_catalog_resource_id}
    \    ${loop_catalog_resource_resp}=    Get SDC Catalog Resource    ${loop_catalog_resource_id}
    \    Add SDC Resource Instance    ${catalog_service_id}    ${loop_catalog_resource_id}    ${loop_catalog_resource_resp['name']}
    \    Set To Dictionary    ${catalog_resources}   ${loop_catalog_resource_id}=${loop_catalog_resource_resp}
    #
    # do this here because the loop_catalog_resource_resp is different format after adding networks
    ${vf_module}=   Find Element In Array    ${loop_catalog_resource_resp['groups']}    type    org.openecomp.groups.VfModule
    #
    #  do allottedresource
    ${allottedresource_list}=   Create List    TunnelXConn     BRG
    #  Example data
    #${tunnelxconn_dict}=   Create Dictionary      invariantUUID=8ac029e7-77aa-40d4-b28a-d17c02d5fd82    UUID=2ddc1b37-d7da-4aab-b645-ed7db34a5d03    node_type=org.openecomp.service.Demovcpevgmux
    #${brg_dict}=   Create Dictionary      invariantUUID=ff0337b9-dbe2-4d88-bb74-18bf027ae586   UUID=1b6974f1-4aed-47f4-b962-816aa1261927    node_type=org.openecomp.service.Demovcpevbrgemu
    # Create /tmp/vcpe_allotted_resource_data.json with demo vgmux and brgemu CSARs
    Create Allotted Resource Data File
    ${vcpe_ar_data_file}    OperatingSystem.Get File    /tmp/vcpe_allotted_resource_data.json
    ${tunnelxconn_invariant_uuid}=    Catenate    ${vcpe_ar_data_file.json()['tunnelxconn']['invariantUUID']}
    ${tunnelxconn_uuid}=    Catenate    ${vcpe_ar_data_file.json()['tunnelxconn']['UUID']}
    ${tunnelxconn_node_type}=    Catenate    ${vcpe_ar_data_file.json()['tunnelxconn']['node_type']}
    ${brg_invariant_uuid}=    Catenate    ${vcpe_ar_data_file.json()['brg']['invariantUUID']}
    ${brg_uuid}=    Catenate    ${vcpe_ar_data_file.json()['brg']['UUID']}
    ${brg_node_type}=    Catenate    ${vcpe_ar_data_file.json()['brg']['node_type']}
    ${tunnelxconn_dict}=   Create Dictionary      invariantUUID=${tunnelxconn_invariant_uuid}  UUID=${tunnelxconn_uuid}  node_type=${tunnelxconn_node_type}
    ${brg_dict}=   Create Dictionary      invariantUUID=${brg_invariant_uuid}   UUID=${brg_uuid}  node_type=${brg_node_type}
    ${xoffset}=    Set Variable    ${100}
    ${allottedresource_uuid}=   Get AllottedResource UUID
    ${random}=    Get Current Date
    :FOR   ${allottedresource}   IN   @{allottedresource_list}
    \    ${loop_catalog_resource_id}=   Set Variable    ${allottedresource_uuid}
    \    Append To List    ${catalog_resource_ids}   ${loop_catalog_resource_id}
    \    ${loop_catalog_resource_id}=    Add SDC Allotted Resource Catalog Resource     00000    ${allottedresource}_${random}    ONAP     ${loop_catalog_resource_id}   ${allottedresource}
    \    ${loop_catalog_resource_id2}=   Add SDC Resource Instance To Resource     ${loop_catalog_resource_id}    ${allottedresource_uuid}    ${allottedresource}    ${xoffset}      ${0}
    \    ${loop_catalog_resource_resp}=    Get SDC Catalog Resource    ${loop_catalog_resource_id}
    #
    #   Set the properties to relate to the brg and gmux
    #
    \    Run Keyword If   '${allottedresource}'=='TunnelXConn'    Setup SDC Catalog Resource AllottedResource Properties      ${catalog_service_id}    ${allottedresource}   ${loop_catalog_resource_id}   ${tunnelxconn_dict['invariantUUID']}   ${tunnelxconn_dict['UUID']}   ${tunnelxconn_dict['node_type']}
    \    Run Keyword If   '${allottedresource}'=='BRG'   Setup SDC Catalog Resource AllottedResource Properties      ${catalog_service_id}    ${allottedresource}   ${loop_catalog_resource_id}   ${brg_dict['invariantUUID']}   ${brg_dict['UUID']}   ${brg_dict['node_type']}
    #
    #    Set the nf_role nf_type
    #
    \    Run Keyword If   '${allottedresource}'=='TunnelXConn'    Setup SDC Catalog Resource AllottedResource Inputs  ${catalog_service_id}    ${allottedresource}   ${loop_catalog_resource_id}
    \    Run Keyword If   '${allottedresource}'=='BRG'    Setup SDC Catalog Resource AllottedResource Inputs  ${catalog_service_id}    ${allottedresource}   ${loop_catalog_resource_id}
    \    ${loop_catalog_resource_id}=   Certify SDC Catalog Resource    ${loop_catalog_resource_id}  ${SDC_DESIGNER_USER_ID}
    \    Add SDC Resource Instance    ${catalog_service_id}    ${loop_catalog_resource_id}    ${loop_catalog_resource_resp['name']}
    \    Set To Dictionary    ${catalog_resources}   ${loop_catalog_resource_id}=${loop_catalog_resource_resp}
    ${catalog_service_resp}=    Get SDC Catalog Service    ${catalog_service_id}
    Checkin SDC Catalog Service    ${catalog_service_id}
    Request Certify SDC Catalog Service    ${catalog_service_id}
    Start Certify SDC Catalog Service    ${catalog_service_id}
    # on certify it gets a new id
    ${catalog_service_id}=    Certify SDC Catalog Service    ${catalog_service_id}
    Approve SDC Catalog Service    ${catalog_service_id}
        :FOR   ${DIST_INDEX}    IN RANGE   1
        \   Log     Distribution Attempt ${DIST_INDEX}
        \   Distribute SDC Catalog Service    ${catalog_service_id}
        \   ${catalog_service_resp}=    Get SDC Catalog Service    ${catalog_service_id}
        \   ${status}   ${_} =   Run Keyword And Ignore Error   Loop Over Check Catalog Service Distributed       ${catalog_service_resp['uuid']}
        \   Exit For Loop If   '${status}'=='PASS'
        Should Be Equal As Strings  ${status}  PASS
    [Return]    ${catalog_service_resp['name']}    ${loop_catalog_resource_resp['name']}    ${vf_module}   ${catalog_resource_ids}    ${catalog_service_id}   ${catalog_resources}


Create Allotted Resource Data File
   [Documentation]    Create Allotted Resource json data file
   ${allotted_resource}=    Create Dictionary
   ${allotted_csar_map}=    Create Dictionary
   Set To Dictionary    ${allotted_csar_map}    tunnelxconn=service-Demovcpevgmux-csar.csar
   Set To Dictionary    ${allotted_csar_map}    brg=service-Demovcpevbrgemu-csar.csar
   ${keys}=    Get Dictionary Keys    ${allotted_csar_map}
   :FOR   ${key}   IN   @{keys}
   \    ${csar}=    Get From Dictionary    ${allotted_csar_map}    ${key}
   \    ${dir}    ${ext}=    Split String From Right    ${csar}    -    1
   \    Extract Zip File    /tmp/csar/${csar}    /tmp/csar/${dir}
   \    ${template}=    Catenate    /tmp/csar/${dir}/Definitions/${dir}-template.yml
   \    ${json_str}=    Template Yaml To Json    ${template}
   \    ${json_obj}=    To Json   ${json_str}
   \    ${attrs}=    Create Dictionary
   \    Set To Dictionary    ${attrs}    invariantUUID=${json_obj['metadata']['invariantUUID']}
   \    Set To Dictionary    ${attrs}    UUID=${json_obj['metadata']['UUID']}
   \    Set To Dictionary    ${attrs}    node_type=${json_obj['topology_template']['substitution_mappings']['node_type']}
   \    Set To Dictionary    ${allotted_resource}    ${key}=${attrs}
   ${result_str}=   Evaluate    json.dumps(${allotted_resource}, indent=2)    json
   Log    ${result_str}
   Create File    /tmp/vcpe_allotted_resource_data.json    ${result_str}

Download CSAR
   [Documentation]   Download CSAR
   [Arguments]    ${catalog_service_id}    ${save_directory}=/tmp/csar
   # get meta data
   ${resp}=    SDC.Run Get Request    ${SDC_BE_ENDPOINT}    ${SDC_CATALOG_SERVICES_PATH}/${catalog_service_id}/filteredDataByParams?include=toscaArtifacts    ${SDC_DESIGNER_USER_ID}        auth=${GLOBAL_SDC_AUTHENTICATION}
   ${csar_resource_id}=    Set Variable   ${resp.json()['toscaArtifacts']['assettoscacsar']['uniqueId']}
   ${resp}=    SDC.Run Get Request    ${SDC_BE_ENDPOINT}    ${SDC_CATALOG_SERVICES_PATH}/${catalog_service_id}/artifacts/${csar_resource_id}    ${SDC_DESIGNER_USER_ID}    auth=${GLOBAL_SDC_AUTHENTICATION}
   ${csar_file_name}=   Set Variable    ${resp.json()['artifactName']}
   ${base64Obj}=   Set Variable    ${resp.json()['base64Contents']}
   ${binObj}=   Base64 Decode   ${base64Obj}
   Create Binary File  ${save_directory}/${csar_file_name}  ${binObj}
   Log      ${\n}Downloaded:${csar_file_name}


Get Generic NeutronNet UUID
   [Documentation]   Look up the UUID of the Generic NeutronNetwork Resource
   ${resp}=    SDC.Run Get Request   ${SDC_BE_ENDPOINT}    ${SDC_CATALOG_RESOURCES_QUERY_PATH}/Generic%20NeutronNet/resourceVersion/1.0   ${SDC_DESIGNER_USER_ID}    auth=${GLOBAL_SDC_AUTHENTICATION}
   [Return]    ${resp.json()['allVersions']['1.0']}

Get AllottedResource UUID
   [Documentation]   Look up the UUID of the Allotted Resource
   # if this fails then the AllottedResource template got deleted from SDC by mistake
   ${resp}=    SDC.Run Get Request   ${SDC_BE_ENDPOINT}    ${SDC_CATALOG_RESOURCES_QUERY_PATH}/AllottedResource/resourceVersion/1.0   ${SDC_DESIGNER_USER_ID}    auth=${GLOBAL_SDC_AUTHENTICATION}
   [Return]    ${resp.json()['allVersions']['1.0']}

Loop Over Check Catalog Service Distributed
    [Arguments]    ${catalog_service_id}
    # SO watchdog timeout is 300 seconds need buffer
    ${dist_status}=   Set Variable    CONTINUE
    :FOR  ${CHECK_INDEX}  IN RANGE   20
    \   ${status}   ${_} =   Run Keyword And Ignore Error     Check Catalog Service Distributed    ${catalog_service_id}    ${dist_status}
    \   Sleep     20s
    \   Return From Keyword If   '${status}'=='PASS'
    # need a way to exit the loop early on DISTRIBUTION_COMPLETE_ERROR  ${dist_status} doesnt work
    #\   Exit For Loop If   '${dist_status}'=='EXIT'
    Should Be Equal As Strings  ${status}   PASS

Setup SDC Catalog Resource
    [Documentation]    Creates all the steps a VF needs for an SDC Catalog Resource and returns the id
    [Arguments]    ${model_zip_path}    ${cds}=None
    ${license_model_id}   ${license_model_version_id}=    Add SDC License Model


    ${license_temp_date}=   Get Current Date
    ${license_start_date}=   Get Current Date     result_format=%m/%d/%Y
    ${license_end_date}=     Add Time To Date   ${license_temp_date}    365 days    result_format=%m/%d/%Y
    ${key_group_id}=    Add SDC License Group    ${license_model_id}   ${license_model_version_id}  ${license_start_date}  ${license_end_date}
    ${pool_id}=    Add SDC Entitlement Pool    ${license_model_id}   ${license_model_version_id}  ${license_start_date}  ${license_end_date}

    ${feature_group_id}=    Add SDC Feature Group    ${license_model_id}    ${key_group_id}    ${pool_id}  ${license_model_version_id}
    ${license_agreement_id}=    Add SDC License Agreement    ${license_model_id}    ${feature_group_id}   ${license_model_version_id}
    Submit SDC License Model    ${license_model_id}   ${license_model_version_id}
    ${license_model_resp}=    Get SDC License Model    ${license_model_id}   ${license_model_version_id}
    ${matches}=   Get Regexp Matches  ${model_zip_path}  temp/(.*)\.zip  1
    ${software_product_name_prefix}=    Set Variable   ${matches[0]}
    ${software_product_id}   ${software_product_version_id}=    Add SDC Software Product    ${license_agreement_id}    ${feature_group_id}    ${license_model_resp['vendorName']}    ${license_model_id}    ${license_model_version_id}    ${software_product_name_prefix}
    Upload SDC Heat Package    ${software_product_id}    ${model_zip_path}   ${software_product_version_id}
    Validate SDC Software Product    ${software_product_id}  ${software_product_version_id}
    Submit SDC Software Product    ${software_product_id}  ${software_product_version_id}
    Package SDC Software Product    ${software_product_id}   ${software_product_version_id}
    ${software_product_resp}=    Get SDC Software Product    ${software_product_id}    ${software_product_version_id}
    ${catalog_resource_id}=    Add SDC Catalog Resource     ${license_agreement_id}    ${software_product_resp['name']}    ${license_model_resp['vendorName']}    ${software_product_id}
    # Check if need to set up CDS properties
    Run Keyword If    '${cds}' == 'vfwng'    Setup SDC Catalog Resource CDS Properties    ${catalog_resource_id}

    ${catalog_resource_id}=   Certify SDC Catalog Resource    ${catalog_resource_id}  ${SDC_DESIGNER_USER_ID}
    [Return]    ${catalog_resource_id}


Setup SDC Catalog Resource Deployment Artifact Properties
    [Documentation]    Set up Deployment Artiface properties
    [Arguments]    ${catalog_service_id}    ${catalog_parent_service_id}   ${catalog_resource_unique_id}  ${blueprint_file}
    ${resp}=    Get SDC Catalog Resource Component Instances Properties  ${catalog_service_id}
    ${blueprint_data}    OperatingSystem.Get File    ${SDC_CATALOG_DEPLOYMENT_ARTIFACT_PATH}${blueprint_file}
    ${payloadData}=      Base64 Encode   ${blueprint_data}
    ${dict}=    Create Dictionary  artifactLabel=blueprint  artifactName=${blueprint_file}   artifactType=DCAE_INVENTORY_BLUEPRINT  artifactGroupType=DEPLOYMENT  description=${blueprint_file}   payloadData=${payloadData}
    Templating.Create Environment    sdc    ${GLOBAL_TEMPLATE_FOLDER}
    ${data}=   Templating.Apply Template    sdc   ${SDC_ARTIFACT_UPLOAD_TEMPLATE}    ${dict}
    # POST artifactUpload to resource
    ${artifact_upload_path}=    Catenate  ${SDC_CATALOG_SERVICES_PATH}/${catalog_service_id}/resourceInstance/${catalog_resource_unique_id}${SDC_CATALOG_SERVICE_RESOURCE_ARTIFACT_PATH}
    ${resp}=    SDC.Run Post Request    ${SDC_BE_ENDPOINT}    ${artifact_upload_path}    ${data}   ${SDC_DESIGNER_USER_ID}    auth=${GLOBAL_SDC_AUTHENTICATION}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp}


Setup SDC Catalog Resource GenericNeutronNet Properties
    [Documentation]    Set up GenericNeutronNet properties and inputs
    [Arguments]    ${catalog_service_id}    ${nf_role}    ${catalog_parent_service_id}
    ${resp}=    Get SDC Catalog Resource Component Instances Properties  ${catalog_service_id}
    ${componentInstances}  Set Variable   @{resp['componentInstancesProperties']}
    # componentInstances can have 1 or more than 1 entry
    ${passed}=    Run Keyword And Return Status   Evaluate    type(${componentInstances})
    ${type}=      Run Keyword If     ${passed}    Evaluate    type(${componentInstances})
    ${componentInstancesList}=    Run Keyword If   "${type}"!="<type 'list'>"    Create List  ${componentInstances}
    ...    ELSE   Set Variable    ${componentInstances}
    :FOR   ${item}  IN   @{componentInstancesList}
    \    ${test}    ${v}=    Run Keyword and Ignore Error    Should Contain    ${item}     ${nf_role}
    \    Run Keyword If    '${test}' == 'FAIL'    Continue For Loop
    \    ${componentInstance1}=   Set Variable    ${item}
    :FOR    ${comp}    IN    @{resp['componentInstancesProperties']["${componentInstance1}"]}
    \    ${name}    Set Variable   ${comp['name']}
    \    ${test}    ${v}=    Run Keyword and Ignore Error    Should Contain    ${name}    network_role
    \    Run Keyword If    '${test}' == 'FAIL'    Continue For Loop
    \    ${description}    Set Variable    ${comp['description']}
    \    ${description}=    Replace String    ${description}    ${\n}   \
    \    ${uniqueId}    Set Variable    ${comp['uniqueId']}
    \    ${parentUniqueId}    Set Variable    ${comp['parentUniqueId']}
    \    ${ownerId}    Set Variable    ${comp['ownerId']}
    \    ${dict}=    Create Dictionary    parentUniqueId=${parentUniqueId}   ownerId=${ownerId}  uniqueId=${uniqueId}    description=${description}
    \    Run Keyword If   '${name}'=='network_role'   Set To Dictionary    ${dict}    name=${name}    value=${nf_role}
    \    Templating.Create Environment    sdc    ${GLOBAL_TEMPLATE_FOLDER}
    \    ${data}=   Templating.Apply Template    sdc   ${SDC_CATALOG_NET_RESOURCE_INPUT_TEMPLATE}    ${dict}
    \    ${response}=    Set SDC Catalog Resource Component Instance Properties    ${catalog_parent_service_id}    ${catalog_service_id}    ${data}


Setup SDC Catalog Resource AllottedResource Properties
    [Documentation]    Set up Allotted Resource properties and inputs
    [Arguments]    ${catalog_service_id}    ${nf_role}    ${catalog_resource_id}   ${invariantUUID}   ${UUID}     ${node_type}
    # Set component instances properties
    ${nf_role_lc}=   Convert To Lowercase   ${nf_role}
    ${resp}=    Get SDC Catalog Resource Component Instances Properties For Resource     ${catalog_resource_id}
    ${componentInstances}  Set Variable   @{resp['componentInstancesProperties']}
    # componentInstances can have 1 or more than 1 entry
    ${passed}=    Run Keyword And Return Status   Evaluate    type(${componentInstances})
    ${type}=      Run Keyword If     ${passed}    Evaluate    type(${componentInstances})
    ${componentInstancesList}=    Run Keyword If   "${type}"!="<type 'list'>"    Create List  ${componentInstances}
    ...    ELSE   Set Variable    ${componentInstances}
    :FOR   ${item}  IN   @{componentInstancesList}
    \    ${test}    ${v}=    Run Keyword and Ignore Error    Should Contain    ${item}     ${nf_role_lc}
    \    Run Keyword If    '${test}' == 'FAIL'    Continue For Loop
    \    ${componentInstance1}=   Set Variable    ${item}
    ${dict}=    Create Dictionary
    :FOR    ${comp}    IN    @{resp['componentInstancesProperties']["${componentInstance1}"]}
    \    ${name}    Set Variable   ${comp['name']}
    \    ${test}    ${v}=    Run Keyword and Ignore Error    Should Contain Any     ${name}    network_role  providing_service_invariant_uuid  providing_service_uuid  providing_service_name   uniqueId
    \    Run Keyword If    '${test}' == 'FAIL'    Continue For Loop
    \    ${parentUniqueId}    Set Variable    ${comp['parentUniqueId']}
    \    ${ownerId}    Set Variable    ${comp['ownerId']}
    \    Set To Dictionary     ${dict}    parentUniqueId=${parentUniqueId}   ownerId=${ownerId}
    \    Run Keyword If   '${name}'=='providing_service_invariant_uuid'   Set To Dictionary    ${dict}    providing_service_invariant_uuid=${invariantUUID}
    \    Run Keyword If   '${name}'=='providing_service_uuid'   Set To Dictionary    ${dict}    providing_service_uuid=${UUID}
    \    Run Keyword If   '${name}'=='providing_service_name'   Set To Dictionary    ${dict}    providing_service_name=${node_type}
    #    Sets it for each loop but should be one
    \    ${uniqueId}    Set Variable     ${comp['uniqueId']}
    \    ${uniqueId}   Fetch From Left   ${uniqueId}   .
    \    Set To Dictionary    ${dict}    uniqueId=${uniqueId}
    Templating.Create Environment    sdc    ${GLOBAL_TEMPLATE_FOLDER}
    ${data}=   Templating.Apply Template    sdc   ${SDC_CATALOG_ALLOTTED_RESOURCE_PROPERTIES_TEMPLATE}    ${dict}
    ${response}=    Set SDC Catalog Resource Component Instance Properties For Resource    ${catalog_resource_id}    ${componentInstance1}    ${data}
    Log    resp=${response}


Setup SDC Catalog Resource AllottedResource Inputs
    [Documentation]    Set up Allotted Resource inputs
    [Arguments]    ${catalog_service_id}    ${nf_role}    ${catalog_resource_id}
    # Set vnf inputs
    ${resp}=    Get SDC Catalog Resource Inputs    ${catalog_resource_id}
    ${dict}=    Create Dictionary
    :FOR    ${comp}    IN    @{resp['inputs']}
    \    ${name}    Set Variable    ${comp['name']}
    \    ${uid}    Set Variable    ${comp['uniqueId']}
    \    Run Keyword If    '${name}'=='nf_type'    Set To Dictionary    ${dict}    nf_type=${nf_role}    nf_type_uid=${uid}
    \    Run Keyword If    '${name}'=='nf_role'    Set To Dictionary    ${dict}    nf_role=${nf_role}   nf_role_uid=${uid}
    Templating.Create Environment    sdc    ${GLOBAL_TEMPLATE_FOLDER}
    ${data}=   Templating.Apply Template    sdc   ${SDC_CATALOG_ALLOTTED_RESOURCE_INPUTS_TEMPLATE}    ${dict}
    ${response}=    Set SDC Catalog Resource VNF Inputs    ${catalog_resource_id}    ${data}
    [Return]    ${response}

Setup SDC Catalog Resource CDS Properties
    [Documentation]    Set up vfwng VNF properties and inputs for CDS
    [Arguments]    ${catalog_resource_id}
    # Set vnf module properties
    ${resp}=    Get SDC Catalog Resource Component Instances   ${catalog_resource_id}
    :FOR    ${comp}    IN    @{resp['componentInstances']}
    \    ${name}    Set Variable   ${comp['name']}
    \    ${uniqueId}    Set Variable    ${comp['uniqueId']}
    \    ${actualComponentUid}    Set Variable    ${comp['actualComponentUid']}
    \    ${test}    ${v}=    Run Keyword and Ignore Error    Should Contain    ${name}    abstract_
    \    Run Keyword If    '${test}' == 'FAIL'    Continue For Loop
    \    ${response}=    Get SDC Catalog Resource Component Instance Properties    ${catalog_resource_id}    ${uniqueId}    ${actualComponentUid}
    \    ${dict}=    Create Dictionary    parent_id=${response[6]['parentUniqueId']}
    \    Run Keyword If   '${name}'=='abstract_vfw'   Set To Dictionary    ${dict}    nfc_function=vfw    nfc_naming_policy=SDNC_Policy.ONAP_VFW_NAMING_TIMESTAMP
    \    Run Keyword If   '${name}'=='abstract_vpg'   Set To Dictionary    ${dict}    nfc_function=vpg    nfc_naming_policy=SDNC_Policy.ONAP_VPG_NAMING_TIMESTAMP
    \    Run Keyword If   '${name}'=='abstract_vsn'   Set To Dictionary    ${dict}    nfc_function=vsn    nfc_naming_policy=SDNC_Policy.ONAP_VSN_NAMING_TIMESTAMP
    \    Templating.Create Environment    sdc    ${GLOBAL_TEMPLATE_FOLDER}
    \    ${data}=   Templating.Apply Template    sdc   ${SDC_RESOURCE_INSTANCE_VNF_PROPERTIES_TEMPLATE}    ${dict}
    \    ${response}=    Set SDC Catalog Resource Component Instance Properties    ${catalog_resource_id}    ${uniqueId}    ${data}
    \    Log    resp=${response}

    # Set vnf inputs
    ${resp}=    Get SDC Catalog Resource Inputs    ${catalog_resource_id}
    ${dict}=    Create Dictionary
    :FOR    ${comp}    IN    @{resp['inputs']}
    \    ${name}    Set Variable    ${comp['name']}
    \    ${uid}    Set Variable    ${comp['uniqueId']}
    \    Run Keyword If    '${name}'=='nf_function'    Set To Dictionary    ${dict}    nf_function=ONAP-FIREWALL    nf_function_uid=${uid}
    \    Run Keyword If    '${name}'=='nf_type'    Set To Dictionary    ${dict}    nf_type=FIREWALL    nf_type_uid=${uid}
    \    Run Keyword If    '${name}'=='nf_naming_code'    Set To Dictionary    ${dict}    nf_naming_code=vfw    nf_naming_code_uid=${uid}
    \    Run Keyword If    '${name}'=='nf_role'    Set To Dictionary    ${dict}    nf_role=vFW    nf_role_uid=${uid}
    \    Run Keyword If    '${name}'=='cloud_env'    Set To Dictionary    ${dict}    cloud_env=openstack    cloud_env_uid=${uid}
    Templating.Create Environment    sdc    ${GLOBAL_TEMPLATE_FOLDER}
    ${data}=   Templating.Apply Template    sdc   ${SDC_RESOURCE_INSTANCE_VNF_INPUTS_TEMPLATE}    ${dict}
    ${response}=    Set SDC Catalog Resource VNF Inputs    ${catalog_resource_id}    ${data}

Add SDC License Model
    [Documentation]    Creates an SDC License Model and returns its id
    ${uuid}=    Generate UUID4
    ${shortened_uuid}=     Evaluate    str("${uuid}")[:23]
    ${map}=    Create Dictionary    vendor_name=${shortened_uuid}
    Templating.Create Environment    sdc    ${GLOBAL_TEMPLATE_FOLDER}
    ${data}=   Templating.Apply Template    sdc   ${SDC_LICENSE_MODEL_TEMPLATE}    ${map}
    ${resp}=    SDC.Run Post Request    ${SDC_BE_ONBOARD_ENDPOINT}    ${SDC_VENDOR_LICENSE_MODEL_PATH}    ${data}  ${SDC_DESIGNER_USER_ID}      auth=${GLOBAL_SDC_AUTHENTICATION}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()['itemId']}    ${resp.json()['version']['id']}
    
Get SDC License Model
    [Documentation]    gets an SDC license model by its id
    [Arguments]    ${id}   ${version_id}=0.1
    ${resp}=    SDC.Run Get Request   ${SDC_BE_ONBOARD_ENDPOINT}    ${SDC_VENDOR_LICENSE_MODEL_PATH}/${id}/versions/${version_id}   ${SDC_DESIGNER_USER_ID}    auth=${GLOBAL_SDC_AUTHENTICATION}
    [Return]    ${resp.json()}

Get SDC License Models
    [Documentation]    Gets all SDC License Models
    ${resp}=    SDC.Run Get Request   ${SDC_BE_ONBOARD_ENDPOINT}    ${SDC_VENDOR_LICENSE_MODEL_PATH}   ${SDC_DESIGNER_USER_ID}    auth=${GLOBAL_SDC_AUTHENTICATION}
    [Return]    ${resp.json()}

Checkin SDC License Model
    [Documentation]    Checks in an SDC License Model by its id
    [Arguments]    ${id}   ${version_id}=0.1
    ${map}=    Create Dictionary    action=Checkin
    Templating.Create Environment    sdc    ${GLOBAL_TEMPLATE_FOLDER}
    ${data}=   Templating.Apply Template    sdc   ${SDC_ACTION_TEMPLATE}    ${map}
    ${resp}=    SDC.Run Put Request    ${SDC_BE_ONBOARD_ENDPOINT}    ${SDC_VENDOR_LICENSE_MODEL_PATH}/${id}/versions/${version_id}${SDC_VENDOR_ACTIONS_PATH}    ${data}   ${SDC_DESIGNER_USER_ID}    auth=${GLOBAL_SDC_AUTHENTICATION}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()}

Submit SDC License Model
    [Documentation]    Submits an SDC License Model by its id
    [Arguments]    ${id}   ${version_id}=0.1
    ${map}=    Create Dictionary    action=Submit
    Templating.Create Environment    sdc    ${GLOBAL_TEMPLATE_FOLDER}
    ${data}=   Templating.Apply Template    sdc   ${SDC_ACTION_TEMPLATE}    ${map}
    ${resp}=    SDC.Run Put Request    ${SDC_BE_ONBOARD_ENDPOINT}    ${SDC_VENDOR_LICENSE_MODEL_PATH}/${id}/versions/${version_id}${SDC_VENDOR_ACTIONS_PATH}    ${data}   ${SDC_DESIGNER_USER_ID}    auth=${GLOBAL_SDC_AUTHENTICATION}
    [Return]    ${resp.json()}

Checkin SDC Software Product
    [Documentation]    Checks in an SDC Software Product by its id
    [Arguments]    ${id}   ${version_id}=0.1
    ${map}=    Create Dictionary    action=Checkin
    Templating.Create Environment    sdc    ${GLOBAL_TEMPLATE_FOLDER}
    ${data}=   Templating.Apply Template    sdc   ${SDC_ACTION_TEMPLATE}    ${map}
    ${resp}=    SDC.Run Put Request    ${SDC_BE_ONBOARD_ENDPOINT}    ${SDC_VENDOR_SOFTWARE_PRODUCT_PATH}/${id}/versions/${version_id}${SDC_VENDOR_ACTIONS_PATH}    ${data}  ${SDC_DESIGNER_USER_ID}    auth=${GLOBAL_SDC_AUTHENTICATION}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()}

Validate SDC Software Product
    [Documentation]    Validates an SDC Software Product by its id
    [Arguments]    ${id}   ${version_id}=0.1
    ${data}=   Catenate
    ${resp}=    SDC.Run Put Request    ${SDC_BE_ONBOARD_ENDPOINT}    ${SDC_VENDOR_SOFTWARE_PRODUCT_PATH}/${id}/versions/${version_id}/orchestration-template-candidate/process    ${data}    ${SDC_DESIGNER_USER_ID}    auth=${GLOBAL_SDC_AUTHENTICATION}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()}

Submit SDC Software Product
    [Documentation]    Submits an SDC Software Product by its id
    [Arguments]    ${id}   ${version_id}=0.1
    ${map}=    Create Dictionary    action=Submit
    Templating.Create Environment    sdc    ${GLOBAL_TEMPLATE_FOLDER}
    ${data}=   Templating.Apply Template    sdc   ${SDC_ACTION_TEMPLATE}    ${map}
    ${resp}=    SDC.Run Put Request    ${SDC_BE_ONBOARD_ENDPOINT}    ${SDC_VENDOR_SOFTWARE_PRODUCT_PATH}/${id}/versions/${version_id}${SDC_VENDOR_ACTIONS_PATH}    ${data}   ${SDC_DESIGNER_USER_ID}    auth=${GLOBAL_SDC_AUTHENTICATION}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()}

Package SDC Software Product
    [Documentation]    Creates a package of an SDC Software Product by its id
    [Arguments]    ${id}   ${version_id}=0.1
    ${map}=    Create Dictionary    action=Create_Package
    Templating.Create Environment    sdc    ${GLOBAL_TEMPLATE_FOLDER}
    ${data}=   Templating.Apply Template    sdc   ${SDC_ACTION_TEMPLATE}    ${map}
    ${resp}=    SDC.Run Put Request    ${SDC_BE_ONBOARD_ENDPOINT}    ${SDC_VENDOR_SOFTWARE_PRODUCT_PATH}/${id}/versions/${version_id}${SDC_VENDOR_ACTIONS_PATH}    ${data}   ${SDC_DESIGNER_USER_ID}      auth=${GLOBAL_SDC_AUTHENTICATION}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()}

Add SDC Entitlement Pool
    [Documentation]    Creates an SDC Entitlement Pool and returns its id
    [Arguments]    ${license_model_id}   ${version_id}=0.1     ${license_start_date}="01/01/1960"   ${license_end_date}="01/01/1961"
    ${uuid}=    Generate UUID4
    ${shortened_uuid}=     Evaluate    str("${uuid}")[:23]
    ${map}=    Create Dictionary    entitlement_pool_name=${shortened_uuid}  license_start_date=${license_start_date}  license_end_date=${license_end_date}
    Templating.Create Environment    sdc    ${GLOBAL_TEMPLATE_FOLDER}
    ${data}=   Templating.Apply Template    sdc   ${SDC_ENTITLEMENT_POOL_TEMPLATE}    ${map}
    ${resp}=    SDC.Run Post Request    ${SDC_BE_ONBOARD_ENDPOINT}    ${SDC_VENDOR_LICENSE_MODEL_PATH}/${license_model_id}/versions/${version_id}${SDC_VENDOR_ENTITLEMENT_POOL_PATH}    ${data}  ${SDC_DESIGNER_USER_ID}      auth=${GLOBAL_SDC_AUTHENTICATION}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()['value']}

Get SDC Entitlement Pool
    [Documentation]    Gets an SDC Entitlement Pool by its id
    [Arguments]    ${license_model_id}    ${pool_id}
    ${resp}=    SDC.Run Get Request   ${SDC_BE_ONBOARD_ENDPOINT}    ${SDC_VENDOR_LICENSE_MODEL_PATH}/${license_model_id}${SDC_VENDOR_ENTITLEMENT_POOL_PATH}/${pool_id}  ${SDC_DESIGNER_USER_ID}    auth=${GLOBAL_SDC_AUTHENTICATION}
    [Return]    ${resp.json()}

Add SDC License Group
    [Documentation]    Creates an SDC License Group and returns its id
    [Arguments]    ${license_model_id}   ${version_id}=1.0   ${license_start_date}="01/01/1960"   ${license_end_date}="01/01/1961"
    ${uuid}=    Generate UUID4
    ${shortened_uuid}=     Evaluate    str("${uuid}")[:23]
    ${map}=    Create Dictionary    key_group_name=${shortened_uuid}   license_start_date=${license_start_date}  license_end_date=${license_end_date}
    Templating.Create Environment    sdc    ${GLOBAL_TEMPLATE_FOLDER}
    ${data}=   Templating.Apply Template    sdc   ${SDC_KEY_GROUP_TEMPLATE}    ${map}
    ${resp}=    SDC.Run Post Request    ${SDC_BE_ONBOARD_ENDPOINT}    ${SDC_VENDOR_LICENSE_MODEL_PATH}/${license_model_id}/versions/${version_id}${SDC_VENDOR_KEY_GROUP_PATH}     ${data}   ${SDC_DESIGNER_USER_ID}    auth=${GLOBAL_SDC_AUTHENTICATION}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()['value']}

Get SDC License Group
    [Documentation]    Gets an SDC License Group by its id
    [Arguments]    ${license_model_id}    ${group_id}      ${version_id}
    ${resp}=    SDC.Run Get Request   ${SDC_BE_ONBOARD_ENDPOINT}    ${SDC_VENDOR_LICENSE_MODEL_PATH}/${license_model_id}/versions/${version_id}${SDC_VENDOR_KEY_GROUP_PATH}/${group_id}   ${SDC_DESIGNER_USER_ID}    auth=${GLOBAL_SDC_AUTHENTICATION}
    [Return]    ${resp.json()}

Add SDC Feature Group
    [Documentation]    Creates an SDC Feature Group and returns its id
    [Arguments]    ${license_model_id}    ${key_group_id}    ${entitlement_pool_id}      ${version_id}=0.1
    ${uuid}=    Generate UUID4
    ${shortened_uuid}=     Evaluate    str("${uuid}")[:23]
    ${map}=    Create Dictionary    feature_group_name=${shortened_uuid}    key_group_id=${key_group_id}    entitlement_pool_id=${entitlement_pool_id}   manufacturer_reference_number=mrn${shortened_uuid}
    Templating.Create Environment    sdc    ${GLOBAL_TEMPLATE_FOLDER}
    ${data}=   Templating.Apply Template    sdc   ${SDC_FEATURE_GROUP_TEMPLATE}    ${map}
    ${resp}=    SDC.Run Post Request    ${SDC_BE_ONBOARD_ENDPOINT}    ${SDC_VENDOR_LICENSE_MODEL_PATH}/${license_model_id}/versions/${version_id}${SDC_VENDOR_FEATURE_GROUP_PATH}     ${data}    ${SDC_DESIGNER_USER_ID}   auth=${GLOBAL_SDC_AUTHENTICATION}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()['value']}

Get SDC Feature Group
    [Documentation]    Gets an SDC Feature Group by its id
    [Arguments]    ${license_model_id}    ${group_id}
    ${resp}=    SDC.Run Get Request   ${SDC_BE_ONBOARD_ENDPOINT}    ${SDC_VENDOR_LICENSE_MODEL_PATH}/${license_model_id}${SDC_VENDOR_FEATURE_GROUP_PATH}/${group_id}   ${SDC_DESIGNER_USER_ID}    auth=${GLOBAL_SDC_AUTHENTICATION}
    [Return]    ${resp.json()}

Add SDC License Agreement
    [Documentation]    Creates an SDC License Agreement and returns its id
    [Arguments]    ${license_model_id}    ${feature_group_id}      ${version_id}=0.1
    ${uuid}=    Generate UUID4
    ${shortened_uuid}=     Evaluate    str("${uuid}")[:23]
    ${map}=    Create Dictionary    license_agreement_name=${shortened_uuid}    feature_group_id=${feature_group_id}
    Templating.Create Environment    sdc    ${GLOBAL_TEMPLATE_FOLDER}
    ${data}=   Templating.Apply Template    sdc   ${SDC_LICENSE_AGREEMENT_TEMPLATE}    ${map}
    ${resp}=    SDC.Run Post Request    ${SDC_BE_ONBOARD_ENDPOINT}    ${SDC_VENDOR_LICENSE_MODEL_PATH}/${license_model_id}/versions/${version_id}${SDC_VENDOR_LICENSE_AGREEMENT_PATH}     ${data}    ${SDC_DESIGNER_USER_ID}     auth=${GLOBAL_SDC_AUTHENTICATION}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()['value']}

Get SDC License Agreement
    [Documentation]    Gets an SDC License Agreement by its id
    [Arguments]    ${license_model_id}    ${agreement_id}
    ${resp}=    SDC.Run Get Request   ${SDC_BE_ONBOARD_ENDPOINT}    ${SDC_VENDOR_LICENSE_MODEL_PATH}/${license_model_id}${SDC_VENDOR_LICENSE_AGREEMENT_PATH}/${agreement_id}   ${SDC_DESIGNER_USER_ID}    auth=${GLOBAL_SDC_AUTHENTICATION}
    [Return]    ${resp.json()}

Add SDC Software Product
    [Documentation]    Creates an SDC Software Product and returns its id
    [Arguments]    ${license_agreement_id}    ${feature_group_id}    ${license_model_name}    ${license_model_id}   ${license_model_version_id}  ${name_prefix}
    ${uuid}=    Generate UUID4
    ${shortened_uuid}=     Evaluate    str("${uuid}")[:13]
    ${software_product_name}=  Catenate   ${name_prefix}   ${shortened_uuid}
    ${map}=    Create Dictionary    software_product_name=${software_product_name}    feature_group_id=${feature_group_id}    license_agreement_id=${license_agreement_id}    vendor_name=${license_model_name}    vendor_id=${license_model_id}    version_id=${license_model_version_id}
    Templating.Create Environment    sdc    ${GLOBAL_TEMPLATE_FOLDER}
    ${data}=   Templating.Apply Template    sdc   ${SDC_SOFTWARE_PRODUCT_TEMPLATE}    ${map}
    ${resp}=    SDC.Run Post Request    ${SDC_BE_ONBOARD_ENDPOINT}    ${SDC_VENDOR_SOFTWARE_PRODUCT_PATH}     ${data}    ${SDC_DESIGNER_USER_ID}   auth=${GLOBAL_SDC_AUTHENTICATION}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()['itemId']}   ${resp.json()['version']['id']}

Get SDC Software Product
    [Documentation]    Gets an SDC Software Product by its id
    [Arguments]    ${software_product_id}   ${version_id}=0.1
    ${resp}=    SDC.Run Get Request    ${SDC_BE_ONBOARD_ENDPOINT}    ${SDC_VENDOR_SOFTWARE_PRODUCT_PATH}/${software_product_id}/versions/${version_id}   ${SDC_DESIGNER_USER_ID}     auth=${GLOBAL_SDC_AUTHENTICATION}
    [Return]    ${resp.json()}

Add SDC Catalog Resource
    [Documentation]    Creates an SDC Catalog Resource and returns its id
    [Arguments]    ${license_agreement_id}    ${software_product_name}    ${license_model_name}    ${software_product_id}
    ${map}=    Create Dictionary    software_product_id=${software_product_id}    software_product_name=${software_product_name}    license_agreement_id=${license_agreement_id}    vendor_name=${license_model_name}
    Templating.Create Environment    sdc    ${GLOBAL_TEMPLATE_FOLDER}
    ${data}=   Templating.Apply Template    sdc   ${SDC_CATALOG_RESOURCE_TEMPLATE}    ${map}
    ${resp}=    SDC.Run Post Request    ${SDC_BE_ENDPOINT}    ${SDC_CATALOG_RESOURCES_PATH}     ${data}    ${SDC_DESIGNER_USER_ID}    auth=${GLOBAL_SDC_AUTHENTICATION}
    Should Be Equal As Strings  ${resp.status_code}     201
    [Return]    ${resp.json()['uniqueId']}

Add SDC Allotted Resource Catalog Resource
    [Documentation]    Creates an SDC Allotted Resource Catalog Resource and returns its id
    [Arguments]    ${license_agreement_id}    ${software_product_name}    ${license_model_name}    ${software_product_id}   ${subcategory}
    ${map}=    Create Dictionary    software_product_id=${software_product_id}    software_product_name=${software_product_name}    license_agreement_id=${license_agreement_id}    vendor_name=${license_model_name}   subcategory=${subcategory}
    Templating.Create Environment    sdc    ${GLOBAL_TEMPLATE_FOLDER}
    ${data}=   Templating.Apply Template    sdc   ${SDC_ALLOTTED_RESOURCE_CATALOG_RESOURCE_TEMPLATE}    ${map}
    ${resp}=    SDC.Run Post Request    ${SDC_BE_ENDPOINT}    ${SDC_CATALOG_RESOURCES_PATH}     ${data}    ${SDC_DESIGNER_USER_ID}    auth=${GLOBAL_SDC_AUTHENTICATION}
    Should Be Equal As Strings  ${resp.status_code}     201
    [Return]    ${resp.json()['uniqueId']}

Mark SDC Catalog Resource Inactive
    [Documentation]    Marks SDC Catalog Resource as inactive
    [Arguments]    ${catalog_resource_id}
    ${resp}=    SDC.Run Delete Request    ${SDC_BE_ENDPOINT}    ${SDC_CATALOG_RESOURCES_PATH}/${catalog_resource_id}     ${None}    ${SDC_DESIGNER_USER_ID}    auth=${GLOBAL_SDC_AUTHENTICATION}
    Should Be Equal As Strings  ${resp.status_code}     204
    [Return]    ${resp}

Delete Inactive SDC Catalog Resources
    [Documentation]    Delete all SDC Catalog Resources that are inactive
    ${resp}=    SDC.Run Delete Request    ${SDC_BE_ENDPOINT}    ${SDC_CATALOG_INACTIVE_RESOURCES_PATH}     ${None}    ${SDC_DESIGNER_USER_ID}    auth=${GLOBAL_SDC_AUTHENTICATION}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()}

Get SDC Catalog Resource
    [Documentation]    Gets an SDC Catalog Resource by its id
    [Arguments]    ${catalog_resource_id}
    ${resp}=    SDC.Run Get Request    ${SDC_BE_ENDPOINT}   ${SDC_CATALOG_RESOURCES_PATH}/${catalog_resource_id}    ${SDC_DESIGNER_USER_ID}    auth=${GLOBAL_SDC_AUTHENTICATION}
    [Return]    ${resp.json()}

Get SDC Catalog Resource Component Instances
    [Documentation]    Gets component instances of an SDC Catalog Resource by its id
    [Arguments]    ${catalog_resource_id}
    ${resp}=    SDC.Run Get Request    ${SDC_FE_ENDPOINT}    ${SDC_FE_CATALOG_RESOURCES_PATH}/${catalog_resource_id}/filteredDataByParams?include=componentInstances    ${SDC_DESIGNER_USER_ID}    auth=${GLOBAL_SDC_AUTHENTICATION}
    [Return]    ${resp.json()}

Get SDC Catalog Resource Deployment Artifact Properties
    [Documentation]    Gets deployment artifact properties of an SDC Catalog Resource by its id
    [Arguments]    ${catalog_resource_id}
    ${resp}=    SDC.Run Get Request    ${SDC_FE_ENDPOINT}    ${SDC_CATALOG_SERVICES_PATH}/${catalog_resource_id}/filteredDataByParams?include=deploymentArtifacts    ${SDC_DESIGNER_USER_ID}    auth=${GLOBAL_SDC_AUTHENTICATION}
    [Return]    ${resp.json()}


Get SDC Catalog Resource Component Instances Properties
    [Documentation]    Gets SDC Catalog Resource component instances properties by its id
    [Arguments]    ${catalog_resource_id}
    ${resp}=    SDC.Run Get Request    ${SDC_BE_ENDPOINT}    ${SDC_CATALOG_SERVICES_PATH}/${catalog_resource_id}/filteredDataByParams?include=componentInstancesProperties    ${SDC_DESIGNER_USER_ID}    auth=${GLOBAL_SDC_AUTHENTICATION}
    [Return]    ${resp.json()}

Get SDC Catalog Resource Component Instances Properties For Resource
    [Documentation]    Gets SDC Catalog Resource component instances properties for a Resource (VF) by its id
    [Arguments]    ${catalog_resource_id}
    ${resp}=    SDC.Run Get Request    ${SDC_FE_ENDPOINT}    ${SDC_FE_CATALOG_RESOURCES_PATH}/${catalog_resource_id}/filteredDataByParams?include=componentInstancesProperties    ${SDC_DESIGNER_USER_ID}    auth=${GLOBAL_SDC_AUTHENTICATION}
    [Return]    ${resp.json()}

Get SDC Catalog Resource Inputs
    [Documentation]    Gets SDC Catalog Resource inputs by its id
    [Arguments]    ${catalog_resource_id}
    ${resp}=    SDC.Run Get Request    ${SDC_FE_ENDPOINT}    ${SDC_FE_CATALOG_RESOURCES_PATH}/${catalog_resource_id}/filteredDataByParams?include=inputs    ${SDC_DESIGNER_USER_ID}    auth=${GLOBAL_SDC_AUTHENTICATION}
    [Return]    ${resp.json()}

Get SDC Catalog Resource Component Instance Properties
    [Documentation]    Gets component instance properties of an SDC Catalog Resource by their ids
    [Arguments]    ${catalog_resource_id}    ${component_instance_id}    ${component_id}
    ${resp}=    SDC.Run Get Request    ${SDC_FE_ENDPOINT}    ${SDC_FE_CATALOG_RESOURCES_PATH}/${catalog_resource_id}/componentInstances/${component_instance_id}/${component_id}/inputs    ${SDC_DESIGNER_USER_ID}auth=${GLOBAL_SDC_AUTHENTICATION}
    [Return]    ${resp.json()}

Set SDC Catalog Resource Component Instance Properties
    [Documentation]    Sets SDC Catalog Resource component instance properties by ids
    [Arguments]    ${catalog_resource_id}    ${component_parent_service_id}    ${data}
    ${resp}=    SDC.Run Post Request    ${SDC_FE_ENDPOINT}    ${SDC_FE_CATALOG_SERVICES_PATH}/${component_parent_service_id}/resourceInstance/${catalog_resource_id}/properties    ${data}    ${SDC_DESIGNER_USER_ID}    auth=${GLOBAL_SDC_AUTHENTICATION}
    [Return]   ${resp.json()}

Set SDC Catalog Resource Component Instance Properties For Resource
    [Documentation]    Sets SDC Resource component instance properties by ids
    [Arguments]    ${catalog_parent_resource_id}    ${catalog_resource_id}    ${data}
    ${resp}=    SDC.Run Post Request    ${SDC_FE_ENDPOINT}    ${SDC_FE_CATALOG_RESOURCES_PATH}/${catalog_parent_resource_id}/resourceInstance/${catalog_resource_id}/properties   ${data}    ${SDC_DESIGNER_USER_ID}   auth=${GLOBAL_SDC_AUTHENTICATION}
    [Return]   ${resp.json()}

Set CDS Catalog Resource Component Instance Properties
    [Documentation]    Sets CDS Catalog Resource component instance properties by ids
    [Arguments]    ${catalog_resource_id}    ${component_instance_id}    ${data}
    ${resp}=    SDC.Run Post Request    ${SDC_FE_ENDPOINT}    ${SDC_FE_CATALOG_RESOURCES_PATH}/${catalog_resource_id}/resourceInstance/${component_instance_id}/inputs    ${data}    ${SDC_DESIGNER_USER_ID}    auth=${GLOBAL_SDC_AUTHENTICATION}
    [Return]    ${resp.json()}

Set SDC Catalog Resource VNF Inputs
    [Documentation]    Sets VNF Inputs for an SDC Catalog Resource by its id
    [Arguments]    ${catalog_resource_id}    ${data}
    ${resp}=    SDC.Run Post Request    ${SDC_FE_ENDPOINT}    ${SDC_FE_CATALOG_RESOURCES_PATH}/${catalog_resource_id}/update/inputs    ${data}    ${SDC_DESIGNER_USER_ID}    auth=${GLOBAL_SDC_AUTHENTICATION}
    [Return]    ${resp.json()}

Get SDC Demo Vnf Catalog Resource
    [Documentation]  Gets Resource ids of demonstration VNFs for instantiation
    [Arguments]    ${service_name}
    ${resp}=   SDC.Run Get Request    ${SDC_BE_ENDPOINT}    ${SDC_CATALOG_SERVICES_PATH}/serviceName/${service_name}/serviceVersion/1.0    ${SDC_DESIGNER_USER_ID}    auth=${GLOBAL_SDC_AUTHENTICATION}
    @{ITEMS}=    Copy List    ${resp.json()['componentInstances']}
    ${demo_catalog_resource}=   Create Dictionary
    :FOR    ${ELEMENT}    IN    @{ITEMS}
    \    Log    ${ELEMENT['name']}
    \    Log    ${ELEMENT['groupInstances'][0]['groupName']}
    \    ${vnf}=   Get VNF From Group Name     ${ELEMENT['groupInstances'][0]['groupName']}     ${service_name}
    \    ${vnf_data}=    Create Dictionary    vnf_type=${ELEMENT['name']}  vf_module=${ELEMENT['groupInstances'][0]['groupName']}
    \    LOG     ${vnf_data}
    \    Set To Dictionary    ${demo_catalog_resource}    ${vnf}=${vnf_data}
    \    LOG     ${demo_catalog_resource}
    [Return]    ${demo_catalog_resource}

Get VNF From Group Name
    [Documentation]   Looks up VNF key from service mapping for a regex on group_name and service_name
    [Arguments]   ${group_name}    ${service_name}
    ${vnf}=   Set Variable If
    ...                      ('${service_name}'=='demoVFWCL') and ('base_vfw' in '${group_name}')   vFWCLvFWSNK
    ...                      ('${service_name}'=='demoVFWCL') and ('base_vpkg' in '${group_name}')   vFWCLvPKG
    ...                      ('${service_name}'=='demoVLB') and ('base_vlb' in '${group_name}')   vLB
    [Return]   ${vnf}

Checkin SDC Catalog Resource
    [Documentation]    Checks in an SDC Catalog Resource by its id
    [Arguments]    ${catalog_resource_id}
    ${map}=    Create Dictionary    user_remarks=Robot remarks
    Templating.Create Environment    sdc    ${GLOBAL_TEMPLATE_FOLDER}
    ${data}=   Templating.Apply Template    sdc   ${SDC_USER_REMARKS_TEMPLATE}    ${map}
    ${resp}=    SDC.Run Post Request    ${SDC_BE_ENDPOINT}    ${SDC_DESIGNER_USER_ID}    ${SDC_CATALOG_RESOURCES_PATH}/${catalog_resource_id}${SDC_CATALOG_LIFECYCLE_PATH}/checkin    ${data}    auth=${GLOBAL_SDC_AUTHENTICATION}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()}

Request Certify SDC Catalog Resource
    [Documentation]    Requests certification of an SDC Catalog Resource by its id
    [Arguments]    ${catalog_resource_id}
    ${map}=    Create Dictionary    user_remarks=Robot remarks
    Templating.Create Environment    sdc    ${GLOBAL_TEMPLATE_FOLDER}
    ${data}=   Templating.Apply Template    sdc   ${SDC_USER_REMARKS_TEMPLATE}    ${map}
    ${resp}=    SDC.Run Post Request    ${SDC_BE_ENDPOINT}    ${SDC_CATALOG_RESOURCES_PATH}/${catalog_resource_id}${SDC_CATALOG_LIFECYCLE_PATH}/certificationRequest    ${data}    ${SDC_DESIGNER_USER_ID}    auth=${GLOBAL_SDC_AUTHENTICATION}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()}

Start Certify SDC Catalog Resource
    [Documentation]    Start certification of an SDC Catalog Resource by its id
    [Arguments]    ${catalog_resource_id}
    ${resp}=    SDC.Run Post Request    ${SDC_BE_ENDPOINT}    ${SDC_CATALOG_RESOURCES_PATH}/${catalog_resource_id}${SDC_CATALOG_LIFECYCLE_PATH}/startCertification    ${None}    ${SDC_TESTER_USER_ID}    auth=${GLOBAL_SDC_AUTHENTICATION}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()}

Certify SDC Catalog Resource
    [Documentation]    Certifies an SDC Catalog Resource by its id and returns the new id
    [Arguments]    ${catalog_resource_id}    ${user_id}=${SDC_TESTER_USER_ID}
    ${map}=    Create Dictionary    user_remarks=Robot remarks
    Templating.Create Environment    sdc    ${GLOBAL_TEMPLATE_FOLDER}
    ${data}=   Templating.Apply Template    sdc   ${SDC_USER_REMARKS_TEMPLATE}    ${map}
    ${resp}=    SDC.Run Post Request    ${SDC_BE_ENDPOINT}    ${SDC_CATALOG_RESOURCES_PATH}/${catalog_resource_id}${SDC_CATALOG_LIFECYCLE_PATH}/certify    ${data}    ${user_id}    auth=${GLOBAL_SDC_AUTHENTICATION}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()['uniqueId']}

Upload SDC Heat Package
    [Documentation]    Creates an SDC Software Product and returns its id
    [Arguments]    ${software_product_id}    ${file_path}   ${version_id}=0.1
    ${files}=     Create Dictionary
    Create Multi Part     ${files}  upload  ${file_path}    contentType=application/zip
    ${resp}=    SDC.Run Post Files Request    ${SDC_BE_ONBOARD_ENDPOINT}    ${SDC_VENDOR_SOFTWARE_PRODUCT_PATH}/${software_product_id}/versions/${version_id}${SDC_VENDOR_SOFTWARE_UPLOAD_PATH}     ${files}    ${SDC_DESIGNER_USER_ID}    auth=${GLOBAL_SDC_AUTHENTICATION}
    Should Be Equal As Strings      ${resp.status_code}     200

Add SDC Catalog Service
    [Documentation]    Creates an SDC Catalog Service and returns its id
    [Arguments]   ${catalog_service_name}
    ${uuid}=    Generate UUID4
    ${shortened_uuid}=     Evaluate    str("${uuid}")[:23]
    ${catalog_service_name}=   Set Variable If   '${catalog_service_name}' ==''   ${shortened_uuid}   ${catalog_service_name}
    ${map}=    Create Dictionary    service_name=${catalog_service_name}
    Templating.Create Environment    sdc    ${GLOBAL_TEMPLATE_FOLDER}
    ${data}=   Templating.Apply Template    sdc   ${SDC_CATALOG_SERVICE_TEMPLATE}    ${map}
    ${resp}=    SDC.Run Post Request    ${SDC_BE_ENDPOINT}    ${SDC_CATALOG_SERVICES_PATH}     ${data}    ${SDC_DESIGNER_USER_ID}    auth=${GLOBAL_SDC_AUTHENTICATION}
    Should Be Equal As Strings  ${resp.status_code}     201
    [Return]    ${resp.json()['uniqueId']}

Mark SDC Catalog Service Inactive
    [Documentation]    Deletes an SDC Catalog Service
    [Arguments]    ${catalog_service_id}
    ${resp}=    SDC.Run Delete Request    ${SDC_BE_ENDPOINT}    ${SDC_CATALOG_SERVICES_PATH}/${catalog_service_id}     ${None}    ${SDC_DESIGNER_USER_ID}    auth=${GLOBAL_SDC_AUTHENTICATION}
    Should Be Equal As Strings  ${resp.status_code}     204
    [Return]    ${resp}

Delete Inactive SDC Catalog Services
    [Documentation]    Delete all SDC Catalog Services that are inactive
    ${resp}=    SDC.Run Delete Request    ${SDC_BE_ENDPOINT}    ${SDC_CATALOG_INACTIVE_SERVICES_PATH}     ${None}    ${SDC_DESIGNER_USER_ID}    auth=${GLOBAL_SDC_AUTHENTICATION}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()}

Get SDC Catalog Service
    [Documentation]    Gets an SDC Catalog Service by its id
    [Arguments]    ${catalog_service_id}
    ${resp}=    SDC.Run Get Request    ${SDC_BE_ENDPOINT}    ${SDC_CATALOG_SERVICES_PATH}/${catalog_service_id}    ${SDC_DESIGNER_USER_ID}    auth=${GLOBAL_SDC_AUTHENTICATION}
    [Return]    ${resp.json()}

Checkin SDC Catalog Service
    [Documentation]    Checks in an SDC Catalog Service by its id
    [Arguments]    ${catalog_service_id}
    ${map}=    Create Dictionary    user_remarks=Robot remarks
    Templating.Create Environment    sdc    ${GLOBAL_TEMPLATE_FOLDER}
    ${data}=  Templating.Apply Template    sdc   ${SDC_USER_REMARKS_TEMPLATE}    ${map}
    ${resp}=    SDC.Run Post Request    ${SDC_BE_ENDPOINT}    ${SDC_CATALOG_SERVICES_PATH}/${catalog_service_id}${SDC_CATALOG_LIFECYCLE_PATH}/checkin    ${data}    ${SDC_DESIGNER_USER_ID}    auth=${GLOBAL_SDC_AUTHENTICATION}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()}

Request Certify SDC Catalog Service
    [Documentation]    Requests certification of an SDC Catalog Service by its id
    [Arguments]    ${catalog_service_id}
    ${map}=    Create Dictionary    user_remarks=Robot remarks
    Templating.Create Environment    sdc    ${GLOBAL_TEMPLATE_FOLDER}
    ${data}=  Templating.Apply Template    sdc   ${SDC_USER_REMARKS_TEMPLATE}    ${map}
    ${resp}=    SDC.Run Post Request    ${SDC_BE_ENDPOINT}    ${SDC_CATALOG_SERVICES_PATH}/${catalog_service_id}${SDC_CATALOG_LIFECYCLE_PATH}/certificationRequest    ${data}    ${SDC_DESIGNER_USER_ID}    auth=${GLOBAL_SDC_AUTHENTICATION}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()}

Start Certify SDC Catalog Service
    [Documentation]    Start certification of an SDC Catalog Service by its id
    [Arguments]    ${catalog_service_id}
    ${resp}=    SDC.Run Post Request    ${SDC_BE_ENDPOINT}    ${SDC_CATALOG_SERVICES_PATH}/${catalog_service_id}${SDC_CATALOG_LIFECYCLE_PATH}/startCertification    ${None}    ${SDC_TESTER_USER_ID}    auth=${GLOBAL_SDC_AUTHENTICATION}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()}

Certify SDC Catalog Service
    [Documentation]    Certifies an SDC Catalog Service by its id and returns the new id
    [Arguments]    ${catalog_service_id}
    ${map}=    Create Dictionary    user_remarks=Robot remarks
    Templating.Create Environment    sdc    ${GLOBAL_TEMPLATE_FOLDER}
    ${data}=  Templating.Apply Template    sdc   ${SDC_USER_REMARKS_TEMPLATE}    ${map}
    ${resp}=    SDC.Run Post Request    ${SDC_BE_ENDPOINT}    ${SDC_CATALOG_SERVICES_PATH}/${catalog_service_id}${SDC_CATALOG_LIFECYCLE_PATH}/certify    ${data}    ${SDC_TESTER_USER_ID}    auth=${GLOBAL_SDC_AUTHENTICATION}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()['uniqueId']}

Approve SDC Catalog Service
    [Documentation]    Approves an SDC Catalog Service by its id
    [Arguments]    ${catalog_service_id}
    ${map}=    Create Dictionary    user_remarks=Robot remarks
    Templating.Create Environment    sdc    ${GLOBAL_TEMPLATE_FOLDER}
    ${data}=   Templating.Apply Template    sdc   ${SDC_USER_REMARKS_TEMPLATE}    ${map}
    ${resp}=    SDC.Run Post Request    ${SDC_BE_ENDPOINT}    ${SDC_CATALOG_SERVICES_PATH}/${catalog_service_id}${SDC_CATALOG_SERVICE_DISTRIBUTION_STATE_PATH}${SDC_DISTRIBUTION_STATE_APPROVE_PATH}    ${data}    ${SDC_GOVERNOR_USER_ID}    auth=${GLOBAL_SDC_AUTHENTICATION}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()}
    
Distribute SDC Catalog Service
    [Documentation]    distribute an SDC Catalog Service by its id
    [Arguments]    ${catalog_service_id}
    ${resp}=    SDC.Run Post Request    ${SDC_BE_ENDPOINT}    ${SDC_CATALOG_SERVICES_PATH}/${catalog_service_id}${SDC_CATALOG_SERVICE_DISTRIBUTION_ACTIVATE_PATH}    ${None}    ${SDC_OPS_USER_ID}    auth=${GLOBAL_SDC_AUTHENTICATION}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()}

Add SDC Resource Instance
    [Documentation]    Creates an SDC Resource Instance and returns its id
    [Arguments]    ${catalog_service_id}    ${catalog_resource_id}    ${catalog_resource_name}  ${xoffset}=${0}   ${yoffset}=${0}   ${resourceType}=VF
    ${milli_timestamp}=    Generate Timestamp
    ${xoffset}=    Set Variable   ${xoffset+306}
    ${yoffset}=    Set Variable   ${yoffset+248}
    ${map}=    Create Dictionary    catalog_resource_id=${catalog_resource_id}    catalog_resource_name=${catalog_resource_name}    milli_timestamp=${milli_timestamp}   posX=${xoffset}    posY=${yoffset}    originType=${resourceType}
    Templating.Create Environment    sdc    ${GLOBAL_TEMPLATE_FOLDER}
    ${data}=   Templating.Apply Template    sdc   ${SDC_RESOURCE_INSTANCE_TEMPLATE}    ${map}
    ${resp}=    SDC.Run Post Request    ${SDC_BE_ENDPOINT}    ${SDC_CATALOG_SERVICES_PATH}/${catalog_service_id}${SDC_CATALOG_SERVICE_RESOURCE_INSTANCE_PATH}     ${data}    ${SDC_DESIGNER_USER_ID}    auth=${GLOBAL_SDC_AUTHENTICATION}
    Should Be Equal As Strings  ${resp.status_code}     201
    [Return]    ${resp.json()['uniqueId']}

Add SDC Resource Instance To Resource
    [Documentation]    Creates an SDC Resource Instance in a Resource (VF) and returns its id
    [Arguments]    ${parent_catalog_resource_id}    ${catalog_resource_id}    ${catalog_resource_name}  ${xoffset}=${0}   ${yoffset}=${0}    ${resourceType}=VF
    ${milli_timestamp}=    Generate Timestamp
    ${xoffset}=    Set Variable   ${xoffset+306}
    ${yoffset}=    Set Variable   ${yoffset+248}
    ${map}=    Create Dictionary    catalog_resource_id=${catalog_resource_id}    catalog_resource_name=${catalog_resource_name}    milli_timestamp=${milli_timestamp}   posX=${xoffset}    posY=${yoffset}    originType=${resourceType}
    Templating.Create Environment    sdc    ${GLOBAL_TEMPLATE_FOLDER}
    ${data}=  Templating.Apply Template    sdc   ${SDC_RESOURCE_INSTANCE_TEMPLATE}    ${map}
    ${resp}=    SDC.Run Post Request    ${SDC_BE_ENDPOINT}    ${SDC_CATALOG_RESOURCES_PATH}/${parent_catalog_resource_id}${SDC_CATALOG_SERVICE_RESOURCE_INSTANCE_PATH}     ${data}    ${SDC_DESIGNER_USER_ID}    auth=${GLOBAL_SDC_AUTHENTICATION}
    Should Be Equal As Strings  ${resp.status_code}     201
    [Return]    ${resp.json()['uniqueId']}

Get Catalog Service Distribution
    [Documentation]    Gets an SDC Catalog Service distribution
    [Arguments]    ${catalog_service_uuid}
    ${resp}=    SDC.Run Get Request   ${SDC_BE_ENDPOINT}    ${SDC_CATALOG_SERVICES_PATH}/${catalog_service_uuid}${SDC_CATALOG_SERVICE_DISTRIBUTION_PATH}    ${SDC_OPS_USER_ID}    auth=${GLOBAL_SDC_AUTHENTICATION}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()}

Check Catalog Service Distributed
    [Documentation]    Checks if an SDC Catalog Service is distributed
    [Arguments]    ${catalog_service_uuid}    ${dist_status}
    ${dist_resp}=    Get Catalog Service Distribution    ${catalog_service_uuid}
    Should Be Equal As Strings  ${dist_resp['distributionStatusOfServiceList'][0]['deployementStatus']}         Distributed
    ${det_resp}=    Get Catalog Service Distribution Details    ${dist_resp['distributionStatusOfServiceList'][0]['distributionID']}
    @{ITEMS}=    Copy List    ${det_resp['distributionStatusList']}
    Should Not Be Empty   ${ITEMS}
    ${SO_COMPLETE}   Set Variable   FALSE
    ${dist_status}   Set Variable   CONTINUE
    Should Not Be Empty   ${ITEMS}
    :FOR    ${ELEMENT}    IN    @{ITEMS}
    \    Log    ${ELEMENT['omfComponentID']}
    \    Log    ${ELEMENT['status']}
    \    ${SO_COMPLETE}   Set Variable If   (('${ELEMENT['status']}' == 'DISTRIBUTION_COMPLETE_OK')) or ('${SO_COMPLETE}'=='TRUE')  TRUE
    \    Exit For Loop If   ('${SO_COMPLETE}'=='TRUE')
    \    Exit For Loop If   ('${ELEMENT['status']}' == 'DISTRIBUTION_COMPLETE_ERROR')
    \    ${dist_status}=  Set Variable If   (('${ELEMENT['status']}' == 'COMPONENT_DONE_ERROR') and ('${ELEMENT['omfComponentID']}' == 'aai-ml'))  EXIT
    \    Exit For Loop If   (('${ELEMENT['status']}' == 'COMPONENT_DONE_ERROR') and ('${ELEMENT['omfComponentID']}' == 'aai-ml'))
    Should Be True   ( '${SO_COMPLETE}'=='TRUE')   SO Test

Get Catalog Service Distribution Details
    [Documentation]    Gets SDC Catalog Service distribution details
    [Arguments]    ${catalog_service_distribution_id}
    ${resp}=    SDC.Run Get Request    ${SDC_BE_ENDPOINT}    ${SDC_CATALOG_SERVICES_PATH}${SDC_CATALOG_SERVICE_DISTRIBUTION_PATH}/${catalog_service_distribution_id}    ${SDC_OPS_USER_ID}    auth=${GLOBAL_SDC_AUTHENTICATION}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()}
    
Run SDC Health Check
    [Documentation]    Runs a SDC health check
    ${resp}=    SDC.Run Get Request     ${SDC_FE_ENDPOINT}    ${SDC_HEALTH_CHECK_PATH}    user=${None}
    # only test for HTTP 200 to determine SDC Health. SDC_DE_HEALTH is informational
    Should Be Equal As Strings  ${resp.status_code}     200    SDC DOWN
    ${SDC_DE_HEALTH}=    Catenate   DOWN
    @{ITEMS}=    Copy List    ${resp.json()['componentsInfo']}
    :FOR    ${ELEMENT}    IN    @{ITEMS}
    \    Log    ${ELEMENT['healthCheckStatus']}
    \    ${SDC_DE_HEALTH}  Set Variable If   (('DE' in '${ELEMENT['healthCheckComponent']}') and ('${ELEMENT['healthCheckStatus']}' == 'UP')) or ('${SDC_DE_HEALTH}'=='UP')  UP
    Log   (DMaaP:${SDC_DE_HEALTH})

Open SDC GUI
    [Documentation]   Logs in to SDC GUI
    [Arguments]    ${PATH}
    ## Setup Browever now being managed by the test case
    ##Setup Browser
    Go To    ${SDC_FE_ENDPOINT}${PATH}
    Maximize Browser Window

    Set Browser Implicit Wait    ${GLOBAL_SELENIUM_BROWSER_IMPLICIT_WAIT}
    Log    Logging in to ${SDC_FE_ENDPOINT}${PATH}
    Title Should Be    SDC
    Wait Until Page Contains Element    xpath=//div/a[text()='SDC']    ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT}
    Log    Logged in to ${SDC_FE_ENDPOINT}${PATH}


Create Multi Part
   [Arguments]  ${addTo}  ${partName}  ${filePath}  ${contentType}=${None}
   ${fileData}=   Get Binary File  ${filePath}
   ${fileDir}  ${fileName}=  Split Path  ${filePath}
   ${partData}=  Create List  ${fileName}  ${fileData}  ${contentType}
   Set To Dictionary  ${addTo}  ${partName}=${partData}


Add CDS Parameters 
    [Arguments]  ${catalog_service_name} 
    ${resp}=   SDC.Run Get Request    ${SDC_BE_ENDPOINT}    ${SDC_CATALOG_SERVICES_PATH}/serviceName/${catalog_service_name}/serviceVersion/0.1  ${SDC_DESIGNER_USER_ID}    auth=${GLOBAL_SDC_AUTHENTICATION}
    #${resp_json}=  To Json  ${resp}
    ${service_uuid}=  Set Variable  ${resp.json()['uniqueId']}
    ${component_uuid}=  Set Variable  ${resp.json()['componentInstances'][0]['uniqueId']}
    @{inputs}=   Copy List  ${resp.json()['componentInstances'][0]['inputs']}
    :FOR  ${input}  IN  @{inputs}
    \    Run Keyword If  '${input['name']}' == "sdnc_artifact_name"   Set Input Parameter  ${service_uuid}  ${component_uuid}  ${input}  string  vdns-vnf
         ...  ELSE IF  '${input['name']}' == "sdnc_model_name"   Set Input Parameter  ${service_uuid}  ${component_uuid}  ${input}  string  test
         ...  ELSE IF  '${input['name']}' == "sdnc_model_version"   Set Input Parameter  ${service_uuid}  ${component_uuid}  ${input}  string  1.0.0
         ...  ELSE IF  '${input['name']}' == "skip_post_instantiation_configuration"   Set Input Parameter  ${service_uuid}  ${component_uuid}  ${input}  boolean  false
    

Set Input Parameter 
    [Arguments]   ${service_uuid}  ${component_uuid}  ${input}  ${input_type}  ${input_value}    
    ${resp}=    SDC.Run Post Request  ${SDC_BE_ENDPOINT}   ${SDC_CATALOG_SERVICES_PATH}/${service_uuid}/resourceInstance/${component_uuid}/inputs    {"constraints":[],"name":"${input['name']}","parentUniqueId":"${input['parentUniqueId']}","password":false,"required":false,"schema":{"property":{}},"type":"${input_type}","uniqueId":"${input['uniqueId']}","value":"${input_value}","definition":false,"toscaPresentation":{"ownerId":"${input['ownerId']}"}}    ${SDC_DESIGNER_USER_ID}    auth=${GLOBAL_SDC_AUTHENTICATION} 
    Should Be Equal As Strings  ${resp.status_code}     200
