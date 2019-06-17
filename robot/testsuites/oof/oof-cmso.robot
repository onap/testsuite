*** Settings ***
Documentation     Testing OOF-CMSO
...
...               Testing OOF-CMSO Future Schedule ETE
Resource          ../resources/oof_interface.robot

*** Test Cases ***
Basic OOF-CMSO CSIT
    [Tags]    cmso
    Run OOF-CMSO Future Schedule