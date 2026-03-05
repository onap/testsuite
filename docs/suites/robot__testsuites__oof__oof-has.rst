Suite: robot/testsuites/oof/oof-has.robot
=========================================

Suite Metadata
--------------

- **Source file:** ``robot/testsuites/oof/oof-has.robot``
- **Suite documentation:** Testing OOF-HAS Testing OOF-HAS SEND PLANS
- **Total test cases:** 1

Test Cases
----------

Basic OOF-HAS CSIT
~~~~~~~~~~~~~~~~~~

- **Name:** ``Basic OOF-HAS CSIT``
- **Tags:** ``has``
- **Step count:** 1
- **First step:** ``Run OOF-Homing SendPlanWithWrongVersion``

Possible Improvements
---------------------

- Keep suite documentation aligned with current ONAP release behavior and update references when endpoints or flows change.
- Add `[Documentation]` to 1 test case(s) to explain intent, preconditions, and expected outcome.
- Review tag naming consistency (for example `health-*`, `instantiate*`, `ete`) to keep filtering and reporting uniform.
- Add teardown cleanup checks so repeated runs are idempotent and less sensitive to residual state.
