*** Settings ***
Documentation	  Create A&AI Customer API.
...
...	              Create A&AI Customer API

Resource    ../json_templater.robot
Resource    aai_interface.robot
Library    OperatingSystem
Library    Collections



*** Variables ***
${ZONE_INDEX_PATH}     /aai/v11
${AAI_QUERY_RESOURCE_PATH}   /query?format=resource

${SYSTEM USER}    robot-ete
${AAI_GET_MODEL_BODY}=    robot/assets/templates/aai/distribution_complete_query.templat

*** Keywords ***
Get Demonstration Model Data
    [Documentation]   Get Model Data for Demonstration Models
    [Arguments]    ${service}
    ${data}=	OperatingSystem.Get File     ${AAI_GET_MODEL_BODY}    
    ${post_resp}=   Run A&AI Post Request   ${AAI_INDEX_PATH}${AAI_QUERY_RESOURCE_PATH}    ${data}
    #${service_model_type}     ${vnf_type}    ${vf_modules}   ${catalog_resources}=    Get Demonstration Model Data    ${service}
    #[Return]    ${post_resp.service_model_type...
    [Return]      aaa     bbbb    cccc     ddddd




