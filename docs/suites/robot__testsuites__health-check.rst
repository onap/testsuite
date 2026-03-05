Suite: robot/testsuites/health-check.robot
==========================================

Suite Metadata
--------------

- **Source file:** ``robot/testsuites/health-check.robot``
- **Suite documentation:** Test that ONAP components are available via basic API calls
- **Default test timeout:** ``100 seconds``
- **Total test cases:** 66

Test Cases
----------

Basic A&AI Health Check
~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Basic A&AI Health Check``
- **Tags:** ``health``, ``core``, ``health-aai``
- **Step count:** 1
- **First step:** ``Run A&AI Health Check``

Enhanced A&AI Health Check
~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Enhanced A&AI Health Check``
- **Tags:** ``health``, ``core``, ``health-aai``
- **Step count:** 2
- **First step:** ``Run Resource API AAI Inventory check``

Basic AAF Health Check
~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Basic AAF Health Check``
- **Tags:** ``health-aaf``
- **Step count:** 1
- **First step:** ``Run AAF Health Check``

Basic AAF SMS Health Check
~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Basic AAF SMS Health Check``
- **Tags:** ``health-aaf``
- **Step count:** 1
- **First step:** ``Run SMS Health Check``

Basic CLI Health Check
~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Basic CLI Health Check``
- **Tags:** ``health-cli``
- **Step count:** 1
- **First step:** ``Run CLI Health Check``

Basic CLAMP Health Check
~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Basic CLAMP Health Check``
- **Tags:** ``health-clamp``
- **Step count:** 1
- **First step:** ``Run CLAMP Health Check``

Basic DCAE Microservices Health Check
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Basic DCAE Microservices Health Check``
- **Tags:** ``health``, ``medium``, ``health-dcaegen2-services``
- **Step count:** 1
- **First step:** ``Run DCAE Microservices Health Check``

Basic DMAAP Data Router Health Check
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Basic DMAAP Data Router Health Check``
- **Tags:** ``datarouter``, ``health-dmaap``
- **Step count:** 1
- **First step:** ``Run DR Health Check``

Basic DMAAP Message Router Health Check
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Basic DMAAP Message Router Health Check``
- **Tags:** ``messagerouter``
- **Step count:** 1
- **First step:** ``Run MR Health Check``

Basic DMAAP Message Router PubSub Health Check
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Basic DMAAP Message Router PubSub Health Check``
- **Tags:** ``healthmr``, ``messagerouter``
- **Timeout:** ``30``
- **Step count:** 1
- **First step:** ``Run MR PubSub Health Check``

Basic External API NBI Health Check
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Basic External API NBI Health Check``
- **Tags:** ``externalapi``, ``api``, ``medium``
- **Step count:** 1
- **First step:** ``Run NBI Health Check``

Basic Log Elasticsearch Health Check
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Basic Log Elasticsearch Health Check``
- **Tags:** ``oom``, ``health-log``
- **Step count:** 1
- **First step:** ``Run Log Elasticsearch Health Check``

Basic Log Kibana Health Check
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Basic Log Kibana Health Check``
- **Tags:** ``oom``, ``health-log``
- **Step count:** 1
- **First step:** ``Run Log Kibana Health Check``

Basic Log Logstash Health Check
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Basic Log Logstash Health Check``
- **Tags:** ``oom``, ``health-log``
- **Step count:** 1
- **First step:** ``Run Log Logstash Health Check``

Basic Microservice Bus Health Check
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Basic Microservice Bus Health Check``
- **Tags:** ``health-msb``
- **Step count:** 1
- **First step:** ``Run MSB Health Check``

Basic Multicloud API Health Check
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Basic Multicloud API Health Check``
- **Tags:** ``health``, ``multicloud``, ``small``, ``health-multicloud``
- **Step count:** 1
- **First step:** ``Run MultiCloud Health Check``

Basic Multicloud-pike API Health Check
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Basic Multicloud-pike API Health Check``
- **Tags:** ``multicloud``, ``small``, ``health-multicloud``
- **Step count:** 1
- **First step:** ``Run MultiCloud-pike Health Check``

Basic Multicloud-starlingx API Health Check
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Basic Multicloud-starlingx API Health Check``
- **Tags:** ``multicloud``, ``health-multicloud``
- **Step count:** 1
- **First step:** ``Run MultiCloud-starlingx Health Check``

Basic Multicloud-titanium_cloud API Health Check
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Basic Multicloud-titanium_cloud API Health Check``
- **Tags:** ``multicloud``, ``health-multicloud``
- **Step count:** 1
- **First step:** ``Run MultiCloud-titanium_cloud Health Check``

Basic Multicloud-vio API Health Check
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Basic Multicloud-vio API Health Check``
- **Tags:** ``multicloud``, ``health-multicloud``
- **Step count:** 1
- **First step:** ``Run MultiCloud-vio Health Check``

Basic Multicloud-k8s API Health Check
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Basic Multicloud-k8s API Health Check``
- **Tags:** ``health``, ``multicloud``, ``health-multicloud``
- **Step count:** 1
- **First step:** ``Run MultiCloud-k8s Health Check``

Basic Multicloud-fcaps API Health Check
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Basic Multicloud-fcaps API Health Check``
- **Tags:** ``health``, ``multicloud``, ``health-multicloud``
- **Step count:** 1
- **First step:** ``Run MultiCloud-fcaps Health Check``

Basic Multicloud-prometheus API Health Check
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Basic Multicloud-prometheus API Health Check``
- **Tags:** ``multicloud``, ``health-multicloud``
- **Step count:** 1
- **First step:** ``Run MultiCloud-prometheus Health Check``

Basic OOF-Homing Health Check
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Basic OOF-Homing Health Check``
- **Tags:** ``health-oof``
- **Step count:** 1
- **First step:** ``Run OOF-Homing Health Check``

Basic OOF-OSDF Health Check
~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Basic OOF-OSDF Health Check``
- **Tags:** ``health-oof``
- **Step count:** 1
- **First step:** ``Run OOF-OSDF Health Check``

Basic Policy Health Check
~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Basic Policy Health Check``
- **Tags:** ``health``, ``medium``, ``health-policy``
- **Step count:** 1
- **First step:** ``Run Policy Health Check``

Enhanced Policy New Healthcheck
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Enhanced Policy New Healthcheck``
- **Tags:** ``health``, ``medium``, ``health-policy``
- **Timeout:** ``60``
- **Step count:** 6
- **First step:** ``Check for Existing Policy and Clean up``

Basic Pomba AAI-context-builder Health Check
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Basic Pomba AAI-context-builder Health Check``
- **Tags:** ``oom``, ``health-pomba``
- **Step count:** 1
- **First step:** ``Run Pomba Aai Context Builder Health Check``

Basic Pomba SDC-context-builder Health Check
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Basic Pomba SDC-context-builder Health Check``
- **Tags:** ``oom``, ``health-pomba``
- **Step count:** 1
- **First step:** ``Run Pomba Sdc Context Builder Health Check``

Basic Pomba Network-discovery-context-builder Health Check
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Basic Pomba Network-discovery-context-builder Health Check``
- **Tags:** ``oom``, ``health-pomba``
- **Step count:** 1
- **First step:** ``Run Pomba Network Discovery Context Builder Health Check``

Basic Pomba Service-Decomposition Health Check
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Basic Pomba Service-Decomposition Health Check``
- **Tags:** ``oom``, ``health-pomba``
- **Step count:** 1
- **First step:** ``Run Pomba Service Decomposition Health Check``

Basic Pomba Network-Discovery-MicroService Health Check
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Basic Pomba Network-Discovery-MicroService Health Check``
- **Tags:** ``oom``, ``health-pomba``
- **Step count:** 1
- **First step:** ``Run Pomba Network Discovery MicroService Health Check``

Basic Pomba Pomba-Kibana Health Check
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Basic Pomba Pomba-Kibana Health Check``
- **Tags:** ``oom``, ``health-pomba``
- **Step count:** 1
- **First step:** ``Run Pomba Kibana Health Check``

Basic Pomba Elastic-Search Health Check
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Basic Pomba Elastic-Search Health Check``
- **Tags:** ``oom``, ``health-pomba``
- **Step count:** 1
- **First step:** ``Run Pomba Elastic Search Health Check``

Basic Pomba Sdnc-Context-Builder Health Check
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Basic Pomba Sdnc-Context-Builder Health Check``
- **Tags:** ``oom``, ``health-pomba``
- **Step count:** 1
- **First step:** ``Run Pomba Sdnc Context Builder Health Check``

Basic Pomba Context-Aggregator Health Check
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Basic Pomba Context-Aggregator Health Check``
- **Tags:** ``oom``, ``health-pomba``
- **Step count:** 1
- **First step:** ``Run Pomba Context Aggregator Health Check``

Basic SDC Health Check
~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Basic SDC Health Check``
- **Tags:** ``health``, ``core``, ``health-sdc``
- **Step count:** 1
- **First step:** ``Run SDC Health Check``

Enhanced SDC Health Check
~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Enhanced SDC Health Check``
- **Tags:** ``health``, ``core``, ``health-sdc``
- **Step count:** 2
- **First step:** ``Run SDC BE ONBOARD Healthcheck``

Basic SDNC Health Check
~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Basic SDNC Health Check``
- **Tags:** ``health``, ``core``, ``health-sdnc``
- **Step count:** 1
- **First step:** ``Run SDNC Health Check``

Enhanced SDNC Health Check
~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Enhanced SDNC Health Check``
- **Tags:** ``health``, ``core``, ``health-sdnc``
- **Step count:** 1
- **First step:** ``Run SDNC Health Check Generic Resource API``

Basic SO Health Check
~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Basic SO Health Check``
- **Tags:** ``health``, ``core``, ``health-so``
- **Step count:** 9
- **First step:** ``SO.Run Get Request ${GLOBAL_SO_APIHAND_ENDPOINT} ${GLOBAL_SO_HEALTH_CHECK_PATH}``

Basic UseCaseUI API Health Check
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Basic UseCaseUI API Health Check``
- **Tags:** ``health``, ``api``, ``medium``, ``health-uui``
- **Step count:** 1
- **First step:** ``Run UUI Health Check``

Basic VFC gvnfmdriver API Health Check
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Basic VFC gvnfmdriver API Health Check``
- **Tags:** ``3rdparty``, ``health-vfc``
- **Step count:** 1
- **First step:** ``Run VFC gvnfmdriver Health Check``

Basic VFC huaweivnfmdriver API Health Check
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Basic VFC huaweivnfmdriver API Health Check``
- **Tags:** ``3rdparty``, ``health-vfc``
- **Step count:** 1
- **First step:** ``Run VFC huaweivnfmdriver Health Check``

Basic VFC nslcm API Health Check
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Basic VFC nslcm API Health Check``
- **Tags:** ``api``, ``health-vfc``
- **Step count:** 1
- **First step:** ``Run VFC nslcm Health Check``

Basic VFC vnflcm API Health Check
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Basic VFC vnflcm API Health Check``
- **Tags:** ``api``, ``health-vfc``
- **Step count:** 1
- **First step:** ``Run VFC vnflcm Health Check``

Basic VFC vnfmgr API Health Check
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Basic VFC vnfmgr API Health Check``
- **Tags:** ``api``, ``health-vfc``
- **Step count:** 1
- **First step:** ``Run VFC vnfmgr Health Check``

Basic VFC vnfres API Health Check
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Basic VFC vnfres API Health Check``
- **Tags:** ``api``, ``health-vfc``
- **Step count:** 1
- **First step:** ``Run VFC vnfres Health Check``

Basic VFC ztevnfmdriver API Health Check
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Basic VFC ztevnfmdriver API Health Check``
- **Tags:** ``3rdparty``, ``health-vfc``
- **Step count:** 1
- **First step:** ``Run VFC ztevnfmdriver Health Check``

Basic VNFSDK Health Check
~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Basic VNFSDK Health Check``
- **Tags:** ``health-vnfsdk``
- **Step count:** 1
- **First step:** ``Run VNFSDK Health Check``

Health Distribution Test
~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Health Distribution Test``
- **Tags:** ``healthdist``
- **Timeout:** ``1200``
- **Step count:** 1
- **First step:** ``Model Distribution For Directory With Teardown vFW``

Portal Login Tests
~~~~~~~~~~~~~~~~~~

- **Name:** ``Portal Login Tests``
- **Tags:** ``healthlogin``
- **Timeout:** ``120``
- **Step count:** 1
- **First step:** ``Run Portal Login Tests``

Portal Application Access Tests
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Portal Application Access Tests``
- **Tags:** ``healthportalapp``
- **Timeout:** ``900``
- **Step count:** 1
- **First step:** ``Run Portal Application Access Tests``

Portal SDC Application Access Test
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Portal SDC Application Access Test``
- **Tags:** ``healthportalapp2``
- **Timeout:** ``180``
- **Step count:** 2
- **First step:** ``Run Portal Application Login Test cs0008 demo123456! gridster-SDC-icon-link tabframe-SDC Welcome to SDC``

Portal VID Application Access Test
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Portal VID Application Access Test``
- **Tags:** ``healthportalapp2``
- **Timeout:** ``180``
- **Step count:** 2
- **First step:** ``Run Portal Application Login Test demo demo123456! gridster-Virtual-Infrastructure-Deployment-icon-link tabframe-Virtual-Infrastructure-Deployment Welcome to VID``

Portal A&AI UI Application Access Test
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Portal A&AI UI Application Access Test``
- **Tags:** ``healthportalapp2``
- **Timeout:** ``180``
- **Step count:** 2
- **First step:** ``Run Portal Application Login Test demo demo123456! gridster-A&AI-UI-icon-link tabframe-A&AI-UI A&AI``

Portal Policy Editor Application Access Test
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Portal Policy Editor Application Access Test``
- **Tags:** ``healthportalapp2``
- **Timeout:** ``180``
- **Step count:** 2
- **First step:** ``Run Portal Application Login Test demo demo123456! gridster-Policy-icon-link tabframe-Policy Policy Editor``

Portal SO Monitoring Application Access Test
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Portal SO Monitoring Application Access Test``
- **Tags:** ``healthportalapp2``
- **Timeout:** ``180``
- **Step count:** 2
- **First step:** ``Run Portal Application Login Test demo demo123456! gridster-SO-Monitoring-icon-link tabframe-SO-Monitoring SO``

Portal xDemo APP Application Access Test
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Portal xDemo APP Application Access Test``
- **Tags:** ``healthportalapp2``
- **Timeout:** ``180``
- **Step count:** 2
- **First step:** ``Run Portal Application Login Test demo demo123456! gridster-xDemo-App-icon-link tabframe-xDemo-App xDemo``

Portal CLI Application Access Test
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Portal CLI Application Access Test``
- **Tags:** ``healthportalapp2``
- **Timeout:** ``180``
- **Step count:** 2
- **First step:** ``Run Portal Application Login Test demo demo123456! gridster-CLI-icon-link tabframe-CLI CLI``

Basic Holmes Rule Management API Health Check
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Basic Holmes Rule Management API Health Check``
- **Tags:** ``health-holmes``
- **Step count:** 1
- **First step:** ``Run Holmes Rule Mgmt Healthcheck``

Basic Holmes Engine Management API Health Check
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Basic Holmes Engine Management API Health Check``
- **Tags:** ``health-holmes``
- **Step count:** 1
- **First step:** ``Run Holmes Engine Mgmt Healthcheck``

Basic Modeling Parser API Health Check
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Basic Modeling Parser API Health Check``
- **Tags:** ``api``, ``health-modeling``
- **Step count:** 1
- **First step:** ``Run Modeling Parser Healthcheck``

Enhanced CDS Health Check
~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Enhanced CDS Health Check``
- **Tags:** ``health``, ``small``, ``health-cds``
- **Step count:** 8
- **First step:** ``Run CDS Basic Health Check``

Mariadb Galera Pod Connectivity Test
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Mariadb Galera Pod Connectivity Test``
- **Tags:** ``health-mariadb-galera``
- **Step count:** 1
- **First step:** ``Check for Mariadb Galera Pod Connection``

Mariadb Galera SO Connectivity Test
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Mariadb Galera SO Connectivity Test``
- **Tags:** ``health-mariadb-galera``
- **Step count:** 1
- **First step:** ``Check for SO Databases Connection``

Possible Improvements
---------------------

- Keep suite documentation aligned with current ONAP release behavior and update references when endpoints or flows change.
- Add `[Documentation]` to 66 test case(s) to explain intent, preconditions, and expected outcome.
- Review tag naming consistency (for example `health-*`, `instantiate*`, `ete`) to keep filtering and reporting uniform.
- Refactor 2 long test case(s) into reusable user keywords to reduce maintenance cost and improve readability.
- Split broad health checks into component-focused suites to reduce blast radius and simplify parallel execution.
