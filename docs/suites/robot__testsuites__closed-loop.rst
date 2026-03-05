Suite: robot/testsuites/closed-loop.robot
=========================================

Suite Metadata
--------------

- **Source file:** ``robot/testsuites/closed-loop.robot``
- **Suite documentation:** Closed Loop Test cases
- **Total test cases:** 4

Test Cases
----------

VFW Closed Loop Test
~~~~~~~~~~~~~~~~~~~~

- **Name:** ``VFW Closed Loop Test``
- **Tags:** ``closedloop``, ``vfwcl``
- **Step count:** 1
- **First step:** ``VFW Policy``

VDNS Closed Loop Test
~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``VDNS Closed Loop Test``
- **Tags:** ``closedloop``, ``vdnscl``
- **Step count:** 1
- **First step:** ``VDNS Policy``

VFWCL Closed Loop Test
~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``VFWCL Closed Loop Test``
- **Tags:** ``vfwclosedloop``
- **Teardown:** ``VFWCL Set To Medium ${PACKET_GENERATOR_HOST}``
- **Step count:** 4
- **First step:** ``Log ${EMPTY}``

VFWCL Repush Monitoring And Operational Policies
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``VFWCL Repush Monitoring And Operational Policies``
- **Tags:** ``repushpolicy``
- **Step count:** 11
- **First step:** ``Validate the vFWCL Policy``

Possible Improvements
---------------------

- Keep suite documentation aligned with current ONAP release behavior and update references when endpoints or flows change.
- Add `[Documentation]` to 4 test case(s) to explain intent, preconditions, and expected outcome.
- Review tag naming consistency (for example `health-*`, `instantiate*`, `ete`) to keep filtering and reporting uniform.
- Refactor 1 long test case(s) into reusable user keywords to reduce maintenance cost and improve readability.
