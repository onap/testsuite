*** Settings ***
Documentation	  SO Cloud Config Test Cases
Test Timeout    1 minute

Library           ONAPLibrary.SO    WITH NAME    SO
Resource          ../resources/aai/create_tenant.robot


*** Test Cases ***
Create Cloud Config Test
    [TAGS]    so    cloudconfig
    # Run Create Cloud Configuration    RegionOne   RegionOne   RegionOne    DEFAULT_KEYSTONE    identify_url:http://10.12.25.2:5000/v2.0    mso_id:demo  mso_pass:encrypted_password  admin_tenant:1e097c6713e74fd7ac8e4295e605ee1e    member_role:admin    identity_server_type:KEYSTONE    identity_authentication_type:USERNAME_PASSWORD
    ${arguments}=    Create Dictionary     site_name=${GLOBAL_INJECTED_REGION}  region_id=${GLOBAL_INJECTED_REGION}  clli=${GLOBAL_INJECTED_REGION}    identity_id=DEFAULT_KEYSTONE    identity_url=${GLOBAL_INJECTED_KEYSTONE}/${GLOBAL_INJECTED_OPENSTACK_KEYSTONE_API_VERSION}    mso_id=${GLOBAL_INJECTED_OPENSTACK_USERNAME}    mso_pass=${GLOBAL_INJECTED_OPENSTACK_API_KEY}    admin_tenant=${GLOBAL_INJECTED_OPENSTACK_TENANT_ID}   member_role=admin     identity_server_type=KEYSTONE_V3     authentication_type=USERNAME_PASSWORD   
    ${auth}=  Create List  ${GLOBAL_SO_CATDB_USERNAME}    ${GLOBAL_SO_PASSWORD}
    SO.Upsert Cloud Configuration    ${GLOBAL_SO_CATDB_ENDPOINT}    ${GLOBAL_SO_CLOUD_CONFIG_PATH}    ${GLOBAL_TEMPLATE_FOLDER}    ${GLOBAL_SO_CLOUD_CONFIG_TEMPLATE}    ${arguments}    auth=${auth}

Create Cloud Config RegionThree V3 Test
    [TAGS]    so    cloudconfig  cloudconfigv3
    [Documentation]   Create Keystone V3 in Region 3
    ...  [Arguments]    ${site_name}    ${region_id}   ${clli}   ${identity_id}   ${identity_url}   ${mso_id}    ${mso_pass}    
    ...      ${admin_tenant}    ${member_role}    ${identity_server_type}    ${authentication_type}    ${project_domain_name}    ${user_domain_Name}
    ...  ${region_id} in openstack is set up by cloud administration and does not have to be same as ONAP ${site_name}
    ...  In Windriver/Intel test labs the os_region_id's are all set to "RegionOne"
    ...  clli by testing team convention is same as onap site_name
    ...  KEYSTONE URL should end in /v3 SO will put /auth when KEYSTONE_V3 is the identity_server_type
    ${arguments}=    Create Dictionary     site_name=${GLOBAL_INJECTED_REGION_THREE}  region_id=${GLOBAL_INJECTED_REGION}  clli=${GLOBAL_INJECTED_REGION_THREE}    identity_id=REGION_THREE_KEYSTONE    identity_url=${GLOBAL_INJECTED_KEYSTONE_REGION_THREE}/${GLOBAL_INJECTED_OPENSTACK_KEYSTONE_API_VERSION_REGION_THREE}    mso_id=${GLOBAL_INJECTED_OPENSTACK_USERNAME_REGION_THREE}    mso_pass=${GLOBAL_INJECTED_OPENSTACK_SO_ENCRYPTED_PASSWORD_REGION_THREE}    admin_tenant=${GLOBAL_INJECTED_OPENSTACK_TENANT_ID_REGION_THREE}   member_role=admin     identity_server_type=KEYSTONE_V3     authentication_type=USERNAME_PASSWORD    project_domain_name=${GLOBAL_INJECTED_OPENSTACK_PROJECT_DOMAIN_REGION_THREE}    user_domain_name=${GLOBAL_INJECTED_OPENSTACK_USER_DOMAIN_REGION_THREE}     
    ${auth}=  Create List  ${GLOBAL_SO_CATDB_USERNAME}    ${GLOBAL_SO_PASSWORD}
    SO.Upsert Cloud Configuration    ${GLOBAL_SO_CATDB_ENDPOINT}    ${GLOBAL_SO_CLOUD_CONFIG_PATH}    ${GLOBAL_TEMPLATE_FOLDER}    ${GLOBAL_SO_CLOUD_CONFIG_TEMPLATE}    ${arguments}    auth=${auth}
    Inventory Tenant If Not Exists    CloudOwner   ${GLOBAL_INJECTED_REGION_THREE}  SharedNode  OwnerType  v1  CloudZone  ${GLOBAL_INJECTED_OPENSTACK_TENANT_ID_REGION_THREE}  ${GLOBAL_INJECTED_OPENSTACK_PROJECT_DOMAIN_REGION_THREE}

Get Cloud Config Test
    [TAGS]    mso    cloudconfig
    ${auth}=  Create List  ${GLOBAL_SO_CATDB_USERNAME}    ${GLOBAL_SO_PASSWORD}
    ${get_resp}=    SO.Get Cloud Configuration    ${GLOBAL_SO_CATDB_ENDPOINT}    ${GLOBAL_SO_CLOUD_CONFIG_PATH}	${GLOBAL_INJECTED_REGION}   auth=${auth} 
    Should Be Equal As Strings  ${get_resp.status_code}     200