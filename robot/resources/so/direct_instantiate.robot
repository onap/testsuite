*** Settings ***
Documentation     Instantiate VNF

Library    OperatingSystem
Library    Collections
Library    String
Library    DateTime
Library    SoUtils
Library    RequestsLibrary
Library    ONAPLibrary.PreloadData    WITH NAME     PreloadData
Library    ONAPLibrary.Utilities
Library    ONAPLibrary.JSON
Library    ONAPLibrary.ServiceMapping    WITH NAME     ServiceMapping
Library    ONAPLibrary.Templating    WITH NAME     Templating
Library    ONAPLibrary.SO    WITH NAME    SO
Resource       ../global_properties.robot


***Variables ***
${SO_TEMPLATE_PATH}        so
${SO_CATALOGDB_PATH}  /ecomp/mso/catalog/v2/serviceVnfs?serviceModelName
${SO_APIHANDLER_PATH}    /onap/so/infra/serviceInstantiation/v7/serviceInstances
${CDS_BLUEPRINTS_ENDPOINT}    http://cds-blueprints-processor-http:8080 
${CDS_BOOTSTRAP_PATH}    /api/v1/blueprint-model/bootstrap
${CDS_AUTH}    Y2NzZGthcHBzOmNjc2RrYXBwcw==

*** Keywords ***
Instantiate Service Direct To SO
    [Documentation]    Creates an entire service from a CSAR
    [Arguments]    ${service}   ${csar_file}   ${vnf_template_file}
    # Example: ${csar_file}=  Set Variable   /tmp/csar/service-Vfw20190413133734-csar.csar
    # Example: ${vnf_template_file}=  Set Variable   /var/opt/ONAP/testsuite/vcpeutils/preload_templates/template.vfw_vfmodule.json
    PreloadData.Set Directory    preload    ./demo/preload_data
    ${preload_dict}=       Get Default Preload Data    preload
    ${template}=   Create Dictionary
    @{keys}=    Get Dictionary Keys    ${preload_dict}
    ${parameters}=    Get Globally Injected Parameters
    :FOR   ${key}   IN   @{keys}
    \    ${value}=   Get From Dictionary    ${preload_dict}    ${key}
    \    ${tmp_value}=   Set Variable If   'GLOBAL_' in $value     ${value}
    \    ${tmp_value}=   Run Keyword If  'GLOBAL_' in $value  Replace String  ${tmp_value}    \$      ${EMPTY}
    \    ${tmp_value}=   Run Keyword If  'GLOBAL_' in $value  Replace String  ${tmp_value}    {      ${EMPTY}
    \    ${tmp_value}=   Run Keyword If  'GLOBAL_' in $value  Replace String  ${tmp_value}    }      ${EMPTY}
    \    ${value}=   Set Variable If   'GLOBAL_' in $value    ${parameters["${tmp_value}"]}     ${value}
    \    ${new_key}=   Catenate    \$   {   ${key}   }
    \    ${new_key}=     Evaluate  '${new_key}'.replace(' ','')
    \    Set To Dictionary    ${template}   ${new_key}    ${value}

    ${tmp_key1}=   Catenate  \$  {   ecompnet  }
    ${tmp_key1}=     Evaluate  '${tmp_key1}'.replace(' ','')
    ${tmp_key2}=   Catenate  \$  {   GLOBAL_INJECTED_UBUNTU_1404_IMAGE  }
    ${tmp_key2}=     Evaluate  '${tmp_key2}'.replace(' ','')
    # ecompnet  13 , 14, 15
    # use same method as sdnc preload robot script
    ${ecompnet}=    Evaluate    str((${GLOBAL_BUILD_NUMBER}%128)+128)

    Set To Dictionary   ${template}    ${tmp_key1}     ${ecompnet}     ${tmp_key2}     ${GLOBAL_INJECTED_UBUNTU_1404_IMAGE}

    Log    ${preload_dict}
    Log    ${template}
    ${service_instance_id}=   Create Entire Service   ${csar_file}    ${vnf_template_file}   ${template}   ${GLOBAL_INJECTED_REGION}  ${GLOBAL_INJECTED_OPENSTACK_TENANT_ID}    ${GLOBAL_INJECTED_PUBLIC_KEY}
    Log     ServiceInstanceId:${service_instance_id}
    Should Not Be Equal As Strings  ${service_instance_id}   None


CDS Service Instantiate
    [Arguments]  ${cds_service_model}  ${service_uuid}  ${service_invariantUUID}
    ${auth}=  Create List  ${GLOBAL_SO_CATDB_USERNAME}  ${GLOBAL_SO_PASSWORD}
    ${resp}=  SO.Run Get Request  ${GLOBAL_SO_CATDB_ENDPOINT}  ${SO_CATALOGDB_PATH}=${cds_service_model}  auth=${auth}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${session}=  Create Session  cds  ${CDS_BLUEPRINTS_ENDPOINT}
    ${data}=  Create Dictionary  loadModelType=true  loadResourceDictionary=true  loadCBA=true
    ${headers}=  Create Dictionary  Content-Type=application/json  Authorization=Basic ${CDS_AUTH}
    ${resp}=  Post Request  cds  ${CDS_BOOTSTRAP_PATH}  data=${data}  headers=${headers}
    ${status_string}=    Convert To String    ${resp.status_code}
    Should Match Regexp    ${status_string}    ^(200|201|202)$
    ${time_now}=  Get Time
    @{date_time}=  Split String  ${time_now}
    ${time_stamp}=  Catenate  SEPARATOR=_  @{date_time}[0]  @{date_time}[1]
    ${customized_time_stamp}=  Remove String  ${time_stamp}  :
    ${cds_instance_name}=   Set Variable   cds_vlb_svc_${customized_time_stamp}
    ${global_parameters}=  Get Globally Injected Parameters
    ${owning_entity_id}=  Get OwningEntity Id  OE-Demonstration
    ${dict}=   Set To Dictionary  ${global_parameters}  dcae_collector_ip=${GLOBAL_DCAE_COLLECTOR_IP}  dcae_collector_port=${GLOBAL_DCAE_COLLECTOR_PORT}  vlb_0_int_pktgen_private_port_0_mac=${GLOBAL_VLB_0_INT_PKTGEN_PRIVATE_PORT_0_MAC}  vpg_0_int_pktgen_private_port_0_mac=${GLOBAL_VPG_0_INT_PKTGEN_PRIVATE_PORT_0_MAC}  service_instance_name=${cds_instance_name}  owning_entity=OE-Demonstration    homing_solution=none    owning_entity_id=${owning_entity_id}    subscriber_id=Demonstration  cloud_owner=${GLOBAL_AAI_CLOUD_OWNER}  subscription_service_type=vLB  service_model_name=${cds_service_model}  service_model_uuid=${service_uuid}  service_model_invariantuuid=${service_invariantUUID}  resp=${resp.json()}
    Templating.Create Environment    cds    ${GLOBAL_TEMPLATE_FOLDER}
    ${data}=   Templating.Apply Template    cds    ${SO_TEMPLATE_PATH}/cds_service_template.jinja    ${dict}
    Log  ${data}
    ${auth}=  Create List  ${GLOBAL_SO_USERNAME}  ${GLOBAL_SO_PASSWORD}
    ${resp}=  SO.Run Post Request  ${GLOBAL_SO_APIHAND_ENDPOINT}  ${SO_APIHANDLER_PATH}  ${data}  auth=${auth}
    Should Be Equal As Strings  ${resp.status_code}  202
    [Return]  ${resp.json()['requestReferences']['requestId']}
