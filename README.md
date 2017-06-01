# Getting Started
## Prerequisites
This guide assumes you have run git clone on https://gerrit.onap.org/r/p/testsuite.git

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


## Robot Project Structure
### Overview
ProjectName - robot

```
`-- robot
    |-- assets - put anything you need as input like json files, cert keys, heat templates
    |   |-- templates - put any json templates in here, you can include subfolders for each component
    |-- library - put any python libraries need to run tests in here
    |   |-- OpenECOMP - put any python code libraries we write in here
    |-- resources - put any robot resource files aka libraries we write in here
    |   |-- aai
    |   `-- vid
    `-- testsuites - put any robot test suites we write in here
```    

### Tag Strucutre
Robot uses tags to seperate out test cases to run. below are the tags we use

* garbage - use this for test cases that should be cleaned up before go live date
* health - use this for test cases that perform a health check of the environment
* smoke - use this for test cases that perform a basic check of a component
* ete - use this for the test cases that are perofrming an end to end test

## Branching Structure
### Overview
Repository Name: testsuite

Branching strategy:
```
`-- testsuite
    |-- master - the main branch and always the latest deployable code. Send a pull to here from feature and Dan or Jerry will approve.
    |-- feature-[XXXXXX] - when you want to make changes you make them here, when you are satisfied send pull request to master
```    

## Executing ETE Testcases
### Overview
Two scripts have been provided in the root of the ete-testsuite project to enable test exectution

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

