Suite: robot/testsuites/oof/oof-osdf.robot
==========================================

Suite Metadata
--------------

- **Source file:** ``robot/testsuites/oof/oof-osdf.robot``
- **Suite documentation:** Testing OOF-HAS Testing OOF-HAS SEND PLANS
- **Total test cases:** 2

Test Cases
----------

Basic OOF-OSDF CSIT for Homing
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Basic OOF-OSDF CSIT for Homing``
- **Tags:** ``homing``
- **Step count:** 1
- **First step:** ``Run OOF-OSDF Post Homing``

Basic OOF-OSDF CSIT for pci-opt
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Basic OOF-OSDF CSIT for pci-opt``
- **Tags:** ``homing``
- **Step count:** 1
- **First step:** ``Run OOF-OSDF Post PCI-OPT``

Possible Improvements
---------------------

- Keep suite documentation aligned with current ONAP release behavior and update references when endpoints or flows change.
- Add `[Documentation]` to 2 test case(s) to explain intent, preconditions, and expected outcome.
- Review tag naming consistency (for example `health-*`, `instantiate*`, `ete`) to keep filtering and reporting uniform.
- Add teardown cleanup checks so repeated runs are idempotent and less sensitive to residual state.
