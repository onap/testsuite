*** Settings ***
Documentation     The main interface for interacting with Mariadb Galera. It contains the keywords which will login to the Mariadb Galera pod and validates SO databases connectivity.

Library               Collections
Library               OperatingSystem
Library               String

*** Variables ***
&{MARIADB_GALERA_CREDENTIALS}               user=root  password=secretpassword
@{MARIADB_GALERA_SO_DATABASES}              catalogdb  requestdb  camundabpmn
@{CONNECTION_ERROR_MESSAGE}                 Can't connect  No such file or directory  command terminated
${POD_LOGGED_IN_MESSAGE}                    logged into Mariadb Galera pod
${MYSQL_STATUS_MESSAGE}                     Current database:


*** Keywords ***
Fetch Namespace
    [Documentation]    This keyword is responsible for fetching and returning the value of namespace from the provided Global IP Address variable.
    [Arguments]    ${GLOBAL_INJECTED_SO_BPMN_IP_ADDR}
    ${namespace}=    Evaluate    "${GLOBAL_INJECTED_SO_BPMN_IP_ADDR}".split(".")[-1]
    [Return]    ${namespace}

Check for Mariadb Galera Pod Connection
    [Documentation]    This keyword is responsible for logging into the Mariadb Galera pod and check if we can login to the Mariadb Galera pod. To verify we print a string and match the output whether the same string was returned or not.
    [Arguments]    ${message}=${POD_LOGGED_IN_MESSAGE}
    ${namespace}=    Fetch Namespace    ${GLOBAL_INJECTED_SO_BPMN_IP_ADDR}
    # Extracting the mariadb galera pod and storing it into a variable
    ${mariadb_pod}=    Run    kubectl -n ${namespace} get po -o name | grep -w 'mariadb-galera-[0-9]'
    ${pod_connectivity_command}=    Catenate    kubectl -n ${namespace} exec ${mariadb_pod} -- sh -c "echo ${message}"
    ${pod_connectivity_output}=    Run    ${pod_connectivity_command}
    # The output should contain the exact same message which we are printing by logging into the Mariadb Galera pod
    Should Contain    ${pod_connectivity_output}    ${message}    ignore_case=True

Check for SO Databases Connection
    [Documentation]    This keyword is responsible for logging into the Mariadb Galera pod and check if we can login to the SO MySQL Databases.
    ${namespace}=    Fetch Namespace    ${GLOBAL_INJECTED_SO_BPMN_IP_ADDR}
    # Extracting the mariadb galera pod and storing it into a variable
    ${mariadb_pod}=    Run    kubectl -n ${namespace} get po -o name | grep -w 'mariadb-galera-[0-9]'
    # Looping through all 3 mariadb galera databases (catalogdb, requestdb and camundabpmn) to validate SO connectivity
    FOR    ${index}    IN RANGE    3
           ${mysql_connectivity_command}=    Catenate    kubectl -n ${namespace} exec ${mariadb_pod} -- sh
               ...  -c "mysql -u ${MARIADB_GALERA_CREDENTIALS}[user] -p${MARIADB_GALERA_CREDENTIALS}[password] ${MARIADB_GALERA_SO_DATABASES}[${index}]
               ...  -e 'status'"
           ${mysql_connectivity_output}=    Run    ${mysql_connectivity_command}
           # The output should contain the message that is having SO databases name.
           Should Contain    ${mysql_connectivity_output}    ${MYSQL_STATUS_MESSAGE}	${MARIADB_GALERA_SO_DATABASES}[${index}]    ignore_case=True
           Should Not Contain Any    ${CONNECTION_ERROR_MESSAGE}    ${mysql_connectivity_output}    ignore_case=True
    END
