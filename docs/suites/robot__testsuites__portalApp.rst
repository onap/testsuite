Suite: robot/testsuites/portalApp.robot
=======================================

Suite Metadata
--------------

- **Source file:** ``robot/testsuites/portalApp.robot``
- **Suite documentation:** End-to-end test cases for basic ONAP Portal functionalities
- **Default test timeout:** ``5 minutes``
- **Total test cases:** 17

Test Cases
----------

Login into Portal URL
~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Login into Portal URL``
- **Tags:** ``portal``, ``portal-ci``
- **Step count:** 1
- **First step:** ``Portal admin Login To Portal GUI``

Portal Change REST URL Of X-DemoApp
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Documentation:** Portal Change REST URL Of X-DemoApp

- **Name:** ``Portal Change REST URL Of X-DemoApp``
- **Tags:** ``portal``, ``portal-ci``
- **Step count:** 1
- **First step:** ``Portal Change REST URL``

Portal R1 Release for AAF
~~~~~~~~~~~~~~~~~~~~~~~~~

**Documentation:** ONAP Portal R1 functionality for AAF test

- **Name:** ``Portal R1 Release for AAF``
- **Tags:** ``portal``, ``portal-ci``
- **Step count:** 1
- **First step:** ``Portal AAF new fields``

EP Admin widget layout reset
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``EP Admin widget layout reset``
- **Tags:** ``portalSKIP``, ``portal-ci``
- **Step count:** 1
- **First step:** ``Reset widget layout option``

Validate Functional Top Menu Get Access
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Validate Functional Top Menu Get Access``
- **Tags:** ``portal``, ``portal-ci``
- **Step count:** 1
- **First step:** ``Functional Top Menu Get Access``

Validate Functional Top Menu Contact Us
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Validate Functional Top Menu Contact Us``
- **Tags:** ``portal``, ``portal-ci``
- **Step count:** 1
- **First step:** ``Functional Top Menu Contact Us``

Edit Functional Menu
~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Edit Functional Menu``
- **Tags:** ``portal``
- **Step count:** 1
- **First step:** ``Portal admin Edit Functional menu``

Create a Test user for Application Admin -Test
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Create a Test user for Application Admin -Test``
- **Tags:** ``portal``, ``portal-ci``
- **Step count:** 2
- **First step:** ``${login_id} ${email_address}= Generate Random User portal``

Create a Test User for Application Admin
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Create a Test User for Application Admin``
- **Tags:** ``portal``, ``portal-ci``
- **Step count:** 2
- **First step:** ``${login_id} ${email_address}= Generate Random User demoapp``

Add Application Admin for Existing User Test user
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Add Application Admin for Existing User Test user``
- **Tags:** ``portal``
- **Step count:** 2
- **First step:** ``${login_id} ${email_address}= Generate Random User demoapp``

Create a Test user for Standard User
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Create a Test user for Standard User``
- **Tags:** ``portal``
- **Step count:** 2
- **First step:** ``${login_id} ${email_address}= Generate Random User demosta``

Add Application Admin for Existing User
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Add Application Admin for Existing User``
- **Tags:** ``portal``
- **Step count:** 2
- **First step:** ``${login_id} ${email_address}= Generate Random User portal``

Delete Application Admin for Existing User
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Delete Application Admin for Existing User``
- **Tags:** ``portal``
- **Step count:** 2
- **First step:** ``${login_id} ${email_address}= Generate Random User portal``

Logout from Portal GUI as Portal Admin
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Logout from Portal GUI as Portal Admin``
- **Tags:** ``portal``, ``portal-ci``
- **Step count:** 1
- **First step:** ``Portal admin Logout from Portal GUI``

Login To Portal GUI as APP Admin
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Login To Portal GUI as APP Admin``
- **Tags:** ``portal``, ``portal-ci``
- **Step count:** 2
- **First step:** ``${login_id} ${email_address}= Generate Random User demoapp``

Logout from Portal GUI as APP Admin
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Logout from Portal GUI as APP Admin``
- **Tags:** ``portal``, ``portal-ci``
- **Step count:** 1
- **First step:** ``Application admin Logout from Portal GUI``

Logout from Portal GUI as Standard User
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Name:** ``Logout from Portal GUI as Standard User``
- **Tags:** ``portal``, ``portal-ci``
- **Step count:** 2
- **First step:** ``Standard User Logout from Portal GUI``

Possible Improvements
---------------------

- Keep suite documentation aligned with current ONAP release behavior and update references when endpoints or flows change.
- Add `[Documentation]` to 15 test case(s) to explain intent, preconditions, and expected outcome.
- Review tag naming consistency (for example `health-*`, `instantiate*`, `ete`) to keep filtering and reporting uniform.
- Stabilize UI tests by preferring resilient locators and explicit waits over timing assumptions.
