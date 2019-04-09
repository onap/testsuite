*** Settings ***
Documentation	  The main interface for interacting with MUSIC. It handles low level stuff like managing the http request library and MUSIC required fields
Library	          RequestsClientCert
Library 	      RequestsLibrary
Library	          UUID      

Resource          ../global_properties.robot

*** Variables ***
${MUSIC_HEALTH_CHECK_PATH}        /MUSIC/rest/v2/version
${MUSIC_CASSA_HEALTH_CHECK_PATH}        /MUSIC/rest/v2/service/musicHealthCheck
${MUSIC_ENDPOINT}     ${GLOBAL_MUSIC_SERVER_PROTOCOL}://${GLOBAL_INJECTED_MUSIC_IP_ADDR}:${GLOBAL_MUSIC_SERVER_PORT}

*** Keywords ***
Run MUSIC Health Check
     [Documentation]    Runs MUSIC Health check
     ${resp}=    Run MUSIC Get Request    ${MUSIC_HEALTH_CHECK_PATH}    
     Should Be Equal As Strings 	${resp.status_code} 	200
     Should Be Equal As Strings 	${resp.json()['status']} 	SUCCESS
         

Run MUSIC Cassandra Connection Check
     [Documentation]    Confirm MUSIC's connection to Cassandra in active
     ${resp}=    Run MUSIC Get Request    ${MUSIC_CASSA_HEALTH_CHECK_PATH}    
     Should Be Equal As Strings 	${resp.status_code} 	200
     Should Be Equal As Strings 	${resp.json()['Cassandra']} 	Active
