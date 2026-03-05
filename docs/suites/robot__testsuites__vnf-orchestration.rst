Suite: robot/testsuites/vnf-orchestration.robot
===============================================

Suite Metadata
--------------

- **Source file:** ``robot/testsuites/vnf-orchestration.robot``
- **Suite documentation:** Executes the VNF Orchestration Test cases including setup and teardown
- **Suite test template:** ``Orchestrate VNF Template``
- **Total test cases:** 5

Test Cases
----------

Template argument headers declared in suite: ``CUSTOMER``, ``SERVICE``, ``PRODUCT_FAMILY``.

Instantiate Virtual DNS
~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Instantiate Virtual DNS``
- **Template arguments:** ``ETE_Customer``, ``vLB``, ``vLB``
- **Tags:** ``instantiateVNFAPI``
- **Step count:** 0

Instantiate Virtual Volume Group
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Instantiate Virtual Volume Group``
- **Template arguments:** ``ETE_Customer``, ``vVG``, ``vVG``
- **Tags:** ``instantiateVNFAPI``
- **Step count:** 0

Instantiate Virtual FirewallCL
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Instantiate Virtual FirewallCL``
- **Template arguments:** ``ETE_Customer``, ``vFWCL``, ``vFWCL``
- **Tags:** ``instantiateVNFAPI``
- **Step count:** 0

Instantiate Virtual DNS No Delete
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Instantiate Virtual DNS No Delete``
- **Template arguments:** ``ETE_Customer``, ``vLB``, ``vLB``, ``KEEP``
- **Tags:** ``instantiateNoDeleteVNFAPI``
- **Step count:** 0

Instantiate Virtual FirewallCL No Delete
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Instantiate Virtual FirewallCL No Delete``
- **Template arguments:** ``ETE_Customer``, ``vFWCL``, ``vFWCL``, ``KEEP``
- **Tags:** ``instantiateNoDeleteVNFAPI``
- **Step count:** 0

Possible Improvements
---------------------

- Keep suite documentation aligned with current ONAP release behavior and update references when endpoints or flows change.
- Add `[Documentation]` to 5 test case(s) to explain intent, preconditions, and expected outcome.
- Review tag naming consistency (for example `health-*`, `instantiate*`, `ete`) to keep filtering and reporting uniform.
- For template-driven cases, add short per-case documentation so intent is visible without reading the template implementation.
- Externalize environment-specific input values into variable files to reduce hard-coded orchestration parameters.
