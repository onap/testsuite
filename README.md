# Getting Started
## Prerequisites
This guide assumes you have run git clone on https://gerrit.onap.org/r/p/testsuite.git

For more info please see the [Development Guide](https://wiki.onap.org/display/DW/Robot+Framework+Development+Guide)

## Development Environment Setup
### Python Installation
You should install 2.7.12: [https://www.python.org/downloads/release/python-2712](https://www.python.org/downloads/release/python-2712)


### Pip Install
Install pip with the get-pip.py file from [https://bootstrap.pypa.io/get-pip.py](https://bootstrap.pypa.io/get-pip.py)
once downloaded run

```
python get-pip.py
```
let it install.

From the desktop, right click the Computer icon.
Choose Properties from the context menu.
Click the Advanced system settings link.
Click Environment Variables. In the section System Variables, click New.
In the New System Variable window, set the name as 'HTTPS\_PROXY' then specify the value of the HTTPS_PROXY environment variable as your proxy. 
Click OK. 
Close all remaining windows by clicking OK.


### Robot Install
Reopen Command prompt window, and run below code to install robot.

```
pip install robotframework
```


### IDE Install
Most further documents will use the RED environment for Robot.
[https://github.com/nokia/RED/releases/download/0.7.0/RED\_0.7.0.20160914115048-win32.win32.x86_64.zip](https://github.com/nokia/RED/releases/download/0.7.0/RED\_0.7.0.20160914115048-win32.win32.x86_64.zip)

Once you install that IDE you probably will want to have a python editor to edit python files better.
Go to Help > Eclipse Marketplace and search for PyDev and click install on PyDev for Eclipse 5.2.0

Once you install that IDE you will need EGit to check in git code.
Go to Help > Eclipse Marketplace and search for Egit git team provider and click install on EGit Git Team Provider 4.5.0

Once you install that IDE you will probably want a json editor to edit json better.
Go to Help > Eclipse Marketplace and search for Json Tools and click install on Json Tools 1.1.0

### Project Setup
Note: You do not need to run these commands every time, only on a library update or initial checkout.

```
./setup.sh  
```

Note that this script will download the chromedriver for the current OS. The default is linux64 which will download the appropriate chromedriver to /usr/local/bin so that it will be in the execution PATH.

Windows and Mac hosts will download into the current working directory. Windows and MAC users will need to ensure that the driver is 
in the execution PATH.


## Executing ETE Testcases
### Overview
Two scripts have been provided in the root of the ete-testsuite project to enable test execution

* runTags.sh - This shell uses Robot [Tags] to drive which tests are executed and is designed for automated testing.
* oneTest.sh - This shell is designed for unit testing of individual .robot files. It accepts a single argument identifying the .robot file in robot/testsuites to execute.
  
#### runTags.sh
For further information on using Robot [Tags], see [http://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#configuring-execution] and [http://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#simple-patterns]

When executing tests via tags, all of the robot files in the project are scanned for tests cases with the specified tags.

There are 3 flavors of runTags.sh 
* runTags.sh with no arguments. This defaults to the default tag or runTags.sh -i health
* runTags.sh with a single include tag. In this case the -i or --include may be omitted. So runTags.sh ete is the same as runTags.sh -i ete
* runTags.sh with multiple tags. In this case, tags must be accompanied by a -i/--include or -e/--exclude to properly identify the disposition of the tagged testcase.

```
runTags.sh -i health -i ete -e garbage
```

## Contributing
Follow set of guidelines below:

### Avoid using global variables
Use environment variables instead or get necessary data in the testsuite.

### Avoid using Evaluate
Check if there is relevant keyword provided in available libraries.

### Avoid placing Keywords in Testsuites
Move them to `resources` directory.
