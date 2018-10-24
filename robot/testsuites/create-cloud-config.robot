*** Settings ***
Documentation	  SO Cloud Config Test Cases
Test Timeout    1 minute


Resource          ../resources/so/create_cloud_config.robot


*** Test Cases ***
Create Cloud Config Test
    [TAGS]    mso    cloudconfig
    # Run Create Cloud Configuration    RegionOne   RegionOne   RegionOne    DEFAULT_KEYSTONE    identify_url:http://10.12.25.2:5000/v2.0    mso_id:demo  mso_pass:encrypted_password  admin_tenant:1e097c6713e74fd7ac8e4295e605ee1e    member_role:admin    identity_server_type:KEYSTONE    identity_authentication_type:USERNAME_PASSWORD
    Create Cloud Configuration    ${GLOBAL_INJECTED_REGION}   ${GLOBAL_INJECTED_REGION}  ${GLOBAL_INJECTED_REGION}   DEFAULT_KEYSTONE    ${GLOBAL_INJECTED_KEYSTONE}/${GLOBAL_INJECTED_OPENSTACK_KEYSTONE_API_VERSION}    ${GLOBAL_INJECTED_OPENSTACK_USERNAME}   ${GLOBAL_INJECTED_OPENSTACK_API_KEY}    ${GLOBAL_INJECTED_OPENSTACK_TENANT_ID}     admin    KEYSTONE    USERNAME_PASSWORD 

Get Cloud Config Test
    [TAGS]    mso    cloudconfig
    Get Cloud Configuration    ${GLOBAL_INJECTED_REGION}   
