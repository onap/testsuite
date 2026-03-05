Suite: robot/testsuites/cds.robot
=================================

Suite Metadata
--------------

- **Source file:** ``robot/testsuites/cds.robot``
- **Suite documentation:** Executes the VNF Orchestration with CDS Test cases including setup and teardown
- **Suite test template:** ``Orchestrate VNF With CDS Template``
- **Total test cases:** 1

Test Cases
----------

Template argument headers declared in suite: ``CUSTOMER``, ``SERVICE``, ``PRODUCT_FAMILY``.

Instantiate Virtual vFW With CDS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Instantiate Virtual vFW With CDS``
- **Template arguments:** ``ETE_Customer``, ``Service_Ete_Name``, ``vFW``
- **Tags:** ``cds``
- **Step count:** 0

Possible Improvements
---------------------

- Keep suite documentation aligned with current ONAP release behavior and update references when endpoints or flows change.
- Add `[Documentation]` to 1 test case(s) to explain intent, preconditions, and expected outcome.
- Review tag naming consistency (for example `health-*`, `instantiate*`, `ete`) to keep filtering and reporting uniform.
- For template-driven cases, add short per-case documentation so intent is visible without reading the template implementation.
