Suite: robot/testsuites/model-distribution-vcpe.robot
=====================================================

Suite Metadata
--------------

- **Source file:** ``robot/testsuites/model-distribution-vcpe.robot``
- **Suite documentation:** Testing sdc.
- **Suite test template:** ``Model Distribution For vCPEResCust Directory``
- **Total test cases:** 1

Test Cases
----------

Distribute vCPEResCust Model
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Distribute vCPEResCust Model``
- **Template arguments:** ``vCPEResCust``
- **Tags:** ``distributevCPEResCust``
- **Step count:** 0

Possible Improvements
---------------------

- Keep suite documentation aligned with current ONAP release behavior and update references when endpoints or flows change.
- Add `[Documentation]` to 1 test case(s) to explain intent, preconditions, and expected outcome.
- Review tag naming consistency (for example `health-*`, `instantiate*`, `ete`) to keep filtering and reporting uniform.
- For template-driven cases, add short per-case documentation so intent is visible without reading the template implementation.
- Add explicit post-distribution verification assertions to prove model availability in target consumers.
