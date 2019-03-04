*** Settings ***
Documentation   AAI CSIT-style regression tests for CCVPN - new schema elements introduced in Casablanca release for CCVPN use case
Default Tags    aai csit ccvpn
Test Timeout    10s
Resource    ${EXECDIR}/robot/resources/aai/ccvpn-connectivities.robot

*** Variables ***
${connectivity_id}=  robot-connectivity-test-1

*** Test Cases ***
Connectivity test case
    Confirm API Not Implemented Connectivity  ${connectivity_id}
    Confirm No Connectivity  ${connectivity_id}
    Create Connectivity If Not Exists  ${connectivity_id}
    Get Connectivity  ${connectivity_id}
    Delete Connectivity If Exists  ${connectivity_id}
    Confirm No Connectivity  ${connectivity_id}
    [Teardown]  Delete Connectivity If Exists  ${connectivity_id}
