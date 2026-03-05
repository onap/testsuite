Suite: robot/testsuites/model-distribution.robot
================================================

Suite Metadata
--------------

- **Source file:** ``robot/testsuites/model-distribution.robot``
- **Suite documentation:** Testing sdc.
- **Suite test template:** ``Model Distribution For Directory``
- **Total test cases:** 4

Test Cases
----------

Distribute vLB Model
~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Distribute vLB Model``
- **Template arguments:** ``vLB``
- **Tags:** ``distribute``, ``distributeVLB``
- **Step count:** 0

Distribute vFW Model
~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Distribute vFW Model``
- **Template arguments:** ``vFW``
- **Tags:** ``distribute``
- **Step count:** 0

Distribute vVG Model
~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Distribute vVG Model``
- **Template arguments:** ``vVG``
- **Tags:** ``distribute``
- **Step count:** 0

Distribute vFWDT Model
~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Distribute vFWDT Model``
- **Template arguments:** ``vFWDT``
- **Tags:** ``distributeVFWDT``
- **Step count:** 0

Possible Improvements
---------------------

- Keep suite documentation aligned with current ONAP release behavior and update references when endpoints or flows change.
- Add `[Documentation]` to 4 test case(s) to explain intent, preconditions, and expected outcome.
- Review tag naming consistency (for example `health-*`, `instantiate*`, `ete`) to keep filtering and reporting uniform.
- For template-driven cases, add short per-case documentation so intent is visible without reading the template implementation.
- Add explicit post-distribution verification assertions to prove model availability in target consumers.
