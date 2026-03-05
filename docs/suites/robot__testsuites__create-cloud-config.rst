Suite: robot/testsuites/create-cloud-config.robot
=================================================

Suite Metadata
--------------

- **Source file:** ``robot/testsuites/create-cloud-config.robot``
- **Suite documentation:** SO Cloud Config Test Cases
- **Default test timeout:** ``1 minute``
- **Total test cases:** 3

Test Cases
----------

Create Cloud Config Test
~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Create Cloud Config Test``
- **Tags:** ``so``, ``cloudconfig``
- **Step count:** 3
- **First step:** ``${arguments}= Create Dictionary site_name=${GLOBAL_INJECTED_REGION} region_id=${GLOBAL_INJECTED_REGION} clli=${GLOBAL_INJECTED_REGION} identity_id=DEFAULT_KEYSTONE identity_url=${GLOBAL_INJECTED_KEYSTONE}/${GLOBAL_INJECTED_OPENSTACK_KEYSTONE_API_VERSION} mso_id=${GLOBAL_INJECTED_OPENSTACK_USERNAME} mso_pass=${GLOBAL_INJECTED_OPENSTACK_API_KEY} admin_tenant=${GLOBAL_INJECTED_OPENSTACK_TENANT_ID} member_role=admin identity_server_type=KEYSTONE_V3 authentication_type=USERNAME_PASSWORD``

Create Cloud Config RegionThree V3 Test
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Documentation:** Create Keystone V3 in Region 3 [Arguments]    ${site_name}    ${region_id}   ${clli}   ${identity_id}   ${identity_url}   ${mso_id}    ${mso_pass} ${admin_tenant}    ${member_role}    ${identity_server_type}    ${authentication_type}    ${project_domain_name}    ${user_domain_Name} ${region_id} in openstack is set up by cloud administration and does not have to be same as ONAP ${site_name} In Windriver/Intel test labs the os_region_id's are all set to "RegionOne" clli by testing team convention is same as onap site_name KEYSTONE URL should end in /v3 SO will put /auth when KEYSTONE_V3 is the identity_server_type

- **Name:** ``Create Cloud Config RegionThree V3 Test``
- **Tags:** ``so``, ``cloudconfig``, ``cloudconfigv3``
- **Step count:** 4
- **First step:** ``${arguments}= Create Dictionary site_name=${GLOBAL_INJECTED_REGION_THREE} region_id=${GLOBAL_INJECTED_REGION} clli=${GLOBAL_INJECTED_REGION_THREE} identity_id=REGION_THREE_KEYSTONE identity_url=${GLOBAL_INJECTED_KEYSTONE_REGION_THREE}/${GLOBAL_INJECTED_OPENSTACK_KEYSTONE_API_VERSION_REGION_THREE} mso_id=${GLOBAL_INJECTED_OPENSTACK_USERNAME_REGION_THREE} mso_pass=${GLOBAL_INJECTED_OPENSTACK_SO_ENCRYPTED_PASSWORD_REGION_THREE} admin_tenant=${GLOBAL_INJECTED_OPENSTACK_TENANT_ID_REGION_THREE} member_role=admin identity_server_type=KEYSTONE_V3 authentication_type=USERNAME_PASSWORD project_domain_name=${GLOBAL_INJECTED_OPENSTACK_PROJECT_DOMAIN_REGION_THREE} user_domain_name=${GLOBAL_INJECTED_OPENSTACK_USER_DOMAIN_REGION_THREE}``

Get Cloud Config Test
~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Get Cloud Config Test``
- **Tags:** ``mso``, ``cloudconfig``
- **Step count:** 3
- **First step:** ``${auth}= Create List ${GLOBAL_SO_CATDB_USERNAME} ${GLOBAL_SO_PASSWORD}``

Possible Improvements
---------------------

- Keep suite documentation aligned with current ONAP release behavior and update references when endpoints or flows change.
- Add `[Documentation]` to 2 test case(s) to explain intent, preconditions, and expected outcome.
- Review tag naming consistency (for example `health-*`, `instantiate*`, `ete`) to keep filtering and reporting uniform.
- Add teardown cleanup checks so repeated runs are idempotent and less sensitive to residual state.
