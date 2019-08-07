*** Settings ***
Resource          ../resources/sdc_interface.robot
Resource          ../resources/sdc_dcaed_interface.robot

*** Test Cases ***
# This test case implements the steps described in
# https://wiki.onap.org/display/DW/How+to+Create+a+Service+with+a+Monitoring+Configuration+using+SDC
Create Service With Monitoring Configuration Test
    [Tags]  sdc-dcae-d
    [Documentation]   Create a service with a monitoring configuration

    ${unique_postfix}=  sdc_interface.Generate Unique Postfix
    ${test_vf_name}=   Set Variable   TestVF_${unique_postfix}
    ${test_cs_name}=   Set Variable   TestService_${unique_postfix}
    ${test_vfcmt_name}=   Set Variable   TestVFCMT_${unique_postfix}
    ${test_mc_name}=   Set Variable   TestMC_${unique_postfix}

    ${cert_vf_unique_id}    ${cert_vf_uuid}   sdc_interface.Onboard DCAE Microservice   ${test_vf_name}
    ${cert_vfcmt_uuid}   sdc_dcaed_interface.Create Monitoring Template   ${test_vfcmt_name}   ${cert_vf_uuid}
    ${cs_unique_id}   ${cs_uuid}    ${vfi_name}   sdc_interface.Create Monitoring Configuration   ${test_cs_name}   ${cert_vf_unique_id}   ${test_vf_name}
    sdc_dcaed_interface.Create Monitoring Configuration To DCAE-DS   ${cert_vfcmt_uuid}   ${cs_uuid}    ${vfi_name}    ${test_mc_name}
    sdc_interface.Certify And Approve SDC Catalog Service    ${cs_unique_id}
