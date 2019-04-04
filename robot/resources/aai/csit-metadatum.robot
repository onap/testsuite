*** Settings ***
Documentation     Operations on metadata in AAI for BBS use case,
...               using earliest API version where it is implemented
...               and latest API version where it is not implemented.
...               Note that metadatum is always a sub-object!

Resource    ../json_templater.robot
Resource    aai_interface.robot
Resource    csit-api-version-properties.robot
Resource    csit-relationship-list.robot
Resource    csit-subobject.robot
Library    OperatingSystem
Library    Collections


*** Variables ***
${AAI_META_CONTAINER_PATH}=  /metadata
${AAI_META_SUBOBJECT_PATH}=  /metadatum
${AAI_META_UNIQUE_KEY}=      metaname
${AAI_META_CSIT_BODY}=       robot/assets/templates/aai/csit-metadatum.template
${AAI_META_ROOT_PATH}=       ${AAI_BUSINESS_PATH}${AAI_META_CONTAINER_PATH}${AAI_META_SUBOBJECT_PATH}
${AAI_META_API_NA_INDEX_PATH}=    ${AAI_UNSUPPORTED_INDEX_PATH}
${AAI_META_API_IMPL_INDEX_PATH}=  ${AAI_DUBLIN_INDEX_PATH}
# ${AAI_META_API_IMPL_INDEX_PATH}=  ${AAI_CASABLANCA_INDEX_PATH}

*** Keywords ***
Create Metadatum If Not Exists
    [Documentation]    Creates Metadatum in AAI if it doesn't exist
    [Arguments]    ${api_version_base_object_url}  ${metaname}  ${metaval}
    ${get_resp}=    Get SubObject  ${api_version_base_object_url}  ${AAI_META_CONTAINER_PATH}  ${AAI_META_SUBOBJECT_PATH}  ${AAI_META_UNIQUE_KEY}  ${metaname}
    Return From Keyword If    '${get_resp.status_code}' == '200'
    Create Metadatum  ${api_version_base_object_url}  ${metaname}  ${metaval}

Create Metadatum
    [Documentation]    Creates Metadatum in AAI
    [Arguments]    ${api_version_base_object_url}  ${metaname}  ${metaval}
    ${arguments}=    Create Dictionary     metaname=${metaname}  metaval=${metaval}
    ${put_resp}=    Create SubObject  ${api_version_base_object_url}  ${AAI_META_CONTAINER_PATH}  ${AAI_META_SUBOBJECT_PATH}  ${metaname}  ${AAI_META_CSIT_BODY}  ${arguments}

Delete Metadatum If Exists
    [Documentation]    Removes Metadatum from AAI if it exists
    [Arguments]    ${api_version_base_object_url}  ${metaname}
    ${get_resp}=    Get SubObject  ${api_version_base_object_url}  ${AAI_META_CONTAINER_PATH}  ${AAI_META_SUBOBJECT_PATH}  ${AAI_META_UNIQUE_KEY}  ${metaname}
    Run Keyword If    '${get_resp.status_code}' == '200'    Delete Metadatum     ${api_version_base_object_url}  ${metaname}   ${get_resp.json()}

Delete Metadatum
    [Documentation]    Removes Metadatum from AAI
    [Arguments]    ${api_version_base_object_url}  ${metaname}  ${json}
    ${del_resp}=    Delete SubObject  ${api_version_base_object_url}  ${AAI_META_CONTAINER_PATH}  ${AAI_META_SUBOBJECT_PATH}  ${metaname}  ${json}

Get Metadatum
    [Documentation]   Return Metadatum
    [Arguments]    ${api_version_base_object_url}  ${metaname}
    ${get_resp}=    Get SubObject  ${api_version_base_object_url}  ${AAI_META_CONTAINER_PATH}  ${AAI_META_SUBOBJECT_PATH}  ${AAI_META_UNIQUE_KEY}  ${metaname}
    Should Be Equal As Strings  ${get_resp.status_code}     200
    [Return]  ${get_resp.json()}

Get Valid Metadatum URL
    [Documentation]   Return Valid Metadatum URL
    [Arguments]    ${api_version_base_object_url}  ${metaname}
    ${resp}=    Get Valid SubObject URL  ${api_version_base_object_url}  ${AAI_META_CONTAINER_PATH}  ${AAI_META_SUBOBJECT_PATH}  ${metaname}
    [Return]  ${resp}

Get Nodes Query Metadatum
    [Documentation]   Return Nodes query Metadatum
    [Arguments]    ${metaname}
    ${get_resp}=    Confirm Nodes Query SubObjects  ${AAI_META_API_IMPL_INDEX_PATH}  ${AAI_META_CONTAINER_PATH}  ${AAI_META_UNIQUE_KEY}  ${metaname}
    [Return]  ${get_resp.json()}

Get Example Metadatum
    [Documentation]   Return Example Metadatum
    ${get_resp}=    Confirm Examples Query SubObjects  ${AAI_META_API_IMPL_INDEX_PATH}  ${AAI_META_CONTAINER_PATH}
    [Return]  ${get_resp.json()}

Confirm No Metadatum
    [Documentation]   Confirm No Metadatum
    [Arguments]    ${api_version_base_object_url}  ${metaname}
    ${get_resp}=    Get SubObject  ${api_version_base_object_url}  ${AAI_META_CONTAINER_PATH}  ${AAI_META_SUBOBJECT_PATH}  ${AAI_META_UNIQUE_KEY}  ${metaname}
    Should Be Equal As Strings  ${get_resp.status_code}     404

Confirm API Not Implemented Metadatum
    [Documentation]   Confirm latest API version where Metadatum is not implemented
    [Arguments]    ${metaname}
    ${resp}=    Confirm API Not Implemented SubObject  ${AAI_META_API_NA_INDEX_PATH}${AAI_BUSINESS_PATH}  ${AAI_META_CONTAINER_PATH}  ${AAI_META_SUBOBJECT_PATH}  ${metaname}


