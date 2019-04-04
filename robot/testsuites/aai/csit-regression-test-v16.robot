*** Settings ***
Documentation   AAI CSIT-style regression tests for BBS - new schema elements introduced in Dublin release for BBS use case
Test Timeout    20s
Resource    ${EXECDIR}/robot/resources/aai/csit-customer.robot
Resource    ${EXECDIR}/robot/resources/aai/csit-service-subscription.robot
Resource    ${EXECDIR}/robot/resources/aai/csit-service-instance.robot
Resource    ${EXECDIR}/robot/resources/aai/csit-metadatum.robot
Resource    ${EXECDIR}/robot/resources/aai/csit-generic-vnf.robot
Resource    ${EXECDIR}/robot/resources/aai/csit-pnf.robot

*** Variables ***
${global_customer_id}=  robot-customer-test-1
${subscriber_name}=  robot-subscriber-name-1
${subscriber_type}=  robot-subscriber-type-1
${service_type}=  robot-service-type-1
${service_instance_id}=  robot-service-instance-1
${metaname1}=  robot-metaname-1
${metaval1}=  robot-metaval-1
${metaname2}=  robot-metaname-2
${metaval2}=  robot-metaval-2
${vnf_id}=  robot-gvnf-test-1
${vnf_type}=  robot-gvnf-type-1
${pnf_name}=  robot-pnf-name-1
${pnf_id}=  robot-pnf-id-1

*** Test Cases ***
Customer test case
    [Tags]    aai  csit  bbs  customer  csit_aai_bbs_customer
    Confirm API Not Implemented Customer  ${global_customer_id}
    Get Example Customer
    Confirm No Customer  ${global_customer_id}
    Create Customer If Not Exists  ${global_customer_id}  ${subscriber_name}  ${subscriber_type}
    ${get_resp}=  Get Customer  ${global_customer_id}
    ${nodes_resp}=  Get Nodes Query Customer  ${global_customer_id}
    [Teardown]  Run Keywords  Delete Customer If Exists  ${global_customer_id}  AND  Confirm No Customer  ${global_customer_id}

Service Subscription test case
    [Tags]    aai  csit  bbs  service-subscription  csit_aai_bbs_service-subscription
    [Setup]  Create Customer If Not Exists  ${global_customer_id}  ${subscriber_name}  ${subscriber_type}
    ${customer_url}=  Get Valid Customer URL  ${global_customer_id}
    Confirm API Not Implemented Service Subscription  ${service_type}
    Get Example Service Subscription
    Confirm No Service Subscription  ${customer_url}  ${service_type}
    Create Service Subscription If Not Exists  ${customer_url}  ${service_type}
    ${get_resp}=  Get Service Subscription  ${customer_url}  ${service_type}
    ${nodes_resp}=  Get Nodes Query Service Subscription  ${service_type}
    ${depth_resp}=  Get Object With Depth  ${customer_url}
    ${depth_resp_txt}=  Catenate  ${depth_resp}
    Should Match Regexp    ${depth_resp_txt}     ${service_type}
    [Teardown]  Run Keywords  Delete Service Subscription If Exists  ${customer_url}  ${service_type}  AND  Confirm No Service Subscription  ${customer_url}  ${service_type}  AND  Delete Customer If Exists  ${global_customer_id}  AND  Confirm No Customer  ${global_customer_id}

Service Instance test case
    [Tags]    aai  csit  bbs  service-instance  csit_aai_bbs_service-instance
    [Setup]  Create Customer If Not Exists  ${global_customer_id}  ${subscriber_name}  ${subscriber_type}
    ${customer_url}=  Get Valid Customer URL  ${global_customer_id}
    Create Service Subscription If Not Exists  ${customer_url}  ${service_type}
    ${subscription_url}=  Get Valid Service Subscription URL  ${customer_url}  ${service_type}
    Confirm API Not Implemented Service Instance  ${service_instance_id}
    Get Example Service Instance
    Confirm No Service Instance  ${subscription_url}  ${service_instance_id}
    Create Service Instance If Not Exists  ${subscription_url}  ${service_instance_id}
    ${get_resp}=  Get Service Instance  ${subscription_url}  ${service_instance_id}
    ${nodes_resp}=  Get Nodes Query Service Instance  ${service_instance_id}
    ${depth_resp}=  Get Object With Depth  ${subscription_url}
    ${depth_resp_txt}=  Catenate  ${depth_resp}
    Should Match Regexp    ${depth_resp_txt}     ${service_instance_id}
    [Teardown]  Run Keywords  Delete Service Instance If Exists  ${subscription_url}  ${service_instance_id}  AND  Confirm No Service Instance  ${subscription_url}  ${service_instance_id}  AND  Delete Customer If Exists  ${global_customer_id}  AND  Confirm No Customer  ${global_customer_id}

Metadatum test case
    [Tags]    aai  csit  bbs  metadatum  csit_aai_bbs_metadatum
    [Setup]  Create Customer If Not Exists  ${global_customer_id}  ${subscriber_name}  ${subscriber_type}
    ${customer_url}=  Get Valid Customer URL  ${global_customer_id}
    Create Service Subscription If Not Exists  ${customer_url}  ${service_type}
    ${subscription_url}=  Get Valid Service Subscription URL  ${customer_url}  ${service_type}
    Create Service Instance If Not Exists  ${subscription_url}  ${service_instance_id}
    ${sintance_url}=  Get Valid Service Instance URL  ${subscription_url}  ${service_instance_id}
    Confirm API Not Implemented Metadatum  ${metaname1}
    Get Example Metadatum
    Confirm No Metadatum  ${sintance_url}  ${metaname1}
    Create Metadatum If Not Exists  ${sintance_url}  ${metaname1}  ${metaval1}
    ${get_resp1}=  Get Metadatum  ${sintance_url}  ${metaname1}
    ${nodes_resp1}=  Get Nodes Query Metadatum  ${metaname1}
    Create Metadatum If Not Exists  ${sintance_url}  ${metaname2}  ${metaval2}
    ${get_resp2}=  Get Metadatum  ${sintance_url}  ${metaname2}
    ${nodes_resp2}=  Get Nodes Query Metadatum  ${metaname2}
    ${depth_resp}=  Get Object With Depth  ${sintance_url}
    ${depth_resp_txt}=  Catenate  ${depth_resp}
    Should Match Regexp    ${depth_resp_txt}     ${metaname1}
    Should Match Regexp    ${depth_resp_txt}     ${metaval1}
    Should Match Regexp    ${depth_resp_txt}     ${metaname2}
    Should Match Regexp    ${depth_resp_txt}     ${metaval2}
    [Teardown]  Run Keywords  Delete Metadatum If Exists  ${sintance_url}  ${metaname1}  AND  Confirm No Metadatum  ${sintance_url}  ${metaname1}  AND  Delete Customer If Exists  ${global_customer_id}  AND  Confirm No Customer  ${global_customer_id}

GenericVnf test case
    [Tags]    aai  csit  bbs  generic-vnf  csit_aai_bbs_generic-vnf
    Confirm API Not Implemented GenericVnf  ${vnf_id}
    Get Example GenericVnf
    Confirm No GenericVnf  ${vnf_id}
    Create GenericVnf If Not Exists  ${vnf_id}  ${vnf_type}
    ${get_resp}=  Get GenericVnf  ${vnf_id}
    ${nodes_resp}=  Get Nodes Query GenericVnf  ${vnf_id}
    [Teardown]  Run Keywords  Delete GenericVnf If Exists  ${vnf_id}  AND  Confirm No GenericVnf  ${vnf_id}

Pnf test case
    [Tags]    aai  csit  bbs  pnf  csit_aai_bbs_pnf
    Confirm API Not Implemented Pnf  ${pnf_name}
    Get Example Pnf
    Confirm No Pnf  ${pnf_name}
    Create Pnf If Not Exists  ${pnf_name}  ${pnf_id}
    ${get_resp}=  Get Pnf  ${pnf_name}
    ${nodes_resp}=  Get Nodes Query Pnf  ${pnf_name}
    [Teardown]  Run Keywords  Delete Pnf If Exists  ${pnf_name}  AND  Confirm No Pnf  ${pnf_name}

All Teardowns test case
    [Tags]    teardowns  csit_aai_bbs_teardowns
    Delete Customer If Exists  ${global_customer_id}
    Delete GenericVnf If Exists  ${vnf_id}
    Delete Pnf If Exists  ${pnf_name}
    Confirm No Customer  ${global_customer_id}
    Confirm No GenericVnf  ${vnf_id}
    Confirm No Pnf  ${pnf_name}

