*** Settings ***
Documentation     The main interface for interacting with DCAE. It handles low level stuff like managing the http request library and DCAE required fields
Library 	      RequestsLibrary
Library	          UUID
Library           OperatingSystem
Library           Collections
Resource          global_properties.robot

*** Variables ***
${DCAE_HEALTH_CHECK_BODY}    robot/assets/dcae/dcae_healthcheck.json
${DCAE_HEALTH_CHECK_PATH}    /gui
${DCAE_ENDPOINT}     ${GLOBAL_DCAE_SERVER_PROTOCOL}://${GLOBAL_INJECTED_DCAE_IP_ADDR}:${GLOBAL_DCAE_SERVER_PORT}

*** Keywords ***
Run DCAE Health Check
    [Documentation]    Runs a DCAE health check
    ${auth}=  Create List  ${GLOBAL_DCAE_USERNAME}    ${GLOBAL_DCAE_PASSWORD}
    Log    Creating session ${DCAE_ENDPOINT}
    ${session}=    Create Session 	dcae 	${DCAE_ENDPOINT}    auth=${auth}
    ${uuid}=    Generate UUID
    ${data}=    OperatingSystem.Get File    ${DCAE_HEALTH_CHECK_BODY}
    ${headers}=  Create Dictionary     X-ECOMP-Client-Version=ONAP-R2   action=getTable    Accept=application/json    Content-Type=application/json    X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}
    ${resp}= 	Put Request 	dcae 	${DCAE_HEALTH_CHECK_PATH}     data=${data}    headers=${headers}
    Log    Received response from dcae ${resp.json()}
    Should Be Equal As Strings 	${resp.status_code} 	200
    Check DCAE Results    ${resp.json()}

Check DCAE Results
    [Documentation]    Parse DCAE JSON response and make sure all rows have healthTestStatus=GREEN (except for the exceptions ;-)
    [Arguments]    ${json}
    @{rows}=    Get From Dictionary    ${json['returns']}    rows
    @{headers}=    Get From Dictionary    ${json['returns']}    columns

    # Retrieve column names from headers
    ${columns}=    Create List
    :for    ${header}    in    @{headers}
    \    ${colName}=    Get From Dictionary    ${header}    colName
    \    Append To List    ${columns}    ${colName}

    # Process each row making sure status=GREEN
    :for    ${row}    in    @{rows}
    \    ${cells}=    Get From Dictionary    ${row}    cells
    \    ${dict}=    Make A Dictionary    ${cells}    ${columns}
    \    Is DCAE Status Valid    ${dict}

Is DCAE Status Valid
    [Arguments]   ${dict}
    # If it is GREEN we are done.
    ${status}   ${value}=   Run Keyword And Ignore Error       Dictionary Should Contain Item    ${dict}    healthTestStatus    GREEN
    Return From Keyword If   '${status}' == 'PASS'

    # Check for Exceptions
    # Only 1 so far
    ${status}   ${value}=   Run Keyword And Ignore Error       Check For Exception    ${dict}    vm-controller    UNDEPLOYED   YELLOW
    Return From Keyword If   '${status}' == 'PASS'

    # Status not GREEN or is not an exception
    Fail    Health check failed ${dict}

Check for Exception
    [Arguments]   ${dict}   ${service}    ${status}   ${healthTestStatus}
    # Test the significant attributes to see if this is a legit exception
    ${exception}=   Copy Dictionary   ${dict}
    Set To Dictionary   ${exception}   service=${service}   status=${status}    healthTestStatus=${healthTestStatus}
    Dictionaries Should Be Equal    ${dict}    ${exception}



Make A Dictionary
    [Documentation]    Given a list of column names and a list of dictionaries, map columname=value
    [Arguments]     ${columns}    ${names}    ${valuename}=value
    ${dict}=    Create Dictionary
    ${collength}=    Get Length    ${columns}
    ${namelength}=    Get Length    ${names}
    :for    ${index}    in range    0   ${collength}
    \    ${name}=    Evaluate     ${names}[${index}]
    \    ${valued}=    Evaluate     ${columns}[${index}]
    \    ${value}=    Get From Dictionary    ${valued}    ${valueName}
    \    Set To Dictionary    ${dict}   ${name}    ${value}
    [Return]     ${dict}