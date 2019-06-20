*** Settings ***
Documentation     Testing OOF-HAS
...
...               Testing OOF-HAS SEND PLANS
Resource          ../../resources/oof_interface.robot

*** Test Cases ***
Basic OOF-OSDF CSIT for Homing
    [Tags]    homing
    Run OOF-OSDF Post Homing

Basic OOF-OSDF CSIT for pci-opt
    [Tags]    homing
    Run OOF-OSDF Post PCI-OPT
