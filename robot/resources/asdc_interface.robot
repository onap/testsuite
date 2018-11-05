*** Settings ***
Documentation     The main interface for interacting with ASDC. It handles low level stuff like managing the http request library and DCAE required fields
Library 	      RequestsLibrary
Library	          UUID
Library	          JSONUtils
Library           OperatingSystem
Library           Collections
Library 	      ExtendedSelenium2Library
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
${ASDC_CATALOG_RESOURCES_PATH}    /sdc2/rest/v1/catalog/resources
${ASDC_CATALOG_SERVICES_PATH}    /sdc2/rest/v1/catalog/services
${ASDC_CATALOG_INACTIVE_RESOURCES_PATH}    /sdc2/rest/v1/inactiveComponents/resource
${ASDC_CATALOG_INACTIVE_SERVICES_PATH}    /sdc2/rest/v1/inactiveComponents/service
${ASDC_CATALOG_LIFECYCLE_PATH}    /lifecycleState
${ASDC_CATALOG_SERVICE_RESOURCE_INSTANCE_PATH}    /resourceInstance
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
${ASDC_CATALOG_RESOURCE_TEMPLATE}    robot/assets/templates/asdc/catalog_resource.template
${ASDC_USER_REMARKS_TEMPLATE}    robot/assets/templates/asdc/user_remarks.template
${ASDC_CATALOG_SERVICE_TEMPLATE}    robot/assets/templates/asdc/catalog_service.template
${ASDC_RESOURCE_INSTANCE_TEMPLATE}    robot/assets/templates/asdc/resource_instance.template
${ASDC_RESOURCE_INSTANCE_VNF_PROPERTIES_TEMPLATE}    robot/assets/templates/asdc/catalog_vnf_properties.template
${ASDC_RESOURCE_INSTANCE_VNF_INPUTS_TEMPLATE}    robot/assets/templates/asdc/catalog_vnf_inputs.template
${ASDC_FE_ENDPOINT}     ${GLOBAL_ASDC_SERVER_PROTOCOL}://${GLOBAL_INJECTED_SDC_FE_IP_ADDR}:${GLOBAL_ASDC_FE_PORT}
${ASDC_BE_ENDPOINT}     ${GLOBAL_ASDC_SERVER_PROTOCOL}://${GLOBAL_INJECTED_SDC_BE_IP_ADDR}:${GLOBAL_ASDC_BE_PORT}
${ASDC_BE_ONBOARD_ENDPOINT}     ${GLOBAL_ASDC_SERVER_PROTOCOL}://${GLOBAL_INJECTED_SDC_BE_ONBOARD_IP_ADDR}:${GLOBAL_ASDC_BE_ONBOARD_PORT}

*** Keywords ***
Distribute Model From ASDC
    [Documentation]    goes end to end creating all the asdc objects based ona  model and distributing it to the systems. it then returns the service name, vf name and vf module name
    [Arguments]    ${model_zip_path}   ${catalog_service_name}=    ${cds}=
    ${catalog_service_id}=    Add ASDC Catalog Service    ${catalog_service_name}
    ${catalog_resource_ids}=    Create List
    ${catalog_resources}=   Create Dictionary
    : FOR    ${zip}     IN     @{model_zip_path}
    \    ${loop_catalog_resource_id}=    Setup ASDC Catalog Resource    ${zip}    ${cds}
    \    Append To List    ${catalog_resource_ids}   ${loop_catalog_resource_id}
    \    ${loop_catalog_resource_resp}=    Get ASDC Catalog Resource    ${loop_catalog_resource_id}
    \    Add ASDC Resource Instance    ${catalog_service_id}    ${loop_catalog_resource_id}    ${loop_catalog_resource_resp['name']}
    \    Set To Dictionary    ${catalog_resources}   ${loop_catalog_resource_id}=${loop_catalog_resource_resp}
    ${catalog_service_resp}=    Get ASDC Catalog Service    ${catalog_service_id}
    Checkin ASDC Catalog Service    ${catalog_service_id}
    Request Certify ASDC Catalog Service    ${catalog_service_id}
    Start Certify ASDC Catalog Service    ${catalog_service_id}
    # on certify it gets a new id
    ${catalog_service_id}=    Certify ASDC Catalog Service    ${catalog_service_id}
    Approve ASDC Catalog Service    ${catalog_service_id}
        : FOR   ${DIST_INDEX}    IN RANGE   1
        \   Log     Distribution Attempt ${DIST_INDEX}
        \   Distribute ASDC Catalog Service    ${catalog_service_id}
        \   ${catalog_service_resp}=    Get ASDC Catalog Service    ${catalog_service_id}
        \   ${vf_module}=    Find Element In Array    ${loop_catalog_resource_resp['groups']}    type    org.openecomp.groups.VfModule
        \   ${status}   ${_} =   Run Keyword And Ignore Error   Loop Over Check Catalog Service Distributed       ${catalog_service_resp['uuid']}
	\   Exit For Loop If   '${status}'=='PASS'
        Should Be Equal As Strings  ${status}  PASS
    [Return]    ${catalog_service_resp['name']}    ${loop_catalog_resource_resp['name']}    ${vf_module}   ${catalog_resource_ids}    ${catalog_service_id}   ${catalog_resources}

Loop Over Check Catalog Service Distributed
    [Arguments]    ${catalog_service_id}
    # SO watchdog timeout is 300 seconds need buffer
    ${dist_status}=   Set Variable    FAIL
    : FOR     ${CHECK_INDEX}  IN RANGE   20
    \   ${status}   ${_} =   Run Keyword And Ignore Error     Check Catalog Service Distributed    ${catalog_service_id}    ${dist_status}
    \   Sleep     20s
    \   Return From Keyword If   '${status}'=='PASS'
    \   Exit For Loop If   '${dist_status}'=='EXIT'
    Should Be Equal As Strings  ${status}   PASS 

Setup ASDC Catalog Resource
    [Documentation]    Creates all the steps a vf needs for an asdc catalog resource and returns the id
    [Arguments]    ${model_zip_path}    ${cds}=
    ${license_model_id}   ${license_model_version_id}=    Add ASDC License Model
    ${key_group_id}=    Add ASDC License Group    ${license_model_id}   ${license_model_version_id}
    ${pool_id}=    Add ASDC Entitlement Pool    ${license_model_id}   ${license_model_version_id}
    ${feature_group_id}=    Add ASDC Feature Group    ${license_model_id}    ${key_group_id}    ${pool_id}  ${license_model_version_id}
    ${license_agreement_id}=    Add ASDC License Agreement    ${license_model_id}    ${feature_group_id}   ${license_model_version_id}
    Submit ASDC License Model    ${license_model_id}   ${license_model_version_id}
    ${license_model_resp}=    Get ASDC License Model    ${license_model_id}   ${license_model_version_id}
    ${software_product_id}   ${software_product_version_id}=    Add ASDC Software Product    ${license_agreement_id}    ${feature_group_id}    ${license_model_resp['vendorName']}    ${license_model_id}    ${license_model_version_id}
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
Setup ASDC Catalog Resource CDS Properties
    [Documentation]    Set up vfwng VNF properties and inputs for CDS
    [Arguments]    ${catalog_resource_id} 
    # Set vnf module properties
    ${resp}=    Get ASDC Catalog Resource Component Instances   ${catalog_resource_id}
    :FOR    ${comp}    in    @{resp['componentInstances']}
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
    :FOR    ${comp}    in    @{resp['inputs']} 
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
    [Documentation]    Creates an asdc license model and returns its id
    ${uuid}=    Generate UUID
    ${shortened_uuid}=     Evaluate    str("${uuid}")[:23]
    ${map}=    Create Dictionary    vendor_name=${shortened_uuid}
    ${data}=   Fill JSON Template File    ${ASDC_LICENSE_MODEL_TEMPLATE}    ${map}
    ${resp}=    Run ASDC Post Request    ${ASDC_VENDOR_LICENSE_MODEL_PATH}    ${data}  ${ASDC_DESIGNER_USER_ID}  ${ASDC_BE_ONBOARD_ENDPOINT}
    Should Be Equal As Strings 	${resp.status_code} 	200
    [Return]    ${resp.json()['itemId']}    ${resp.json()['version']['id']}
Get ASDC License Model
    [Documentation]    gets an asdc license model by its id
    [Arguments]    ${id}   ${version_id}=0.1
    ${resp}=    Run ASDC Get Request    ${ASDC_VENDOR_LICENSE_MODEL_PATH}/${id}/versions/${version_id}   ${ASDC_DESIGNER_USER_ID}   ${ASDC_BE_ONBOARD_ENDPOINT}
    [Return]    ${resp.json()}
Get ASDC License Models
    [Documentation]    gets an asdc license model by its id
    ${resp}=    Run ASDC Get Request    ${ASDC_VENDOR_LICENSE_MODEL_PATH}   ${ASDC_DESIGNER_USER_ID}   ${ASDC_BE_ONBOARD_ENDPOINT}

    [Return]    ${resp.json()}
Checkin ASDC License Model
    [Documentation]    checksin an asdc license model by its id
    [Arguments]    ${id}   ${version_id}=0.1
    ${map}=    Create Dictionary    action=Checkin
    ${data}=   Fill JSON Template File    ${ASDC_ACTION_TEMPLATE}    ${map}
    ${resp}=    Run ASDC Put Request    ${ASDC_VENDOR_LICENSE_MODEL_PATH}/${id}/versions/${version_id}${ASDC_VENDOR_ACTIONS_PATH}    ${data}   ${ASDC_DESIGNER_USER_ID}  ${ASDC_BE_ONBOARD_ENDPOINT} 
    Should Be Equal As Strings 	${resp.status_code} 	200
    [Return]    ${resp.json()}
Submit ASDC License Model
    [Documentation]    submits an asdc license model by its id
    [Arguments]    ${id}   ${version_id}=0.1
    ${map}=    Create Dictionary    action=Submit
    ${data}=   Fill JSON Template File    ${ASDC_ACTION_TEMPLATE}    ${map}
    ${resp}=    Run ASDC Put Request    ${ASDC_VENDOR_LICENSE_MODEL_PATH}/${id}/versions/${version_id}${ASDC_VENDOR_ACTIONS_PATH}    ${data}   ${ASDC_DESIGNER_USER_ID}   ${ASDC_BE_ONBOARD_ENDPOINT}
    Should Be Equal As Strings 	${resp.status_code} 	200
    [Return]    ${resp.json()}
Checkin ASDC Software Product
    [Documentation]    checksin an asdc Software Product by its id
    [Arguments]    ${id}   ${version_id}=0.1
    ${map}=    Create Dictionary    action=Checkin
    ${data}=   Fill JSON Template File    ${ASDC_ACTION_TEMPLATE}    ${map}
    ${resp}=    Run ASDC Put Request    ${ASDC_VENDOR_SOFTWARE_PRODUCT_PATH}/${id}/versions/${version_id}${ASDC_VENDOR_ACTIONS_PATH}    ${data}  ${ASDC_DESIGNER_USER_ID}   ${ASDC_BE_ONBOARD_ENDPOINT}
    Should Be Equal As Strings 	${resp.status_code} 	200
    [Return]    ${resp.json()}
Validate ASDC Software Product
    [Documentation]    checksin an asdc Software Product by its id
    [Arguments]    ${id}   ${version_id}=0.1
    ${data}=   Catenate
    ${resp}=    Run ASDC Put Request    ${ASDC_VENDOR_SOFTWARE_PRODUCT_PATH}/${id}/versions/${version_id}/orchestration-template-candidate/process    ${data}    ${ASDC_DESIGNER_USER_ID}  ${ASDC_BE_ONBOARD_ENDPOINT} 
    Should Be Equal As Strings 	${resp.status_code} 	200
    [Return]    ${resp.json()}
Submit ASDC Software Product
    [Documentation]    submits an asdc Software Product by its id
    [Arguments]    ${id}   ${version_id}=0.1
    ${map}=    Create Dictionary    action=Submit
    ${data}=   Fill JSON Template File    ${ASDC_ACTION_TEMPLATE}    ${map}
    ${resp}=    Run ASDC Put Request    ${ASDC_VENDOR_SOFTWARE_PRODUCT_PATH}/${id}/versions/${version_id}${ASDC_VENDOR_ACTIONS_PATH}    ${data}   ${ASDC_DESIGNER_USER_ID}   ${ASDC_BE_ONBOARD_ENDPOINT} 
    Should Be Equal As Strings 	${resp.status_code} 	200
    [Return]    ${resp.json()}
Package ASDC Software Product
    [Documentation]    creates_package on an asdc Software Product by its id
    [Arguments]    ${id}   ${version_id}=0.1
    ${map}=    Create Dictionary    action=Create_Package
    ${data}=   Fill JSON Template File    ${ASDC_ACTION_TEMPLATE}    ${map}
    ${resp}=    Run ASDC Put Request    ${ASDC_VENDOR_SOFTWARE_PRODUCT_PATH}/${id}/versions/${version_id}${ASDC_VENDOR_ACTIONS_PATH}    ${data}   ${ASDC_DESIGNER_USER_ID}  ${ASDC_BE_ONBOARD_ENDPOINT} 
    Should Be Equal As Strings 	${resp.status_code} 	200
    [Return]    ${resp.json()}
Add ASDC Entitlement Pool
    [Documentation]    Creates an asdc Entitlement Pool and returns its id
    [Arguments]    ${license_model_id}   ${version_id}=0.1
    ${uuid}=    Generate UUID
    ${shortened_uuid}=     Evaluate    str("${uuid}")[:23]
    ${map}=    Create Dictionary    entitlement_pool_name=${shortened_uuid}
    ${data}=   Fill JSON Template File    ${ASDC_ENTITLEMENT_POOL_TEMPLATE}    ${map}
    ${resp}=    Run ASDC Post Request    ${ASDC_VENDOR_LICENSE_MODEL_PATH}/${license_model_id}/versions/${version_id}${ASDC_VENDOR_ENTITLEMENT_POOL_PATH}     ${data}   ${ASDC_DESIGNER_USER_ID}  ${ASDC_BE_ONBOARD_ENDPOINT} 
    Should Be Equal As Strings 	${resp.status_code} 	200
    [Return]    ${resp.json()['value']}
Get ASDC Entitlement Pool
    [Documentation]    gets an asdc Entitlement Pool by its id
    [Arguments]    ${license_model_id}    ${pool_id}
    ${resp}=    Run ASDC Get Request    ${ASDC_VENDOR_LICENSE_MODEL_PATH}/${license_model_id}${ASDC_VENDOR_ENTITLEMENT_POOL_PATH}/${pool_id}  ${ASDC_DESIGNER_USER_ID}   ${ASDC_BE_ONBOARD_ENDPOINT} 
    [Return]    ${resp.json()}
Add ASDC License Group
    [Documentation]    Creates an asdc license group and returns its id
    [Arguments]    ${license_model_id}   ${version_id}=1.0
    ${uuid}=    Generate UUID
    ${shortened_uuid}=     Evaluate    str("${uuid}")[:23]
    ${map}=    Create Dictionary    key_group_name=${shortened_uuid}
    ${data}=   Fill JSON Template File    ${ASDC_KEY_GROUP_TEMPLATE}    ${map}
    ${resp}=    Run ASDC Post Request    ${ASDC_VENDOR_LICENSE_MODEL_PATH}/${license_model_id}/versions/${version_id}${ASDC_VENDOR_KEY_GROUP_PATH}     ${data}   ${ASDC_DESIGNER_USER_ID}   ${ASDC_BE_ONBOARD_ENDPOINT} 
    Should Be Equal As Strings 	${resp.status_code} 	200
    [Return]    ${resp.json()['value']}
Get ASDC License Group
    [Documentation]    gets an asdc license group by its id
    [Arguments]    ${license_model_id}    ${group_id}      ${version_id}
    ${resp}=    Run ASDC Get Request    ${ASDC_VENDOR_LICENSE_MODEL_PATH}/${license_model_id}/versions/${version_id}${ASDC_VENDOR_KEY_GROUP_PATH}/${group_id}   ${ASDC_DESIGNER_USER_ID}   ${ASDC_BE_ONBOARD_ENDPOINT} 
    [Return]    ${resp.json()}
Add ASDC Feature Group
    [Documentation]    Creates an asdc Feature Group and returns its id
    [Arguments]    ${license_model_id}    ${key_group_id}    ${entitlement_pool_id}      ${version_id}=0.1
    ${uuid}=    Generate UUID
    ${shortened_uuid}=     Evaluate    str("${uuid}")[:23]
    ${map}=    Create Dictionary    feature_group_name=${shortened_uuid}    key_group_id=${key_group_id}    entitlement_pool_id=${entitlement_pool_id}   manufacturer_reference_number=mrn${shortened_uuid}
    ${data}=   Fill JSON Template File    ${ASDC_FEATURE_GROUP_TEMPLATE}    ${map}
    ${resp}=    Run ASDC Post Request    ${ASDC_VENDOR_LICENSE_MODEL_PATH}/${license_model_id}/versions/${version_id}${ASDC_VENDOR_FEATURE_GROUP_PATH}     ${data}    ${ASDC_DESIGNER_USER_ID}   ${ASDC_BE_ONBOARD_ENDPOINT} 
    Should Be Equal As Strings 	${resp.status_code} 	200
    [Return]    ${resp.json()['value']}
Get ASDC Feature Group
    [Documentation]    gets an asdc Feature Group by its id
    [Arguments]    ${license_model_id}    ${group_id}
    ${resp}=    Run ASDC Get Request    ${ASDC_VENDOR_LICENSE_MODEL_PATH}/${license_model_id}${ASDC_VENDOR_FEATURE_GROUP_PATH}/${group_id}   ${ASDC_DESIGNER_USER_ID}   ${ASDC_BE_ONBOARD_ENDPOINT} 
    [Return]    ${resp.json()}
Add ASDC License Agreement
    [Documentation]    Creates an asdc License Agreement and returns its id
    [Arguments]    ${license_model_id}    ${feature_group_id}      ${version_id}=0.1
    ${uuid}=    Generate UUID
    ${shortened_uuid}=     Evaluate    str("${uuid}")[:23]
    ${map}=    Create Dictionary    license_agreement_name=${shortened_uuid}    feature_group_id=${feature_group_id}
    ${data}=   Fill JSON Template File    ${ASDC_LICENSE_AGREEMENT_TEMPLATE}    ${map}
    ${resp}=    Run ASDC Post Request    ${ASDC_VENDOR_LICENSE_MODEL_PATH}/${license_model_id}/versions/${version_id}${ASDC_VENDOR_LICENSE_AGREEMENT_PATH}     ${data}    ${ASDC_DESIGNER_USER_ID}   ${ASDC_BE_ONBOARD_ENDPOINT} 
    Should Be Equal As Strings 	${resp.status_code} 	200
    [Return]    ${resp.json()['value']}
Get ASDC License Agreement
    [Documentation]    gets an asdc License Agreement by its id
    [Arguments]    ${license_model_id}    ${agreement_id}
    ${resp}=    Run ASDC Get Request    ${ASDC_VENDOR_LICENSE_MODEL_PATH}/${license_model_id}${ASDC_VENDOR_LICENSE_AGREEMENT_PATH}/${agreement_id}   ${ASDC_DESIGNER_USER_ID}   ${ASDC_BE_ONBOARD_ENDPOINT} 
    [Return]    ${resp.json()}
Add ASDC Software Product
    [Documentation]    Creates an asdc Software Product and returns its id
    [Arguments]    ${license_agreement_id}    ${feature_group_id}    ${license_model_name}    ${license_model_id}   ${license_model_version_id}
    ${uuid}=    Generate UUID
    ${shortened_uuid}=     Evaluate    str("${uuid}")[:23]
    ${map}=    Create Dictionary    software_product_name=${shortened_uuid}    feature_group_id=${feature_group_id}    license_agreement_id=${license_agreement_id}    vendor_name=${license_model_name}    vendor_id=${license_model_id}    version_id=${license_model_version_id}
    ${data}=   Fill JSON Template File    ${ASDC_SOFTWARE_PRODUCT_TEMPLATE}    ${map}
    ${resp}=    Run ASDC Post Request    ${ASDC_VENDOR_SOFTWARE_PRODUCT_PATH}     ${data}    ${ASDC_DESIGNER_USER_ID}   ${ASDC_BE_ONBOARD_ENDPOINT} 
    Should Be Equal As Strings 	${resp.status_code} 	200
    [Return]    ${resp.json()['itemId']}   ${resp.json()['version']['id']}
Get ASDC Software Product
    [Documentation]    gets an asdc Software Product by its id
    [Arguments]    ${software_product_id}   ${version_id}=0.1
    ${resp}=    Run ASDC Get Request    ${ASDC_VENDOR_SOFTWARE_PRODUCT_PATH}/${software_product_id}/versions/${version_id}   ${ASDC_DESIGNER_USER_ID}  ${ASDC_BE_ONBOARD_ENDPOINT} 
    [Return]    ${resp.json()}
Add ASDC Catalog Resource
    [Documentation]    Creates an asdc Catalog Resource and returns its id
    [Arguments]    ${license_agreement_id}    ${software_product_name}    ${license_model_name}    ${software_product_id}
    ${map}=    Create Dictionary    software_product_id=${software_product_id}    software_product_name=${software_product_name}    license_agreement_id=${license_agreement_id}    vendor_name=${license_model_name}
    ${data}=   Fill JSON Template File    ${ASDC_CATALOG_RESOURCE_TEMPLATE}    ${map}
    ${resp}=    Run ASDC Post Request    ${ASDC_CATALOG_RESOURCES_PATH}     ${data}    ${ASDC_DESIGNER_USER_ID}   
    Should Be Equal As Strings 	${resp.status_code} 	201
    [Return]    ${resp.json()['uniqueId']}
Mark ASDC Catalog Resource Inactive
    [Documentation]    deletes an asdc Catalog Resource
    [Arguments]    ${catalog_resource_id}
    ${resp}=    Run ASDC Delete Request    ${ASDC_CATALOG_RESOURCES_PATH}/${catalog_resource_id}     ${ASDC_DESIGNER_USER_ID}
    Should Be Equal As Strings 	${resp.status_code} 	204
    [Return]    ${resp}
Delete Inactive ASDC Catalog Resources
    [Documentation]    delete all asdc Catalog Resources that are inactive
    ${resp}=    Run ASDC Delete Request    ${ASDC_CATALOG_INACTIVE_RESOURCES_PATH}     ${ASDC_DESIGNER_USER_ID}
    Should Be Equal As Strings 	${resp.status_code} 	200
    [Return]    ${resp.json()}
Get ASDC Catalog Resource
    [Documentation]    gets an asdc Catalog Resource by its id
    [Arguments]    ${catalog_resource_id}
    ${resp}=    Run ASDC Get Request    ${ASDC_CATALOG_RESOURCES_PATH}/${catalog_resource_id}    ${ASDC_DESIGNER_USER_ID} 
    [Return]    ${resp.json()}
Get ASDC Catalog Resource Component Instances
    [Documentation]    gets asdc Catalog Resource Component Instances by its id
    [Arguments]    ${catalog_resource_id}
    ${resp}=    Run ASDC Get Request    ${ASDC_FE_CATALOG_RESOURCES_PATH}/${catalog_resource_id}/filteredDataByParams?include=componentInstances    ${ASDC_DESIGNER_USER_ID}    ${ASDC_FE_ENDPOINT}
    [Return]    ${resp.json()}
Get ASDC Catalog Resource Inputs
    [Documentation]    gets asdc Catalog Inputs by its id
    [Arguments]    ${catalog_resource_id}
    ${resp}=    Run ASDC Get Request    ${ASDC_FE_CATALOG_RESOURCES_PATH}/${catalog_resource_id}/filteredDataByParams?include=inputs    ${ASDC_DESIGNER_USER_ID}    ${ASDC_FE_ENDPOINT}
    [Return]    ${resp.json()}
Get ASDC Catalog Resource Component Instance Properties
    [Documentation]    gets an asdc Catalog Resource properties by its id
    [Arguments]    ${catalog_resource_id}    ${component_instance_id}    ${component_id}
    ${resp}=    Run ASDC Get Request    ${ASDC_FE_CATALOG_RESOURCES_PATH}/${catalog_resource_id}/componentInstances/${component_instance_id}/${component_id}/inputs    ${ASDC_DESIGNER_USER_ID}    ${ASDC_FE_ENDPOINT}
    [Return]    ${resp.json()}
Set ASDC Catalog Resource Component Instance Properties
    [Documentation]    sets an asdc Catalog Resource by its id
    [Arguments]    ${catalog_resource_id}    ${component_instance_id}    ${data}
    ${resp}=    Run ASDC Post Request    ${ASDC_FE_CATALOG_RESOURCES_PATH}/${catalog_resource_id}/resourceInstance/${component_instance_id}/inputs    ${data}    ${ASDC_DESIGNER_USER_ID}    ${ASDC_FE_ENDPOINT}
    [Return]    ${resp.json()}
Set ASDC Catalog Resource VNF Inputs
    [Documentation]    sets an asdc Catalog Resource by its id
    [Arguments]    ${catalog_resource_id}    ${data}
    ${resp}=    Run ASDC Post Request    ${ASDC_FE_CATALOG_RESOURCES_PATH}/${catalog_resource_id}/update/inputs    ${data}    ${ASDC_DESIGNER_USER_ID}    ${ASDC_FE_ENDPOINT}
    [Return]    ${resp.json()}
Get SDC Demo Vnf Catalog Resource
    [Documentation]  gets resource id's for demonstration VNFs for instantiate
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
    [Documentation]   looks up vnf key from service mapping for a regex on groupName and service_name
    [Arguments]   ${group_name}    ${service_name}
    ${vnf}=   Set Variable If
    ...                      ('${service_name}'=='demoVFWCL') and ('base_vfw' in '${group_name}')   vFWSNK
    ...                      ('${service_name}'=='demoVFWCL') and ('base_vpkg' in '${group_name}')   vPKG
    ...                      ('${service_name}'=='demoVLB') and ('base_vlb' in '${group_name}')   vLB
    [Return]   ${vnf}
Checkin ASDC Catalog Resource
    [Documentation]    checksin an asdc Catalog Resource by its id
    [Arguments]    ${catalog_resource_id}
    ${map}=    Create Dictionary    user_remarks=Robot remarks
    ${data}=   Fill JSON Template File    ${ASDC_USER_REMARKS_TEMPLATE}    ${map}
    ${resp}=    Run ASDC Post Request    ${ASDC_CATALOG_RESOURCES_PATH}/${catalog_resource_id}${ASDC_CATALOG_LIFECYCLE_PATH}/checkin    ${data}    ${ASDC_DESIGNER_USER_ID}
    Should Be Equal As Strings 	${resp.status_code} 	200
    [Return]    ${resp.json()}
Request Certify ASDC Catalog Resource
    [Documentation]    requests certify on an asdc Catalog Resource by its id
    [Arguments]    ${catalog_resource_id}
    ${map}=    Create Dictionary    user_remarks=Robot remarks
    ${data}=   Fill JSON Template File    ${ASDC_USER_REMARKS_TEMPLATE}    ${map}
    ${resp}=    Run ASDC Post Request    ${ASDC_CATALOG_RESOURCES_PATH}/${catalog_resource_id}${ASDC_CATALOG_LIFECYCLE_PATH}/certificationRequest    ${data}    ${ASDC_DESIGNER_USER_ID}
    Should Be Equal As Strings 	${resp.status_code} 	200
    [Return]    ${resp.json()}
Start Certify ASDC Catalog Resource
    [Documentation]    start certify an asdc Catalog Resource by its id
    [Arguments]    ${catalog_resource_id}
    ${resp}=    Run ASDC Post Request    ${ASDC_CATALOG_RESOURCES_PATH}/${catalog_resource_id}${ASDC_CATALOG_LIFECYCLE_PATH}/startCertification    ${None}    ${ASDC_TESTER_USER_ID}
    Should Be Equal As Strings 	${resp.status_code} 	200
    [Return]    ${resp.json()}
Certify ASDC Catalog Resource
    [Documentation]    start certify an asdc Catalog Resource by its id and returns the new id
    [Arguments]    ${catalog_resource_id}    ${user_id}=${ASDC_TESTER_USER_ID}
    ${map}=    Create Dictionary    user_remarks=Robot remarks
    ${data}=   Fill JSON Template File    ${ASDC_USER_REMARKS_TEMPLATE}    ${map}
    ${resp}=    Run ASDC Post Request    ${ASDC_CATALOG_RESOURCES_PATH}/${catalog_resource_id}${ASDC_CATALOG_LIFECYCLE_PATH}/certify    ${data}    ${user_id}
    Should Be Equal As Strings 	${resp.status_code} 	200
    [Return]    ${resp.json()['uniqueId']}

Upload ASDC Heat Package
    [Documentation]    Creates an asdc Software Product and returns its id
    [Arguments]    ${software_product_id}    ${file_path}   ${version_id}=0.1
     ${files}=     Create Dictionary
     Create Multi Part     ${files}  upload  ${file_path}    contentType=application/zip
    ${resp}=    Run ASDC Post Files Request    ${ASDC_VENDOR_SOFTWARE_PRODUCT_PATH}/${software_product_id}/versions/${version_id}${ASDC_VENDOR_SOFTWARE_UPLOAD_PATH}     ${files}    ${ASDC_DESIGNER_USER_ID}   ${ASDC_BE_ONBOARD_ENDPOINT} 
	Should Be Equal As Strings 	${resp.status_code} 	200

Add ASDC Catalog Service
    [Documentation]    Creates an asdc Catalog Service and returns its id
    [Arguments]   ${catalog_service_name}
    ${uuid}=    Generate UUID
    ${shortened_uuid}=     Evaluate    str("${uuid}")[:23]
    ${catalog_service_name}=   Set Variable If   '${catalog_service_name}' ==''   ${shortened_uuid}   ${catalog_service_name}
    ${map}=    Create Dictionary    service_name=${catalog_service_name}
    ${data}=   Fill JSON Template File    ${ASDC_CATALOG_SERVICE_TEMPLATE}    ${map}
    ${resp}=    Run ASDC Post Request    ${ASDC_CATALOG_SERVICES_PATH}     ${data}    ${ASDC_DESIGNER_USER_ID}
    Should Be Equal As Strings 	${resp.status_code} 	201
    [Return]    ${resp.json()['uniqueId']}
Mark ASDC Catalog Service Inactive
    [Documentation]    Deletes an asdc Catalog Service
    [Arguments]    ${catalog_service_id}
    ${resp}=    Run ASDC Delete Request    ${ASDC_CATALOG_SERVICES_PATH}/${catalog_service_id}     ${ASDC_DESIGNER_USER_ID}
    Should Be Equal As Strings 	${resp.status_code} 	204
    [Return]    ${resp}
Delete Inactive ASDC Catalog Services
    [Documentation]    delete all asdc Catalog Serivces that are inactive
    ${resp}=    Run ASDC Delete Request    ${ASDC_CATALOG_INACTIVE_SERVICES_PATH}     ${ASDC_DESIGNER_USER_ID}
    Should Be Equal As Strings 	${resp.status_code} 	200
    [Return]    ${resp.json()}
Get ASDC Catalog Service
    [Documentation]    gets an asdc Catalog Service by its id
    [Arguments]    ${catalog_service_id}
    ${resp}=    Run ASDC Get Request    ${ASDC_CATALOG_SERVICES_PATH}/${catalog_service_id}    ${ASDC_DESIGNER_USER_ID}
    [Return]    ${resp.json()}
Checkin ASDC Catalog Service
    [Documentation]    checksin an asdc Catalog Service by its id
    [Arguments]    ${catalog_service_id}
    ${map}=    Create Dictionary    user_remarks=Robot remarks
    ${data}=   Fill JSON Template File    ${ASDC_USER_REMARKS_TEMPLATE}    ${map}
    ${resp}=    Run ASDC Post Request    ${ASDC_CATALOG_SERVICES_PATH}/${catalog_service_id}${ASDC_CATALOG_LIFECYCLE_PATH}/checkin    ${data}    ${ASDC_DESIGNER_USER_ID}
    Should Be Equal As Strings 	${resp.status_code} 	200
    [Return]    ${resp.json()}
Request Certify ASDC Catalog Service
    [Documentation]    requests certify on an asdc Catalog Service by its id
    [Arguments]    ${catalog_service_id}
    ${map}=    Create Dictionary    user_remarks=Robot remarks
    ${data}=   Fill JSON Template File    ${ASDC_USER_REMARKS_TEMPLATE}    ${map}
    ${resp}=    Run ASDC Post Request    ${ASDC_CATALOG_SERVICES_PATH}/${catalog_service_id}${ASDC_CATALOG_LIFECYCLE_PATH}/certificationRequest    ${data}    ${ASDC_DESIGNER_USER_ID}
    Should Be Equal As Strings 	${resp.status_code} 	200
    [Return]    ${resp.json()}
Start Certify ASDC Catalog Service
    [Documentation]    start certify an asdc Catalog Service by its id
    [Arguments]    ${catalog_service_id}
    ${resp}=    Run ASDC Post Request    ${ASDC_CATALOG_SERVICES_PATH}/${catalog_service_id}${ASDC_CATALOG_LIFECYCLE_PATH}/startCertification    ${None}    ${ASDC_TESTER_USER_ID}
    Should Be Equal As Strings 	${resp.status_code} 	200
    [Return]    ${resp.json()}
Certify ASDC Catalog Service
    [Documentation]    start certify an asdc Catalog Service by its id and returns the new id
    [Arguments]    ${catalog_service_id}
    ${map}=    Create Dictionary    user_remarks=Robot remarks
    ${data}=   Fill JSON Template File    ${ASDC_USER_REMARKS_TEMPLATE}    ${map}
    ${resp}=    Run ASDC Post Request    ${ASDC_CATALOG_SERVICES_PATH}/${catalog_service_id}${ASDC_CATALOG_LIFECYCLE_PATH}/certify    ${data}    ${ASDC_TESTER_USER_ID}
    Should Be Equal As Strings 	${resp.status_code} 	200
    [Return]    ${resp.json()['uniqueId']}
Approve ASDC Catalog Service
    [Documentation]    approve an asdc Catalog Service by its id
    [Arguments]    ${catalog_service_id}
    ${map}=    Create Dictionary    user_remarks=Robot remarks
    ${data}=   Fill JSON Template File    ${ASDC_USER_REMARKS_TEMPLATE}    ${map}
    ${resp}=    Run ASDC Post Request    ${ASDC_CATALOG_SERVICES_PATH}/${catalog_service_id}${ASDC_CATALOG_SERVICE_DISTRIBUTION_STATE_PATH}${ASDC_DISTRIBUTION_STATE_APPROVE_PATH}    ${data}    ${ASDC_GOVERNOR_USER_ID}
    Should Be Equal As Strings 	${resp.status_code} 	200
    [Return]    ${resp.json()}
Distribute ASDC Catalog Service
    [Documentation]    distribute an asdc Catalog Service by its id
    [Arguments]    ${catalog_service_id}
    ${resp}=    Run ASDC Post Request    ${ASDC_CATALOG_SERVICES_PATH}/${catalog_service_id}${ASDC_CATALOG_SERVICE_DISTRIBUTION_ACTIVATE_PATH}    ${None}    ${ASDC_OPS_USER_ID}
    Should Be Equal As Strings 	${resp.status_code} 	200
    [Return]    ${resp.json()}
Add ASDC Resource Instance
    [Documentation]    Creates an asdc Resource Instance and returns its id
    [Arguments]    ${catalog_service_id}    ${catalog_resource_id}    ${catalog_resource_name}
    ${milli_timestamp}=    Generate MilliTimestamp UUID
    ${map}=    Create Dictionary    catalog_resource_id=${catalog_resource_id}    catalog_resource_name=${catalog_resource_name}    milli_timestamp=${milli_timestamp}
    ${data}=   Fill JSON Template File    ${ASDC_RESOURCE_INSTANCE_TEMPLATE}    ${map}
    ${resp}=    Run ASDC Post Request    ${ASDC_CATALOG_SERVICES_PATH}/${catalog_service_id}${ASDC_CATALOG_SERVICE_RESOURCE_INSTANCE_PATH}     ${data}    ${ASDC_DESIGNER_USER_ID}
    Should Be Equal As Strings 	${resp.status_code} 	201
    [Return]    ${resp.json()['uniqueId']}
Get Catalog Service Distribution
    [Documentation]    gets an asdc catalog Service distrbution
    [Arguments]    ${catalog_service_uuid}
    ${resp}=    Run ASDC Get Request    ${ASDC_CATALOG_SERVICES_PATH}/${catalog_service_uuid}${ASDC_CATALOG_SERVICE_DISTRIBUTION_PATH}    ${ASDC_OPS_USER_ID}
    Should Be Equal As Strings 	${resp.status_code} 	200
    [Return]    ${resp.json()}
Check Catalog Service Distributed
    [Documentation]    gets an asdc catalog Service distrbution
    [Arguments]    ${catalog_service_uuid}    ${dist_status}
    ${dist_resp}=    Get Catalog Service Distribution    ${catalog_service_uuid}
    Should Be Equal As Strings 	${dist_resp['distributionStatusOfServiceList'][0]['deployementStatus']} 	Distributed
    ${det_resp}=    Get Catalog Service Distribution Details    ${dist_resp['distributionStatusOfServiceList'][0]['distributionID']}
    @{ITEMS}=    Copy List    ${det_resp['distributionStatusList']}
    Should Not Be Empty   ${ITEMS}
    ${SO_COMPLETE}   Set Variable   FALSE
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
    [Documentation]    gets an asdc catalog Service distrbution details
    [Arguments]    ${catalog_service_distribution_id}
    ${resp}=    Run ASDC Get Request    ${ASDC_CATALOG_SERVICES_PATH}${ASDC_CATALOG_SERVICE_DISTRIBUTION_PATH}/${catalog_service_distribution_id}    ${ASDC_OPS_USER_ID} 
    Should Be Equal As Strings 	${resp.status_code} 	200
    [Return]    ${resp.json()}
Run ASDC Health Check
    [Documentation]    Runs a ASDC health check
    ${session}=    Create Session 	asdc 	${ASDC_FE_ENDPOINT}
    ${uuid}=    Generate UUID
    ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json    X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}
    ${resp}= 	Get Request 	asdc 	${ASDC_HEALTH_CHECK_PATH}     headers=${headers}
    # only test for HTTP 200 to determine SDC Health. SDC_DE_HEALTH is informational
    Should Be Equal As Strings 	${resp.status_code} 	200    SDC DOWN
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
    ${session}=    Create Session 	asdc 	${MY_ASDC_BE_ENDPOINT}    auth=${auth}
    ${uuid}=    Generate UUID
    ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json    USER_ID=${user}    X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}
    ${resp}= 	Get Request 	asdc 	${data_path}     headers=${headers}
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
    ${resp}= 	Put Request 	asdc 	${data_path}     data=${data}    headers=${headers}
    Log    Received response from asdc ${resp.text}
    [Return]    ${resp}

Run ASDC Post Files Request
    [Documentation]    Runs an ASDC post request
    [Arguments]    ${data_path}    ${files}    ${user}=${ASDC_DESIGNER_USER_ID}   ${MY_ASDC_BE_ENDPOINT}=${ASDC_BE_ENDPOINT}
    ${auth}=  Create List  ${GLOBAL_ASDC_BE_USERNAME}    ${GLOBAL_ASDC_BE_PASSWORD}
    Log    Creating session ${MY_ASDC_BE_ENDPOINT}
    ${session}=    Create Session 	asdc 	${MY_ASDC_BE_ENDPOINT}    auth=${auth}
    ${uuid}=    Generate UUID
    ${headers}=  Create Dictionary     Accept=application/json    Content-Type=multipart/form-data    USER_ID=${user}    X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}
    ${resp}= 	Post Request 	asdc 	${data_path}     files=${files}    headers=${headers}
    Log    Received response from asdc ${resp.text}
    [Return]    ${resp}

Run ASDC Post Request
    [Documentation]    Runs an ASDC post request
    [Arguments]    ${data_path}    ${data}    ${user}=${ASDC_DESIGNER_USER_ID}   ${MY_ASDC_BE_ENDPOINT}=${ASDC_BE_ENDPOINT}
    ${auth}=  Create List  ${GLOBAL_ASDC_BE_USERNAME}    ${GLOBAL_ASDC_BE_PASSWORD}
    Log    Creating session ${MY_ASDC_BE_ENDPOINT}
    ${session}=    Create Session 	asdc 	${MY_ASDC_BE_ENDPOINT}    auth=${auth}
    ${uuid}=    Generate UUID
    ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json    USER_ID=${user}    X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}
    ${resp}= 	Post Request 	asdc 	${data_path}     data=${data}    headers=${headers}
    Log    Received response from asdc ${resp.text}
    [Return]    ${resp}
Run ASDC Delete Request
    [Documentation]    Runs an ASDC delete request
    [Arguments]    ${data_path}    ${user}=${ASDC_DESIGNER_USER_ID}  ${MY_ASDC_BE_ENDPOINT}=${ASDC_BE_ENDPOINT}
    ${auth}=  Create List  ${GLOBAL_ASDC_BE_USERNAME}    ${GLOBAL_ASDC_BE_PASSWORD} 
    Log    Creating session ${MY_ASDC_BE_ENDPOINT}
    ${session}=    Create Session 	asdc 	${MY_ASDC_BE_ENDPOINT}    auth=${auth}
    ${uuid}=    Generate UUID
    ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json    USER_ID=${user}    X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}
    ${resp}= 	Delete Request 	asdc 	${data_path}        headers=${headers}
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

