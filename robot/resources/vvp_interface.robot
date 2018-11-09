*** Settings ***
Documentation     Tests the health of the VVP containers...
Library    Collections
Library         String
Library 	      RequestsLibrary
Resource        global_properties.robot

*** Variables ***
${VVP_PATH}    /
${VVP_CI_UWSGI_ENDPOINT}    ${GLOBAL_VVP_SERVER_PROTOCOL}://${GLOBAL_INJECTED_VVP_CI_UWSGI_IP_ADDR}:${GLOBAL_VVP_CI_UWSGI_PORT}
${VVP_CMS_UWSGI_ENDPOINT}    ${GLOBAL_VVP_SERVER_PROTOCOL}://${GLOBAL_INJECTED_VVP_CMS_UWSGI_IP_ADDR}:${GLOBAL_VVP_CMS_UWSGI_PORT1}
${VVP_EM_UWSGI_ENDPOINT}    ${GLOBAL_VVP_SERVER_PROTOCOL}://${GLOBAL_INJECTED_VVP_EM_UWSGI_IP_ADDR}:${GLOBAL_VVP_EM_UWSGI_PORT}
${VVP_EXT_HAPROXY_ENDPOINT}    ${GLOBAL_VVP_SERVER_PROTOCOL}://${GLOBAL_INJECTED_VVP_EXT_HAPROXY_IP_ADDR}:${GLOBAL_VVP_EXT_HAPROXY_PORT1}
${VVP_GITLAB_ENDPOINT}    ${GLOBAL_VVP_SERVER_PROTOCOL}://${GLOBAL_INJECTED_VVP_GITLAB_IP_ADDR}:${GLOBAL_VVP_GITLAB_PORT1}
${VVP_IMAGESCANNER_ENDPOINT}    ${GLOBAL_VVP_SERVER_PROTOCOL}://${GLOBAL_INJECTED_VVP_IMAGESCANNER_IP_ADDR}:${GLOBAL_VVP_IMAGESCANNER_PORT}
${VVP_INT_HAPROXY_ENDPOINT}    ${GLOBAL_VVP_SERVER_PROTOCOL}://${GLOBAL_INJECTED_VVP_INT_HAPROXY_IP_ADDR}:${GLOBAL_VVP_INT_HAPROXY_PORT1}
${VVP_JENKINS_ENDPOINT}    ${GLOBAL_VVP_SERVER_PROTOCOL}://${GLOBAL_INJECTED_VVP_JENKINS_IP_ADDR}:${GLOBAL_VVP_JENKINS_PORT}
${VVP_POSTGRES_ENDPOINT}    ${GLOBAL_VVP_SERVER_PROTOCOL}://${GLOBAL_INJECTED_VVP_POSTGRES_IP_ADDR}:${GLOBAL_VVP_POSTGRES_PORT}
${VVP_REDIS_ENDPOINT}    ${GLOBAL_VVP_SERVER_PROTOCOL}://${GLOBAL_INJECTED_VVP_REDIS_IP_ADDR}:${GLOBAL_VVP_REDIS_PORT}

*** Keywords ***
Run VVP ICE CI Container (Automat Testing) Health Check
    [Documentation]  TBD 
    ${resp}=    Run ICE CI Container (Automat Testing) Get Request    ${VVP_PATH}
    Should Be Equal As Strings 	${resp.status_code} 	200

Run ICE CI Container (Automat Testing) Get Request 
    [Documentation]   TBD 
    [Arguments]    ${data_path}
    Log    Creating session ${VVP_CI_UWSGI_ENDPOINT}
    ${session}=    Create Session 	ice-ci      ${VVP_CI_UWSGI_ENDPOINT}
    ${resp}= 	Get Request 	ice-ci     ${data_path}
    Log    Received response from ice-ci ${resp.text}
    [Return]    ${resp}

Run VVP CMS Health Check
    [Documentation]  TBD 
    ${resp}=     Run VVP CMS Get Request    ${VVP_PATH}
    Should Be Equal As Strings 	${resp.status_code} 	200

Run VVP CMS Get Request    ${VVP_PATH}
    [Documentation]   TBD 
    [Arguments]    ${data_path}
    Log    Creating session ${VVP_CMS_UWSGI_ENDPOINT}
    ${session}=    Create Session 	cms      ${VVP_CMS_UWSGI_ENDPOINT}
    ${resp}= 	Get Request 	cms     ${data_path}
    Log    Received response from cms ${resp.text}
    [Return]    ${resp}

Run VVP Engagement Manager Health Check
    [Documentation]  TBD 
    ${resp}=    Run VVP Engagement Manager Get Request    ${VVP_PATH}
    Should Be Equal As Strings 	${resp.status_code} 	200

Run VVP Engagement Manager Get Request
    [Documentation]   TBD 
    [Arguments]    ${data_path}
    Log    Creating session ${VVP_EM_UWSGI_ENDPOINT}
    ${session}=    Create Session 	engagement-manager      ${VVP_EM_UWSGI_ENDPOINT}
    ${resp}= 	Get Request 	engagement-manager     ${data_path}
    Log    Received response from engagement-manager ${resp.text}
    [Return]    ${resp}

Run VVP Ext HA Proxy Health Check
    [Documentation]  TBD 
    ${resp}=    Run VVP Ext HA Proxy Get Request    ${VVP_PATH}
    Should Be Equal As Strings 	${resp.status_code} 	200

Run VVP Ext HA Proxy Get Request
    [Documentation]   TBD 
    [Arguments]    ${data_path}
    Log    Creating session ${VVP_EXT_HAPROXY_ENDPOINT}
    ${session}=    Create Session 	ext-haproxy      ${VVP_EXT_HAPROXY_ENDPOINT}
    ${resp}= 	Get Request 	ext-haproxy     ${data_path}
    Log    Received response from ext-haproxy ${resp.text}
    [Return]    ${resp}

Run VVP Gitlab Health Check
    [Documentation]  TBD 
    ${resp}=    Run VVP Gitlab Get Request    ${VVP_PATH}
    Should Be Equal As Strings 	${resp.status_code} 	200

Run VVP Gitlab Get Request
    [Documentation]   TBD 
    [Arguments]    ${data_path}
    Log    Creating session ${VVP_GITLAB_ENDPOINT}
    ${session}=    Create Session 	gitlab      ${VVP_GITLAB_ENDPOINT}
    ${resp}= 	Get Request 	gitlab     ${data_path}
    Log    Received response from gitlab ${resp.text}
    [Return]    ${resp}

Run VVP Image Scanner Health Check
    [Documentation]  TBD 
    ${resp}=    Run VVP Image Scanner Get Request    ${VVP_PATH}
    Should Be Equal As Strings 	${resp.status_code} 	200

Run VVP Image Scanner Get Request
    [Documentation]   TBD 
    [Arguments]    ${data_path}
    Log    Creating session ${VVP_IMAGESCANNER_ENDPOINT}
    ${session}=    Create Session 	image-scanner      ${VVP_IMAGESCANNER_ENDPOINT}
    ${resp}= 	Get Request 	image-scanner     ${data_path}
    Log    Received response from image-scanner ${resp.text}
    [Return]    ${resp}

Run VVP Int HA Proxy Health Check
    [Documentation]  TBD 
    ${resp}=    Run VVP Int HA Proxy Get Request    ${VVP_PATH}
    Should Be Equal As Strings 	${resp.status_code} 	200

Run VVP Int HA Proxy Get Request
    [Documentation]   TBD 
    [Arguments]    ${data_path}
    Log    Creating session ${VVP_INT_HAPROXY_ENDPOINT}
    ${session}=    Create Session 	int-haproxy      ${VVP_INT_HAPROXY_ENDPOINT}
    ${resp}= 	Get Request 	int-haproxy     ${data_path}
    Log    Received response from int-haproxy ${resp.text}
    [Return]    ${resp}

Run VVP Jenkins Health Check
    [Documentation]  TBD 
    ${resp}=    Run VVP Jenkins Get Request    ${VVP_PATH}
    Should Be Equal As Strings 	${resp.status_code} 	200

Run VVP Jenkins Get Request
    [Documentation]   TBD 
    [Arguments]    ${data_path}
    Log    Creating session ${VVP_JENKINS_ENDPOINT}
    ${session}=    Create Session 	jenkins      ${VVP_JENKINS_ENDPOINT}
    ${resp}= 	Get Request 	jenkins     ${data_path}
    Log    Received response from jenkins ${resp.text}
    [Return]    ${resp}

Run VVP Postgresql Health Check
    [Documentation]  TBD 
    ${resp}=    Run VVP Postgresql Get Request    ${VVP_PATH}
    Should Be Equal As Strings 	${resp.status_code} 	200

Run VVP Postgresql Get Request
    [Documentation]   TBD 
    [Arguments]    ${data_path}
    Log    Creating session ${VVP_POSTGRES_ENDPOINT}
    ${session}=    Create Session 	postgresql      ${VVP_POSTGRES_ENDPOINT}
    ${resp}= 	Get Request 	postgresql     ${data_path}
    Log    Received response from postgresql ${resp.text}
    [Return]    ${resp}

Run VVP Redis Health Check
    [Documentation]  TBD 
    ${resp}=    Run VVP Redis Get Request    ${VVP_PATH}
    Should Be Equal As Strings 	${resp.status_code} 	200

Run VVP Redis Get Request
    [Documentation]   TBD 
    [Arguments]    ${data_path}
    Log    Creating session ${VVP_REDIS_ENDPOINT}
    ${session}=    Create Session 	redis      ${VVP_REDIS_ENDPOINT}
    ${resp}= 	Get Request 	redis     ${data_path}
    Log    Received response from redis ${resp.text}
    [Return]    ${resp}

