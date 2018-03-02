*** Settings ***
Documentation     Testing ecomp components are available via calls.
...
...                   Testing ecomp components are available via calls.

Resource          ../resources/dcae_interface.robot
Resource          ../resources/sdngc_interface.robot
Resource          ../resources/aai/aai_interface.robot
Resource          ../resources/vid/vid_interface.robot
Resource          ../resources/policy_interface.robot
Resource          ../resources/mso_interface.robot
Resource          ../resources/asdc_interface.robot
Resource          ../resources/appc_interface.robot
Resource          ../resources/portal_interface.robot
Resource          ../resources/mr_interface.robot
Resource          ../resources/aaf_interface.robot
Resource          ../resources/msb_interface.robot
Resource          ../resources/clamp_interface.robot

*** Test Cases ***
Basic SDNGC Health Check
        Run SDNGC Health Check

Basic A&AI Health Check
        Run A&AI Health Check

Basic Policy Health Check
    Run Policy Health Check

Basic MSO Health Check
    Run MSO Health Check

Basic ASDC Health Check
    Run ASDC Health Check

Basic APPC Health Check
    Run APPC Health Check

Basic Portal Health Check
    Run Portal Health Check

Basic Message Router Health Check
        Run MR Health Check

Basic VID Health Check
        Run VID Health Check

Basic Microservice Bus Health Check
    Run MSB Health Check

Basic Clamp Health Check
    Run MSB Health Check
