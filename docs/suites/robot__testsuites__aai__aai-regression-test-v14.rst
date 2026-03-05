Suite: robot/testsuites/aai/aai-regression-test-v14.robot
=========================================================

Suite Metadata
--------------

- **Source file:** ``robot/testsuites/aai/aai-regression-test-v14.robot``
- **Suite documentation:** AAI CSIT-style regression tests for CCVPN - new schema elements introduced in Casablanca release for CCVPN use case
- **Default test timeout:** ``20s``
- **Total test cases:** 5

Test Cases
----------

Connectivity test case
~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Connectivity test case``
- **Tags:** ``aai``, ``csit``, ``ccvpn``, ``connectivity``
- **Teardown:** ``Run Keywords Delete Connectivity If Exists ${connectivity_id} AND Confirm No Connectivity ${connectivity_id}``
- **Step count:** 4
- **First step:** ``Confirm API Not Implemented Connectivity ${connectivity_id}``

VPN Binding test case
~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``VPN Binding test case``
- **Tags:** ``aai``, ``csit``, ``ccvpn``, ``vpn-binding``
- **Teardown:** ``Run Keywords Delete VPN Binding If Exists ${vpn_id} AND Confirm No VPN Binding ${vpn_id}``
- **Step count:** 3
- **First step:** ``Confirm No VPN Binding ${vpn_id}``

Connectivity to VPN Binding Relationship test case
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Connectivity to VPN Binding Relationship test case``
- **Tags:** ``aai``, ``csit``, ``ccvpn``, ``connectivity``, ``vpn-binding``, ``relationship``
- **Teardown:** ``Run Keywords Delete Connectivity If Exists ${connectivity_id} AND Delete VPN Binding If Exists ${vpn_id}``
- **Step count:** 13
- **First step:** ``Confirm No Connectivity ${connectivity_id}``

VPN Binding Relationship to Connectivity test case
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``VPN Binding Relationship to Connectivity test case``
- **Tags:** ``aai``, ``csit``, ``ccvpn``, ``connectivity``, ``vpn-binding``, ``relationship``
- **Teardown:** ``Run Keywords Delete Connectivity If Exists ${connectivity_id} AND Delete VPN Binding If Exists ${vpn_id}``
- **Step count:** 13
- **First step:** ``Confirm No Connectivity ${connectivity_id}``

All Teardowns test case
~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``All Teardowns test case``
- **Tags:** ``teardowns``
- **Step count:** 4
- **First step:** ``Delete Connectivity If Exists ${connectivity_id}``

Possible Improvements
---------------------

- Keep suite documentation aligned with current ONAP release behavior and update references when endpoints or flows change.
- Add `[Documentation]` to 5 test case(s) to explain intent, preconditions, and expected outcome.
- Review tag naming consistency (for example `health-*`, `instantiate*`, `ete`) to keep filtering and reporting uniform.
- Refactor 2 long test case(s) into reusable user keywords to reduce maintenance cost and improve readability.
