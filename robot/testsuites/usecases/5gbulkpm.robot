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
Resource          ../../resources/usecases/5gbulkpm_interface.robot
Suite Setup       Send File Ready Event to VES Collector and Deploy all DCAE Applications   test  org.3GPP.32.435#measCollec  V10
Suite Teardown    Usecase Teardown

*** Variables ***
${DFC_ERROR_GREP_COMMAND_SANS}      kubectl logs $(kubectl get pods -n onap | grep datafile-collector | awk '{print $1}' | grep -v NAME) --all-containers -n onap --since=15s | grep "Certificate for .* subject alternative names: .*wrong-cert"

*** Test Cases ***

SFTP Server based bulk PM test, no SFTP Server know host veryfication on DFC side
    [Tags]                              5gbulkpm                           5gbulkpm_sftp              5gbulkpm_cust_pm_validate
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

HTTPS Server based bulk PM test, successful HTTPS server certificate verification on DFC side
    [Tags]                              5gbulkpm                           5gbulkpm_https
    [Documentation]
    ...  This test case triggers successful bulk pm upload from HTTPS server using CMPv2 Certificate-based authentication
    ...  Both HTTPS server and DFC have correct certs with correct SAN-s.
    ...  DFC has turned on hostname verification option, verifies HTTPS server host name and downloads pm file from HTTPS server.
    Uploading PM Files to xNF HTTPS Server      https-server
    Sending File Ready Event to VES Collector Over VES Client  https-server
    Verifying 3GPP Perf VES Content On PERFORMANCE_MEASUREMENTS Topic


HTTPS Server based bulk PM test, not successful HTTPS server certificate (wrong certificate) verification on DFC side
    [Tags]                              5gbulkpm                           5gbulkpm_https
    [Documentation]
    ...  This test case triggers unsuccessful bulk pm upload from HTTPS server using CMPv2 Certificate-based authentication
    ...  HTTPS server has incorrect cert with wrong correct SAN-s. DFC has turned on hostname verification option.
    ...  DFC verifies HTTPS server host name against SAN-s and closes connection.
    Uploading PM Files to xNF HTTPS Server      https-server-wrong-sans
    Sending File Ready Event to VES Collector Over VES Client   https-server-wrong-sans
    Wait Until Keyword Succeeds         60 sec               5 sec    Check DFC logs  ${DFC_ERROR_GREP_COMMAND_SANS}


HTTPS Server based bulk PM test, successful HTTPS server certificate (wrong certificate) validation on DFC side (host checking turned off)
    [Tags]                              5gbulkpm                           5gbulkpm_https
    [Documentation]
    ...  This test case triggers successful bulk pm upload from HTTPS server using CMPv2 Certificate-based authentication
    ...  HTTPS server has incorrect cert with wrong correct SAN-s. DFC has turned off hostname verification option.
    ...  DFC doesn’t verify HTTPS server host name against SAN-s and downloads pm file from HTTPS server.
    Change DFC httpsHostnameVerify configuration in Consul   true
    Uploading PM Files to xNF HTTPS Server      https-server-wrong-sans
    Sending File Ready Event to VES Collector Over VES Client   https-server-wrong-sans
    Verifying 3GPP Perf VES Content On PERFORMANCE_MEASUREMENTS Topic


