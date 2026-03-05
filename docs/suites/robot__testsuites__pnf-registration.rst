Suite: robot/testsuites/pnf-registration.robot
==============================================

Suite Metadata
--------------

- **Source file:** ``robot/testsuites/pnf-registration.robot``
- **Suite documentation:** Executes the PNF registration test cases including setup and teardown
- **Default test timeout:** ``15m``
- **Total test cases:** 3

Test Cases
----------

PNF Registration only DCAE part: AAI, VES, PRH, Kafka
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Documentation:** This test case creates A&AI entry for PNF without SDC model distribution and service instantiation in SO. Test case verify PNF Registration only in DCAE part: AAI, VES, PRH, Kafka. During test case Robot adds PNF entry to A&AI that contains: correlation ID, PNF_IPv4_address and PNF_IPv6_address

- **Name:** ``PNF Registration only DCAE part: AAI, VES, PRH, Kafka``
- **Tags:** ``pnf_registrate``, ``ete``
- **Teardown:** ``Cleanup PNF entry in A&AI ${PNF_entry_dict}``
- **Step count:** 4
- **First step:** ``${pnf_correlation_id}= Generate Random String 20 [LETTERS][NUMBERS]``

Instantiate PNF_macro service and succesfully registrate PNF
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Documentation:** This test case creates TOSCA csar software package for PNF. Imports it as VSP package. Cretaes PNF resource, cretaes Macro service, attach PNF resource and distributes it. After sucesfull distribution, service recipe is added to SO ctalog db. Next service is instantied with random PNF id. VES integration event is send with this PNF ID. At the end of the service is checked in terms - service completion - PNF entry update about information from VES event

- **Name:** ``Instantiate PNF_macro service and succesfully registrate PNF``
- **Tags:** ``pnf_registrate_macro_vnf_api``, ``ete``
- **Step count:** 4
- **First step:** ``${pnf_correlation_id}= Generate Random String 20 [LETTERS][NUMBERS]``

Instantiate PNF service (using building blocks) and succesfully registrate PNF
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Documentation:** This test case creates TOSCA csar software package for PNF. Imports it as VSP package. Cretaes PNF resource, cretaes Macro service, attach PNF resource and distributes it. Next service is instantied with random PNF id. VES integration event is send with this PNF ID. At the end of the service is checked in terms - service completion - PNF entry update about information from VES event - PNF orchestration status

- **Name:** ``Instantiate PNF service (using building blocks) and succesfully registrate PNF``
- **Tags:** ``pnf_registrate``, ``ete``
- **Step count:** 4
- **First step:** ``${pnf_correlation_id}= Generate Random String 20 [LETTERS][NUMBERS]``

Possible Improvements
---------------------

- Keep suite documentation aligned with current ONAP release behavior and update references when endpoints or flows change.
- Continue maintaining per-test `[Documentation]` blocks with concise failure diagnostics and expected assertions.
- Review tag naming consistency (for example `health-*`, `instantiate*`, `ete`) to keep filtering and reporting uniform.
- Add teardown cleanup checks so repeated runs are idempotent and less sensitive to residual state.
