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

#Run VVP CMS Health Check
#Run VVP Engagement Manager Health Check
#Run VVP Ext HA Proxy Health Check
#Run VVP Health Check
#Run VVP Gitlab Health Check
#Run VVP Image Scanner Health Check
#Run VVP Int HA Proxy Health Check
#Run VVP Jenkins Health Check
#Run VVP Postgresql Health Check
#Run VVP Redis Health Check
