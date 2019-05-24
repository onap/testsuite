*** Settings ***
Documentation	  SO Cloud Config Test Cases
Test Timeout    1 minute


Resource          ../resources/so_interface.robot
Resource          ../resources/aai/create_tenant.robot


*** Test Cases ***
Create Cloud Config Test
    [TAGS]    mso    cloudconfig
    # Run Create Cloud Configuration    RegionOne   RegionOne   RegionOne    DEFAULT_KEYSTONE    identify_url:http://10.12.25.2:5000/v2.0    mso_id:demo  mso_pass:encrypted_password  admin_tenant:1e097c6713e74fd7ac8e4295e605ee1e    member_role:admin    identity_server_type:KEYSTONE    identity_authentication_type:USERNAME_PASSWORD
    Create Cloud Configuration    ${GLOBAL_INJECTED_REGION}   ${GLOBAL_INJECTED_REGION}  ${GLOBAL_INJECTED_REGION}   DEFAULT_KEYSTONE    ${GLOBAL_INJECTED_KEYSTONE}/${GLOBAL_INJECTED_OPENSTACK_KEYSTONE_API_VERSION}    ${GLOBAL_INJECTED_OPENSTACK_USERNAME}   ${GLOBAL_INJECTED_OPENSTACK_API_KEY}    ${GLOBAL_INJECTED_OPENSTACK_TENANT_ID}     admin    KEYSTONE    USERNAME_PASSWORD 

Create Cloud Config RegionThree V3 Test
    [TAGS]    mso    cloudconfig  cloudconfigv3
    [Documentation]   Create Keystone V3 in Region 3
    ...  [Arguments]    ${site_name}    ${region_id}   ${clli}   ${identity_id}   ${identity_url}   ${mso_id}    ${mso_pass}    
    ...      ${admin_tenant}    ${member_role}    ${identity_server_type}    ${authentication_type}    ${project_domain_name}    ${user_domain_Name}
    ...  ${region_id} in openstack is set up by cloud administration and does not have to be same as ONAP ${site_name}
    ...  In Windriver/Intel test labs the os_region_id's are all set to "RegionOne"
    ...  clli by testing team convention is same as onap site_name
    ...  KEYSTONE URL should end in /v3 SO will put /auth when KEYSTONE_V3 is the identity_server_type
    Create Cloud Configuration v3    ${GLOBAL_INJECTED_REGION_THREE}   ${GLOBAL_INJECTED_REGION}  ${GLOBAL_INJECTED_REGION_THREE}   REGION_THREE_KEYSTONE    ${GLOBAL_INJECTED_KEYSTONE_REGION_THREE}/${GLOBAL_INJECTED_OPENSTACK_KEYSTONE_API_VERSION_REGION_THREE}     ${GLOBAL_INJECTED_OPENSTACK_USERNAME_REGION_THREE}   ${GLOBAL_INJECTED_OPENSTACK_MSO_ENCRYPTED_PASSWORD_REGION_THREE}    ${GLOBAL_INJECTED_OPENSTACK_TENANT_ID_REGION_THREE}     admin    KEYSTONE_V3    USERNAME_PASSWORD  ${GLOBAL_INJECTED_OPENSTACK_PROJECT_DOMAIN_REGION_THREE}  ${GLOBAL_INJECTED_OPENSTACK_USER_DOMAIN_REGION_THREE}
    Inventory Tenant If Not Exists    CloudOwner   ${GLOBAL_INJECTED_REGION_THREE}  SharedNode  OwnerType  v1  CloudZone  ${GLOBAL_INJECTED_OPENSTACK_TENANT_ID_REGION_THREE}  ${GLOBAL_INJECTED_OPENSTACK_PROJECT_DOMAIN_REGION_THREE}


Get Cloud Config Test
    [TAGS]    mso    cloudconfig
    Get Cloud Configuration    ${GLOBAL_INJECTED_REGION}   
