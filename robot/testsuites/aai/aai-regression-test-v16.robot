*** Settings ***
Documentation   AAI CSIT-style regression tests for BBS - new schema elements introduced in Dublin release for BBS use case
Test Timeout    20s
Resource    ${EXECDIR}/robot/resources/aai/bbs-customer.robot
Resource    ${EXECDIR}/robot/resources/aai/bbs-generic-vnf.robot
Resource    ${EXECDIR}/robot/resources/aai/bbs-pnf.robot

*** Variables ***
${global_customer_id}=  robot-customer-test-1
${subscriber_name}=  robot-subscriber-name-1
${subscriber_type}=  robot-subscriber-type-1
${vnf_id}=  robot-gvnf-test-1
${vnf_type}=  robot-gvnf-type-1
${pnf_name}=  robot-pnf-name-1
${pnf_id}=  robot-pnf-id-1

*** Test Cases ***
Customer test case
    [Tags]    aai  csit  bbs  customer
    Get Example Customer
    Confirm No Customer  ${global_customer_id}
    Create Customer If Not Exists  ${global_customer_id}  ${subscriber_name}  ${subscriber_type}
    Get Customer  ${global_customer_id}
    [Teardown]  Run Keywords  Delete Customer If Exists  ${global_customer_id}  AND  Confirm No Customer  ${global_customer_id}

GenericVnf test case
    [Tags]    aai  csit  bbs  generic-vnf
    Get Example GenericVnf
    Confirm No GenericVnf  ${vnf_id}
    Create GenericVnf If Not Exists  ${vnf_id}  ${vnf_type}
    Get GenericVnf  ${vnf_id}
    [Teardown]  Run Keywords  Delete GenericVnf If Exists  ${vnf_id}  AND  Confirm No GenericVnf  ${vnf_id}

Pnf test case
    [Tags]    aai  csit  bbs  pnf
    Get Example Pnf
    Confirm No Pnf  ${pnf_name}
    Create Pnf If Not Exists  ${pnf_name}  ${pnf_id}
    Get Pnf  ${pnf_name}
    [Teardown]  Run Keywords  Delete Pnf If Exists  ${pnf_name}  AND  Confirm No Pnf  ${pnf_name}

All Teardowns test case
    [Tags]    teardowns
    Delete Customer If Exists  ${global_customer_id}
    Delete GenericVnf If Exists  ${vnf_id}
    Delete Pnf If Exists  ${pnf_name}
    Confirm No Customer  ${global_customer_id}
    Confirm No GenericVnf  ${vnf_id}
    Confirm No Pnf  ${pnf_name}

