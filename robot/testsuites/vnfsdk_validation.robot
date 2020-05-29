*** Settings ***
Documentation     This test suite creates csara and signed zip tosca VSP packages, validates them in VNFSDK and SDC
Test Timeout      1m

Resource          ../resources/test_templates/vnfsdk_validation_template.robot
Library           String
Test Template     Validate Onboarding Package
Default Tags      vnfsdk  pnf_preonboarding_onboarding


*** Variables ***
@{allMandatoryEntriesDefinedInTOSCAMeta}       r146092  r130206
@{no_pnfd_release_date_time_error}       r57019  r130206
@{non_mano_artifact_sets_is_mandatory}   r146092  r130206
@{noETSI-Entry-ManifestOrETSI-Entry-Change-Log}  r293901  r130206
@{PNFD_missing}  SOL004  r10087  r87234  r35854  r15837  r17852  r293901  r146092  r57019  r787965  r130206  r972082
@{missing_entry_in_manifest}
@{allMandatoryEntriesDefinedInTOSCAMeta_sdc_message}  Following entry not supported in TOSCA.meta Entry-Tests  Manifest contains invalid line: 7: #The manifest file shall include a list of all files contained in or referenced from the VNF package with their location
@{no_pnfd_release_date_time_error_sdc_message}   Following entry not supported in TOSCA.meta Entry-Tests  Invalid Manifest metadata entry: '#The manifest file shall include a list of all files contained in or referenced from the VNF package with their location'.;\nAt line 6: '#The manifest file shall include a list of all files contained in or referenced from the VNF package with their location'.
@{non_mano_artifact_sets_is_mandatory_sdc_message}   Following entry not supported in TOSCA.meta Entry-Tests  Manifest contains invalid line: 7: #The manifest file shall include a list of all files contained in or referenced from the VNF package with their location
@{noETSI-Entry-ManifestOrETSI-Entry-Change-Log_sdc_message}   Manifest contains invalid line: 7: #The manifest file shall include a list of all files contained in or referenced from the VNF package with their location   Manifest contains invalid line: 7: #The manifest file shall include a list of all files contained in or referenced from the VNF package with their location
@{PNFD_missing_sdc_message}   TOSCA.meta file in TOSCA-metadata directory missing entry Created-By
@{invalid_certificate}  Could not verify signature!
@{missing_entry_in_manifest_sdc_message}  'pnf_main_descriptor.cert' artifact is not being referenced in manifest file


*** Test Cases ***
Validate Onboarding allMandatoryEntriesDefinedInTOSCAMeta
     [Documentation]
     ...  This test case creates TOSCA csar software package for PNF, based on /var/opt/ONAP/demo/tosca/vnfsdk/allMandatoryEntriesDefinedInTOSCAMeta
     ...  Imports it as csar VSP package to SDC and comapres with list of expected errors.
     ...  Runs VNFSDK validation and comapres with list of expected errors.
     ...  Expected failed requirements from VNFSDK  @{allMandatoryEntriesDefinedInTOSCAMeta}
     ...  Expected errors from SDC Onboarding  @{allMandatoryEntriesDefinedInTOSCAMeta_sdc_message}
     allMandatoryEntriesDefinedInTOSCAMeta   failed_vnfreqNames=@{allMandatoryEntriesDefinedInTOSCAMeta}  sdc_response=@{allMandatoryEntriesDefinedInTOSCAMeta_sdc_message}

Validate Onboarding non_mano_artifact_sets_is_mandatory
     [Documentation]
     ...  This test case creates TOSCA csar software package for PNF, based on /var/opt/ONAP/demo/tosca/vnfsdk/non_mano_artifact_sets_is_mandatory
     ...  Imports it as csar VSP package to SDC and comapres with list of expected errors.
     ...  Runs VNFSDK validation and comapres with list of expected errors.
     ...  Expected failed requirements from VNFSDK  @{non_mano_artifact_sets_is_mandatory}
     ...  Expected errors from SDC Onboarding  @{non_mano_artifact_sets_is_mandatory_sdc_message}
     non_mano_artifact_sets_is_mandatory   failed_vnfreqNames=@{non_mano_artifact_sets_is_mandatory}  sdc_response=@{non_mano_artifact_sets_is_mandatory_sdc_message}

Validate Onboarding no_pnfd_release_date_time_error
     [Documentation]
     ...  This test case creates TOSCA csar software package for PNF, based on /var/opt/ONAP/demo/tosca/vnfsdk/no_pnfd_release_date_time_error
     ...  Imports it as csar VSP package to SDC and comapres with list of expected errors.
     ...  Runs VNFSDK validation and comapres with list of expected errors.
     ...  Expected failed requirements from VNFSDK  @{no_pnfd_release_date_time_error}
     ...  Expected errors from SDC Onboarding  @{no_pnfd_release_date_time_error_sdc_message}
     no_pnfd_release_date_time_error   failed_vnfreqNames=@{no_pnfd_release_date_time_error}  sdc_response=@{no_pnfd_release_date_time_error_sdc_message}

Validate Onboarding noETSI-Entry-ManifestOrETSI-Entry-Change-Log
     [Documentation]
     ...  This test case creates TOSCA csar software package for PNF, based on /var/opt/ONAP/demo/tosca/vnfsdk/noETSI-Entry-ManifestOrETSI-Entry-Change-Log
     ...  Imports it as csar VSP package to SDC and comapres with list of expected errors.
     ...  Runs VNFSDK validation and comapres with list of expected errors.
     ...  Expected failed requirements from VNFSDK  @{noETSI-Entry-ManifestOrETSI-Entry-Change-Log}
     ...  Expected errors from SDC Onboarding  @{noETSI-Entry-ManifestOrETSI-Entry-Change-Log_sdc_message}
     noETSI-Entry-ManifestOrETSI-Entry-Change-Log   failed_vnfreqNames=@{noETSI-Entry-ManifestOrETSI-Entry-Change-Log}  sdc_response=@{noETSI-Entry-ManifestOrETSI-Entry-Change-Log_sdc_message}

Validate Onboarding PNFD_missing
     [Documentation]
     ...  This test case creates TOSCA csar software package for PNF, based on /var/opt/ONAP/demo/tosca/vnfsdk/PNFD_missing
     ...  Imports it as csar VSP package to SDC and comapres with list of expected errors.
     ...  Runs VNFSDK validation and comapres with list of expected errors.
     ...  Expected failed requirements from VNFSDK  @{PNFD_missing}
     ...  Expected errors from SDC Onboarding  @{PNFD_missing_sdc_message}
     PNFD_missing   failed_vnfreqNames=@{PNFD_missing}  sdc_response=@{PNFD_missing_sdc_message}

Validate Onboarding test_SDC_and_VNFSDK_API, integrity_check CMS_with_cert
     [Documentation]
     ...  This test case creates TOSCA csar software package for PNF, based on /var/opt/ONAP/demo/tosca/vnfsdk/test_SDC_and_VNFSDK_API
     ...  Imports it as csar VSP package to SDC and expects success.
     ...  Runs VNFSDK validation and and expects success.
     test_SDC_and_VNFSDK_API_with_hash   negative_test_case=FALSE   integrity_check=CMS_with_cert

Validate Onboarding test_SDC_and_VNFSDK_API, integrity_check CMS_without_cert
     [Documentation]
     ...  This test case creates TOSCA csar software package for PNF, based on /var/opt/ONAP/demo/tosca/vnfsdk/test_SDC_and_VNFSDK_API
     ...  Imports it as csar VSP package to SDC and expects success.
     ...  Runs VNFSDK validation and and expects success.
     test_SDC_and_VNFSDK_API_with_hash   negative_test_case=FALSE   integrity_check=CMS_without_cert

Validate Onboarding test_SDC_and_VNFSDK_API, secured csar - CMS only - sdc valid certificate, integrity_check CMS_without_cert
     [Documentation]
     ...  This test case creates TOSCA csar software package for PNF, based on /var/opt/ONAP/demo/tosca/vnfsdk/test_SDC_and_VNFSDK_API
     ...  Next sign with certificate that is imported to SDC onabarding POD using CMS only method (CMS file signs csar, zip contains only csar and cms files )
     ...  Imports it as zip VSP package to SDC and expects success.
     ...  Runs VNFSDK validation and and expects success.
     test_SDC_and_VNFSDK_API_with_hash   secured_package=TRUE   negative_test_case=FALSE  integrity_check=CMS_without_cert  secure_type=CMS  sdc_cert=sdc-valid

Validate Onboarding test_SDC_and_VNFSDK_API, secured csar - CMS and CERT - sdc valid certificate, integrity_check CMS_with_cert
     [Documentation]
     ...  This test case creates TOSCA csar software package for PNF, based on /var/opt/ONAP/demo/tosca/vnfsdk/test_SDC_and_VNFSDK_API
     ...  Next sign with certificate that is imported to SDC onabarding POD using CMS and CERT  method (CMS file signs csar, zip contains csar, certificate and cms files )
     ...  Imports it as zip VSP package to SDC and expects success.
     ...  Runs VNFSDK validation and and expects success.
     test_SDC_and_VNFSDK_API_with_hash   secured_package=TRUE   negative_test_case=FALSE  integrity_check=CMS_with_cert  secure_type=CMS_AND_CERT  sdc_cert=sdc-valid

Validate Onboarding test_SDC_and_VNFSDK_API, secured csar - CMS only - sdc invalid certificate, integrity_check CMS_without_cert
     [Documentation]
     ...  This test case creates TOSCA csar software package for PNF, based on /var/opt/ONAP/demo/tosca/vnfsdk/test_SDC_and_VNFSDK_API
     ...  Next sign with certificate that is not imported to SDC onabarding POD using CMS only method (CMS file signs csar, zip contains only csar and cms files )
     ...  Imports it as zip VSP package to SDC and expects error due to issues with certificate validation.
     ...  Runs VNFSDK validation and and expects success.
     test_SDC_and_VNFSDK_API_with_hash   secured_package=TRUE   negative_test_case=FALSE  integrity_check=CMS_without_cert  sdc_response=@{invalid_certificate}  secure_type=CMS  sdc_cert=sdc-invalid

Validate Onboarding test_SDC_and_VNFSDK_API, secured csar - CMS and CERT - sdc invalid certificate, integrity_check CMS_with_cert
     [Documentation]
     ...  This test case creates TOSCA csar software package for PNF, based on /var/opt/ONAP/demo/tosca/vnfsdk/test_SDC_and_VNFSDK_API
     ...  Next sign with certificate that is not imported to SDC onabarding POD using CMS and CERT  method (CMS file signs csar, zip contains csar, certificate and cms files )
     ...  Imports it as zip VSP package to SDC and expects error due to issues with certificate validation.
     ...  Runs VNFSDK validation and and expects success
     test_SDC_and_VNFSDK_API_with_hash   secured_package=TRUE   negative_test_case=FALSE  integrity_check=CMS_with_cert  sdc_response=@{invalid_certificate}  secure_type=CMS_AND_CERT  sdc_cert=sdc-invalid

