*** Settings ***
Documentation     Instantiate VNF 

Library    OperatingSystem
Library    Collections
Library    String
Library    DateTime
Library    SoUtils 
Library    ONAPLibrary.PreloadData    
Resource       ../global_properties.robot

*** Variables ***
${VNF_KEYPAIR_SSH_KEY}    robot/assets/keys/onap_dev_public.txt

*** Keywords ***
Instantiate Service Direct To SO 
    [Documentation]    Creates an entire service from a CSAR
    [Arguments]    ${service}   ${csar_file}   ${vnf_template_file} 
    # Example: ${csar_file}=  Set Variable   /tmp/csar/service-Vfw20190413133734-csar.csar
    # Example: ${vnf_template_file}=  Set Variable   /var/opt/ONAP/testsuite/vcpeutils/preload_templates/template.vfw_vfmodule.json
    ${name_suffix}=   Get Current Date     exclude_millis=True
    ${name_suffix}=       Evaluate    '${name_suffix}'.replace(' ','')
    ${name_suffix}=       Evaluate    '${name_suffix}'.replace(':','')
    Set Directory    preload    ./demo/preload_data
    ${preload_dict}=       Get Default Preload Data    preload
    ${template}=   Create Dictionary
    @{keys}=    Get Dictionary Keys    ${preload_dict}
    :FOR   ${key}   IN   @{keys}
    \    ${value}=   Get From Dictionary    ${preload_dict}    ${key}
    \    ${tmp_value}=   Set Variable If   'GLOBAL_' in $value     ${value}  
    \    ${tmp_value}=   Run Keyword If  'GLOBAL_' in $value  Replace String  ${tmp_value}    \$      ${EMPTY}
    \    ${tmp_value}=   Run Keyword If  'GLOBAL_' in $value  Replace String  ${tmp_value}    {      ${EMPTY}
    \    ${tmp_value}=   Run Keyword If  'GLOBAL_' in $value  Replace String  ${tmp_value}    }      ${EMPTY}
    \    ${value}=   Set Variable If   'GLOBAL_' in $value    ${GLOBAL_INJECTED_PROPERTIES["${tmp_value}"]}     ${value}
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
    ${service_instance_id}=   Create Entire Service   ${csar_file}    ${vnf_template_file}   ${template}   ${name_suffix}   ${GLOBAL_INJECTED_REGION}  ${GLOBAL_INJECTED_OPENSTACK_TENANT_ID}
    Log     ServiceInstanceId:${service_instance_id}
    Should Not Be Equal As Strings  ${service_instance_id}   None

