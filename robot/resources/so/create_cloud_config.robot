*** Settings ***
Documentation	  Create Cloud Config

Resource    ../json_templater.robot
Resource    ../so_interface.robot
Library    OperatingSystem
Library    Collections


*** Variables ***
${CLOUD_CONFIG_PATH}    /cloudSite

${SYSTEM USER}    robot-ete
${SO_ADD_CLOUD_CONFIG}=   ../templates/so/create_cloud_config.template

*** Keywords ***
Create Cloud Configuration
    [Documentation]    Creates a cloud configuration in SO, so it knows how to talk to an openstack cloud
    [Arguments]    ${site_name}    ${region_id}   ${clli}   ${identity_id}   ${identity_url}   ${mso_id}    ${mso_pass}    ${admin_tenant}    ${member_role}    ${identity_server_type}    ${authentication_type}    
     ${arguments}=    Create Dictionary     site_name=${site_name}  region_id=${region_id}  clli=${clli}    identity_id=${identity_id}    identity_url=${identity_url}    mso_id=${mso_id}    mso_pass=${mso_pass}    admin_tenant=${admin_tenant}   member_role=${member_role}     identity_server_type=${identity_server_type}     authentication_type=${authentication_type}
    ${data}=	Fill JSON Template File    ${SO_ADD_CLOUD_CONFIG}    ${arguments}
    ${get_resp}=    Run MSO POST Request     ${CLOUD_CONFIG_PATH}/${site_name}     ${data}
    Return From Keyword If    '${get_resp.status_code}' == '200'