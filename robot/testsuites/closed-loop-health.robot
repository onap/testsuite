*** Settings ***
Test Timeout    1 minute
Documentation	  Testing ONAP closed loop health check.
...
...	              Testing ONAP Closed Loop .

Resource          ../resources/ves_collecter_interface.robot

*** Test Cases ***
Test Simple Close Loop 
    [Tags]    closedloophealth    
    Send VES Event  ${filename}
