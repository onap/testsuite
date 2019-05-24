*** Settings ***
Documentation     The main interface for interacting with MSO. It handles low level stuff like managing the http request library and MSO required fields
Library           ONAPLibrary.SO

Resource          global_properties.robot
Resource          json_templater.robot

*** Variables ***
${SO_HEALTH_CHECK_PATH}    /manage/health
${CLOUD_CONFIG_PATH}    /cloudSite
${SO_ADD_CLOUD_CONFIG}=   robot/assets/templates/so/create_cloud_config.template
${SO_ADD_CLOUD_CONFIG_V3}=   robot/assets/templates/so/cloud_config_v3.template

*** Keywords ***
Run SO Global Health Check
    Run Get Request	   ${GLOBAL_SO_APIHAND_ENDPOINT}    ${SO_HEALTH_CHECK_PATH}
    Run Get Request	   ${GLOBAL_SO_ASDCHAND_ENDPOINT}    ${SO_HEALTH_CHECK_PATH}
    Run Get Request    ${GLOBAL_SO_BPMN_ENDPOINT}    ${SO_HEALTH_CHECK_PATH}
    Run Get Request    ${GLOBAL_SO_CATDB_ENDPOINT}    ${SO_HEALTH_CHECK_PATH}
    Run Get Request    ${GLOBAL_SO_OPENSTACK_ENDPOINT}    ${SO_HEALTH_CHECK_PATH}
    Run Get Request    ${GLOBAL_SO_REQDB_ENDPOINT}    ${SO_HEALTH_CHECK_PATH}
    Run Get Request    ${GLOBAL_SO_SDNC_ENDPOINT}    ${SO_HEALTH_CHECK_PATH}
    Run Get Request    ${GLOBAL_SO_VFC_ENDPOINT}    ${SO_HEALTH_CHECK_PATH}
    Run Get Request    ${GLOBAL_SO_VNFM_ENDPOINT}    ${SO_HEALTH_CHECK_PATH}
    
Get Cloud Configuration
    [Documentation]    Gets cloud configuration in SO
    [Arguments]    ${site_name}
    ${auth}=  Create List  ${GLOBAL_MSO_CATDB_USERNAME}    ${GLOBAL_MSO_PASSWORD}
    ${get_resp}=    Run Get Request    ${GLOBAL_SO_CATDB_ENDPOINT}    ${CLOUD_CONFIG_PATH}/${site_name}   auth=${auth} 
    Should Be Equal As Strings  ${get_resp.status_code}     200
    
Create Cloud Configuration
    [Documentation]    Creates a cloud configuration in SO, so it knows how to talk to an openstack cloud
    [Arguments]    ${site_name}    ${region_id}   ${clli}   ${identity_id}   ${identity_url}   ${mso_id}    ${mso_pass}    ${admin_tenant}    ${member_role}    ${identity_server_type}    ${authentication_type}    
    ${arguments}=    Create Dictionary     site_name=${site_name}  region_id=${region_id}  clli=${clli}    identity_id=${identity_id}    identity_url=${identity_url}    mso_id=${mso_id}    mso_pass=${mso_pass}    admin_tenant=${admin_tenant}   member_role=${member_role}     identity_server_type=${identity_server_type}     authentication_type=${authentication_type}
    ${data}=	Fill JSON Template File    ${SO_ADD_CLOUD_CONFIG}     ${arguments}
    ${auth}=  Create List  ${GLOBAL_MSO_CATDB_USERNAME}    ${GLOBAL_MSO_PASSWORD}
    ${get_resp}=   Run Put Request   ${GLOBAL_SO_CATDB_ENDPOINT}    ${CLOUD_CONFIG_PATH}/${site_name}   ${data}    auth=${auth}     
    ${get_resp}=    Run Keyword If    '${get_resp.status_code}'=='404'    Update Cloud Configuration    ${site_name}    ${region_id}   ${clli}   ${identity_id}   ${identity_url}   ${mso_id}    ${mso_pass}    ${admin_tenant}    ${member_role}    ${identity_server_type}    ${authentication_type}
    Should Be Equal As Strings  ${get_resp.status_code}     200


Create Cloud Configuration v3
    [Documentation]    Creates a cloud configuration in SO, so it knows how to talk to an openstack cloud
    [Arguments]    ${site_name}    ${region_id}   ${clli}   ${identity_id}   ${identity_url}   ${mso_id}    ${mso_pass}    ${admin_tenant}    ${member_role}    ${identity_server_type}    ${authentication_type}    ${project_domain_name}    ${user_domain_Name}
    ${arguments}=    Create Dictionary     site_name=${site_name}  region_id=${region_id}  clli=${clli}    identity_id=${identity_id}    identity_url=${identity_url}    mso_id=${mso_id}    mso_pass=${mso_pass}    admin_tenant=${admin_tenant}   member_role=${member_role}     identity_server_type=${identity_server_type}     authentication_type=${authentication_type}    project_domain_name=${project_domain_name}    user_domain_name=${user_domain_name}
    Log    ${arguments}
    ${data}=	Fill JSON Template File    ${SO_ADD_CLOUD_CONFIG_V3}     ${arguments}
    ${auth}=  Create List  ${GLOBAL_MSO_CATDB_USERNAME}    ${GLOBAL_MSO_PASSWORD}
    ${get_resp}=   Run Post Request   ${GLOBAL_SO_CATDB_ENDPOINT}    ${CLOUD_CONFIG_PATH}   ${data}    auth=${auth} 
    ${status_string}=    Convert To String    ${get_resp.status_code}
    Should Match Regexp    ${status_string} 	^(201|200)$

Update Cloud Configuration
    [Documentation]    Updates a cloud configuration in SO
    [Arguments]    ${site_name}    ${region_id}   ${clli}   ${identity_id}   ${identity_url}   ${mso_id}    ${mso_pass}    ${admin_tenant}    ${member_role}    ${identity_server_type}    ${authentication_type}
    ${arguments}=    Create Dictionary     site_name=${site_name}  region_id=${region_id}  clli=${clli}    identity_id=${identity_id}    identity_url=${identity_url}    mso_id=${mso_id}    mso_pass=${mso_pass}    admin_tenant=${admin_tenant}   member_role=${member_role}     identity_server_type=${identity_server_type}     authentication_type=${authentication_type}
    ${data}=    Fill JSON Template File    ${SO_ADD_CLOUD_CONFIG}     ${arguments}
    ${auth}=  Create List  ${GLOBAL_MSO_CATDB_USERNAME}    ${GLOBAL_MSO_PASSWORD}
    ${get_resp}=   Run Put Request   ${GLOBAL_SO_CATDB_ENDPOINT}    ${CLOUD_CONFIG_PATH}/${site_name}   ${data}    auth=${auth} 
    Should Be Equal As Strings  ${get_resp.status_code}     200
    [Return]   ${get_resp}
