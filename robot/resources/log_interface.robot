*** Settings ***
Documentation     Tests the health of the log containers: Elasticsearch, Logstash and Kibana.
Library    Collections
Library         String
Library 	      RequestsLibrary
Resource        global_properties.robot

*** Variables ***
${LOG_PATH}         /
${LOG_ELASTICSEARCH_ENDPOINT}    ${GLOBAL_LOG_SERVER_PROTOCOL}://${GLOBAL_INJECTED_LOG_ELASTICSEARCH_IP_ADDR}:${GLOBAL_LOG_ELASTICSEARCH_PORT}
${LOG_LOGSTASH_ENDPOINT}    ${GLOBAL_LOG_SERVER_PROTOCOL}://${GLOBAL_INJECTED_LOG_LOGSTASH_IP_ADDR}:${GLOBAL_LOG_LOGSTASH_PORT}
${LOG_KIBANA_ENDPOINT}    ${GLOBAL_LOG_SERVER_PROTOCOL}://${GLOBAL_INJECTED_LOG_KIBANA_IP_ADDR}:${GLOBAL_LOG_KIBANA_PORT}

*** Keywords ***
Run Log Elasticsearch Health Check
    [Documentation]   Tests Elasticsearch interface
    ${resp}=    Run Log Elasticsearch Get Request    ${LOG_PATH}
    Should Be Equal As Strings 	${resp.status_code} 	200

Run Log Elasticsearch Get Request
    [Documentation]    Runs an Elasticsearch request
    [Arguments]    ${data_path}
    Log    Creating session ${LOG_ELASTICSEARCH_ENDPOINT}
    ${session}=    Create Session 	log-elasticsearch 	${LOG_ELASTICSEARCH_ENDPOINT}
    ${resp}= 	Get Request 	log-elasticsearch 	${data_path}
    Log    Received response from log-elasticsearch ${resp.text}
    [Return]    ${resp}

Run Log Logstash Health Check
    [Documentation]   Tests Logstash interface
    ${resp}=    Run Log Logstash Get Request    ${LOG_PATH}
    Should Be Equal As Strings 	${resp.status_code} 	200

Run Log Logstash Get Request
    [Documentation]    Runs a Logstash request
    [Arguments]    ${data_path}
    Log    Creating session ${LOG_LOGSTASH_ENDPOINT}
    ${session}=    Create Session 	log-logstash 	${LOG_LOGSTASH_ENDPOINT}
    ${resp}= 	Get Request 	log-logstash 	${data_path}
    Log    Received response from log-logstash ${resp.text}
    [Return]    ${resp}

Run Log Kibana Health Check
    [Documentation]   Tests Kibana interface
    ${resp}=    Run Log Kibana Get Request    ${LOG_PATH}
    Should Be Equal As Strings 	${resp.status_code} 	200

Run Log Kibana Get Request
    [Documentation]    Runs a Kibana request
    [Arguments]    ${data_path}
    Log    Creating session ${LOG_KIBANA_ENDPOINT}
    ${session}=    Create Session 	log-kibana 	${LOG_KIBANA_ENDPOINT}
    ${resp}= 	Get Request 	log-kibana 	${data_path}
    Log    Received response from log-kibana ${resp.text}
    [Return]    ${resp}

