*** Settings ***
Documentation   AAI CSIT-style tests for CCVPN - new schema elements introduced in Casablanca release for CCVPN use case
Default Tags    aai csit ccvpn
Test Timeout    10s
Resource    ${EXECDIR}/robot/resources/aai/ccvpn-connectivities.robot

*** Variables ***
${connectivity-id}=  robot-connectivity-test-1

*** Test Cases ***
Connectivity test case
    Confirm API Not Implemented Connectivity  ${connectivity-id}
    Confirm No Connectivity  ${connectivity-id}
    Create Connectivity If Not Exists  ${connectivity-id}
    Get Connectivity  ${connectivity-id}
    Delete Connectivity If Exists  ${connectivity-id}
    Confirm No Connectivity  ${connectivity-id}
    [Teardown]  Delete Connectivity If Exists  ${connectivity-id}
