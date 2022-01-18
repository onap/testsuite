*** Settings ***
Documentation     The main interface for interacting with Cassandra. It contains the keywords which will login to the cassandra pods and run a select CQL command.

Library               Collections
Library               OperatingSystem
Library               String

*** Variables ***
&{CASSANDRA_CREDENTIALS}         user=cassandra  password=cassandra
@{CONNECTION_ERROR_MESSAGES}     Unable to connect  Connection error  Connection refused
${AAIGRAPH_KEYSPACE}             aaigraph
${EDGESTORE_TABLE}               edgestore
${POD_LOGGED_IN_MESSAGE}         logged into cassandra pod
${CQLSH_CONSISTENCY_MESSAGE}     consistency level
${CQLSH_ROWS_OUTPUT_MESSAGE}     rows
${CASSANDRA_STATEFUL_SET_LABEL}  app.kubernetes.io/name=cassandra

*** Keywords ***

Get List of Cassandra Pods
    [Documentation]     This keyword is responsible for returning the list of Cassandra pods for a specific namespace.
    [Arguments]  ${namespace}
    # Extracting the cassandra pods and storing it into a list
    ${cassandra_pods}=  Run  kubectl -n ${namespace} get po -o name | grep -w 'cassandra-[0-9]'
    @{cassandra_pod_list}=  Split String  ${cassandra_pods}
    [Return]   @{cassandra_pod_list}

Fetch Namespace
    [Documentation]     This keyword is responsible for fetching and returning the value of namespace from the provided Global IP Address variable.
    [Arguments]  ${GLOBAL_INJECTED_IP_ADDR}
    ${namespace}=   Evaluate  "${GLOBAL_INJECTED_IP_ADDR}".split(".")[-1]
    [Return]  ${namespace}

Check for Cassandra Pod Connection
    [Documentation]   This keyword is responsible for logging into the cassandra pods and check if we can login to the cassandra pod. To verify we print a string and match the output whether the same string was returned or not.
    [Arguments]  ${message}=${POD_LOGGED_IN_MESSAGE}
    ${namespace}=   Fetch Namespace  ${GLOBAL_INJECTED_AAI_IP_ADDR}
    @{cassandra_pod_list}=  Get List of Cassandra Pods  ${namespace}
    FOR  ${pod}  IN  @{cassandra_pod_list}
        ${pod_connectivity_command}=  Catenate  kubectl -n ${namespace} exec ${pod} -c "cassandra" -- sh -c "echo ${message}"
        ${pod_connectivity_output}=  Run  ${pod_connectivity_command}
        # The output should contain the exact same message which we are printing by logging into the cassandra pod
        Should Contain  ${pod_connectivity_output}  ${message}  ignore_case=True
    END

Check for cqlsh Connection
    [Documentation]   This keyword is responsible for logging into the cassandra pods and check if we can login to the cqlsh client. To verify we run a cqlsh specific command and match the output.
    ${namespace}=   Fetch Namespace  ${GLOBAL_INJECTED_AAI_IP_ADDR}
    @{cassandra_pod_list}=  Get List of Cassandra Pods  ${namespace}
    FOR  ${pod}  IN  @{cassandra_pod_list}
        ${cqlsh_connectivity_command}=  Catenate  kubectl -n ${namespace} exec ${pod} -c "cassandra"
                                        ...  -- sh -c "cqlsh -u ${CASSANDRA_CREDENTIALS}[user] -p ${CASSANDRA_CREDENTIALS}[password]
                                        ...   -e 'consistency'"
        ${cqlsh_connectivity_output}=  Run  ${cqlsh_connectivity_command}
        # The output should contain the message that is passed as an argument.
        Should Contain  ${cqlsh_connectivity_output}  ${CQLSH_CONSISTENCY_MESSAGE}  ignore_case=True
    END

Fetch Value from a Table in CQL Keyspace
    [Documentation]   This keyword is responsible for logging into the cassandra pods and connecting to a specific keyspace and running a select command.
    ${namespace}=   Fetch Namespace  ${GLOBAL_INJECTED_AAI_IP_ADDR}
    @{cassandra_pod_list}=  Get List of Cassandra Pods  ${namespace}
    FOR  ${pod}  IN  @{cassandra_pod_list}
        # The CQL command which will log into cassandra DB
        ${cql_command}=  Catenate  kubectl -n ${namespace} exec ${pod} -c "cassandra"
                        ...  -- sh -c "cqlsh -u ${CASSANDRA_CREDENTIALS}[user] -p ${CASSANDRA_CREDENTIALS}[password]
                        ...  -e 'use ${AAIGRAPH_KEYSPACE}; select * from ${EDGESTORE_TABLE} limit 1;'"
        ${cql_output}=  Run  ${cql_command}
        # The output should contain the string "rows"
        Should Contain  ${cql_output}  ${CQLSH_ROWS_OUTPUT_MESSAGE}  ignore_case=True
        # The output should not contain any of the error messages matching with CONNECTION_ERROR_MESSAGES list elements
        Should Not Contain Any    ${CONNECTION_ERROR_MESSAGES}  ${cql_output}    ignore_case=True
    END

Run Cassandra Replica Pods Healthcheck 
    [Documentation]     This keyword is responsible to validate ready replicas with total replica count in Cassandra
    ${namespace}=   Fetch Namespace  ${GLOBAL_INJECTED_AAI_IP_ADDR}
    Wait Until Keyword Succeeds    1    60s    Validate Cassandra Replica Count   ${namespace}

Validate Cassandra Replica Count
    [Documentation]     This keyword fetches ready replicas and total replica count in Cassandra and check if both count match and validate.
    [Arguments]  ${namespace}
    ${replica_count}=  Run  kubectl get sts -n ${namespace} -l ${CASSANDRA_STATEFUL_SET_LABEL} -o jsonpath='{.items[].status.replicas}'
    ${ready_replica_count}=  Run  kubectl get sts -n ${namespace} -l ${CASSANDRA_STATEFUL_SET_LABEL} -o jsonpath='{.items[].status.readyReplicas}'
    ${replica_count_validation_flag}=  Run Keyword And Return Status     Should Be Equal    ${replica_count}    ${ready_replica_count}
    ${replica_count_validation_flag_string}  Convert To String    ${replica_count_validation_flag}
    Should Be Equal    ${replica_count_validation_flag_string}    True

Check For Non-Running Cassandra Pods and Validate
    [Documentation]     This keyword checks for non running cassandra pods and print the non running pod names in console
    ${namespace}=   Fetch Namespace  ${GLOBAL_INJECTED_AAI_IP_ADDR}
    ${pod_name}=    Run  kubectl -n ${namespace} get po -o name --field-selector=status.phase!=Running |grep -w 'cassandra-[0-9]'
    ${pod_name_string}=     String.Replace String    ${pod_name}     \n     ${SPACE}
    Run Keyword If    "${pod_name_string}"=="${EMPTY}"    Log To Console    All Cassandra Pods are in running state
    Should Be Empty    ${pod_name_string}    ${pod_name_string} not in running state
