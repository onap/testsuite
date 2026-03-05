Suite: robot/testsuites/vnf-orchestration-gra.robot
===================================================

Suite Metadata
--------------

- **Source file:** ``robot/testsuites/vnf-orchestration-gra.robot``
- **Suite documentation:** Executes the VNF Orchestration Test cases using GRA API including setup and teardown
- **Suite test template:** ``Orchestrate VNF Template``
- **Total test cases:** 5

Test Cases
----------

Template argument headers declared in suite: ``CUSTOMER``, ``SERVICE``, ``PRODUCT_FAMILY``.

Instantiate Virtual DNS GRA
~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Instantiate Virtual DNS GRA``
- **Template arguments:** ``ETE_Customer``, ``vLB``, ``vLB``
- **Tags:** ``instantiateGRA``, ``instantiate``, ``stability72hr``, ``stability72hrvLB``
- **Step count:** 0

Instantiate Virtual Volume Group GRA
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Instantiate Virtual Volume Group GRA``
- **Template arguments:** ``ETE_Customer``, ``vVG``, ``vVG``
- **Tags:** ``instantiateGRA``, ``instantiate``, ``stability72hr``, ``stability72hrvVG``
- **Step count:** 0

Instantiate Virtual FirewallCL GRA
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Instantiate Virtual FirewallCL GRA``
- **Template arguments:** ``ETE_Customer``, ``vFWCL``, ``vFWCL``
- **Tags:** ``instantiateGRA``, ``instantiate``, ``stability72hr``, ``stability72hrvFWCL``
- **Step count:** 0

Instantiate Virtual DNS GRA No Delete
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Instantiate Virtual DNS GRA No Delete``
- **Template arguments:** ``ETE_Customer``, ``vLB``, ``vLB``, ``KEEP``
- **Tags:** ``instantiateNoDelete``, ``instantiateNoDeleteVLB``
- **Step count:** 0

Instantiate Virtual FirewallCL GRA No Delete
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Instantiate Virtual FirewallCL GRA No Delete``
- **Template arguments:** ``ETE_Customer``, ``vFWCL``, ``vFWCL``, ``KEEP``
- **Tags:** ``instantiateNoDelete``, ``instantiateNoDeleteVFWCL``
- **Step count:** 0

Possible Improvements
---------------------

- Keep suite documentation aligned with current ONAP release behavior and update references when endpoints or flows change.
- Add `[Documentation]` to 5 test case(s) to explain intent, preconditions, and expected outcome.
- Review tag naming consistency (for example `health-*`, `instantiate*`, `ete`) to keep filtering and reporting uniform.
- For template-driven cases, add short per-case documentation so intent is visible without reading the template implementation.
- Externalize environment-specific input values into variable files to reduce hard-coded orchestration parameters.
