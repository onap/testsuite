*** Settings ***
Documentation     Testing OOF-HAS
...
...               Testing OOF-HAS SEND PLANS
Resource          ../resources/oof_interface.robot

*** Test Cases ***
Basic OOF-HAS CSIT
    [Tags]    has
    Run OOF-Homing SendPlanWithWrongVersion
