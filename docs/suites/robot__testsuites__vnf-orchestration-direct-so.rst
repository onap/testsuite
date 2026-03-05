Suite: robot/testsuites/vnf-orchestration-direct-so.robot
=========================================================

Suite Metadata
--------------

- **Source file:** ``robot/testsuites/vnf-orchestration-direct-so.robot``
- **Suite documentation:** Instantiate VNF via Direct SO Calls
- **Default test timeout:** ``600 second``
- **Total test cases:** 1

Test Cases
----------

SO Direct Instantiate vFW VNF
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Documentation:** Direct REST API into SO ./ete-k8s.sh onap healtdist   (cpy csar file name) ./ete-k8s.sh onap instantiateVFWdirectso  CSAR_FILE:/tmp/csar/service-Vfw20190413133734-csar.csar

- **Name:** ``SO Direct Instantiate vFW VNF``
- **Tags:** ``instantiateVFWdirectso``
- **Step count:** 2
- **First step:** ``Run Keyword If '${CSAR_FILE}' == '' Fail "CSAR_FILE must not be empty (/tmp/csar/service-Vfw20190413133734-csar.csar)"``

Possible Improvements
---------------------

- Keep suite documentation aligned with current ONAP release behavior and update references when endpoints or flows change.
- Continue maintaining per-test `[Documentation]` blocks with concise failure diagnostics and expected assertions.
- Review tag naming consistency (for example `health-*`, `instantiate*`, `ete`) to keep filtering and reporting uniform.
- Externalize environment-specific input values into variable files to reduce hard-coded orchestration parameters.
