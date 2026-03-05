Suite: robot/testsuites/usecases/5gbulkpm.robot
===============================================

Suite Metadata
--------------

- **Source file:** ``robot/testsuites/usecases/5gbulkpm.robot``
- **Suite documentation:** 5G Bulk PM Usecase functionality
- **Total test cases:** 1

Test Cases
----------

SFTP Server based bulk PM test, no SFTP Server know host veryfication on DFC side
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Documentation:** This test case triggers successful bulk pm upload from SFTP server without SFTP server host verification in DFC known host file. Known host verification is turned off on DFC

- **Name:** ``SFTP Server based bulk PM test, no SFTP Server know host veryfication on DFC side``
- **Tags:** ``5gbulkpm``, ``5gbulkpm_sftp``
- **Step count:** 4
- **First step:** ``Uploading PM Files to xNF SFTP Server``

Possible Improvements
---------------------

- Keep suite documentation aligned with current ONAP release behavior and update references when endpoints or flows change.
- Continue maintaining per-test `[Documentation]` blocks with concise failure diagnostics and expected assertions.
- Review tag naming consistency (for example `health-*`, `instantiate*`, `ete`) to keep filtering and reporting uniform.
- Document required external dependencies and data contracts (topics, endpoints, credentials) for faster troubleshooting.
