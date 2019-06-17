*** Settings ***
Documentation     Tests the health of the VVP containers...
Library    Collections
Library         String
Library 	      RequestsLibrary
Resource        global_properties.robot

*** Variables ***
${VVP_PATH}    /
${VVP_CI_UWSGI_ENDPOINT}
${VVP_CMS_UWSGI_ENDPOINT}
${VVP_EM_UWSGI_ENDPOINT}
${VVP_EXT_HAPROXY_ENDPOINT}
${VVP_GITLAB_ENDPOINT}
${VVP_IMAGESCANNER_ENDPOINT}
${VVP_INT_HAPROXY_ENDPOINT}
${VVP_JENKINS_ENDPOINT}
${VVP_POSTGRES_ENDPOINT}
${VVP_REDIS_ENDPOINT}

*** Keywords ***
Run VVP ICE CI Container (Automat Testing) Health Check
    [Documentation]  Tests interface for container with purpose: end-to-end flow tests based on Seleniunm
    ${resp}=    Run ICE CI Container (Automat Testing) Get Request    ${VVP_PATH}
    Should Be Equal As Strings 	${resp.status_code} 	200

Run ICE CI Container (Automat Testing) Get Request
    [Documentation]   Runs request in container with purpose: end-to-end flow tests based on Seleniunm
    [Arguments]    ${data_path}
    Log    Creating session ${VVP_CI_UWSGI_ENDPOINT}
    ${session}=    Create Session 	ice-ci      ${VVP_CI_UWSGI_ENDPOINT}
    ${resp}= 	Get Request 	ice-ci     ${data_path}
    Log    Received response from ice-ci ${resp.text}
    [Return]    ${resp}

Run VVP CMS Health Check
    [Documentation]     Tests interface for container with purpose: backend uwsgi server which hosts django application
    ${resp}=     Run VVP CMS Get Request    ${VVP_PATH}
    Should Be Equal As Strings 	${resp.status_code} 	200

Run VVP CMS Get Request
    [Documentation]   Runs request in container with purpose: backend uwsgi server which hosts django application
    [Arguments]    ${data_path}
    Log    Creating session ${VVP_CMS_UWSGI_ENDPOINT}
    ${session}=    Create Session 	cms      ${VVP_CMS_UWSGI_ENDPOINT}
    ${resp}= 	Get Request 	cms     ${data_path}
    Log    Received response from cms ${resp.text}
    [Return]    ${resp}

Run VVP Engagement Manager Health Check
    [Documentation]  Tests interface for container with purpose: backend uwsgi server which hosts django application
    ${resp}=    Run VVP Engagement Manager Get Request    ${VVP_PATH}
    Should Be Equal As Strings 	${resp.status_code} 	200

Run VVP Engagement Manager Get Request
    [Documentation]    Runs request in container with purpose: backend uwsgi server which hosts django application
    [Arguments]    ${data_path}
    Log    Creating session ${VVP_EM_UWSGI_ENDPOINT}
    ${session}=    Create Session 	engagement-manager      ${VVP_EM_UWSGI_ENDPOINT}
    ${resp}= 	Get Request 	engagement-manager     ${data_path}
    Log    Received response from engagement-manager ${resp.text}
    [Return]    ${resp}

Run VVP Ext HA Proxy Health Check
    [Documentation]  Tests interface for container with purpose: load balancer for external transport
    ${resp}=    Run VVP Ext HA Proxy Get Request    ${VVP_PATH}
    Should Be Equal As Strings 	${resp.status_code} 	200

Run VVP Ext HA Proxy Get Request
    [Documentation]   Runs request in container with purpose: load balancer for external transport
    [Arguments]    ${data_path}
    Log    Creating session ${VVP_EXT_HAPROXY_ENDPOINT}
    ${session}=    Create Session 	ext-haproxy      ${VVP_EXT_HAPROXY_ENDPOINT}
    ${resp}= 	Get Request 	ext-haproxy     ${data_path}
    Log    Received response from ext-haproxy ${resp.text}
    [Return]    ${resp}

Run VVP Gitlab Health Check
    [Documentation]  Tests gitlab interface
    ${resp}=    Run VVP Gitlab Get Request    ${VVP_PATH}
    Should Be Equal As Strings 	${resp.status_code} 	200

Run VVP Gitlab Get Request
    [Documentation]   Runs an gitlab request
    [Arguments]    ${data_path}
    Log    Creating session ${VVP_GITLAB_ENDPOINT}
    ${session}=    Create Session 	gitlab      ${VVP_GITLAB_ENDPOINT}
    ${resp}= 	Get Request 	gitlab     ${data_path}
    Log    Received response from gitlab ${resp.text}
    [Return]    ${resp}

Run VVP Image Scanner Health Check
    [Documentation]  Tests interface for container with purpose: scan for validity and viruses on users files
    ${resp}=    Run VVP Image Scanner Get Request    ${VVP_PATH}
    Should Be Equal As Strings 	${resp.status_code} 	200

Run VVP Image Scanner Get Request
    [Documentation]   Runs request in container with purpose: scan for validity and viruses on users files
    [Arguments]    ${data_path}
    Log    Creating session ${VVP_IMAGESCANNER_ENDPOINT}
    ${session}=    Create Session 	image-scanner      ${VVP_IMAGESCANNER_ENDPOINT}
    ${resp}= 	Get Request 	image-scanner     ${data_path}
    Log    Received response from image-scanner ${resp.text}
    [Return]    ${resp}

Run VVP Int HA Proxy Health Check
    [Documentation]  Tests interface for container with purpose: load balancer for internal (container to container) transport
    ${resp}=    Run VVP Int HA Proxy Get Request    ${VVP_PATH}
    Should Be Equal As Strings 	${resp.status_code} 	200

Run VVP Int HA Proxy Get Request
    [Documentation]   Runs request in container with purpose: load balancer for internal (container to container) transport
    [Arguments]    ${data_path}
    Log    Creating session ${VVP_INT_HAPROXY_ENDPOINT}
    ${session}=    Create Session 	int-haproxy      ${VVP_INT_HAPROXY_ENDPOINT}
    ${resp}= 	Get Request 	int-haproxy     ${data_path}
    Log    Received response from int-haproxy ${resp.text}
    [Return]    ${resp}

Run VVP Jenkins Health Check
    [Documentation]  Tests jenkins interface
    ${resp}=    Run VVP Jenkins Get Request    ${VVP_PATH}
    Should Be Equal As Strings 	${resp.status_code} 	200

Run VVP Jenkins Get Request
    [Documentation]   Runs a jenkins request
    [Arguments]    ${data_path}
    Log    Creating session ${VVP_JENKINS_ENDPOINT}
    ${session}=    Create Session 	jenkins      ${VVP_JENKINS_ENDPOINT}
    ${resp}= 	Get Request 	jenkins     ${data_path}
    Log    Received response from jenkins ${resp.text}
    [Return]    ${resp}

Run VVP Postgresql Health Check
    [Documentation]  Tests postgresql interface
    ${resp}=    Run VVP Postgresql Get Request    ${VVP_PATH}
    Should Be Equal As Strings 	${resp.status_code} 	200

Run VVP Postgresql Get Request
    [Documentation]   Runs a postgresql request
    [Arguments]    ${data_path}
    Log    Creating session ${VVP_POSTGRES_ENDPOINT}
    ${session}=    Create Session 	postgresql      ${VVP_POSTGRES_ENDPOINT}
    ${resp}= 	Get Request 	postgresql     ${data_path}
    Log    Received response from postgresql ${resp.text}
    [Return]    ${resp}

Run VVP Redis Health Check
    [Documentation]  Tests redis interface
    ${resp}=    Run VVP Redis Get Request    ${VVP_PATH}
    Should Be Equal As Strings 	${resp.status_code} 	200

Run VVP Redis Get Request
    [Documentation]   Runs a redis request
    [Arguments]    ${data_path}
    Log    Creating session ${VVP_REDIS_ENDPOINT}
    ${session}=    Create Session 	redis      ${VVP_REDIS_ENDPOINT}
    ${resp}= 	Get Request 	redis     ${data_path}
    Log    Received response from redis ${resp.text}
    [Return]    ${resp}

