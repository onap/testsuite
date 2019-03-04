*** Settings ***
Documentation   AAI Casablanca CCVPN test - new schema elements introduced in Casablanca release for CCVPN use case
Default Tags    AAI-Casablanca-CCVPN
Test Timeout    10s
Resource    ${EXECDIR}/robot/resources/global_properties.robot
Resource    ${EXECDIR}/robot/resources/aai/ccvpn-connectivities.robot

*** Variables ***
${connectivity-id}=  robot-connectivity-test-1

*** Test Cases ***
Connectivity test case
    [Setup]  Confirm No Connectivity  ${connectivity-id}
    Confirm Not Beijing Connectivity  ${connectivity-id}
    Confirm No Connectivity  ${connectivity-id}
    Create Connectivity If Not Exists  ${connectivity-id}
    Get Connectivity  ${connectivity-id}
    Delete Connectivity If Exists  ${connectivity-id}
    Confirm No Connectivity  ${connectivity-id}
    [Teardown]  Delete Connectivity If Exists  ${connectivity-id}
