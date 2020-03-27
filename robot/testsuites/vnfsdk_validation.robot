*** Settings ***
Documentation     This test suite creates csara and signed zip tosca VSP packages, validates them in VNFSDK and SDC
Test Timeout      1m

Resource          ../resources/test_templates/vnfsdk_validation_template.robot
Library           String
Test Template     Validate Onboarding Package
Default Tags      vnfsdk


*** Variables ***
@{allMandatoryEntriesDefinedInTOSCAMeta}       r146092
@{no_pnfd_release_date_time_error}       r57019
@{non_mano_artifact_sets_is_mandatory}   r146092
@{noETSI-Entry-ManifestOrETSI-Entry-Change-Log}  r293901
@{PNFD_missing}  SOL004  r10087  r87234  r35854  r15837  r17852  r293901  r146092  r57019  r787965
@{allMandatoryEntriesDefinedInTOSCAMeta_sdc_message}  Following entry not supported in TOSCA.meta Entry-Tests=Artifacts/Tests  Manifest contains invalid line : #The manifest file shall include a list of all files contained in or referenced from the VNF package with their location
@{no_pnfd_release_date_time_error_sdc_message}  Following entry not supported in TOSCA.meta Entry-Tests=Artifacts/Tests  Manifest contains invalid line : #The manifest file shall include a list of all files contained in or referenced from the VNF package with their location
@{non_mano_artifact_sets_is_mandatory_sdc_message}  Following entry not supported in TOSCA.meta Entry-Tests=Artifacts/Tests  Manifest contains invalid line : #The manifest file shall include a list of all files contained in or referenced from the VNF package with their location
@{noETSI-Entry-ManifestOrETSI-Entry-Change-Log_sdc_message}   Manifest contains invalid line : #The manifest file shall include a list of all files contained in or referenced from the VNF package with their location
@{PNFD_missing_sdc_message}   TOSCA.meta file in TOSCA-metadata directory missing entry Created-By
@{invalid_certificate}  Could not verify signature!


*** Test Cases ***
Validate Onboarding allMandatoryEntriesDefinedInTOSCAMeta
     [Documentation]
     ...  This test case creates TOSCA csar software package for PNF, based on /var/opt/ONAP/demo/tosca/vnfsdk/allMandatoryEntriesDefinedInTOSCAMeta
     ...  Imports it as csar VSP package to SDC and comapres with list of expected errors.
     ...  Runs VNFSDK validation and comapres with list of expected errors.
     allMandatoryEntriesDefinedInTOSCAMeta   failed_vnfreqNames=@{allMandatoryEntriesDefinedInTOSCAMeta}  sdc_response=@{allMandatoryEntriesDefinedInTOSCAMeta_sdc_message}

Validate Onboarding non_mano_artifact_sets_is_mandatory
     [Documentation]
     ...  This test case creates TOSCA csar software package for PNF, based on /var/opt/ONAP/demo/tosca/vnfsdk/non_mano_artifact_sets_is_mandatory
     ...  Imports it as csar VSP package to SDC and comapres with list of expected errors.
     ...  Runs VNFSDK validation and comapres with list of expected errors.
     non_mano_artifact_sets_is_mandatory   failed_vnfreqNames=@{non_mano_artifact_sets_is_mandatory}  sdc_response=@{non_mano_artifact_sets_is_mandatory_sdc_message}

Validate Onboarding no_pnfd_release_date_time_error
     [Documentation]
     ...  This test case creates TOSCA csar software package for PNF, based on /var/opt/ONAP/demo/tosca/vnfsdk/no_pnfd_release_date_time_error
     ...  Imports it as csar VSP package to SDC and comapres with list of expected errors.
     ...  Runs VNFSDK validation and comapres with list of expected errors.
     no_pnfd_release_date_time_error   failed_vnfreqNames=@{no_pnfd_release_date_time_error}  sdc_response=@{no_pnfd_release_date_time_error_sdc_message}

Validate Onboarding noETSI-Entry-ManifestOrETSI-Entry-Change-Log
     [Documentation]
     ...  This test case creates TOSCA csar software package for PNF, based on /var/opt/ONAP/demo/tosca/vnfsdk/noETSI-Entry-ManifestOrETSI-Entry-Change-Log
     ...  Imports it as csar VSP package to SDC and comapres with list of expected errors.
     ...  Runs VNFSDK validation and comapres with list of expected errors.
     noETSI-Entry-ManifestOrETSI-Entry-Change-Log   failed_vnfreqNames=@{noETSI-Entry-ManifestOrETSI-Entry-Change-Log}  sdc_response=@{noETSI-Entry-ManifestOrETSI-Entry-Change-Log_sdc_message}

Validate Onboarding PNFD_missing
     [Documentation]
     ...  This test case creates TOSCA csar software package for PNF, based on /var/opt/ONAP/demo/tosca/vnfsdk/PNFD_missing
     ...  Imports it as csar VSP package to SDC and comapres with list of expected errors.
     ...  Runs VNFSDK validation and comapres with list of expected errors.
     PNFD_missing   failed_vnfreqNames=@{PNFD_missing}  sdc_response=@{PNFD_missing_sdc_message}

Validate Onboarding test_SDC_and_VNFSDK_API
     [Documentation]
     ...  This test case creates TOSCA csar software package for PNF, based on /var/opt/ONAP/demo/tosca/vnfsdk/test_SDC_and_VNFSDK_API
     ...  Imports it as csar VSP package to SDC and expects success.
     ...  Runs VNFSDK validation and and expects success.
     test_SDC_and_VNFSDK_API   negative_test_case=FALSE

Validate Onboarding test_SDC_and_VNFSDK_API, secured csar, CMS only, valid certificate
     [Documentation]
     ...  This test case creates TOSCA csar software package for PNF, based on /var/opt/ONAP/demo/tosca/vnfsdk/test_SDC_and_VNFSDK_API
     ...  Next sign with certificate that is imported to SDC onabarding POD using CMS only method (CMS file signs csar, zip contains only csar and cms files )
     ...  Imports it as zip VSP package to SDC and expects success.
     ...  Runs VNFSDK validation and and expects success.
     test_SDC_and_VNFSDK_API   secured_package=TRUE   negative_test_case=FALSE  secure_type=CMS  sdc_cert=sdc-valid

Validate Onboarding test_SDC_and_VNFSDK_API, secured csar, CMS and CERT, valid certificate
     [Documentation]
     ...  This test case creates TOSCA csar software package for PNF, based on /var/opt/ONAP/demo/tosca/vnfsdk/test_SDC_and_VNFSDK_API
     ...  Next sign with certificate that is imported to SDC onabarding POD using CMS and CERT  method (CMS file signs csar, zip contains csar, certificate and cms files )
     ...  Imports it as zip VSP package to SDC and expects success.
     ...  Runs VNFSDK validation and and expects success.
     test_SDC_and_VNFSDK_API   secured_package=TRUE   negative_test_case=FALSE  secure_type=CMS_AND_CERT  sdc_cert=sdc-valid

Validate Onboarding test_SDC_and_VNFSDK_API secured csar, CMS only, invalid certificate
     [Documentation]
     ...  This test case creates TOSCA csar software package for PNF, based on /var/opt/ONAP/demo/tosca/vnfsdk/test_SDC_and_VNFSDK_API
     ...  Next sign with certificate that is not imported to SDC onabarding POD using CMS only method (CMS file signs csar, zip contains only csar and cms files )
     ...  Imports it as zip VSP package to SDC and expects error due to issues with certificate validation.
     ...  Runs VNFSDK validation and and expects success.
     test_SDC_and_VNFSDK_API   secured_package=TRUE   negative_test_case=FALSE  sdc_response=@{invalid_certificate}  secure_type=CMS  sdc_cert=sdc-invalid

Validate Onboarding test_SDC_and_VNFSDK_API secured csar, CMS and CERT, invalid certificate
     [Documentation]
     ...  This test case creates TOSCA csar software package for PNF, based on /var/opt/ONAP/demo/tosca/vnfsdk/test_SDC_and_VNFSDK_API
     ...  Next sign with certificate that is not imported to SDC onabarding POD using CMS and CERT  method (CMS file signs csar, zip contains csar, certificate and cms files )
     ...  Imports it as zip VSP package to SDC and expects error due to issues with certificate validation.
     ...  Runs VNFSDK validation and and expects success
     test_SDC_and_VNFSDK_API   secured_package=TRUE   negative_test_case=FALSE  sdc_response=@{invalid_certificate}  secure_type=CMS_AND_CERT  sdc_cert=sdc-invalid

