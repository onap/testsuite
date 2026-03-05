Suite: robot/testsuites/vnfsdk_validation.robot
===============================================

Suite Metadata
--------------

- **Source file:** ``robot/testsuites/vnfsdk_validation.robot``
- **Suite documentation:** This test suite creates csara and signed zip tosca VSP packages, validates them in VNFSDK and SDC
- **Default test timeout:** ``1m``
- **Suite test template:** ``Validate Onboarding Package``
- **Total test cases:** 11

Test Cases
----------

Validate Onboarding allMandatoryEntriesDefinedInTOSCAMeta
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Documentation:** This test case creates TOSCA csar software package for PNF, based on /var/opt/ONAP/demo/tosca/vnfsdk/allMandatoryEntriesDefinedInTOSCAMeta Imports it as csar VSP package to SDC and comapres with list of expected errors. Runs VNFSDK validation and comapres with list of expected errors. Expected failed requirements from VNFSDK  @{allMandatoryEntriesDefinedInTOSCAMeta} Expected errors from SDC Onboarding  @{allMandatoryEntriesDefinedInTOSCAMeta_sdc_message}

- **Name:** ``Validate Onboarding allMandatoryEntriesDefinedInTOSCAMeta``
- **Step count:** 1
- **First step:** ``allMandatoryEntriesDefinedInTOSCAMeta failed_vnfreqNames=@{allMandatoryEntriesDefinedInTOSCAMeta} sdc_response=@{allMandatoryEntriesDefinedInTOSCAMeta_sdc_message}``

Validate Onboarding non_mano_artifact_sets_is_mandatory
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Documentation:** This test case creates TOSCA csar software package for PNF, based on /var/opt/ONAP/demo/tosca/vnfsdk/non_mano_artifact_sets_is_mandatory Imports it as csar VSP package to SDC and comapres with list of expected errors. Runs VNFSDK validation and comapres with list of expected errors. Expected failed requirements from VNFSDK  @{non_mano_artifact_sets_is_mandatory} Expected errors from SDC Onboarding  @{non_mano_artifact_sets_is_mandatory_sdc_message}

- **Name:** ``Validate Onboarding non_mano_artifact_sets_is_mandatory``
- **Step count:** 1
- **First step:** ``non_mano_artifact_sets_is_mandatory failed_vnfreqNames=@{non_mano_artifact_sets_is_mandatory} sdc_response=@{non_mano_artifact_sets_is_mandatory_sdc_message}``

Validate Onboarding no_pnfd_release_date_time_error
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Documentation:** This test case creates TOSCA csar software package for PNF, based on /var/opt/ONAP/demo/tosca/vnfsdk/no_pnfd_release_date_time_error Imports it as csar VSP package to SDC and comapres with list of expected errors. Runs VNFSDK validation and comapres with list of expected errors. Expected failed requirements from VNFSDK  @{no_pnfd_release_date_time_error} Expected errors from SDC Onboarding  @{no_pnfd_release_date_time_error_sdc_message}

- **Name:** ``Validate Onboarding no_pnfd_release_date_time_error``
- **Step count:** 1
- **First step:** ``no_pnfd_release_date_time_error failed_vnfreqNames=@{no_pnfd_release_date_time_error} sdc_response=@{no_pnfd_release_date_time_error_sdc_message}``

Validate Onboarding noETSI-Entry-ManifestOrETSI-Entry-Change-Log
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Documentation:** This test case creates TOSCA csar software package for PNF, based on /var/opt/ONAP/demo/tosca/vnfsdk/noETSI-Entry-ManifestOrETSI-Entry-Change-Log Imports it as csar VSP package to SDC and comapres with list of expected errors. Runs VNFSDK validation and comapres with list of expected errors. Expected failed requirements from VNFSDK  @{noETSI-Entry-ManifestOrETSI-Entry-Change-Log} Expected errors from SDC Onboarding  @{noETSI-Entry-ManifestOrETSI-Entry-Change-Log_sdc_message}

- **Name:** ``Validate Onboarding noETSI-Entry-ManifestOrETSI-Entry-Change-Log``
- **Step count:** 1
- **First step:** ``noETSI-Entry-ManifestOrETSI-Entry-Change-Log failed_vnfreqNames=@{noETSI-Entry-ManifestOrETSI-Entry-Change-Log} sdc_response=@{noETSI-Entry-ManifestOrETSI-Entry-Change-Log_sdc_message}``

Validate Onboarding PNFD_missing
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Documentation:** This test case creates TOSCA csar software package for PNF, based on /var/opt/ONAP/demo/tosca/vnfsdk/PNFD_missing Imports it as csar VSP package to SDC and comapres with list of expected errors. Runs VNFSDK validation and comapres with list of expected errors. Expected failed requirements from VNFSDK  @{PNFD_missing} Expected errors from SDC Onboarding  @{PNFD_missing_sdc_message}

- **Name:** ``Validate Onboarding PNFD_missing``
- **Step count:** 1
- **First step:** ``PNFD_missing failed_vnfreqNames=@{PNFD_missing} sdc_response=@{PNFD_missing_sdc_message}``

Validate Onboarding test_SDC_and_VNFSDK_API, integrity_check CMS_with_cert
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Documentation:** This test case creates TOSCA csar software package for PNF, based on /var/opt/ONAP/demo/tosca/vnfsdk/test_SDC_and_VNFSDK_API Imports it as csar VSP package to SDC and expects success. Runs VNFSDK validation and and expects success.

- **Name:** ``Validate Onboarding test_SDC_and_VNFSDK_API, integrity_check CMS_with_cert``
- **Step count:** 1
- **First step:** ``test_SDC_and_VNFSDK_API_with_hash_cert_in_CMS negative_test_case=FALSE integrity_check=CMS_with_cert``

Validate Onboarding test_SDC_and_VNFSDK_API, integrity_check CMS_without_cert
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Documentation:** This test case creates TOSCA csar software package for PNF, based on /var/opt/ONAP/demo/tosca/vnfsdk/test_SDC_and_VNFSDK_API Imports it as csar VSP package to SDC and expects success. Runs VNFSDK validation and and expects success.

- **Name:** ``Validate Onboarding test_SDC_and_VNFSDK_API, integrity_check CMS_without_cert``
- **Step count:** 1
- **First step:** ``test_SDC_and_VNFSDK_API_with_hash negative_test_case=FALSE integrity_check=CMS_without_cert``

Validate Onboarding test_SDC_and_VNFSDK_API, secured csar - CMS only - sdc valid certificate, integrity_check CMS_without_cert
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Documentation:** This test case creates TOSCA csar software package for PNF, based on /var/opt/ONAP/demo/tosca/vnfsdk/test_SDC_and_VNFSDK_API Next sign with certificate that is imported to SDC onabarding POD using CMS only method (CMS file signs csar, zip contains only csar and cms files ) Imports it as zip VSP package to SDC and expects success. Runs VNFSDK validation and and expects success.

- **Name:** ``Validate Onboarding test_SDC_and_VNFSDK_API, secured csar - CMS only - sdc valid certificate, integrity_check CMS_without_cert``
- **Step count:** 1
- **First step:** ``test_SDC_and_VNFSDK_API_with_hash secured_package=TRUE negative_test_case=FALSE integrity_check=CMS_without_cert secure_type=CMS sdc_cert=sdc-valid``

Validate Onboarding test_SDC_and_VNFSDK_API, secured csar - CMS and CERT - sdc valid certificate, integrity_check CMS_with_cert
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Documentation:** This test case creates TOSCA csar software package for PNF, based on /var/opt/ONAP/demo/tosca/vnfsdk/test_SDC_and_VNFSDK_API Next sign with certificate that is imported to SDC onabarding POD using CMS and CERT  method (CMS file signs csar, zip contains csar, certificate and cms files ) Imports it as zip VSP package to SDC and expects success. Runs VNFSDK validation and and expects success.

- **Name:** ``Validate Onboarding test_SDC_and_VNFSDK_API, secured csar - CMS and CERT - sdc valid certificate, integrity_check CMS_with_cert``
- **Step count:** 1
- **First step:** ``test_SDC_and_VNFSDK_API_with_hash_cert_in_CMS secured_package=TRUE negative_test_case=FALSE integrity_check=CMS_with_cert secure_type=CMS_AND_CERT sdc_cert=sdc-valid``

Validate Onboarding test_SDC_and_VNFSDK_API, secured csar - CMS only - sdc invalid certificate, integrity_check CMS_without_cert
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Documentation:** This test case creates TOSCA csar software package for PNF, based on /var/opt/ONAP/demo/tosca/vnfsdk/test_SDC_and_VNFSDK_API Next sign with certificate that is not imported to SDC onabarding POD using CMS only method (CMS file signs csar, zip contains only csar and cms files ) Imports it as zip VSP package to SDC and expects error due to issues with certificate validation. Runs VNFSDK validation and and expects success.

- **Name:** ``Validate Onboarding test_SDC_and_VNFSDK_API, secured csar - CMS only - sdc invalid certificate, integrity_check CMS_without_cert``
- **Step count:** 1
- **First step:** ``test_SDC_and_VNFSDK_API_with_hash secured_package=TRUE negative_test_case=FALSE integrity_check=CMS_without_cert sdc_response=@{invalid_certificate} secure_type=CMS sdc_cert=sdc-invalid``

Validate Onboarding test_SDC_and_VNFSDK_API, secured csar - CMS and CERT - sdc invalid certificate, integrity_check CMS_with_cert
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Documentation:** This test case creates TOSCA csar software package for PNF, based on /var/opt/ONAP/demo/tosca/vnfsdk/test_SDC_and_VNFSDK_API Next sign with certificate that is not imported to SDC onabarding POD using CMS and CERT  method (CMS file signs csar, zip contains csar, certificate and cms files ) Imports it as zip VSP package to SDC and expects error due to issues with certificate validation. Runs VNFSDK validation and and expects success

- **Name:** ``Validate Onboarding test_SDC_and_VNFSDK_API, secured csar - CMS and CERT - sdc invalid certificate, integrity_check CMS_with_cert``
- **Step count:** 1
- **First step:** ``test_SDC_and_VNFSDK_API_with_hash_cert_in_CMS secured_package=TRUE negative_test_case=FALSE integrity_check=CMS_with_cert sdc_response=@{invalid_certificate} secure_type=CMS_AND_CERT sdc_cert=sdc-invalid``

Possible Improvements
---------------------

- Keep suite documentation aligned with current ONAP release behavior and update references when endpoints or flows change.
- Continue maintaining per-test `[Documentation]` blocks with concise failure diagnostics and expected assertions.
- Tag the 11 untagged test case(s) so selective execution (`--include`/`--exclude`) remains predictable.
- Add teardown cleanup checks so repeated runs are idempotent and less sensitive to residual state.
