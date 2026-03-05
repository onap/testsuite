Suite: robot/testsuites/usecases/5gson.robot
============================================

Suite Metadata
--------------

- **Source file:** ``robot/testsuites/usecases/5gson.robot``
- **Suite documentation:** 5G SON Usecase functionality
- **Total test cases:** 9

Test Cases
----------

Creating Policy Types
~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Creating Policy Types``
- **Tags:** ``5gson``
- **Step count:** 3
- **First step:** ``${monitoring_policy_type}= Get Binary File ${5GSON_RESOURCES_PATH}/monitoring_policy_type.json``

Creating SON Policies
~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Creating SON Policies``
- **Tags:** ``5gson``
- **Step count:** 9
- **First step:** ``${pci_policy}= Get Binary File ${5GSON_RESOURCES_PATH}/pci.json``

Deploying SON Polciies
~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Deploying SON Polciies``
- **Tags:** ``5gson``
- **Step count:** 9
- **First step:** ``${pci_deploy}= Get Binary File ${5GSON_RESOURCES_PATH}/pci_deploy.json``

Create dmaap topics
~~~~~~~~~~~~~~~~~~~

- **Name:** ``Create dmaap topics``
- **Tags:** ``5gson``
- **Step count:** 5
- **First step:** ``FOR ${topic} IN @{TOPICS}``

Deploy SON Handler
~~~~~~~~~~~~~~~~~~

- **Name:** ``Deploy SON Handler``
- **Tags:** ``5gson``
- **Step count:** 12
- **First step:** ``${headers}= Create Dictionary content-type=application/json``

Deploy Config DB
~~~~~~~~~~~~~~~~

- **Name:** ``Deploy Config DB``
- **Tags:** ``5gson``
- **Step count:** 17
- **First step:** ``${configdb_blueprint_path} Set Variable ${5GSON_RESOURCES_PATH}/k8s-configdb.yaml``

Load Data to Config DB
~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Load Data to Config DB``
- **Tags:** ``5gson``
- **Step count:** 6
- **First step:** ``Sleep 30 seconds``

Post Fault Message to VES Collector
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Post Fault Message to VES Collector``
- **Tags:** ``5gson``
- **Step count:** 9
- **First step:** ``${session}= Create Session configdb http://configdb.onap:8080``

Verifying Modify Config message from SDNR-CL
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Verifying Modify Config message from SDNR-CL``
- **Tags:** ``5gson``
- **Step count:** 3
- **First step:** ``${no_of_msgs} Set Variable ${0}``

Possible Improvements
---------------------

- Keep suite documentation aligned with current ONAP release behavior and update references when endpoints or flows change.
- Add `[Documentation]` to 9 test case(s) to explain intent, preconditions, and expected outcome.
- Review tag naming consistency (for example `health-*`, `instantiate*`, `ete`) to keep filtering and reporting uniform.
- Refactor 5 long test case(s) into reusable user keywords to reduce maintenance cost and improve readability.
- Document required external dependencies and data contracts (topics, endpoints, credentials) for faster troubleshooting.
