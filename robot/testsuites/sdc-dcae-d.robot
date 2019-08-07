*** Settings ***
Library           ONAPLibrary.Utilities

Resource          ../resources/sdc_interface.robot
Resource          ../resources/sdc_dcaed_interface.robot

*** Test Cases ***
# This test case implements the steps described in
# https://wiki.onap.org/display/DW/How+to+Create+a+Service+with+a+Monitoring+Configuration+using+SDC
Create Service With Monitoring Configuration Test
    [Tags]  sdc-dcae-d
    [Documentation]   Create a service with a monitoring configuration 

    ${unique_postfix}=  Generate Unique Postfix
    ${test_vf_name}=   Set Variable   TestVF_${unique_postfix}
    ${test_cs_name}=   Set Variable   TestService_${unique_postfix}
    ${test_vfcmt_name}=   Set Variable   TestVFCMT_${unique_postfix}
    ${test_mc_name}=   Set Variable   TestMC_${unique_postfix}

    ${cert_vf_unique_id}    ${cert_vf_uuid}   Onboard DCAE Microservice   ${test_vf_name}
    ${cert_vfcmt_uuid}   Create Monitoring Template   ${test_vfcmt_name}   ${cert_vf_uuid}
    ${cs_unique_id}   Create Monitoring Configuration   ${test_cs_name}   ${cert_vf_unique_id}   ${test_vf_name}   ${cert_vfcmt_uuid}   ${test_mc_name}
    Approve Service    ${cs_unique_id}

*** Keywords ***
Generate Unique Postfix
    [Documentation]   Create and return unique postfix to be used in various unique names  
    ${tmp_id} =   Generate Timestamp
    ${tmp_str} =   Convert To String   ${tmp_id}
    [return]    ${tmp_str}

Create Monitoring Template
    [Documentation]   Create a new monitoring template containing the DCAE VF, certify it and return the uuid   
    [Arguments]   ${vfcmt_name}   ${vf_uuid}
    ${vfcmt_uuid}   sdc_dcaed_interface.Add VFCMT To DCAE-DS   ${vfcmt_name}
    sdc_dcaed_interface.Save Composition   ${vfcmt_uuid}   ${vf_uuid}

    # Note that certification is not instructed in
    # https://wiki.onap.org/display/DW/How+to+Create+a+Service+with+a+Monitoring+Configuration+using+SDC
    # due to limitations of GUI so this test case goes beyond the instructions at this certification step

    ${cert_vfcmt_uuid}   sdc_dcaed_interface.Certify VFCMT   ${vfcmt_uuid}
    [return]   ${cert_vfcmt_uuid}

Create Monitoring Configuration
    [Documentation]   Create a monitoring configuration for a given service based on a previously created VFCMT 
    ...               Return the unique_id of the created catalog service for the monitoring configuration
    [Arguments]   ${service_name}   ${vf_unique_id}   ${vf_name}   ${vfcmt_uuid}   ${mc_name}
    ${cs_unique_id}   ${cs_uuid}    sdc_interface.Add Catalog Service For Monitoring Template   ${service_name}
# TODO: Some refactoring to do, we need also the vf_name in addition to the uuid
    ${vfi_uuid}  ${vfi_name}   sdc_interface.Add SDC Resource Instance   ${cs_unique_id}   ${vf_unique_id}   ${vf_name}
    ${mc_uuid}   sdc_dcaed_interface.Add Monitoring Configuration To DCAE-DS  ${vfcmt_uuid}   ${cs_uuid}    ${vfi_name}   ${mc_name}
    sdc_dcaed_interface.Submit Monitoring Configuration To DCAE-DS   ${mc_uuid}   ${cs_uuid}  ${vfi_name}
    [return]   ${cs_unique_id}

# TODO: Add also distribution here?
Approve Service
    [Documentation]    Perform the required steps to certify and approve the given ASDC catalog service
    [Arguments]    ${cs_unique_id}

    sdc_interface.Checkin SDC Catalog Service    ${cs_unique_id}
    sdc_interface.Request Certify SDC Catalog Service    ${cs_unique_id}
    sdc_interface.Start Certify SDC Catalog Service    ${cs_unique_id}
    ${cert_cs_unique_id}=    sdc_interface.Certify SDC Catalog Service    ${cs_unique_id}
    sdc_interface.Approve SDC Catalog Service    ${cert_cs_unique_id}

