*** Settings ***
Documentation     The main interface for interacting with ASDC. It handles low level stuff like managing the http request library and DCAE required fields
Library           RequestsLibrary
Library           UUID
Library           JSONUtils
Library           OperatingSystem
Library           Collections
Library           SeleniumLibrary
Library           String
Library           StringTemplater
Library           ArchiveLibrary
Library           HEATUtils
Library           DateTime
Resource          global_properties.robot
Resource          browser_setup.robot
Resource          json_templater.robot

*** Variables ***
${ASDC_DESIGNER_USER_ID}    cs0008
${ASDC_TESTER_USER_ID}    jm0007
${ASDC_GOVERNOR_USER_ID}    gv0001
${ASDC_OPS_USER_ID}    op0001
${ASDC_HEALTH_CHECK_PATH}    /sdc1/rest/healthCheck
${ASDC_VENDOR_LICENSE_MODEL_PATH}    /onboarding-api/v1.0/vendor-license-models
${ASDC_VENDOR_SOFTWARE_PRODUCT_PATH}    /onboarding-api/v1.0/vendor-software-products
${ASDC_VENDOR_KEY_GROUP_PATH}    /license-key-groups
${ASDC_VENDOR_ENTITLEMENT_POOL_PATH}    /entitlement-pools
${ASDC_VENDOR_FEATURE_GROUP_PATH}    /feature-groups
${ASDC_VENDOR_LICENSE_AGREEMENT_PATH}    /license-agreements
${ASDC_VENDOR_ACTIONS_PATH}    /actions
${ASDC_VENDOR_SOFTWARE_UPLOAD_PATH}    /orchestration-template-candidate
${ASDC_FE_CATALOG_RESOURCES_PATH}    /sdc1/feProxy/rest/v1/catalog/resources
${ASDC_FE_CATALOG_SERVICES_PATH}    /sdc1/feProxy/rest/v1/catalog/services
${ASDC_CATALOG_RESOURCES_PATH}    /sdc2/rest/v1/catalog/resources
${ASDC_CATALOG_SERVICES_PATH}    /sdc2/rest/v1/catalog/services
${ASDC_CATALOG_INACTIVE_RESOURCES_PATH}    /sdc2/rest/v1/inactiveComponents/resource
${ASDC_CATALOG_RESOURCES_QUERY_PATH}    /sdc2/rest/v1/catalog/resources/resourceName
${ASDC_CATALOG_INACTIVE_SERVICES_PATH}    /sdc2/rest/v1/inactiveComponents/service
${ASDC_CATALOG_LIFECYCLE_PATH}    /lifecycleState
${ASDC_CATALOG_SERVICE_RESOURCE_INSTANCE_PATH}    /resourceInstance
${ASDC_CATALOG_SERVICE_RESOURCE_ARTIFACT_PATH}    /artifacts
${ASDC_CATALOG_SERVICE_DISTRIBUTION_STATE_PATH}    /distribution-state
${ASDC_CATALOG_SERVICE_DISTRIBUTION_PATH}    /distribution
${ASDC_DISTRIBUTION_STATE_APPROVE_PATH}    /approve
${ASDC_CATALOG_SERVICE_DISTRIBUTION_ACTIVATE_PATH}    /distribution/PROD/activate
${ASDC_LICENSE_MODEL_TEMPLATE}    robot/assets/templates/asdc/license_model.template
${ASDC_KEY_GROUP_TEMPLATE}    robot/assets/templates/asdc/key_group.template
${ASDC_ENTITLEMENT_POOL_TEMPLATE}    robot/assets/templates/asdc/entitlement_pool.template
${ASDC_FEATURE_GROUP_TEMPLATE}    robot/assets/templates/asdc/feature_group.template
${ASDC_LICENSE_AGREEMENT_TEMPLATE}    robot/assets/templates/asdc/license_agreement.template
${ASDC_ACTION_TEMPLATE}    robot/assets/templates/asdc/action.template
${ASDC_SOFTWARE_PRODUCT_TEMPLATE}    robot/assets/templates/asdc/software_product.template
${ASDC_ARTIFACT_UPLOAD_TEMPLATE}    robot/assets/templates/asdc/artifact_upload.template
${ASDC_CATALOG_RESOURCE_TEMPLATE}    robot/assets/templates/asdc/catalog_resource.template
${ASDC_USER_REMARKS_TEMPLATE}    robot/assets/templates/asdc/user_remarks.template
${ASDC_CATALOG_SERVICE_TEMPLATE}    robot/assets/templates/asdc/catalog_service.template
${ASDC_RESOURCE_INSTANCE_TEMPLATE}    robot/assets/templates/asdc/resource_instance.template
${ASDC_RESOURCE_INSTANCE_VNF_PROPERTIES_TEMPLATE}    robot/assets/templates/asdc/catalog_vnf_properties.template
${ASDC_RESOURCE_INSTANCE_VNF_INPUTS_TEMPLATE}    robot/assets/templates/asdc/catalog_vnf_inputs.template
${SDC_CATALOG_NET_RESOURCE_INPUT_TEMPLATE}    robot/assets/templates/asdc/catalog_net_input_properties.template
${ASDC_ALLOTTED_RESOURCE_CATALOG_RESOURCE_TEMPLATE}    robot/assets/templates/asdc/catalog_resource_alloted_resource.template
${SDC_CATALOG_ALLOTTED_RESOURCE_PROPERTIES_TEMPLATE}    robot/assets/templates/asdc/catalog_allotted_properties.template
${SDC_CATALOG_ALLOTTED_RESOURCE_INPUTS_TEMPLATE}    robot/assets/templates/asdc/catalog_allotted_inputs.template
${SDC_CATALOG_DEPLOYMENT_ARTIFACT_PATH}     robot/assets/asdc/blueprints/
${ASDC_FE_ENDPOINT}     ${GLOBAL_ASDC_SERVER_PROTOCOL}://${GLOBAL_INJECTED_SDC_FE_IP_ADDR}:${GLOBAL_ASDC_FE_PORT}
${ASDC_BE_ENDPOINT}     ${GLOBAL_ASDC_SERVER_PROTOCOL}://${GLOBAL_INJECTED_SDC_BE_IP_ADDR}:${GLOBAL_ASDC_BE_PORT}
${ASDC_BE_ONBOARD_ENDPOINT}     ${GLOBAL_ASDC_SERVER_PROTOCOL}://${GLOBAL_INJECTED_SDC_BE_ONBOARD_IP_ADDR}:${GLOBAL_ASDC_BE_ONBOARD_PORT}

*** Keywords ***
Distribute Model From ASDC
    [Documentation]    Goes end to end creating all the ASDC objects based ONAP model and distributing it to the systems. It then returns the service name, VF name and VF module name
    [Arguments]    ${model_zip_path}   ${catalog_service_name}=    ${cds}=    ${service}=
    # For Testing use random service names
    #${random}=    Get Current Date
    #${catalog_service_id}=    Add ASDC Catalog Service    ${catalog_service_name}_${random}
    ${catalog_service_id}=    Add ASDC Catalog Service    ${catalog_service_name}
    ${catalog_resource_ids}=    Create List
    ${catalog_resources}=   Create Dictionary
    #####  TODO: Support for Multiple resources of one type in a service  ######
    #   The zip list is the resources - no mechanism to indicate more than 1 of the items in the zip list
    #   GLOBAL_SERVICE_VNF_MAPPING  has the logical mapping but it is not the same key as model_zip_path
    #   ${vnflist}=   Get From Dictionary    ${GLOBAL_SERVICE_VNF_MAPPING}    ${service}
    #   Save the resource_id in a dictionary keyed by the resource name in the zipfile name (vFWDT_vFWSNK.zip or vFWDT_vPKG.zip)
    #   Create the resources but do not immediately add resource
    #   Add Resource to Service in a separate FOR loop
    ${resource_types}=   Create Dictionary

    :FOR    ${zip}     IN     @{model_zip_path}
    \    ${loop_catalog_resource_id}=    Setup ASDC Catalog Resource    ${zip}    ${cds}
    #     zip can be vFW.zip or vFWDT_VFWSNK.zip
    \    ${resource_type_match}=    Get Regexp Matches    ${zip}   ${service}_(.*)\.zip    1
    #  Need to be able to distribute preload for vFWCL vFWSNK and vFWDT vFWSNK to prepend service to vnf_type
    \    ${resource_type_string}=   Set Variable If   len(${resource_type_match})==0    ${service}    ${service}${resource_type_match[0]}
    \    Set To Dictionary    ${resource_types}    ${resource_type_string}    ${loop_catalog_resource_id}   
    \    Append To List    ${catalog_resource_ids}   ${loop_catalog_resource_id}


    ${vnflist}=   Get From Dictionary    ${GLOBAL_SERVICE_VNF_MAPPING}    ${service}

    # Spread the icons on the pallette starting on the left
    ${xoffset}=    Set Variable    ${0}

    :FOR  ${vnf}   IN   @{vnflist}
    \    ${loop_catalog_resource_resp}=    Get ASDC Catalog Resource      ${resource_types['${vnf}']}
    \    Set To Dictionary    ${catalog_resources}   ${resource_types['${vnf}']}=${loop_catalog_resource_resp}
    \    ${catalog_resource_unique_name}=   Add ASDC Resource Instance    ${catalog_service_id}    ${resource_types['${vnf}']}    ${loop_catalog_resource_resp['name']}    ${xoffset}
    \    ${xoffset}=   Set Variable   ${xoffset+100}
    #
    # do this here because the loop_catalog_resource_resp is different format after adding networks
    ${vf_module}=   Find Element In Array    ${loop_catalog_resource_resp['groups']}    type    org.openecomp.groups.VfModule
    #
    #  do network
    ${networklist}=   Get From Dictionary    ${GLOBAL_SERVICE_GEN_NEUTRON_NETWORK_MAPPING}    ${service}
    ${generic_neutron_net_uuid}=   Get Generic NeutronNet UUID
    :FOR   ${network}   IN   @{networklist}
    \    ${loop_catalog_resource_id}=   Set Variable    ${generic_neutron_net_uuid}
    \    Append To List    ${catalog_resource_ids}   ${loop_catalog_resource_id}
    \    ${loop_catalog_resource_resp}=    Get ASDC Catalog Resource    ${loop_catalog_resource_id}
    \    ${loop_catalog_resource_id}=   Add ASDC Resource Instance    ${catalog_service_id}    ${loop_catalog_resource_id}    ${network}    ${xoffset}      ${0}    VL
    \    ${nf_role}=   Convert To Lowercase   ${network}
    \    Setup SDC Catalog Resource GenericNeutronNet Properties      ${catalog_service_id}    ${nf_role}   ${loop_catalog_resource_id}
    \    ${xoffset}=   Set Variable   ${xoffset+100}
    \    Set To Dictionary    ${catalog_resources}   ${loop_catalog_resource_id}=${loop_catalog_resource_resp}
    ${catalog_service_resp}=    Get ASDC Catalog Service    ${catalog_service_id}
    #
    # do deployment artifacts
    #
    ${deploymentlist}=   Get From Dictionary    ${GLOBAL_SERVICE_DEPLOYMENT_ARTIFACT_MAPPING}    ${service}
    :FOR  ${deployment}  IN   @{deploymentlist}
    \    ${loop_catalog_resource_resp}=    Get ASDC Catalog Resource    ${loop_catalog_resource_id}
    \    Setup SDC Catalog Resource Deployment Artifact Properties      ${catalog_service_id}   ${loop_catalog_resource_resp}  ${catalog_resource_unique_name}  ${deployment}
    Checkin ASDC Catalog Service    ${catalog_service_id}
    Request Certify ASDC Catalog Service    ${catalog_service_id}
    Start Certify ASDC Catalog Service    ${catalog_service_id}
    # on certify it gets a new id
    ${catalog_service_id}=    Certify ASDC Catalog Service    ${catalog_service_id}
    Approve ASDC Catalog Service    ${catalog_service_id}
        :FOR   ${DIST_INDEX}    IN RANGE   1
        \   Log     Distribution Attempt ${DIST_INDEX}
        \   Distribute ASDC Catalog Service    ${catalog_service_id}
        \   ${catalog_service_resp}=    Get ASDC Catalog Service    ${catalog_service_id}
        \   ${status}   ${_} =   Run Keyword And Ignore Error   Loop Over Check Catalog Service Distributed       ${catalog_service_resp['uuid']}
        \   Exit For Loop If   '${status}'=='PASS'
        Should Be Equal As Strings  ${status}  PASS
    [Return]    ${catalog_service_resp['name']}    ${loop_catalog_resource_resp['name']}    ${vf_module}   ${catalog_resource_ids}    ${catalog_service_id}   ${catalog_resources}

Distribute vCPEResCust Model From ASDC
    [Documentation]    Goes end to end creating all the ASDC objects for the vCPE ResCust Service model and distributing it to the systems. It then returns the service name, VF name and VF module name
    [Arguments]    ${model_zip_path}   ${catalog_service_name}=    ${cds}=    ${service}=
    # For testing use random service name
    #${random}=    Get Current Date
    ${uuid}=    Generate UUID
    ${random}=     Evaluate    str("${uuid}")[:4]
    ${catalog_service_id}=    Add ASDC Catalog Service    ${catalog_service_name}_${random}
    #   catalog_service_name already
    #${catalog_service_id}=    Add ASDC Catalog Service    ${catalog_service_name}
    Log To Console    ${\n}ServiceName: ${catalog_service_name}_${random}
    #${catalog_service_id}=    Add ASDC Catalog Service    ${catalog_service_name}
    ${catalog_resource_ids}=    Create List
    ${catalog_resources}=   Create Dictionary
    :FOR    ${zip}     IN     @{model_zip_path}
    \    ${loop_catalog_resource_id}=    Setup ASDC Catalog Resource    ${zip}    ${cds}
    \    Append To List    ${catalog_resource_ids}   ${loop_catalog_resource_id}
    \    ${loop_catalog_resource_resp}=    Get ASDC Catalog Resource    ${loop_catalog_resource_id}
    \    Add ASDC Resource Instance    ${catalog_service_id}    ${loop_catalog_resource_id}    ${loop_catalog_resource_resp['name']}
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
    \    ${loop_catalog_resource_id}=    Add ASDC Allotted Resource Catalog Resource     00000    ${allottedresource}_${random}    ONAP     ${loop_catalog_resource_id}   ${allottedresource}
    \    ${loop_catalog_resource_id2}=   Add ASDC Resource Instance To Resource     ${loop_catalog_resource_id}    ${allottedresource_uuid}    ${allottedresource}    ${xoffset}      ${0}
    \    ${loop_catalog_resource_resp}=    Get ASDC Catalog Resource    ${loop_catalog_resource_id}
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
    \    ${loop_catalog_resource_id}=   Certify ASDC Catalog Resource    ${loop_catalog_resource_id}  ${ASDC_DESIGNER_USER_ID}
    \    Add ASDC Resource Instance    ${catalog_service_id}    ${loop_catalog_resource_id}    ${loop_catalog_resource_resp['name']}
    \    Set To Dictionary    ${catalog_resources}   ${loop_catalog_resource_id}=${loop_catalog_resource_resp}
    ${catalog_service_resp}=    Get ASDC Catalog Service    ${catalog_service_id}
    Checkin ASDC Catalog Service    ${catalog_service_id}
    Request Certify ASDC Catalog Service    ${catalog_service_id}
    Start Certify ASDC Catalog Service    ${catalog_service_id}
    # on certify it gets a new id
    ${catalog_service_id}=    Certify ASDC Catalog Service    ${catalog_service_id}
    Approve ASDC Catalog Service    ${catalog_service_id}
        :FOR   ${DIST_INDEX}    IN RANGE   1
        \   Log     Distribution Attempt ${DIST_INDEX}
        \   Distribute ASDC Catalog Service    ${catalog_service_id}
        \   ${catalog_service_resp}=    Get ASDC Catalog Service    ${catalog_service_id}
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
   Log To Console    ${result_str}
   Create File    /tmp/vcpe_allotted_resource_data.json    ${result_str}

Download CSAR
   [Documentation]   Download CSAR
   [Arguments]    ${catalog_service_id}    ${save_directory}=/tmp/csar
   # get meta data
   ${resp}=    Run ASDC Get Request    ${ASDC_CATALOG_SERVICES_PATH}/${catalog_service_id}/filteredDataByParams?include=toscaArtifacts    ${ASDC_DESIGNER_USER_ID}    ${ASDC_BE_ENDPOINT}
   ${csar_resource_id}=    Set Variable   ${resp.json()['toscaArtifacts']['assettoscacsar']['uniqueId']}
   ${resp}=    Run ASDC Get Request    ${ASDC_CATALOG_SERVICES_PATH}/${catalog_service_id}/artifacts/${csar_resource_id}
   ${csar_file_name}=   Set Variable    ${resp.json()['artifactName']}
   ${base64Obj}=   Set Variable    ${resp.json()['base64Contents']}
   ${binObj}=   Evaluate   base64.b64decode("${base64Obj}")   modules=base64
   Create Binary File  ${save_directory}/${csar_file_name}  ${binObj}
   Log To Console      ${\n}Downloaded:${csar_file_name}


Get Generic NeutronNet UUID
   [Documentation]   Look up the UUID of the Generic NeutronNetwork Resource
   ${resp}=    Run ASDC Get Request    ${ASDC_CATALOG_RESOURCES_QUERY_PATH}/Generic%20NeutronNet/resourceVersion/1.0   ${ASDC_DESIGNER_USER_ID}   ${ASDC_BE_ENDPOINT}
   [Return]    ${resp.json()['allVersions']['1.0']}

Get AllottedResource UUID
   [Documentation]   Look up the UUID of the Allotted Resource
   # if this fails then the AllottedResource template got deleted from SDC by mistake
   ${resp}=    Run ASDC Get Request    ${ASDC_CATALOG_RESOURCES_QUERY_PATH}/AllottedResource/resourceVersion/1.0   ${ASDC_DESIGNER_USER_ID}   ${ASDC_BE_ENDPOINT}
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

Setup ASDC Catalog Resource
    [Documentation]    Creates all the steps a VF needs for an ASDC Catalog Resource and returns the id
    [Arguments]    ${model_zip_path}    ${cds}=
    ${license_model_id}   ${license_model_version_id}=    Add ASDC License Model


    ${license_temp_date}=   Get Current Date
    ${license_start_date}=   Get Current Date     result_format=%m/%d/%Y
    ${license_end_date}=     Add Time To Date   ${license_temp_date}    365 days    result_format=%m/%d/%Y
    ${key_group_id}=    Add ASDC License Group    ${license_model_id}   ${license_model_version_id}  ${license_start_date}  ${license_end_date}
    ${pool_id}=    Add ASDC Entitlement Pool    ${license_model_id}   ${license_model_version_id}  ${license_start_date}  ${license_end_date}

    ${feature_group_id}=    Add ASDC Feature Group    ${license_model_id}    ${key_group_id}    ${pool_id}  ${license_model_version_id}
    ${license_agreement_id}=    Add ASDC License Agreement    ${license_model_id}    ${feature_group_id}   ${license_model_version_id}
    Submit ASDC License Model    ${license_model_id}   ${license_model_version_id}
    ${license_model_resp}=    Get ASDC License Model    ${license_model_id}   ${license_model_version_id}
    ${matches}=   Get Regexp Matches  ${model_zip_path}  temp/(.*)\.zip  1
    ${software_product_name_prefix}=    Set Variable   ${matches[0]}
    ${software_product_id}   ${software_product_version_id}=    Add ASDC Software Product    ${license_agreement_id}    ${feature_group_id}    ${license_model_resp['vendorName']}    ${license_model_id}    ${license_model_version_id}    ${software_product_name_prefix}
    Upload ASDC Heat Package    ${software_product_id}    ${model_zip_path}   ${software_product_version_id}
    Validate ASDC Software Product    ${software_product_id}  ${software_product_version_id}
    Submit ASDC Software Product    ${software_product_id}  ${software_product_version_id}
    Package ASDC Software Product    ${software_product_id}   ${software_product_version_id}
    ${software_product_resp}=    Get ASDC Software Product    ${software_product_id}    ${software_product_version_id}
    ${catalog_resource_id}=    Add ASDC Catalog Resource     ${license_agreement_id}    ${software_product_resp['name']}    ${license_model_resp['vendorName']}    ${software_product_id}
    # Check if need to set up CDS properties
    Run Keyword If    '${cds}' == 'vfwng'    Setup ASDC Catalog Resource CDS Properties    ${catalog_resource_id}

    ${catalog_resource_id}=   Certify ASDC Catalog Resource    ${catalog_resource_id}  ${ASDC_DESIGNER_USER_ID}
    [Return]    ${catalog_resource_id}


Setup SDC Catalog Resource Deployment Artifact Properties
    [Documentation]    Set up Deployment Artiface properties
    [Arguments]    ${catalog_service_id}    ${catalog_parent_service_id}   ${catalog_resource_unique_id}  ${blueprint_file}
    ${resp}=    Get ASDC Catalog Resource Component Instances Properties  ${catalog_service_id}
    #${resp}=    Get ASDC Catalog Resource Deployment Artifact Properties  ${catalog_service_id}
    ${blueprint_data}    OperatingSystem.Get File    ${SDC_CATALOG_DEPLOYMENT_ARTIFACT_PATH}${blueprint_file}
    ${payloadData}=   Evaluate   base64.b64encode('''${blueprint_data}'''.encode('utf-8'))   modules=base64
    ${dict}=    Create Dictionary  artifactLabel=blueprint  artifactName=${blueprint_file}   artifactType=DCAE_INVENTORY_BLUEPRINT  artifactGroupType=DEPLOYMENT  description=${blueprint_file}   payloadData=${payloadData}
    ${data}=   Fill JSON Template File    ${ASDC_ARTIFACT_UPLOAD_TEMPLATE}    ${dict}
    # POST artifactUpload to resource
    ${artifact_upload_path}=    Catenate  ${ASDC_CATALOG_SERVICES_PATH}/${catalog_service_id}/resourceInstance/${catalog_resource_unique_id}${ASDC_CATALOG_SERVICE_RESOURCE_ARTIFACT_PATH}
    ${resp}=    Run ASDC MD5 Post Request    ${artifact_upload_path}    ${data}   ${ASDC_DESIGNER_USER_ID}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp}


Setup SDC Catalog Resource GenericNeutronNet Properties
    [Documentation]    Set up GenericNeutronNet properties and inputs
    [Arguments]    ${catalog_service_id}    ${nf_role}    ${catalog_parent_service_id}
    ${resp}=    Get ASDC Catalog Resource Component Instances Properties  ${catalog_service_id}
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
    \    ${data}=   Fill JSON Template File    ${SDC_CATALOG_NET_RESOURCE_INPUT_TEMPLATE}    ${dict}
    \    ${response}=    Set ASDC Catalog Resource Component Instance Properties    ${catalog_parent_service_id}    ${catalog_service_id}    ${data}


Setup SDC Catalog Resource AllottedResource Properties
    [Documentation]    Set up Allotted Resource properties and inputs
    [Arguments]    ${catalog_service_id}    ${nf_role}    ${catalog_resource_id}   ${invariantUUID}   ${UUID}     ${node_type}
    # Set component instances properties
    ${nf_role_lc}=   Convert To Lowercase   ${nf_role}
    ${resp}=    Get ASDC Catalog Resource Component Instances Properties For Resource     ${catalog_resource_id}
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
    ${data}=   Fill JSON Template File    ${SDC_CATALOG_ALLOTTED_RESOURCE_PROPERTIES_TEMPLATE}    ${dict}
    ${response}=    Set ASDC Catalog Resource Component Instance Properties For Resource    ${catalog_resource_id}    ${componentInstance1}    ${data}
    Log To Console    resp=${response}


Setup SDC Catalog Resource AllottedResource Inputs
    [Documentation]    Set up Allotted Resource inputs
    [Arguments]    ${catalog_service_id}    ${nf_role}    ${catalog_resource_id}
    # Set vnf inputs
    ${resp}=    Get ASDC Catalog Resource Inputs    ${catalog_resource_id}
    ${dict}=    Create Dictionary
    :FOR    ${comp}    IN    @{resp['inputs']}
    \    ${name}    Set Variable    ${comp['name']}
    \    ${uid}    Set Variable    ${comp['uniqueId']}
    \    Run Keyword If    '${name}'=='nf_type'    Set To Dictionary    ${dict}    nf_type=${nf_role}    nf_type_uid=${uid}
    \    Run Keyword If    '${name}'=='nf_role'    Set To Dictionary    ${dict}    nf_role=${nf_role}   nf_role_uid=${uid}
    ${data}=   Fill JSON Template File    ${SDC_CATALOG_ALLOTTED_RESOURCE_INPUTS_TEMPLATE}    ${dict}
    ${response}=    Set ASDC Catalog Resource VNF Inputs    ${catalog_resource_id}    ${data}
    [Return]    ${response}

Setup ASDC Catalog Resource CDS Properties
    [Documentation]    Set up vfwng VNF properties and inputs for CDS
    [Arguments]    ${catalog_resource_id}
    # Set vnf module properties
    ${resp}=    Get ASDC Catalog Resource Component Instances   ${catalog_resource_id}
    :FOR    ${comp}    IN    @{resp['componentInstances']}
    \    ${name}    Set Variable   ${comp['name']}
    \    ${uniqueId}    Set Variable    ${comp['uniqueId']}
    \    ${actualComponentUid}    Set Variable    ${comp['actualComponentUid']}
    \    ${test}    ${v}=    Run Keyword and Ignore Error    Should Contain    ${name}    abstract_
    \    Run Keyword If    '${test}' == 'FAIL'    Continue For Loop
    \    ${response}=    Get ASDC Catalog Resource Component Instance Properties    ${catalog_resource_id}    ${uniqueId}    ${actualComponentUid}
    \    ${dict}=    Create Dictionary    parent_id=${response[6]['parentUniqueId']}
    \    Run Keyword If   '${name}'=='abstract_vfw'   Set To Dictionary    ${dict}    nfc_function=vfw    nfc_naming_policy=SDNC_Policy.ONAP_VFW_NAMING_TIMESTAMP
    \    Run Keyword If   '${name}'=='abstract_vpg'   Set To Dictionary    ${dict}    nfc_function=vpg    nfc_naming_policy=SDNC_Policy.ONAP_VPG_NAMING_TIMESTAMP
    \    Run Keyword If   '${name}'=='abstract_vsn'   Set To Dictionary    ${dict}    nfc_function=vsn    nfc_naming_policy=SDNC_Policy.ONAP_VSN_NAMING_TIMESTAMP
    \    ${data}=   Fill JSON Template File    ${ASDC_RESOURCE_INSTANCE_VNF_PROPERTIES_TEMPLATE}    ${dict}
    \    ${response}=    Set ASDC Catalog Resource Component Instance Properties    ${catalog_resource_id}    ${uniqueId}    ${data}
    \    Log To Console    resp=${response}

    # Set vnf inputs
    ${resp}=    Get ASDC Catalog Resource Inputs    ${catalog_resource_id}
    ${dict}=    Create Dictionary
    :FOR    ${comp}    IN    @{resp['inputs']}
    \    ${name}    Set Variable    ${comp['name']}
    \    ${uid}    Set Variable    ${comp['uniqueId']}
    \    Run Keyword If    '${name}'=='nf_function'    Set To Dictionary    ${dict}    nf_function=ONAP-FIREWALL    nf_function_uid=${uid}
    \    Run Keyword If    '${name}'=='nf_type'    Set To Dictionary    ${dict}    nf_type=FIREWALL    nf_type_uid=${uid}
    \    Run Keyword If    '${name}'=='nf_naming_code'    Set To Dictionary    ${dict}    nf_naming_code=vfw    nf_naming_code_uid=${uid}
    \    Run Keyword If    '${name}'=='nf_role'    Set To Dictionary    ${dict}    nf_role=vFW    nf_role_uid=${uid}
    \    Run Keyword If    '${name}'=='cloud_env'    Set To Dictionary    ${dict}    cloud_env=openstack    cloud_env_uid=${uid}
    ${data}=   Fill JSON Template File    ${ASDC_RESOURCE_INSTANCE_VNF_INPUTS_TEMPLATE}    ${dict}
    ${response}=    Set ASDC Catalog Resource VNF Inputs    ${catalog_resource_id}    ${data}

Add ASDC License Model
    [Documentation]    Creates an ASDC License Model and returns its id
    ${uuid}=    Generate UUID
    ${shortened_uuid}=     Evaluate    str("${uuid}")[:23]
    ${map}=    Create Dictionary    vendor_name=${shortened_uuid}
    ${data}=   Fill JSON Template File    ${ASDC_LICENSE_MODEL_TEMPLATE}    ${map}
    ${resp}=    Run ASDC Post Request    ${ASDC_VENDOR_LICENSE_MODEL_PATH}    ${data}  ${ASDC_DESIGNER_USER_ID}  ${ASDC_BE_ONBOARD_ENDPOINT}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()['itemId']}    ${resp.json()['version']['id']}
Get ASDC License Model
    [Documentation]    gets an asdc license model by its id
    [Arguments]    ${id}   ${version_id}=0.1
    ${resp}=    Run ASDC Get Request    ${ASDC_VENDOR_LICENSE_MODEL_PATH}/${id}/versions/${version_id}   ${ASDC_DESIGNER_USER_ID}   ${ASDC_BE_ONBOARD_ENDPOINT}
    [Return]    ${resp.json()}

Get ASDC License Models
    [Documentation]    Gets all ASDC License Models
    ${resp}=    Run ASDC Get Request    ${ASDC_VENDOR_LICENSE_MODEL_PATH}   ${ASDC_DESIGNER_USER_ID}   ${ASDC_BE_ONBOARD_ENDPOINT}
    [Return]    ${resp.json()}

Checkin ASDC License Model
    [Documentation]    Checks in an ASDC License Model by its id
    [Arguments]    ${id}   ${version_id}=0.1
    ${map}=    Create Dictionary    action=Checkin
    ${data}=   Fill JSON Template File    ${ASDC_ACTION_TEMPLATE}    ${map}
    ${resp}=    Run ASDC Put Request    ${ASDC_VENDOR_LICENSE_MODEL_PATH}/${id}/versions/${version_id}${ASDC_VENDOR_ACTIONS_PATH}    ${data}   ${ASDC_DESIGNER_USER_ID}  ${ASDC_BE_ONBOARD_ENDPOINT}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()}

Submit ASDC License Model
    [Documentation]    Submits an ASDC License Model by its id
    [Arguments]    ${id}   ${version_id}=0.1
    ${map}=    Create Dictionary    action=Submit
    ${data}=   Fill JSON Template File    ${ASDC_ACTION_TEMPLATE}    ${map}
    ${resp}=    Run ASDC Put Request    ${ASDC_VENDOR_LICENSE_MODEL_PATH}/${id}/versions/${version_id}${ASDC_VENDOR_ACTIONS_PATH}    ${data}   ${ASDC_DESIGNER_USER_ID}   ${ASDC_BE_ONBOARD_ENDPOINT}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()}

Checkin ASDC Software Product
    [Documentation]    Checks in an ASDC Software Product by its id
    [Arguments]    ${id}   ${version_id}=0.1
    ${map}=    Create Dictionary    action=Checkin
    ${data}=   Fill JSON Template File    ${ASDC_ACTION_TEMPLATE}    ${map}
    ${resp}=    Run ASDC Put Request    ${ASDC_VENDOR_SOFTWARE_PRODUCT_PATH}/${id}/versions/${version_id}${ASDC_VENDOR_ACTIONS_PATH}    ${data}  ${ASDC_DESIGNER_USER_ID}   ${ASDC_BE_ONBOARD_ENDPOINT}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()}

Validate ASDC Software Product
    [Documentation]    Validates an ASDC Software Product by its id
    [Arguments]    ${id}   ${version_id}=0.1
    ${data}=   Catenate
    ${resp}=    Run ASDC Put Request    ${ASDC_VENDOR_SOFTWARE_PRODUCT_PATH}/${id}/versions/${version_id}/orchestration-template-candidate/process    ${data}    ${ASDC_DESIGNER_USER_ID}  ${ASDC_BE_ONBOARD_ENDPOINT}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()}

Submit ASDC Software Product
    [Documentation]    Submits an ASDC Software Product by its id
    [Arguments]    ${id}   ${version_id}=0.1
    ${map}=    Create Dictionary    action=Submit
    ${data}=   Fill JSON Template File    ${ASDC_ACTION_TEMPLATE}    ${map}
    ${resp}=    Run ASDC Put Request    ${ASDC_VENDOR_SOFTWARE_PRODUCT_PATH}/${id}/versions/${version_id}${ASDC_VENDOR_ACTIONS_PATH}    ${data}   ${ASDC_DESIGNER_USER_ID}   ${ASDC_BE_ONBOARD_ENDPOINT}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()}

Package ASDC Software Product
    [Documentation]    Creates a package of an ASDC Software Product by its id
    [Arguments]    ${id}   ${version_id}=0.1
    ${map}=    Create Dictionary    action=Create_Package
    ${data}=   Fill JSON Template File    ${ASDC_ACTION_TEMPLATE}    ${map}
    ${resp}=    Run ASDC Put Request    ${ASDC_VENDOR_SOFTWARE_PRODUCT_PATH}/${id}/versions/${version_id}${ASDC_VENDOR_ACTIONS_PATH}    ${data}   ${ASDC_DESIGNER_USER_ID}  ${ASDC_BE_ONBOARD_ENDPOINT}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()}

Add ASDC Entitlement Pool
    [Documentation]    Creates an ASDC Entitlement Pool and returns its id
    [Arguments]    ${license_model_id}   ${version_id}=0.1     ${license_start_date}="01/01/1960"   ${license_end_date}="01/01/1961"
    ${uuid}=    Generate UUID
    ${shortened_uuid}=     Evaluate    str("${uuid}")[:23]
    ${map}=    Create Dictionary    entitlement_pool_name=${shortened_uuid}  license_start_date=${license_start_date}  license_end_date=${license_end_date}
    ${data}=   Fill JSON Template File    ${ASDC_ENTITLEMENT_POOL_TEMPLATE}    ${map}
    ${resp}=    Run ASDC Post Request    ${ASDC_VENDOR_LICENSE_MODEL_PATH}/${license_model_id}/versions/${version_id}${ASDC_VENDOR_ENTITLEMENT_POOL_PATH}     ${data}   ${ASDC_DESIGNER_USER_ID}  ${ASDC_BE_ONBOARD_ENDPOINT}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()['value']}

Get ASDC Entitlement Pool
    [Documentation]    Gets an ASDC Entitlement Pool by its id
    [Arguments]    ${license_model_id}    ${pool_id}
    ${resp}=    Run ASDC Get Request    ${ASDC_VENDOR_LICENSE_MODEL_PATH}/${license_model_id}${ASDC_VENDOR_ENTITLEMENT_POOL_PATH}/${pool_id}  ${ASDC_DESIGNER_USER_ID}   ${ASDC_BE_ONBOARD_ENDPOINT}
    [Return]    ${resp.json()}

Add ASDC License Group
    [Documentation]    Creates an ASDC License Group and returns its id
    [Arguments]    ${license_model_id}   ${version_id}=1.0   ${license_start_date}="01/01/1960"   ${license_end_date}="01/01/1961"
    ${uuid}=    Generate UUID
    ${shortened_uuid}=     Evaluate    str("${uuid}")[:23]
    ${map}=    Create Dictionary    key_group_name=${shortened_uuid}   license_start_date=${license_start_date}  license_end_date=${license_end_date}
    ${data}=   Fill JSON Template File    ${ASDC_KEY_GROUP_TEMPLATE}    ${map}
    ${resp}=    Run ASDC Post Request    ${ASDC_VENDOR_LICENSE_MODEL_PATH}/${license_model_id}/versions/${version_id}${ASDC_VENDOR_KEY_GROUP_PATH}     ${data}   ${ASDC_DESIGNER_USER_ID}   ${ASDC_BE_ONBOARD_ENDPOINT}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()['value']}

Get ASDC License Group
    [Documentation]    Gets an ASDC License Group by its id
    [Arguments]    ${license_model_id}    ${group_id}      ${version_id}
    ${resp}=    Run ASDC Get Request    ${ASDC_VENDOR_LICENSE_MODEL_PATH}/${license_model_id}/versions/${version_id}${ASDC_VENDOR_KEY_GROUP_PATH}/${group_id}   ${ASDC_DESIGNER_USER_ID}   ${ASDC_BE_ONBOARD_ENDPOINT}
    [Return]    ${resp.json()}

Add ASDC Feature Group
    [Documentation]    Creates an ASDC Feature Group and returns its id
    [Arguments]    ${license_model_id}    ${key_group_id}    ${entitlement_pool_id}      ${version_id}=0.1
    ${uuid}=    Generate UUID
    ${shortened_uuid}=     Evaluate    str("${uuid}")[:23]
    ${map}=    Create Dictionary    feature_group_name=${shortened_uuid}    key_group_id=${key_group_id}    entitlement_pool_id=${entitlement_pool_id}   manufacturer_reference_number=mrn${shortened_uuid}
    ${data}=   Fill JSON Template File    ${ASDC_FEATURE_GROUP_TEMPLATE}    ${map}
    ${resp}=    Run ASDC Post Request    ${ASDC_VENDOR_LICENSE_MODEL_PATH}/${license_model_id}/versions/${version_id}${ASDC_VENDOR_FEATURE_GROUP_PATH}     ${data}    ${ASDC_DESIGNER_USER_ID}   ${ASDC_BE_ONBOARD_ENDPOINT}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()['value']}

Get ASDC Feature Group
    [Documentation]    Gets an ASDC Feature Group by its id
    [Arguments]    ${license_model_id}    ${group_id}
    ${resp}=    Run ASDC Get Request    ${ASDC_VENDOR_LICENSE_MODEL_PATH}/${license_model_id}${ASDC_VENDOR_FEATURE_GROUP_PATH}/${group_id}   ${ASDC_DESIGNER_USER_ID}   ${ASDC_BE_ONBOARD_ENDPOINT}
    [Return]    ${resp.json()}

Add ASDC License Agreement
    [Documentation]    Creates an ASDC License Agreement and returns its id
    [Arguments]    ${license_model_id}    ${feature_group_id}      ${version_id}=0.1
    ${uuid}=    Generate UUID
    ${shortened_uuid}=     Evaluate    str("${uuid}")[:23]
    ${map}=    Create Dictionary    license_agreement_name=${shortened_uuid}    feature_group_id=${feature_group_id}
    ${data}=   Fill JSON Template File    ${ASDC_LICENSE_AGREEMENT_TEMPLATE}    ${map}
    ${resp}=    Run ASDC Post Request    ${ASDC_VENDOR_LICENSE_MODEL_PATH}/${license_model_id}/versions/${version_id}${ASDC_VENDOR_LICENSE_AGREEMENT_PATH}     ${data}    ${ASDC_DESIGNER_USER_ID}   ${ASDC_BE_ONBOARD_ENDPOINT}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()['value']}

Get ASDC License Agreement
    [Documentation]    Gets an ASDC License Agreement by its id
    [Arguments]    ${license_model_id}    ${agreement_id}
    ${resp}=    Run ASDC Get Request    ${ASDC_VENDOR_LICENSE_MODEL_PATH}/${license_model_id}${ASDC_VENDOR_LICENSE_AGREEMENT_PATH}/${agreement_id}   ${ASDC_DESIGNER_USER_ID}   ${ASDC_BE_ONBOARD_ENDPOINT}
    [Return]    ${resp.json()}

Add ASDC Software Product
    [Documentation]    Creates an ASDC Software Product and returns its id
    [Arguments]    ${license_agreement_id}    ${feature_group_id}    ${license_model_name}    ${license_model_id}   ${license_model_version_id}  ${name_prefix}
    ${uuid}=    Generate UUID
    ${shortened_uuid}=     Evaluate    str("${uuid}")[:13]
    ${software_product_name}=  Catenate   ${name_prefix}   ${shortened_uuid}
    ${map}=    Create Dictionary    software_product_name=${software_product_name}    feature_group_id=${feature_group_id}    license_agreement_id=${license_agreement_id}    vendor_name=${license_model_name}    vendor_id=${license_model_id}    version_id=${license_model_version_id}
    ${data}=   Fill JSON Template File    ${ASDC_SOFTWARE_PRODUCT_TEMPLATE}    ${map}
    ${resp}=    Run ASDC Post Request    ${ASDC_VENDOR_SOFTWARE_PRODUCT_PATH}     ${data}    ${ASDC_DESIGNER_USER_ID}   ${ASDC_BE_ONBOARD_ENDPOINT}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()['itemId']}   ${resp.json()['version']['id']}

Get ASDC Software Product
    [Documentation]    Gets an ASDC Software Product by its id
    [Arguments]    ${software_product_id}   ${version_id}=0.1
    ${resp}=    Run ASDC Get Request    ${ASDC_VENDOR_SOFTWARE_PRODUCT_PATH}/${software_product_id}/versions/${version_id}   ${ASDC_DESIGNER_USER_ID}  ${ASDC_BE_ONBOARD_ENDPOINT}
    [Return]    ${resp.json()}

Add ASDC Catalog Resource
    [Documentation]    Creates an ASDC Catalog Resource and returns its id
    [Arguments]    ${license_agreement_id}    ${software_product_name}    ${license_model_name}    ${software_product_id}
    ${map}=    Create Dictionary    software_product_id=${software_product_id}    software_product_name=${software_product_name}    license_agreement_id=${license_agreement_id}    vendor_name=${license_model_name}
    ${data}=   Fill JSON Template File    ${ASDC_CATALOG_RESOURCE_TEMPLATE}    ${map}
    ${resp}=    Run ASDC Post Request    ${ASDC_CATALOG_RESOURCES_PATH}     ${data}    ${ASDC_DESIGNER_USER_ID}
    Should Be Equal As Strings  ${resp.status_code}     201
    [Return]    ${resp.json()['uniqueId']}

Add ASDC Allotted Resource Catalog Resource
    [Documentation]    Creates an ASDC Allotted Resource Catalog Resource and returns its id
    [Arguments]    ${license_agreement_id}    ${software_product_name}    ${license_model_name}    ${software_product_id}   ${subcategory}
    ${map}=    Create Dictionary    software_product_id=${software_product_id}    software_product_name=${software_product_name}    license_agreement_id=${license_agreement_id}    vendor_name=${license_model_name}   subcategory=${subcategory}
    ${data}=   Fill JSON Template File    ${ASDC_ALLOTTED_RESOURCE_CATALOG_RESOURCE_TEMPLATE}    ${map}
    ${resp}=    Run ASDC Post Request    ${ASDC_CATALOG_RESOURCES_PATH}     ${data}    ${ASDC_DESIGNER_USER_ID}
    Should Be Equal As Strings  ${resp.status_code}     201
    [Return]    ${resp.json()['uniqueId']}

Mark ASDC Catalog Resource Inactive
    [Documentation]    Marks ASDC Catalog Resource as inactive
    [Arguments]    ${catalog_resource_id}
    ${resp}=    Run ASDC Delete Request    ${ASDC_CATALOG_RESOURCES_PATH}/${catalog_resource_id}     ${ASDC_DESIGNER_USER_ID}
    Should Be Equal As Strings  ${resp.status_code}     204
    [Return]    ${resp}

Delete Inactive ASDC Catalog Resources
    [Documentation]    Delete all ASDC Catalog Resources that are inactive
    ${resp}=    Run ASDC Delete Request    ${ASDC_CATALOG_INACTIVE_RESOURCES_PATH}     ${ASDC_DESIGNER_USER_ID}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()}

Get ASDC Catalog Resource
    [Documentation]    Gets an ASDC Catalog Resource by its id
    [Arguments]    ${catalog_resource_id}
    ${resp}=    Run ASDC Get Request    ${ASDC_CATALOG_RESOURCES_PATH}/${catalog_resource_id}    ${ASDC_DESIGNER_USER_ID}
    [Return]    ${resp.json()}

Get ASDC Catalog Resource Component Instances
    [Documentation]    Gets component instances of an ASDC Catalog Resource by its id
    [Arguments]    ${catalog_resource_id}
    ${resp}=    Run ASDC Get Request    ${ASDC_FE_CATALOG_RESOURCES_PATH}/${catalog_resource_id}/filteredDataByParams?include=componentInstances    ${ASDC_DESIGNER_USER_ID}    ${ASDC_FE_ENDPOINT}
    [Return]    ${resp.json()}

Get ASDC Catalog Resource Deployment Artifact Properties
    [Documentation]    Gets deployment artifact properties of an ASDC Catalog Resource by its id
    [Arguments]    ${catalog_resource_id}
    #${resp}=    Run ASDC Get Request    ${ASDC_CATALOG_SERVICES_PATH}/${catalog_resource_id}/filteredDataByParams?include=componentInstances    ${ASDC_DESIGNER_USER_ID}    ${ASDC_FE_ENDPOINT}
    ${resp}=    Run ASDC Get Request    ${ASDC_CATALOG_SERVICES_PATH}/${catalog_resource_id}/filteredDataByParams?include=deploymentArtifacts    ${ASDC_DESIGNER_USER_ID}    ${ASDC_FE_ENDPOINT}
    [Return]    ${resp.json()}


Get ASDC Catalog Resource Component Instances Properties
    [Documentation]    Gets ASDC Catalog Resource component instances properties by its id
    [Arguments]    ${catalog_resource_id}
    #${resp}=    Run ASDC Get Request    ${ASDC_FE_CATALOG_RESOURCES_PATH}/${catalog_resource_id}/filteredDataByParams?include=componentInstancesProperties    ${ASDC_DESIGNER_USER_ID}    ${ASDC_FE_ENDPOINT}
    ${resp}=    Run ASDC Get Request    ${ASDC_CATALOG_SERVICES_PATH}/${catalog_resource_id}/filteredDataByParams?include=componentInstancesProperties    ${ASDC_DESIGNER_USER_ID}    ${ASDC_BE_ENDPOINT}
    [Return]    ${resp.json()}

Get ASDC Catalog Resource Component Instances Properties For Resource
    [Documentation]    Gets ASDC Catalog Resource component instances properties for a Resource (VF) by its id
    [Arguments]    ${catalog_resource_id}
    ${resp}=    Run ASDC Get Request    ${ASDC_FE_CATALOG_RESOURCES_PATH}/${catalog_resource_id}/filteredDataByParams?include=componentInstancesProperties    ${ASDC_DESIGNER_USER_ID}    ${ASDC_FE_ENDPOINT}
    [Return]    ${resp.json()}

Get ASDC Catalog Resource Inputs
    [Documentation]    Gets ASDC Catalog Resource inputs by its id
    [Arguments]    ${catalog_resource_id}
    ${resp}=    Run ASDC Get Request    ${ASDC_FE_CATALOG_RESOURCES_PATH}/${catalog_resource_id}/filteredDataByParams?include=inputs    ${ASDC_DESIGNER_USER_ID}    ${ASDC_FE_ENDPOINT}
    [Return]    ${resp.json()}

Get ASDC Catalog Resource Component Instance Properties
    [Documentation]    Gets component instance properties of an ASDC Catalog Resource by their ids
    [Arguments]    ${catalog_resource_id}    ${component_instance_id}    ${component_id}
    ${resp}=    Run ASDC Get Request    ${ASDC_FE_CATALOG_RESOURCES_PATH}/${catalog_resource_id}/componentInstances/${component_instance_id}/${component_id}/inputs    ${ASDC_DESIGNER_USER_ID}    ${ASDC_FE_ENDPOINT}
    [Return]    ${resp.json()}

Set ASDC Catalog Resource Component Instance Properties
    [Documentation]    Sets ASDC Catalog Resource component instance properties by ids
    [Arguments]    ${catalog_resource_id}    ${component_parent_service_id}    ${data}
    #${resp}=    Run ASDC Post Request    ${ASDC_FE_CATALOG_RESOURCES_PATH}/${component_parent_service_id}/resourceInstance/${catalog_resource_id}/inputs    ${data}    ${ASDC_DESIGNER_USER_ID}    ${ASDC_FE_ENDPOINT}
    ${resp}=    Run ASDC Post Request    ${ASDC_FE_CATALOG_SERVICES_PATH}/${component_parent_service_id}/resourceInstance/${catalog_resource_id}/properties    ${data}    ${ASDC_DESIGNER_USER_ID}    ${ASDC_FE_ENDPOINT}
    [Return]   ${resp.json()}

Set ASDC Catalog Resource Component Instance Properties For Resource
    [Documentation]    Sets ASDC Resource component instance properties by ids
    [Arguments]    ${catalog_parent_resource_id}    ${catalog_resource_id}    ${data}
    #${resp}=    Run ASDC Post Request    ${ASDC_FE_CATALOG_RESOURCES_PATH}/${catalog_parent_resource_id}/resourceInstance/${catalog_resource_id}/inputs    ${data}    ${ASDC_DESIGNER_USER_ID}    ${ASDC_FE_ENDPOINT}
    ${resp}=    Run ASDC Post Request    ${ASDC_FE_CATALOG_RESOURCES_PATH}/${catalog_parent_resource_id}/resourceInstance/${catalog_resource_id}/properties   ${data}    ${ASDC_DESIGNER_USER_ID}    ${ASDC_FE_ENDPOINT}
    [Return]   ${resp.json()}

Set CDS Catalog Resource Component Instance Properties
    [Documentation]    Sets CDS Catalog Resource component instance properties by ids
    [Arguments]    ${catalog_resource_id}    ${component_instance_id}    ${data}
    ${resp}=    Run ASDC Post Request    ${ASDC_FE_CATALOG_RESOURCES_PATH}/${catalog_resource_id}/resourceInstance/${component_instance_id}/inputs    ${data}    ${ASDC_DESIGNER_USER_ID}    ${ASDC_FE_ENDPOINT}
    [Return]    ${resp.json()}

Set ASDC Catalog Resource VNF Inputs
    [Documentation]    Sets VNF Inputs for an ASDC Catalog Resource by its id
    [Arguments]    ${catalog_resource_id}    ${data}
    ${resp}=    Run ASDC Post Request    ${ASDC_FE_CATALOG_RESOURCES_PATH}/${catalog_resource_id}/update/inputs    ${data}    ${ASDC_DESIGNER_USER_ID}    ${ASDC_FE_ENDPOINT}
    [Return]    ${resp.json()}

Get SDC Demo Vnf Catalog Resource
    [Documentation]  Gets Resource ids of demonstration VNFs for instantiation
    [Arguments]    ${service_name}
    ${resp}=   Run ASDC Get Request    ${ASDC_CATALOG_SERVICES_PATH}/serviceName/${service_name}/serviceVersion/1.0
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

Checkin ASDC Catalog Resource
    [Documentation]    Checks in an ASDC Catalog Resource by its id
    [Arguments]    ${catalog_resource_id}
    ${map}=    Create Dictionary    user_remarks=Robot remarks
    ${data}=   Fill JSON Template File    ${ASDC_USER_REMARKS_TEMPLATE}    ${map}
    ${resp}=    Run ASDC Post Request    ${ASDC_CATALOG_RESOURCES_PATH}/${catalog_resource_id}${ASDC_CATALOG_LIFECYCLE_PATH}/checkin    ${data}    ${ASDC_DESIGNER_USER_ID}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()}

Request Certify ASDC Catalog Resource
    [Documentation]    Requests certification of an ASDC Catalog Resource by its id
    [Arguments]    ${catalog_resource_id}
    ${map}=    Create Dictionary    user_remarks=Robot remarks
    ${data}=   Fill JSON Template File    ${ASDC_USER_REMARKS_TEMPLATE}    ${map}
    ${resp}=    Run ASDC Post Request    ${ASDC_CATALOG_RESOURCES_PATH}/${catalog_resource_id}${ASDC_CATALOG_LIFECYCLE_PATH}/certificationRequest    ${data}    ${ASDC_DESIGNER_USER_ID}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()}

Start Certify ASDC Catalog Resource
    [Documentation]    Start certification of an ASDC Catalog Resource by its id
    [Arguments]    ${catalog_resource_id}
    ${resp}=    Run ASDC Post Request    ${ASDC_CATALOG_RESOURCES_PATH}/${catalog_resource_id}${ASDC_CATALOG_LIFECYCLE_PATH}/startCertification    ${None}    ${ASDC_TESTER_USER_ID}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()}

Certify ASDC Catalog Resource
    [Documentation]    Certifies an ASDC Catalog Resource by its id and returns the new id
    [Arguments]    ${catalog_resource_id}    ${user_id}=${ASDC_TESTER_USER_ID}
    ${map}=    Create Dictionary    user_remarks=Robot remarks
    ${data}=   Fill JSON Template File    ${ASDC_USER_REMARKS_TEMPLATE}    ${map}
    ${resp}=    Run ASDC Post Request    ${ASDC_CATALOG_RESOURCES_PATH}/${catalog_resource_id}${ASDC_CATALOG_LIFECYCLE_PATH}/certify    ${data}    ${user_id}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()['uniqueId']}

Upload ASDC Heat Package
    [Documentation]    Creates an ASDC Software Product and returns its id
    [Arguments]    ${software_product_id}    ${file_path}   ${version_id}=0.1
     ${files}=     Create Dictionary
     Create Multi Part     ${files}  upload  ${file_path}    contentType=application/zip
    ${resp}=    Run ASDC Post Files Request    ${ASDC_VENDOR_SOFTWARE_PRODUCT_PATH}/${software_product_id}/versions/${version_id}${ASDC_VENDOR_SOFTWARE_UPLOAD_PATH}     ${files}    ${ASDC_DESIGNER_USER_ID}   ${ASDC_BE_ONBOARD_ENDPOINT}
        Should Be Equal As Strings      ${resp.status_code}     200

Add ASDC Catalog Service
    [Documentation]    Creates an ASDC Catalog Service and returns its id
    [Arguments]   ${catalog_service_name}
    ${uuid}=    Generate UUID
    ${shortened_uuid}=     Evaluate    str("${uuid}")[:23]
    ${catalog_service_name}=   Set Variable If   '${catalog_service_name}' ==''   ${shortened_uuid}   ${catalog_service_name}
    ${map}=    Create Dictionary    service_name=${catalog_service_name}
    ${data}=   Fill JSON Template File    ${ASDC_CATALOG_SERVICE_TEMPLATE}    ${map}
    ${resp}=    Run ASDC Post Request    ${ASDC_CATALOG_SERVICES_PATH}     ${data}    ${ASDC_DESIGNER_USER_ID}
    Should Be Equal As Strings  ${resp.status_code}     201
    [Return]    ${resp.json()['uniqueId']}

Mark ASDC Catalog Service Inactive
    [Documentation]    Deletes an ASDC Catalog Service
    [Arguments]    ${catalog_service_id}
    ${resp}=    Run ASDC Delete Request    ${ASDC_CATALOG_SERVICES_PATH}/${catalog_service_id}     ${ASDC_DESIGNER_USER_ID}
    Should Be Equal As Strings  ${resp.status_code}     204
    [Return]    ${resp}

Delete Inactive ASDC Catalog Services
    [Documentation]    Delete all ASDC Catalog Services that are inactive
    ${resp}=    Run ASDC Delete Request    ${ASDC_CATALOG_INACTIVE_SERVICES_PATH}     ${ASDC_DESIGNER_USER_ID}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()}

Get ASDC Catalog Service
    [Documentation]    Gets an ASDC Catalog Service by its id
    [Arguments]    ${catalog_service_id}
    ${resp}=    Run ASDC Get Request    ${ASDC_CATALOG_SERVICES_PATH}/${catalog_service_id}    ${ASDC_DESIGNER_USER_ID}
    [Return]    ${resp.json()}

Checkin ASDC Catalog Service
    [Documentation]    Checks in an ASDC Catalog Service by its id
    [Arguments]    ${catalog_service_id}
    ${map}=    Create Dictionary    user_remarks=Robot remarks
    ${data}=   Fill JSON Template File    ${ASDC_USER_REMARKS_TEMPLATE}    ${map}
    ${resp}=    Run ASDC Post Request    ${ASDC_CATALOG_SERVICES_PATH}/${catalog_service_id}${ASDC_CATALOG_LIFECYCLE_PATH}/checkin    ${data}    ${ASDC_DESIGNER_USER_ID}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()}

Request Certify ASDC Catalog Service
    [Documentation]    Requests certification of an ASDC Catalog Service by its id
    [Arguments]    ${catalog_service_id}
    ${map}=    Create Dictionary    user_remarks=Robot remarks
    ${data}=   Fill JSON Template File    ${ASDC_USER_REMARKS_TEMPLATE}    ${map}
    ${resp}=    Run ASDC Post Request    ${ASDC_CATALOG_SERVICES_PATH}/${catalog_service_id}${ASDC_CATALOG_LIFECYCLE_PATH}/certificationRequest    ${data}    ${ASDC_DESIGNER_USER_ID}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()}

Start Certify ASDC Catalog Service
    [Documentation]    Start certification of an ASDC Catalog Service by its id
    [Arguments]    ${catalog_service_id}
    ${resp}=    Run ASDC Post Request    ${ASDC_CATALOG_SERVICES_PATH}/${catalog_service_id}${ASDC_CATALOG_LIFECYCLE_PATH}/startCertification    ${None}    ${ASDC_TESTER_USER_ID}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()}

Certify ASDC Catalog Service
    [Documentation]    Certifies an ASDC Catalog Service by its id and returns the new id
    [Arguments]    ${catalog_service_id}
    ${map}=    Create Dictionary    user_remarks=Robot remarks
    ${data}=   Fill JSON Template File    ${ASDC_USER_REMARKS_TEMPLATE}    ${map}
    ${resp}=    Run ASDC Post Request    ${ASDC_CATALOG_SERVICES_PATH}/${catalog_service_id}${ASDC_CATALOG_LIFECYCLE_PATH}/certify    ${data}    ${ASDC_TESTER_USER_ID}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()['uniqueId']}

Approve ASDC Catalog Service
    [Documentation]    Approves an ASDC Catalog Service by its id
    [Arguments]    ${catalog_service_id}
    ${map}=    Create Dictionary    user_remarks=Robot remarks
    ${data}=   Fill JSON Template File    ${ASDC_USER_REMARKS_TEMPLATE}    ${map}
    ${resp}=    Run ASDC Post Request    ${ASDC_CATALOG_SERVICES_PATH}/${catalog_service_id}${ASDC_CATALOG_SERVICE_DISTRIBUTION_STATE_PATH}${ASDC_DISTRIBUTION_STATE_APPROVE_PATH}    ${data}    ${ASDC_GOVERNOR_USER_ID}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()}
Distribute ASDC Catalog Service
    [Documentation]    distribute an asdc Catalog Service by its id
    [Arguments]    ${catalog_service_id}
    ${resp}=    Run ASDC Post Request    ${ASDC_CATALOG_SERVICES_PATH}/${catalog_service_id}${ASDC_CATALOG_SERVICE_DISTRIBUTION_ACTIVATE_PATH}    ${None}    ${ASDC_OPS_USER_ID}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()}

Add ASDC Resource Instance
    [Documentation]    Creates an ASDC Resource Instance and returns its id
    [Arguments]    ${catalog_service_id}    ${catalog_resource_id}    ${catalog_resource_name}  ${xoffset}=${0}   ${yoffset}=${0}   ${resourceType}=VF
    ${milli_timestamp}=    Generate MilliTimestamp UUID
    ${xoffset}=    Set Variable   ${xoffset+306}
    ${yoffset}=    Set Variable   ${yoffset+248}
    ${map}=    Create Dictionary    catalog_resource_id=${catalog_resource_id}    catalog_resource_name=${catalog_resource_name}    milli_timestamp=${milli_timestamp}   posX=${xoffset}    posY=${yoffset}    originType=${resourceType}
    ${data}=   Fill JSON Template File    ${ASDC_RESOURCE_INSTANCE_TEMPLATE}    ${map}
    ${resp}=    Run ASDC Post Request    ${ASDC_CATALOG_SERVICES_PATH}/${catalog_service_id}${ASDC_CATALOG_SERVICE_RESOURCE_INSTANCE_PATH}     ${data}    ${ASDC_DESIGNER_USER_ID}
    Should Be Equal As Strings  ${resp.status_code}     201
    [Return]    ${resp.json()['uniqueId']}

Add ASDC Resource Instance To Resource
    [Documentation]    Creates an ASDC Resource Instance in a Resource (VF) and returns its id
    [Arguments]    ${parent_catalog_resource_id}    ${catalog_resource_id}    ${catalog_resource_name}  ${xoffset}=${0}   ${yoffset}=${0}    ${resourceType}=VF
    ${milli_timestamp}=    Generate MilliTimestamp UUID
    ${xoffset}=    Set Variable   ${xoffset+306}
    ${yoffset}=    Set Variable   ${yoffset+248}
    ${map}=    Create Dictionary    catalog_resource_id=${catalog_resource_id}    catalog_resource_name=${catalog_resource_name}    milli_timestamp=${milli_timestamp}   posX=${xoffset}    posY=${yoffset}    originType=${resourceType}
    ${data}=   Fill JSON Template File    ${ASDC_RESOURCE_INSTANCE_TEMPLATE}    ${map}
    ${resp}=    Run ASDC Post Request    ${ASDC_CATALOG_RESOURCES_PATH}/${parent_catalog_resource_id}${ASDC_CATALOG_SERVICE_RESOURCE_INSTANCE_PATH}     ${data}    ${ASDC_DESIGNER_USER_ID}
    Should Be Equal As Strings  ${resp.status_code}     201
    [Return]    ${resp.json()['uniqueId']}

Get Catalog Service Distribution
    [Documentation]    Gets an ASDC Catalog Service distribution
    [Arguments]    ${catalog_service_uuid}
    ${resp}=    Run ASDC Get Request    ${ASDC_CATALOG_SERVICES_PATH}/${catalog_service_uuid}${ASDC_CATALOG_SERVICE_DISTRIBUTION_PATH}    ${ASDC_OPS_USER_ID}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()}

Check Catalog Service Distributed
    [Documentation]    Checks if an ASDC Catalog Service is distributed
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
    [Documentation]    Gets ASDC Catalog Service distribution details
    [Arguments]    ${catalog_service_distribution_id}
    ${resp}=    Run ASDC Get Request    ${ASDC_CATALOG_SERVICES_PATH}${ASDC_CATALOG_SERVICE_DISTRIBUTION_PATH}/${catalog_service_distribution_id}    ${ASDC_OPS_USER_ID}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()}
Run ASDC Health Check
    [Documentation]    Runs a ASDC health check
    ${session}=    Create Session       asdc    ${ASDC_FE_ENDPOINT}
    ${uuid}=    Generate UUID
    ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json    X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}
    ${resp}=    Get Request     asdc    ${ASDC_HEALTH_CHECK_PATH}     headers=${headers}
    # only test for HTTP 200 to determine SDC Health. SDC_DE_HEALTH is informational
    Should Be Equal As Strings  ${resp.status_code}     200    SDC DOWN
    ${SDC_DE_HEALTH}=    Catenate   DOWN
    @{ITEMS}=    Copy List    ${resp.json()['componentsInfo']}
    :FOR    ${ELEMENT}    IN    @{ITEMS}
    \    Log    ${ELEMENT['healthCheckStatus']}
    \    ${SDC_DE_HEALTH}  Set Variable If   (('DE' in '${ELEMENT['healthCheckComponent']}') and ('${ELEMENT['healthCheckStatus']}' == 'UP')) or ('${SDC_DE_HEALTH}'=='UP')  UP
    Log To Console   (DMaaP:${SDC_DE_HEALTH})    no_newline=true
Run ASDC Get Request
    [Documentation]    Runs an ASDC get request
    [Arguments]    ${data_path}    ${user}=${ASDC_DESIGNER_USER_ID}  ${MY_ASDC_BE_ENDPOINT}=${ASDC_BE_ENDPOINT}
    ${auth}=  Create List  ${GLOBAL_ASDC_BE_USERNAME}    ${GLOBAL_ASDC_BE_PASSWORD}
    Log    Creating session ${MY_ASDC_BE_ENDPOINT}
    ${session}=    Create Session       asdc    ${MY_ASDC_BE_ENDPOINT}    auth=${auth}
    ${uuid}=    Generate UUID
    ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json    USER_ID=${user}    X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}
    ${resp}=    Get Request     asdc    ${data_path}     headers=${headers}
    Log    Received response from asdc ${resp.text}
    [Return]    ${resp}
Run ASDC Put Request
    [Documentation]    Runs an ASDC put request
    [Arguments]    ${data_path}    ${data}    ${user}=${ASDC_DESIGNER_USER_ID}   ${MY_ASDC_BE_ENDPOINT}=${ASDC_BE_ENDPOINT}
    ${auth}=  Create List  ${GLOBAL_ASDC_BE_USERNAME}    ${GLOBAL_ASDC_BE_PASSWORD}
    Log    Creating session ${MY_ASDC_BE_ENDPOINT}
    ${session}=    Create Session       asdc    ${MY_ASDC_BE_ENDPOINT}    auth=${auth}
    ${uuid}=    Generate UUID
    ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json    USER_ID=${user}    X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}
    ${resp}=    Put Request     asdc    ${data_path}     data=${data}    headers=${headers}
    Log    Received response from asdc ${resp.text}
    [Return]    ${resp}

Run ASDC Post Files Request
    [Documentation]    Runs an ASDC post request
    [Arguments]    ${data_path}    ${files}    ${user}=${ASDC_DESIGNER_USER_ID}   ${MY_ASDC_BE_ENDPOINT}=${ASDC_BE_ENDPOINT}
    ${auth}=  Create List  ${GLOBAL_ASDC_BE_USERNAME}    ${GLOBAL_ASDC_BE_PASSWORD}
    Log    Creating session ${MY_ASDC_BE_ENDPOINT}
    ${session}=    Create Session       asdc    ${MY_ASDC_BE_ENDPOINT}    auth=${auth}
    ${uuid}=    Generate UUID
    ${headers}=  Create Dictionary     Accept=application/json    Content-Type=multipart/form-data    USER_ID=${user}    X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}
    ${resp}=    Post Request    asdc    ${data_path}     files=${files}    headers=${headers}
    Log    Received response from asdc ${resp.text}
    [Return]    ${resp}

Run ASDC MD5 Post Request
    [Documentation]    Runs an ASDC post request with MD5 Checksum header
    [Arguments]    ${data_path}    ${data}    ${user}=${ASDC_DESIGNER_USER_ID}   ${MY_ASDC_BE_ENDPOINT}=${ASDC_BE_ENDPOINT}
    ${auth}=  Create List  ${GLOBAL_ASDC_BE_USERNAME}    ${GLOBAL_ASDC_BE_PASSWORD}
    Log    Creating session ${MY_ASDC_BE_ENDPOINT}
    ${session}=    Create Session       asdc    ${MY_ASDC_BE_ENDPOINT}    auth=${auth}
    ${uuid}=    Generate UUID
    ${data_string}=   Evaluate    json.dumps(${data})     json
    ${md5checksum}=   Evaluate    md5.new('''${data_string}''').hexdigest()   modules=md5
    ${base64md5checksum}=  Evaluate     base64.b64encode("${md5checksum}")     modules=base64
    ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json    USER_ID=${user}    X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}   Content-MD5=${base64md5checksum}
    ${resp}=    Post Request    asdc    ${data_path}     data=${data}    headers=${headers}
    Log    Received response from asdc ${resp.text}
    [Return]    ${resp}

Run ASDC Post Request
    [Documentation]    Runs an ASDC post request
    [Arguments]    ${data_path}    ${data}    ${user}=${ASDC_DESIGNER_USER_ID}   ${MY_ASDC_BE_ENDPOINT}=${ASDC_BE_ENDPOINT}
    ${auth}=  Create List  ${GLOBAL_ASDC_BE_USERNAME}    ${GLOBAL_ASDC_BE_PASSWORD}
    Log    Creating session ${MY_ASDC_BE_ENDPOINT}
    ${session}=    Create Session       asdc    ${MY_ASDC_BE_ENDPOINT}    auth=${auth}
    ${uuid}=    Generate UUID
    ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json    USER_ID=${user}    X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}
    ${resp}=    Post Request    asdc    ${data_path}     data=${data}    headers=${headers}
    Log    Received response from asdc ${resp.text}
    [Return]    ${resp}

Run ASDC Delete Request
    [Documentation]    Runs an ASDC delete request
    [Arguments]    ${data_path}    ${user}=${ASDC_DESIGNER_USER_ID}  ${MY_ASDC_BE_ENDPOINT}=${ASDC_BE_ENDPOINT}
    ${auth}=  Create List  ${GLOBAL_ASDC_BE_USERNAME}    ${GLOBAL_ASDC_BE_PASSWORD}
    Log    Creating session ${MY_ASDC_BE_ENDPOINT}
    ${session}=    Create Session       asdc    ${MY_ASDC_BE_ENDPOINT}    auth=${auth}
    ${uuid}=    Generate UUID
    ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json    USER_ID=${user}    X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}
    ${resp}=    Delete Request  asdc    ${data_path}        headers=${headers}
    Log    Received response from asdc ${resp.text}
    [Return]    ${resp}
Open ASDC GUI
    [Documentation]   Logs in to ASDC GUI
    [Arguments]    ${PATH}
    ## Setup Browever now being managed by the test case
    ##Setup Browser
    Go To    ${ASDC_FE_ENDPOINT}${PATH}
    Maximize Browser Window

    Set Browser Implicit Wait    ${GLOBAL_SELENIUM_BROWSER_IMPLICIT_WAIT}
    Log    Logging in to ${ASDC_FE_ENDPOINT}${PATH}
    Title Should Be    ASDC
    Wait Until Page Contains Element    xpath=//div/a[text()='SDC']    ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT}
    Log    Logged in to ${ASDC_FE_ENDPOINT}${PATH}


Create Multi Part
   [Arguments]  ${addTo}  ${partName}  ${filePath}  ${contentType}=${None}
   ${fileData}=   Get Binary File  ${filePath}
   ${fileDir}  ${fileName}=  Split Path  ${filePath}
   ${partData}=  Create List  ${fileName}  ${fileData}  ${contentType}
   Set To Dictionary  ${addTo}  ${partName}=${partData}

