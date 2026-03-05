Suite: robot/testsuites/ves.robot
=================================

Suite Metadata
--------------

- **Source file:** ``robot/testsuites/ves.robot``
- **Suite documentation:** Suite for checking handling events by VES Collector
- **Total test cases:** 5

Test Cases
----------

Send standard event to VES and check if is routed to proper topic
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Documentation:** This test case checks whether fault event is sent to proper DMAAP topic. Fault event should be routed by VES Collector to unauthenticated.SEC_FAULT_OUTPUT topic on DMAAP MR.

- **Name:** ``Send standard event to VES and check if is routed to proper topic``
- **Tags:** ``vescollector``, ``ete``
- **Step count:** 2
- **First step:** ``${expected_fault_on_mr} Set Variable Fault_Vscf:Acs-Ericcson_PilotNumberPoolExhaustion``

Send 3GPP Fault Supervision event to VES and check if is routed to proper topic
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Documentation:** This test case checks whether fault event is sent to proper DMAAP topic. Fault Supervision event should be routed by domain = "stndDefined" and stndDefinedNamespace = "3GPP-FaultSupervision". Fault should be routed to mr topic unauthenticated.SEC_3GPP_FAULTSUPERVISION_OUTPUT

- **Name:** ``Send 3GPP Fault Supervision event to VES and check if is routed to proper topic``
- **Tags:** ``vescollector``, ``ete``
- **Step count:** 2
- **First step:** ``${expected_fault_on_mr} Set Variable ves_stdnDefined_3GPP-FaultSupervision``

Send 3GPP Heartbeat event to VES and check if is routed to proper topic
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Documentation:** This test case checks whether fault event is sent to proper DMAAP topic. Fault Supervision event should be routed by domain = "stndDefined" and stndDefinedNamespace = "3GPP-Heartbeat". Fault should be routed to mr topic unauthenticated.SEC_3GPP_HEARTBEAT_OUTPUT

- **Name:** ``Send 3GPP Heartbeat event to VES and check if is routed to proper topic``
- **Tags:** ``vescollector``, ``ete``
- **Step count:** 2
- **First step:** ``${expected_fault_on_mr} Set Variable ves_stdnDefined_3GPP-Heartbeat``

Send 3GPP Performance Assurance event to VES and check if is routed to proper topic
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Documentation:** This test case checks whether fault event is sent to proper DMAAP topic. Fault Supervision event should be routed by domain = "stndDefined" and stndDefinedNamespace = "3GPP-PerformanceAssurance". Fault should be routed to mr topic unauthenticated.SEC_3GPP_PERFORMANCEASSURANCE_OUTPUT

- **Name:** ``Send 3GPP Performance Assurance event to VES and check if is routed to proper topic``
- **Tags:** ``vescollector``, ``ete``
- **Step count:** 2
- **First step:** ``${expected_fault_on_mr} Set Variable ves_stdnDefined_3GPP-PerformanceAssurance``

Send 3GPP Provisioning event to VES and check if is routed to proper topic
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Documentation:** This test case checks whether fault event is sent to proper DMAAP topic. Fault Supervision event should be routed by domain = "stndDefined" and stndDefinedNamespace = "3GPP-Provisioning". Fault should be routed to mr topic unauthenticated.SEC_3GPP_PROVISIONING_OUTPUT

- **Name:** ``Send 3GPP Provisioning event to VES and check if is routed to proper topic``
- **Tags:** ``vescollector``, ``ete``
- **Step count:** 2
- **First step:** ``${expected_fault_on_mr} Set Variable ves_stdnDefined_3GPP-Provisioning``

Possible Improvements
---------------------

- Keep suite documentation aligned with current ONAP release behavior and update references when endpoints or flows change.
- Continue maintaining per-test `[Documentation]` blocks with concise failure diagnostics and expected assertions.
- Review tag naming consistency (for example `health-*`, `instantiate*`, `ete`) to keep filtering and reporting uniform.
- Add teardown cleanup checks so repeated runs are idempotent and less sensitive to residual state.
