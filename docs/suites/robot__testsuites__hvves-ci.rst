Suite: robot/testsuites/hvves-ci.robot
======================================

Suite Metadata
--------------

- **Source file:** ``robot/testsuites/hvves-ci.robot``
- **Suite documentation:** HV-VES 'Sunny Scenario' Robot Framework test - message is sent to the collector and Kafka topic is checked if the message has been published. Content is decoded and checked.
- **Default test timeout:** ``5m``
- **Total test cases:** 1

Test Cases
----------

HV-VES test case
~~~~~~~~~~~~~~~~

- **Name:** ``HV-VES test case``
- **Step count:** 6
- **First step:** ``${status} ${data}= Run Keyword And Ignore Error Variable Should Exist ${GLOBAL_KAFKA_BOOTSTRAP_SERVICE}``

Possible Improvements
---------------------

- Keep suite documentation aligned with current ONAP release behavior and update references when endpoints or flows change.
- Add `[Documentation]` to 1 test case(s) to explain intent, preconditions, and expected outcome.
- Tag the 1 untagged test case(s) so selective execution (`--include`/`--exclude`) remains predictable.
- Add teardown cleanup checks so repeated runs are idempotent and less sensitive to residual state.
