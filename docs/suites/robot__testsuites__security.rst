Suite: robot/testsuites/security.robot
======================================

Suite Metadata
--------------

- **Source file:** ``robot/testsuites/security.robot``
- **Suite documentation:** Security validation
- **Total test cases:** 1

Test Cases
----------

Validate present NodePorts
~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Validate present NodePorts``
- **Step count:** 3
- **First step:** ``${expected_nodeports}= Get file ${EXPECTED_NODEPORTS_FILE}``

Possible Improvements
---------------------

- Keep suite documentation aligned with current ONAP release behavior and update references when endpoints or flows change.
- Add `[Documentation]` to 1 test case(s) to explain intent, preconditions, and expected outcome.
- Tag the 1 untagged test case(s) so selective execution (`--include`/`--exclude`) remains predictable.
- Add negative-path assertions (missing/extra ports, malformed files) to strengthen security validation coverage.
