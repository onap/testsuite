*** Settings ***
Documentation	  Create Cloud Config

Resource    ../json_templater.robot
Resource    ../so_interface.robot
Library    OperatingSystem
Library    Collections


*** Variables ***
${CLOUD_CONFIG_PATH}    /cloudSite

${SYSTEM USER}    robot-ete
${SO_ADD_CLOUD_CONFIG}=   robot/assets/templates/so/create_cloud_config.template
${SO_ADD_CLOUD_CONFIG_V3}=   robot/assets/templates/so/cloud_config_v3.template

*** Keywords ***
Create Cloud Configuration
    [Documentation]    Creates a cloud configuration in SO, so it knows how to talk to an openstack cloud
    [Arguments]    ${site_name}    ${region_id}   ${clli}   ${identity_id}   ${identity_url}   ${mso_id}    ${mso_pass}    ${admin_tenant}    ${member_role}    ${identity_server_type}    ${authentication_type}    
    ${arguments}=    Create Dictionary     site_name=${site_name}  region_id=${region_id}  clli=${clli}    identity_id=${identity_id}    identity_url=${identity_url}    mso_id=${mso_id}    mso_pass=${mso_pass}    admin_tenant=${admin_tenant}   member_role=${member_role}     identity_server_type=${identity_server_type}     authentication_type=${authentication_type}
    ${data}=	Fill JSON Template File    ${SO_ADD_CLOUD_CONFIG}     ${arguments}
    ${get_resp}=    Run SO Catalog Post request    ${CLOUD_CONFIG_PATH}/${site_name}     ${data}
    
    ${get_resp}=    Run Keyword If    '${get_resp.status_code}'=='404'    Update Cloud Configuration    ${site_name}    ${region_id}   ${clli}   ${identity_id}   ${identity_url}   ${mso_id}    ${mso_pass}    ${admin_tenant}    ${member_role}    ${identity_server_type}    ${authentication_type}
    Should Be Equal As Strings  ${get_resp.status_code}     200


Create Cloud Configuration v3
    [Documentation]    Creates a cloud configuration in SO, so it knows how to talk to an openstack cloud
    [Arguments]    ${site_name}    ${region_id}   ${clli}   ${identity_id}   ${identity_url}   ${mso_id}    ${mso_pass}    ${admin_tenant}    ${member_role}    ${identity_server_type}    ${authentication_type}    ${project_domain_name}    ${user_domain_Name}
    ${arguments}=    Create Dictionary     site_name=${site_name}  region_id=${region_id}  clli=${clli}    identity_id=${identity_id}    identity_url=${identity_url}    mso_id=${mso_id}    mso_pass=${mso_pass}    admin_tenant=${admin_tenant}   member_role=${member_role}     identity_server_type=${identity_server_type}     authentication_type=${authentication_type}    project_domain_name=${project_domain_name}    user_domain_name=${user_domain_name}
    Log    ${arguments}
    ${data}=	Fill JSON Template File    ${SO_ADD_CLOUD_CONFIG_V3}     ${arguments}
    ${get_resp}=    Run SO Catalog Post request     ${CLOUD_CONFIG_PATH}     ${data}
    ${status_string}=    Convert To String    ${get_resp.status_code}
    Should Match Regexp    ${status_string} 	^(201|200)$

Update Cloud Configuration
    [Documentation]    Updates a cloud configuration in SO
    [Arguments]    ${site_name}    ${region_id}   ${clli}   ${identity_id}   ${identity_url}   ${mso_id}    ${mso_pass}    ${admin_tenant}    ${member_role}    ${identity_server_type}    ${authentication_type}
    ${arguments}=    Create Dictionary     site_name=${site_name}  region_id=${region_id}  clli=${clli}    identity_id=${identity_id}    identity_url=${identity_url}    mso_id=${mso_id}    mso_pass=${mso_pass}    admin_tenant=${admin_tenant}   member_role=${member_role}     identity_server_type=${identity_server_type}     authentication_type=${authentication_type}
    ${data}=    Fill JSON Template File    ${SO_ADD_CLOUD_CONFIG}     ${arguments}
    ${get_resp}=    Run SO Catalog Put request    ${CLOUD_CONFIG_PATH}/${site_name}     ${data}
    Should Be Equal As Strings  ${get_resp.status_code}     200
    [Return]   ${get_resp}

Get Cloud Configuration
    [Documentation]    Gets cloud configuration in SO
    [Arguments]    ${site_name}    
    ${get_resp}=    Run MSO Catalog Get request    ${CLOUD_CONFIG_PATH}/${site_name}
    Should Be Equal As Strings  ${get_resp.status_code}     200


