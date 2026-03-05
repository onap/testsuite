Suite: robot/testsuites/vnf-orchestration-ovp.robot
===================================================

Suite Metadata
--------------

- **Source file:** ``robot/testsuites/vnf-orchestration-ovp.robot``
- **Suite documentation:** The main driver for instantiating a generic VNF
- **Total test cases:** 1

Test Cases
----------

VNF Instantiation
~~~~~~~~~~~~~~~~~

**Documentation:** Instantiate Generic VNF

- **Name:** ``VNF Instantiation``
- **Tags:** ``instantiate_vnf_ovp``
- **Timeout:** ``3000``
- **Step count:** 21
- **First step:** ``Run VVP Validation Scripts ${BUILD_DIR} ${BUILD_DIR}/templates/ ${OUTPUTDIR}/summary``

Possible Improvements
---------------------

- Keep suite documentation aligned with current ONAP release behavior and update references when endpoints or flows change.
- Continue maintaining per-test `[Documentation]` blocks with concise failure diagnostics and expected assertions.
- Review tag naming consistency (for example `health-*`, `instantiate*`, `ete`) to keep filtering and reporting uniform.
- Refactor 1 long test case(s) into reusable user keywords to reduce maintenance cost and improve readability.
- Consider defining a suite-level `Test Timeout` baseline and keep only justified per-test overrides.
- Externalize environment-specific input values into variable files to reduce hard-coded orchestration parameters.
