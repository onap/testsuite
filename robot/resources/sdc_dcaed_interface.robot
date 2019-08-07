*** Settings ***
Library           json
Library           ONAPLibrary.Utilities
Library           ONAPLibrary.Templating    WITH NAME    Templating
Resource          global_properties.robot

*** Variables ***
${SDC_DESIGNER_USER_ID}    cs0008
${DCAE_PATH}    /dcae
${DCAE_CREATE_BLUEPRINT_PATH}   /SERVICE/createBluePrint
${DCAE_VFCMT_TEMPLATE}   sdc/create_vfcmt.jinja
${DCAE_COMPOSITION_TEMPLATE}   sdc/dcae_composition.jinja
${DCAE_MONITORING_CONFIGURATION_TEMPLATE}   sdc/dcae_monitoring_configuration.jinja
${SDC_DCAE_BE_ENDPOINT}     ${GLOBAL_SDC_SERVER_PROTOCOL}://${GLOBAL_INJECTED_SDC_DCAE_BE_IP_ADDR}:${GLOBAL_SDC_DCAE_BE_PORT}

*** Keywords ***

Add VFCMT To DCAE-DS
    [Documentation]   Create VFCMT with the given name and return its uuid
    [Arguments]   ${vfcmt_name}
    ${map}=    Create Dictionary    vfcmtName=${vfcmt_name}   description=VFCMT created by robot
    Create Environment   create_vfcmt   ${GLOBAL_TEMPLATE_FOLDER}
    ${data}=   Apply Template   create_vfcmt   ${DCAE_VFCMT_TEMPLATE}    ${map}
    ${resp}=    Run DCAE-DS Post Request    ${DCAE_PATH}/createVFCMT     ${data}    ${SDC_DESIGNER_USER_ID}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()['uuid']}

Run DCAE-DS Post Request
    [Documentation]    Runs a DCAE-DS post request
    [Arguments]    ${data_path}    ${data}    ${user}=${SDC_DESIGNER_USER_ID}
    Log    Creating session ${SDC_DCAE_BE_ENDPOINT}
    ${session}=    Create Session       sdc_dcae_ds    ${SDC_DCAE_BE_ENDPOINT}
    ${uuid}=    Generate UUID4
    ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json    USER_ID=${user}    X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}
    ${resp}=    Post Request    sdc_dcae_ds    ${data_path}     data=${data}    headers=${headers}
    Log    Received response from SDC-DCAE-BE: ${resp.text}
    [Return]    ${resp}

Run DCAE-DS Put Request
    [Documentation]    Runs a DCAE-DS put request
    [Arguments]    ${data_path}    ${user}=${SDC_DESIGNER_USER_ID}
    Log    Creating session ${SDC_DCAE_BE_ENDPOINT}
    ${session}=    Create Session       sdc_dcae_ds    ${SDC_DCAE_BE_ENDPOINT}
    ${uuid}=    Generate UUID4
    ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json    USER_ID=${user}    X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}
    ${resp}=    Put Request    sdc_dcae_ds    ${data_path}    headers=${headers}
    Log    Received response from SDC-DCAE-BE: ${resp.text}
    [Return]    ${resp}

Save Composition
    [Arguments]   ${vfcmt_uuid}   ${vf_uuid}
    ${map}=    Create Dictionary    cid=${vfcmt_uuid}   vf_id=${vf_uuid}
    Create Environment   dcae_composition   ${GLOBAL_TEMPLATE_FOLDER}
    ${data}=   Apply Template   dcae_composition   ${DCAE_COMPOSITION_TEMPLATE}    ${map}
    ${resp}=    Run DCAE-DS Post Request    ${DCAE_PATH}/saveComposition/${vfcmt_uuid}     ${data}    ${SDC_DESIGNER_USER_ID}
    Should Be Equal As Strings  ${resp.status_code}     200

Certify VFCMT
    [Arguments]   ${vfcmt_uuid}
    ${resp}=    Run DCAE-DS Put Request    ${DCAE_PATH}/certify/vfcmt/${vfcmt_uuid}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()['uuid']}

Add Monitoring Configuration To DCAE-DS
    [Arguments]   ${vfcmt_uuid}   ${cs_uuid}   ${vfi_name}   ${mc_name}
    ${map}=    Create Dictionary    template_uuid=${vfcmt_uuid}   service_uuid=${cs_uuid}   vfi_name=${vfi_name}  name=${mc_name}
    Create Environment   dcae_monitoring_configuration   ${GLOBAL_TEMPLATE_FOLDER}
    ${data}=   Apply Template   dcae_monitoring_configuration   ${DCAE_MONITORING_CONFIGURATION_TEMPLATE}    ${map}
    ${resp}=    Run DCAE-DS Post Request    ${DCAE_PATH}/importMC     ${data}    ${SDC_DESIGNER_USER_ID}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()['vfcmt']['uuid']}

Submit Monitoring Configuration To DCAE-DS
    [Arguments]   ${mc_uuid}   ${cs_uuid}   ${vfi_name}
    ${url_vfi_name}   url_encode_string  ${vfi_name}
    ${resp}=    Run DCAE-DS Post Request    ${DCAE_PATH}${DCAE_CREATE_BLUEPRINT_PATH}/${mc_uuid}/${cs_uuid}/${url_vfi_name}     ${None}    ${SDC_DESIGNER_USER_ID}
    Should Be Equal As Strings  ${resp.status_code}     200

