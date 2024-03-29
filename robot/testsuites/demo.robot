*** Settings ***
Documentation	  Executes the VNF Orchestration Test cases including setup and teardown

Library           ONAPLibrary.SO    WITH NAME    SO
Library   Collections
Resource         ../resources/demo_preload.robot

*** Variables ***

${VNF_NAME}       DemoVNF
${MODULE_NAME}    DemoModuleName

${HB_STACK}
${HB_SERVICE}
${HB_IPV4_OAM_ADDRESS}
${TENANT_NAME}
${VVG_SERVER_ID}
${SERVICE}
${CUSTOMER_NAME}
${SERVICE_INSTANCE_ID}
${STACK_NAMES}
${CATALOG_SERVICE_ID}
${CATALOG_RESOURCE_IDS}
${REVERSE_HEATBRIDGE}
${HB_VNF}

${API_TYPE}   GRA_API

*** Test Cases ***
Initialize Customer And Models
    [Tags]   InitDemo
    Load Customer And Models   Demonstration
    Load Customer   SDN-ETHERNET-INTERNET

Initialize SO Openstack Identity For V3
    [Tags]   InitDemo
    ${arguments}=    Create Dictionary    site_name=${GLOBAL_INJECTED_REGION}    region_id=${GLOBAL_INJECTED_REGION}    clli=${GLOBAL_INJECTED_REGION}    identity_id=DEFAULT_KEYSTONE    identity_url=${GLOBAL_INJECTED_KEYSTONE}/${GLOBAL_INJECTED_OPENSTACK_KEYSTONE_API_VERSION}    mso_id=${GLOBAL_INJECTED_OPENSTACK_USERNAME}    mso_pass=${GLOBAL_INJECTED_OPENSTACK_SO_ENCRYPTED_PASSWORD}    admin_tenant=${GLOBAL_INJECTED_OPENSTACK_TENANT_ID}    member_role=admin    identity_server_type=KEYSTONE_V3     authentication_type=USERNAME_PASSWORD    project_domain_name=${GLOBAL_INJECTED_OPENSTACK_DOMAIN_ID}    user_domain_name=${GLOBAL_INJECTED_OPENSTACK_USER_DOMAIN}
    ${auth}=  Create List  ${GLOBAL_SO_CATDB_USERNAME}    ${GLOBAL_SO_PASSWORD}
    Run Keyword If    '${GLOBAL_INJECTED_OPENSTACK_KEYSTONE_API_VERSION}'=='v3'     SO.Upsert Cloud Configuration    ${GLOBAL_SO_CATDB_ENDPOINT}    ${GLOBAL_SO_CLOUD_CONFIG_PATH}    ${GLOBAL_TEMPLATE_FOLDER}    ${GLOBAL_SO_CLOUD_CONFIG_TEMPLATE}    ${arguments}    auth=${auth}

Initialize vCPE Models
   [Tags]  distributeVCPE
   Load vCPE Models  Demonstration

Initialize Customer
    [Tags]   InitCustomer
    Load Customer   Demonstration
    Load Customer   SDN-ETHERNET-INTERNET

Initialize Models
    [Tags]   InitDistribution
    Load Models   Demonstration

Preload VNF
    [Tags]   PreloadDemo
    Preload User Model   ${VNF_NAME}   ${MODULE_NAME}    ${SERVICE}    ${SERVICE_INSTANCE_ID}

Preload VNF GRA
    [Tags]   PreloadDemoGRA
    Set Global Variable    ${API_TYPE}   GRA_API
    Preload User Model   ${VNF_NAME}   ${MODULE_NAME}    ${SERVICE}    ${SERVICE_INSTANCE_ID}

Instantiate VFW
    [Tags]   instantiateVFW
    Instantiate VNF   vFW   base_vfw

Instantiate Demo VFWCL
    [Tags]   instantiateDemoVFWCL
    Instantiate Demo VNF   vFWCL   base_vpkg

Instantiate Demo VFWCL GRA
    [Tags]   instantiateDemoVFWCLGRA
    Set Global Variable    ${API_TYPE}   GRA_API
    Instantiate Demo VNF   vFWCL   base_vpkg

Instantiate VFWCL
    [Tags]   instantiateVFWCL
    Instantiate VNF   vFWCL  base_vpkg

Instantiate VFWCL GRA
    [Tags]   instantiateVFWCLGRA
    Set Global Variable    ${API_TYPE}   GRA_API
    Instantiate VNF   vFWCL  base_vpkg

Instantiate VFWCL DANOS
    [Tags]   instantiateVFWCLDN
    Set Global Variable    ${API_TYPE}   GRA_API
    Instantiate VNF   vFWCLDN   base_vpkg

Instantiate VLB GRA
    [Tags]   instantiateVLBGRA
    Set Global Variable    ${API_TYPE}   GRA_API
    Instantiate VNF   vLB  base_vpkg

Instantiate VFWDT GRA
    [Tags]   instantiateVFWDTGRA
    Set Global Variable    ${API_TYPE}   GRA_API
    Instantiate VNF   vFWDT  base_vpkg


Instantiate VFWDT
    [Tags]   instantiateVFWDT
    Instantiate VNF   vFWDT  base_vpkg

Instantiate VLB_CDS
    [Tags]   instantiateVLB_CDS
    Instantiate VNF CDS    vLB_CDS   demoVLB_CDS

Delete Instantiated VNF
    [Documentation]   This test assumes all necessary variables are loaded via the variable file create in  Save For Delete
    ...    The Teardown VNF needs to be in the teardown step of the test case...
    [Tags]   deleteVNF
    Setup Browser
    Login To VID GUI
    Delete VNF    ${TENANT_NAME}    ${VVG_SERVER_ID}    ${CUSTOMER_NAME}    ${SERVICE_INSTANCE_ID}    ${STACK_NAMES}    ${REVERSE_HEATBRIDGE}
    [Teardown]   Teardown VNF    ${CUSTOMER_NAME}    ${CATALOG_SERVICE_ID}    ${CATALOG_RESOURCE_IDS}

#Run Heatbridge
#    [Documentation]
#    ...    Try to run heatbridge
#    [Tags]   heatbridge
#    Execute Heatbridge   ${HB_STACK}   ${HB_VNF}    ${HB_SERVICE}    ${HB_IPV4_OAM_ADDRESS}

Distribute vFWNG CDS Model
    [Documentation]    Distribute vFWNG for CDS
    [Tags]    DistributeVFWNG
    [Timeout]    600
    Model Distribution For Directory    service=vFWNG    cds=vfwng

Distribute Demo vFWDT Model
    [Documentation]    Distribute Demo vFWDT  (does not delete model after distribution)
    [Tags]    DistributeDemoVFWDT
    [Timeout]    600
    Model Distribution For Directory    service=vFWDT

Download Service CSAR To Robot
    [Tags]   downloadCsar
    Download CSAR   ${CATALOG_SERVICE_ID}
