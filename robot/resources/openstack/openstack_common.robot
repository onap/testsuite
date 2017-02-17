*** Settings ***
Documentation     The private interface for interacting with Openstack. It handles low level stuff like managing the authtoken and Openstack required fields

Library           OpenstackLibrary
Library 	      RequestsLibrary
Library	          UUID      
Resource    ../global_properties.robot

*** Keywords ***
Internal Get Openstack
    [Documentation]    Runs an Openstack Get Request and returns the response
    [Arguments]    ${alias}    ${service_type}    ${region}    ${url_ext}   ${data_path}=
    Log    Internal Get Openstack values alias=${alias} service_type=${service_type} region=${region} url_ext=${url_ext} data_path=${data_path}
    ${url}=    Get Openstack Service Url    ${alias}     ${service_type}    ${region}
    ${uuid}=    Generate UUID
    ${session_alias}=    Catenate    openstack-${uuid}
    ${session}=    Create Session 	${session_alias} 	${url}${url_ext}        verify=True    
    ${token}=    Get Openstack Token    ${alias}
    ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json    X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}     X-Auth-Token=${token}
    ${resp}= 	Get Request 	${session_alias} 	${data_path}     headers=${headers}
    Log    Received response from openstack ${resp.text}    
    [Return]    ${resp}

Internal Post Openstack
    [Documentation]    Runs an Openstack Post Response and returns the response
    [Arguments]    ${alias}    ${service_type}    ${region}    ${url_ext}   ${data_path}=    ${data}=
    Log    Internal Post Openstack values alias=${alias} service_type=${service_type} region=${region} url_ext=${url_ext} data_path=${data_path}
    ${url}=    Get Openstack Service Url    ${alias}     ${service_type}    ${region}
    ${uuid}=    Generate UUID
    ${session_alias}=    Catenate    openstack-${uuid}
    ${session}=    Create Session 	${session_alias} 	${url}${url_ext}        verify=True    
    ${token}=    Get Openstack Token    ${alias}
    ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json    X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}     X-Auth-Token=${token}
    ${resp}= 	Post Request 	${session_alias} 	${data_path}     data=${data}    headers=${headers}
    Log    Received response from openstack ${resp.text}
    [Return]    ${resp}

Internal Delete Openstack
    [Documentation]    Runs an Openstack Delete Request and returns the response
    [Arguments]    ${alias}    ${service_type}    ${region}    ${url_ext}   ${data_path}=
    Log    Internal Post Openstack values alias=${alias} service_type=${service_type} region=${region} url_ext=${url_ext} data_path=${data_path}
    ${url}=    Get Openstack Service Url    ${alias}     ${service_type}    ${region}
    ${uuid}=    Generate UUID
    ${session_alias}=    Catenate    openstack-${uuid}
    ${session}=    Create Session 	${session_alias} 	${url}${url_ext}        verify=True
    ${token}=    Get Openstack Token    ${alias}
    ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json    X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}     X-Auth-Token=${token}
    ${resp}= 	Delete Request 	${session_alias} 	${data_path}    headers=${headers}
    Log    Received response from openstack ${resp.text}
    [Return]    ${resp}