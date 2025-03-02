# Getting Started

## Prerequisites

This guide assumes you have run git clone on https://gerrit.onap.org/r/testsuite.git

For more info please see the [Development Guide](https://wiki.onap.org/display/DW/Robot+Framework+Development+Guide)

## Development Environment Setup

### Create a virtual environment

```sh
python3 -m venv .venv
```

```sh
source .venv/bin/activate
```

### Install dependencies

Make sure that you have activated the `venv` that you have created in the previous step. Then run

```sh
pip install -r requirements.txt
```

### Proxy setup

Depending on your environment, it may be needed to configure proxy environment variables for your system.
For Windows, right click the Computer icon. Choose Properties from the context menu.
Click the Advanced system settings link. Click Environment Variables. In the section System Variables, click New.
In the New System Variable window, set the name as `HTTPS_PROXY` then specify the value of the `HTTPS_PROXY` environment variable as your proxy. Click OK. Close all remaining windows by clicking OK.

## Project Setup

Note: You do not need to run these commands every time, only on a library update or initial checkout.

```sh
./setup.sh
```

Note that this script will download the chromedriver for the current OS. The default is linux64 which will download the appropriate chromedriver to /usr/local/bin so that it will be in the execution PATH.

Windows and Mac hosts will download into the current working directory. Windows and MAC users will need to ensure that the driver is in the execution PATH.

## Executing ETE Testcases

### Overview
Two scripts have been provided in the root of the ete-testsuite project to enable test execution

* `runTags.sh` - This shell uses Robot [Tags] to drive which tests are executed and is designed for automated testing.
* `oneTest.sh` - This shell is designed for unit testing of individual .robot files. It accepts a single argument identifying the `.robot` file in `robot/testsuites` to execute.

### Invoke directly

```sh
$ robot -V robot_properties.py robot/testsuites/health-check.robot
...
------------------------------------------------------------------------------
Mariadb Galera SO Connectivity Test                                   | FAIL |
catalogdb: 'error: pod, type/name or --filename must be specified' does not contain 'current database:'
------------------------------------------------------------------------------
Health-Check :: Test that ONAP components are available via basic ... | FAIL |
66 critical tests, 1 passed, 65 failed
66 tests total, 1 passed, 65 failed
==============================================================================
Output:  /home/ubuntu/development/onap/testsuite/output.xml
Log:     /home/ubuntu/development/onap/testsuite/log.html
Report:  /home/ubuntu/development/onap/testsuite/report.html
```

#### runTags.sh

For further information on using Robot [Tags], see [Configuring Execution](https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#configuring-execution) and [Simple Patterns](https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#simple-patterns)

When executing tests via tags, all of the robot files in the project are scanned for tests cases with the specified tags.

There are 3 flavors of runTags.sh

* runTags.sh with no arguments. This defaults to the default tag or runTags.sh -i health
* runTags.sh with a single include tag. In this case the -i or --include may be omitted. So runTags.sh ete is the same as runTags.sh -i ete
* runTags.sh with multiple tags. In this case, tags must be accompanied by a -i/--include or -e/--exclude to properly identify the disposition of the tagged testcase.

```sh
runTags.sh -i health -i ete -e garbage
```

## Contributing
Follow [Robot Framework Development Guide](https://wiki.onap.org/display/DW/Robot+Framework+Development+Guide).
