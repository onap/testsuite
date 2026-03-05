Suite: robot/testsuites/demo.robot
==================================

Suite Metadata
--------------

- **Source file:** ``robot/testsuites/demo.robot``
- **Suite documentation:** Executes the VNF Orchestration Test cases including setup and teardown
- **Total test cases:** 21

Test Cases
----------

Initialize Customer And Models
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Initialize Customer And Models``
- **Tags:** ``InitDemo``
- **Step count:** 2
- **First step:** ``Load Customer And Models Demonstration``

Initialize SO Openstack Identity For V3
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Initialize SO Openstack Identity For V3``
- **Tags:** ``InitDemo``
- **Step count:** 3
- **First step:** ``${arguments}= Create Dictionary site_name=${GLOBAL_INJECTED_REGION} region_id=${GLOBAL_INJECTED_REGION} clli=${GLOBAL_INJECTED_REGION} identity_id=DEFAULT_KEYSTONE identity_url=${GLOBAL_INJECTED_KEYSTONE}/${GLOBAL_INJECTED_OPENSTACK_KEYSTONE_API_VERSION} mso_id=${GLOBAL_INJECTED_OPENSTACK_USERNAME} mso_pass=${GLOBAL_INJECTED_OPENSTACK_SO_ENCRYPTED_PASSWORD} admin_tenant=${GLOBAL_INJECTED_OPENSTACK_TENANT_ID} member_role=admin identity_server_type=KEYSTONE_V3 authentication_type=USERNAME_PASSWORD project_domain_name=${GLOBAL_INJECTED_OPENSTACK_DOMAIN_ID} user_domain_name=${GLOBAL_INJECTED_OPENSTACK_USER_DOMAIN}``

Initialize vCPE Models
~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Initialize vCPE Models``
- **Tags:** ``distributeVCPE``
- **Step count:** 1
- **First step:** ``Load vCPE Models Demonstration``

Initialize Customer
~~~~~~~~~~~~~~~~~~~

- **Name:** ``Initialize Customer``
- **Tags:** ``InitCustomer``
- **Step count:** 2
- **First step:** ``Load Customer Demonstration``

Initialize Models
~~~~~~~~~~~~~~~~~

- **Name:** ``Initialize Models``
- **Tags:** ``InitDistribution``
- **Step count:** 1
- **First step:** ``Load Models Demonstration``

Preload VNF
~~~~~~~~~~~

- **Name:** ``Preload VNF``
- **Tags:** ``PreloadDemo``
- **Step count:** 1
- **First step:** ``Preload User Model ${VNF_NAME} ${MODULE_NAME} ${SERVICE} ${SERVICE_INSTANCE_ID}``

Preload VNF GRA
~~~~~~~~~~~~~~~

- **Name:** ``Preload VNF GRA``
- **Tags:** ``PreloadDemoGRA``
- **Step count:** 2
- **First step:** ``Set Global Variable ${API_TYPE} GRA_API``

Instantiate VFW
~~~~~~~~~~~~~~~

- **Name:** ``Instantiate VFW``
- **Tags:** ``instantiateVFW``
- **Step count:** 1
- **First step:** ``Instantiate VNF vFW base_vfw``

Instantiate Demo VFWCL
~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Instantiate Demo VFWCL``
- **Tags:** ``instantiateDemoVFWCL``
- **Step count:** 1
- **First step:** ``Instantiate Demo VNF vFWCL base_vpkg``

Instantiate Demo VFWCL GRA
~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Instantiate Demo VFWCL GRA``
- **Tags:** ``instantiateDemoVFWCLGRA``
- **Step count:** 2
- **First step:** ``Set Global Variable ${API_TYPE} GRA_API``

Instantiate VFWCL
~~~~~~~~~~~~~~~~~

- **Name:** ``Instantiate VFWCL``
- **Tags:** ``instantiateVFWCL``
- **Step count:** 1
- **First step:** ``Instantiate VNF vFWCL base_vpkg``

Instantiate VFWCL GRA
~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Instantiate VFWCL GRA``
- **Tags:** ``instantiateVFWCLGRA``
- **Step count:** 2
- **First step:** ``Set Global Variable ${API_TYPE} GRA_API``

Instantiate VFWCL DANOS
~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Instantiate VFWCL DANOS``
- **Tags:** ``instantiateVFWCLDN``
- **Step count:** 2
- **First step:** ``Set Global Variable ${API_TYPE} GRA_API``

Instantiate VLB GRA
~~~~~~~~~~~~~~~~~~~

- **Name:** ``Instantiate VLB GRA``
- **Tags:** ``instantiateVLBGRA``
- **Step count:** 2
- **First step:** ``Set Global Variable ${API_TYPE} GRA_API``

Instantiate VFWDT GRA
~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Instantiate VFWDT GRA``
- **Tags:** ``instantiateVFWDTGRA``
- **Step count:** 2
- **First step:** ``Set Global Variable ${API_TYPE} GRA_API``

Instantiate VFWDT
~~~~~~~~~~~~~~~~~

- **Name:** ``Instantiate VFWDT``
- **Tags:** ``instantiateVFWDT``
- **Step count:** 1
- **First step:** ``Instantiate VNF vFWDT base_vpkg``

Instantiate VLB_CDS
~~~~~~~~~~~~~~~~~~~

- **Name:** ``Instantiate VLB_CDS``
- **Tags:** ``instantiateVLB_CDS``
- **Step count:** 1
- **First step:** ``Instantiate VNF CDS vLB_CDS demoVLB_CDS``

Delete Instantiated VNF
~~~~~~~~~~~~~~~~~~~~~~~

**Documentation:** This test assumes all necessary variables are loaded via the variable file create in Save For Delete The Teardown VNF needs to be in the teardown step of the test case...

- **Name:** ``Delete Instantiated VNF``
- **Tags:** ``deleteVNF``
- **Teardown:** ``Teardown VNF ${CUSTOMER_NAME} ${CATALOG_SERVICE_ID} ${CATALOG_RESOURCE_IDS}``
- **Step count:** 3
- **First step:** ``Setup Browser``

Distribute vFWNG CDS Model
~~~~~~~~~~~~~~~~~~~~~~~~~~

**Documentation:** Distribute vFWNG for CDS

- **Name:** ``Distribute vFWNG CDS Model``
- **Tags:** ``DistributeVFWNG``
- **Timeout:** ``600``
- **Step count:** 1
- **First step:** ``Model Distribution For Directory service=vFWNG cds=vfwng``

Distribute Demo vFWDT Model
~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Documentation:** Distribute Demo vFWDT (does not delete model after distribution)

- **Name:** ``Distribute Demo vFWDT Model``
- **Tags:** ``DistributeDemoVFWDT``
- **Timeout:** ``600``
- **Step count:** 1
- **First step:** ``Model Distribution For Directory service=vFWDT``

Download Service CSAR To Robot
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Download Service CSAR To Robot``
- **Tags:** ``downloadCsar``
- **Step count:** 1
- **First step:** ``Download CSAR ${CATALOG_SERVICE_ID}``

Possible Improvements
---------------------

- Keep suite documentation aligned with current ONAP release behavior and update references when endpoints or flows change.
- Add `[Documentation]` to 18 test case(s) to explain intent, preconditions, and expected outcome.
- Review tag naming consistency (for example `health-*`, `instantiate*`, `ete`) to keep filtering and reporting uniform.
- Consider defining a suite-level `Test Timeout` baseline and keep only justified per-test overrides.
