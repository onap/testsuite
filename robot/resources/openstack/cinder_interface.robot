*** Settings ***
Documentation     The main interface for interacting with Openstack. It handles low level stuff like managing the authtoken and Openstack required fields
Library           ONAPLibrary.Openstack
Library 	      RequestsLibrary
Library	          ONAPLibrary.Utilities
Library           ONAPLibrary.Templating    WITH NAME    Templating
Resource    ../global_properties.robot
Resource    openstack_common.robot


*** Variables ***
${OPENSTACK_CINDER_API_VERSION}    /v1
${OPENSTACK_CINDER_TYPES_PATH}    /types
${OPENSTACK_CINDER_VOLUMES_PATH}    /volumes
${OPENSTACK_CINDER_VOLUMES_ADD_BODY_FILE}        openstack/cinder_add_volume.jinja
${OPENSTACK_CINDER_VOLUMES_TYPE}    SSD
${OPENSTACK_CINDER_AVAILABILITY_ZONE}    nova

*** Keywords ***
Get Openstack Volume Types
    [Documentation]    Returns the openstack volume types information
    [Arguments]    ${alias}
    ${resp}=    Internal Get Openstack    ${alias}    ${GLOBAL_OPENSTACK_CINDER_SERVICE_TYPE}   ${OPENSTACK_CINDER_TYPES_PATH}
    [Return]    ${resp.json()}

Get Openstack Volume
    [Documentation]    Returns the openstack volume information for the passed in volume id
    [Arguments]    ${alias}    ${volume_id}
    ${resp}=    Internal Get Openstack    ${alias}    ${GLOBAL_OPENSTACK_CINDER_SERVICE_TYPE}   ${OPENSTACK_CINDER_VOLUMES_PATH}	    /${volume_id}
    [Return]    ${resp.json()}

Add Openstack Volume
    [Documentation]    Runs an Openstack Request to add a volume and returns that volume id of the created volume
    [Arguments]    ${alias}    ${name}	    ${size}
    ${uuid}=    Generate UUID4
    ${arguments}=    Create Dictionary    name=${name}     description=${GLOBAL_APPLICATION_ID}${uuid}	size=${size}    type=${OPENSTACK_CINDER_VOLUMES_TYPE}    availability_zone=${OPENSTACK_CINDER_AVAILABILITY_ZONE}
    Templating.Create Environment    cinder    ${GLOBAL_TEMPLATE_FOLDER}
    ${data}=   Templating.Apply Template    cinder    ${OPENSTACK_CINDER_VOLUMES_ADD_BODY_FILE}    ${arguments}
    ${resp}=    Internal Post Openstack    ${alias}    ${GLOBAL_OPENSTACK_CINDER_SERVICE_TYPE}   ${OPENSTACK_CINDER_VOLUMES_PATH}    data_path=    data=${data}
    Should Be Equal As Strings    200  ${resp.status_code}
    [Return]    ${resp.json()['volume']['id']}

Delete Openstack Volume
    [Documentation]    Runs an Openstack Request to delete a volume
    [Arguments]    ${alias}    ${volume_id}
    ${resp}=    Internal Delete Openstack    ${alias}    ${GLOBAL_OPENSTACK_CINDER_SERVICE_TYPE}   ${OPENSTACK_CINDER_VOLUMES_PATH}	  /${volume_id}
    ${status_string}=    Convert To String    ${resp.status_code}
    Should Match Regexp    ${status_string}    ^(204|200|404)$
    [Return]    ${resp.text}