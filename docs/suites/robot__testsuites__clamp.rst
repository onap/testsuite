Suite: robot/testsuites/clamp.robot
===================================

Suite Metadata
--------------

- **Source file:** ``robot/testsuites/clamp.robot``
- **Suite documentation:** Testing CLAMP Testing ecomp components are available via calls.
- **Default test timeout:** ``120 second``
- **Total test cases:** 1

Test Cases
----------

Basic CLAMP Health Check
~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Basic CLAMP Health Check``
- **Tags:** ``clamp``
- **Step count:** 4
- **First step:** ``${current_model_id}= Run CLAMP Get Model Names``

Possible Improvements
---------------------

- Keep suite documentation aligned with current ONAP release behavior and update references when endpoints or flows change.
- Add `[Documentation]` to 1 test case(s) to explain intent, preconditions, and expected outcome.
- Review tag naming consistency (for example `health-*`, `instantiate*`, `ete`) to keep filtering and reporting uniform.
- Add teardown cleanup checks so repeated runs are idempotent and less sensitive to residual state.
