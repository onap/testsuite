*** Settings ***
Documentation     Manage all CDS queries
Library           Collections
Library           RequestsLibrary
Library           HttpLibrary.HTTP
Library           OperatingSystem
Library           requests
Resource            ../global_properties.robot

*** Keywords ***

CDS Authorization
    ${auth}=     Evaluate    ('${GLOBAL_CCSDK_CDS_USERNAME}', '${GLOBAL_CCSDK_CDS_PASSWORD}')
    [Return]    ${auth}

CDS Post Request with files
    [Documentation]    Post request
    [Arguments]    ${url}    ${files}
    ${auth}=    CDS Authorization
    ${resp}=    requests.post    ${url}    files=${files}    auth=${auth}
    [Return]    ${resp}