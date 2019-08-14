*** Settings ***
Documentation     The main interface for interacting with CDS. It handles low level stuff like managing the http request library and CDS required fields
Library               RequestsLibrary
Library           ONAPLibrary.Utilities
Library           OperatingSystem
Library           Collections
Library           ONAPLibrary.JSON
Library           ONAPLibrary.ServiceMapping    WITH NAME     ServiceMapping
Library           ONAPLibrary.PreloadData    WITH NAME     Preload
Library           ONAPLibrary.Templating    WITH NAME     Templating
Library           ONAPLibrary.SDNC        WITH NAME     SDNC
Library           ONAPLibrary.SO    WITH NAME    SO
Library           jinja2    
Resource          global_properties.robot

*** Variables ***
${CDS_HEALTH_CHECK_PATH}    /api/v1/execution-service/health-check 
${CDS_HEALTH_ENDPOINT}     ${GLOBAL_CCSDK_CDS_SERVER_PROTOCOL}://${GLOBAL_INJECTED_CCSDK_CDS_BLUEPRINT_PROCESSOR_IP_ADDR}:${GLOBAL_CCSDK_CDS_HEALTH_SERVER_PORT}
${SDC_SERVICE_CATALOG_ENDPOINT}  ${GLOBAL_SDC_SERVER_PROTOCOL}://${GLOBAL_INJECTED_SDC_BE_IP_ADDR}:${GLOBAL_SDC_BE_PORT} 

${SDC_SERVICE_CATALOG_PATH}    sdc2/rest/v1/catalog/services/serviceName/demoVLB_CDS/serviceVersion/1.0
${SO_CATALOGDB_PATH}  /ecomp/mso/catalog/v2/serviceVnfs?serviceModelName
${SO_APIHANDLER_PATH}    /onap/so/infra/serviceInstantiation/v7/serviceInstances
${SO_REQUESTDB_PATH}  /infraActiveRequests

${customer}    Demonstration
${cloudOwner}    CloudOwner
${subscriptionServiceType}    vLB
${cds_service_path}    cds_service_template.jinja
${SO_TEMPLATE_PATH}        so

*** Keywords ***
Run CDS Health Check
    [Documentation]    Runs a CDS health check
    ${auth}=  Create List  ${GLOBAL_CCSDK_CDS_USERNAME}    ${GLOBAL_CCSDK_CDS_PASSWORD}
    ${session}=    Create Session       cds    ${CDS_HEALTH_ENDPOINT}    auth=${auth}
    ${headers}=  Create Dictionary    Accept=application/json    Content-Type=application/json
    ${resp}=    Get Request     cds    ${CDS_HEALTH_CHECK_PATH}     headers=${headers}
    Log    Received response code from cds ${resp}
    Log    Received content from cds ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200

Get All Services Catalog
    [Arguments]  ${cds-service-model}    
    ${session}=    Create Session       catalog         ${SDC_SERVICE_CATALOG_ENDPOINT}      
    #according to SDC API documentation, we must use Basic Authentation header with SDC API, which doesn't match the username/password in robot_properties.py
    ${headers}=  Create Dictionary   X-ECOMP-InstanceID=VID   USER_ID=cs0008  Authorization=Basic dmlkOktwOGJKNFNYc3pNMFdYbGhhazNlSGxjc2UyZ0F3ODR2YW9HR21KdlV5MlU=
    ${resp}=  Get Request   catalog  ${SDC_SERVICE_CATALOG_PATH}  headers=${headers}
    Should Be Equal As Strings  ${resp.status_code}  200    
    [Return]   ${resp.json()['uuid']}   ${resp.json()['invariantUUID']} 

Get Service VNFs
    [Arguments]  ${cds-service-model}    
    ${auth}=  Create List  ${GLOBAL_SO_CATDB_USERNAME}  ${GLOBAL_SO_PASSWORD}               
    ${session}=  Create Session         VNFs    ${GLOBAL_SO_CATDB_ENDPOINT}  auth=${auth}    
    ${resp}=  Get Request  VNFs  ${SO_CATALOGDB_PATH}=${cds-service-model}           
    Should Be Equal As Strings  ${resp.status_code}  200
    [Return]  ${resp.json()}

Service Assign & Activate 
    [Arguments]  ${customer}  ${cloudOwner}  ${subscriptionServiceType}  ${cds_service_model}  ${service_uuid}  ${service_invariantUUID}  ${resp.json()}  
    ${time_now}=  Get Time
    @{date_time}=  Split String  ${time_now}
    ${time_stamp}=  Catenate  SEPARATOR=_  @{date_time}[0]  @{date_time}[1]
    ${customized_time_stamp}=  Remove String  ${time_stamp}  :
    ${cds_instance_name}=   Set Variable   cds_vlb_svc_${customized_time_stamp}    
      
    ${global_parameters}=  Get Globally Injected Parameters 
    
    ${dict}=   Set To Dictionary  ${global_parameters}  cds_instance_name=${cds_instance_name}  customer=${customer}  cloudOwner=${cloudOwner}  subscriptionServiceType=${subscriptionServiceType}  cds_service_model=${cds_service_model}  service_uuid=${service_uuid}  service_invariantUUID=${service_invariantUUID}  resp=${resp.json()}    
    Templating.Create Environment    cds    ${GLOBAL_TEMPLATE_FOLDER}
    ${data}=   Templating.Apply Template    cds    ${SO_TEMPLATE_PATH}/cds_service_template.jinja    ${dict}
    Log  ${data}
    
    ${auth}=  Create List  ${GLOBAL_SO_USERNAME}  ${GLOBAL_SO_PASSWORD}
    ${session}=    Create Session       ServiceAssign   ${GLOBAL_SO_APIHAND_ENDPOINT}  auth=${auth}              
    ${resp}=  Post Request  ServiceAssign  ${SO_APIHANDLER_PATH}  ${data}    
    Should Be Equal As Strings  ${resp.status_code}  202    
    [Return]  ${resp.json()['requestReferences']['requestId']}
       
Check Infra Active Requests
    [Arguments]  ${cds_requestid}
    ${auth}=  Create List  ${GLOBAL_SO_CATDB_USERNAME }  ${GLOBAL_SO_PASSWORD}        
    SO.Run Polling Get Request  ${GLOBAL_SO_REQDB_ENDPOINT}  ${SO_REQUESTDB_PATH}/${cds_requestid}  tries=30   interval=60  auth=${auth}
