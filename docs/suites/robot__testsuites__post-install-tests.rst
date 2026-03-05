Suite: robot/testsuites/post-install-tests.robot
================================================

Suite Metadata
--------------

- **Source file:** ``robot/testsuites/post-install-tests.robot``
- **Suite documentation:** Testing Installation Tests that confirm an installation is valid and not meant as recurring health test
- **Default test timeout:** ``10 second``
- **Total test cases:** 1

Test Cases
----------

Basic AAI Service Design Models Size Test
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Basic AAI Service Design Models Size Test``
- **Tags:** ``aaimodels``, ``postinstall``
- **Timeout:** ``60``
- **Step count:** 1
- **First step:** ``Validate Size Of AAI Models``

Possible Improvements
---------------------

- Keep suite documentation aligned with current ONAP release behavior and update references when endpoints or flows change.
- Add `[Documentation]` to 1 test case(s) to explain intent, preconditions, and expected outcome.
- Review tag naming consistency (for example `health-*`, `instantiate*`, `ete`) to keep filtering and reporting uniform.
- Add teardown cleanup checks so repeated runs are idempotent and less sensitive to residual state.
