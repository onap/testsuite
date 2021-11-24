*** Settings ***
Documentation     5G Bulk PM Usecase functionality

Library           RequestsLibrary
Library           OperatingSystem
Library           Collections
Library           String
Library           DateTime
Library           SSHLibrary
Library           JSONLibrary
Library           Process
Library           ONAPLibrary.JSON
Library           ONAPLibrary.Utilities
Resource          ../../resources/usecases/5gbulkpm_helm_interface.robot
Resource          ../../resources/chart_museum.robot
Suite Setup       Send File Ready Event to VES Collector and Deploy all DCAE Applications   test  org.3GPP.32.435#measCollec  V10
Suite Teardown    Usecase Teardown

*** Variables ***
${DFC_ERROR_GREP_COMMAND_SANS}      kubectl logs $(kubectl get pods -n onap | grep datafile-collector | awk '{print $1}' | grep -v NAME) --all-containers -n onap --since=15s | grep "Certificate for .* subject alternative names: .*wrong-cert"

*** Test Cases ***

SFTP Server based bulk PM test, no SFTP Server know host veryfication on DFC side
    [Tags]                              5gbulkpm                           5gbulkpm_sftp
    [Documentation]
    ...  This test case triggers successful bulk pm upload from SFTP server without SFTP server host verification in DFC known host file.
    ...  Known host verification is turned off on DFC
    Uploading PM Files to xNF SFTP Server
    Sending File Ready Event to VES Collector
    Verifying 3GPP Perf VES Content On PERFORMANCE_MEASUREMENTS Topic

SFTP Server based bulk PM test, successful SFTP Server known host verification on DFC side
    [Tags]                              5gbulkpm                           5gbulkpm_sftp
    [Documentation]
    ...  This test case triggers successful bulk pm upload from SFTP server with SFTP server host verification in DFC known host file.
    ...  Known host verification is turned on DFC and to know host is added SFTP server entry
    Setting KNOWN_HOSTS_FILE_PATH Environment Variable in DFC
    Uploading PM Files to xNF SFTP Server
    Sending File Ready Event to VES Collector
    Verifying 3GPP Perf VES Content On PERFORMANCE_MEASUREMENTS Topic
    Checking DFC Logs After KNOWN_HOSTS_FILE_PATH Env Variable Added

SFTP Server based bulk PM test, not successful SFTP Server know host verification on DFC side
    [Tags]                              5gbulkpm                           5gbulkpm_sftp
    [Documentation]
    ...  This test case triggers unsuccessful bulk pm upload from SFTP server with SFTP server host verification in DFC known host file.
    ...  Known host verification is turned on DFC and to know host is added wrong SFTP server entry
    Changing SFTP Server RSA Key in DFC
    Uploading PM Files to xNF SFTP Server
    Sending File Ready Event to VES Collector
    Checking DFC Logs After KNOWN_HOSTS_FILE_PATH Env Variable Added

