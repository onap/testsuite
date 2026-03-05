Suite: robot/testsuites/cmpv2.robot
===================================

Suite Metadata
--------------

- **Source file:** ``robot/testsuites/cmpv2.robot``
- **Suite documentation:** CMPv2 Usecase functionality
- **Default test timeout:** ``15m``
- **Total test cases:** 3

Test Cases
----------

Send registration request to CMPv2 VES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Documentation:** This test case triggers registration request from VES Client (where is present only CMPv2 certificate) to VES collector with enabled CMPv2 (both CMPv2 and AAF certificates are present). Test expects successful registration

- **Name:** ``Send registration request to CMPv2 VES``
- **Tags:** ``CMPv2``
- **Step count:** 8
- **First step:** ``${pnf_correlation_id}= Generate Random String 20 [LETTERS][NUMBERS]``

Send registration request to CMPv2 VES with wrong SAN-s
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Documentation:** This test case triggers registration request from VES Client (where is present only CMPv2 certificate)  to VES collector ith enabled CMPv2 (both CMPv2 and AAF certificates are present). CMPv2 certificate has wrong SANs.

- **Name:** ``Send registration request to CMPv2 VES with wrong SAN-s``
- **Tags:** ``CMPv2``
- **Step count:** 6
- **First step:** ``${pnf_correlation_id}= Generate Random String 20 [LETTERS][NUMBERS]``

Send registration request to VES without CMPv2 certificate
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Documentation:** This test case triggers registration request from VES Client (where is present only CMPv2 certificate)  to VES collector with disabled CMPv2 (only AAF certificate is present - VES collector deployed during whole ONAP deploy).

- **Name:** ``Send registration request to VES without CMPv2 certificate``
- **Tags:** ``CMPv2``
- **Step count:** 8
- **First step:** ``Uninstall helm charts ${ONAP_HELM_RELEASE}-ves-client``

Possible Improvements
---------------------

- Keep suite documentation aligned with current ONAP release behavior and update references when endpoints or flows change.
- Continue maintaining per-test `[Documentation]` blocks with concise failure diagnostics and expected assertions.
- Review tag naming consistency (for example `health-*`, `instantiate*`, `ete`) to keep filtering and reporting uniform.
- Refactor 2 long test case(s) into reusable user keywords to reduce maintenance cost and improve readability.
