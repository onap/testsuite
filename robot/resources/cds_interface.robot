*** Settings ***
Documentation     The main interface for interacting with CDS. It handles low level stuff like managing the http request library and CDS required fields
Library               RequestsLibrary
Library           ONAPLibrary.Utilities
Library           OperatingSystem
Library           Collections
Resource          global_properties.robot

*** Variables ***
${CDS_HEALTH_CHECK_PATH}    /api/v1/execution-service/health-check 
${CDS_HEALTH_ENDPOINT}     ${GLOBAL_CCSDK_CDS_SERVER_PROTOCOL}://${GLOBAL_INJECTED_CCSDK_CDS_BLUEPRINT_PROCESSOR_IP_ADDR}:${GLOBAL_CCSDK_CDS_HEALTH_SERVER_PORT}

${SDC_SERVICE_CATALOG_URL}    ${GLOBAL_SDC_SERVER_PROTOCOL}://${GLOBAL_INJECTED_SDC_BE_IP_ADDR}:${GLOBAL_SDC_BE_PORT}   
${SO_CATALOGDB_URL}    ${GLOBAL_SO_SERVER_PROTOCOL}://${GLOBAL_INJECTED_SO_CATDB_IP_ADDR}:${GLOBAL_SO_CATDB_SERVER_PORT}
${SO_APIHANDLER_URL}    ${GLOBAL_SO_SERVER_PROTOCOL}://${GLOBAL_INJECTED_SO_APIHAND_IP_ADDR}:${GLOBAL_SO_APIHAND_SERVER_PORT}
${SO_REQUESTDB_URL}    ${GLOBAL_SO_SERVER_PROTOCOL}://${GLOBAL_INJECTED_SO_REQDB_IP_ADDR}:${GLOBAL_SO_REQDB_SERVER_PORT}

${SDC_SERVICE_CATALOG_PATH}    /sdc/v1/catalog/services
${SO_CATALOGDB_PATH}    /ecomp/mso/catalog/v2/serviceVnfs?serviceModelName
${SO_APIHANDLER_PATH}    /onap/so/infra/serviceInstantiation/v7/serviceInstances
${SO_REQUESTDB_PATH}    /infraActiveRequests

${cds-service-model}    demoVLB_CDS
${customer}    Demonstration
${cloudOwner}    CloudOwner
${subscriptionServiceType}    vLB
${cloud_env}    openstack

*** Keywords ***
Run CDS Health Check
    [Documentation]    Runs a CDS health check
    ${auth}=  Create List  ${GLOBAL_CCSDK_CDS_USERNAME}    ${GLOBAL_CCSDK_CDS_PASSWORD}
    Log    Creating session ${CDS_HEALTH_ENDPOINT}
    ${session}=    Create Session       cds    ${CDS_HEALTH_ENDPOINT}    auth=${auth}
    ${headers}=  Create Dictionary    Accept=application/json    Content-Type=application/json
    ${resp}=    Get Request     cds    ${CDS_HEALTH_CHECK_PATH}     headers=${headers}
    Log    Received response code from cds ${resp}
    Log    Received content from cds ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200

Get All Services Catalog
    [Arguments]  ${SDC_SERVICE_CATALOG_URL}  ${SDC_SERVICE_CATALOG_PATH}  ${cds-service-model}   
    Log To Console    TESTING 1
    ${auth}=  Create List  ${GLOBAL_SDC_USERNAME}    ${GLOBAL_SDC_PASSWORD}    
    ${session}=    Create Session       catalog         ${SDC_SERVICE_CATALOG_URL}   
    ${headers}=  Create Dictionary   X-ECOMP-InstanceID=VID   Authorization=Basic dmlkOktwOGJKNFNYc3pNMFdYbGhhazNlSGxjc2UyZ0F3ODR2YW9HR21KdlV5MlU=
    ${resp}=  Get Request   catalog  ${SDC_SERVICE_CATALOG_PATH}  headers=${headers}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Log To Console   "Lookup service mode in SDC Catalog: ${cds-service-model}
    
    :FOR  ${objects}  IN  @{resp.json()}
    \    Run Keyword If  '${objects['name']}' == '${cds-service-model}'   Exit For Loop
    Log To Console   \n${objects['uuid']}\n${objects['invariantUUID']} 
    [Return]   ${objects['uuid']}   ${objects['invariantUUID']}
     
Get Service VNFs
    [Arguments]  ${SO_CATALOGDB_URL}  ${SO_CATALOGDB_PATH}  ${cds-service-model}    
    ${auth}=  Create List  ${GLOBAL_SO_USERNAME}    ${GLOBAL_SO_PASSWORD}                
    ${session}=  Create Session         VNFs    ${SO_CATALOGDB_URL}    
    ${headers}=  Create Dictionary  Authorization=Basic YnBlbDpwYXNzd29yZDEk
    Log To Console   ${cds-service-model}
    Log To Console   ${SO_CATALOGDB_PATH}
    ${resp}=  Get Request  VNFs  ${SO_CATALOGDB_PATH}=${cds-service-model}  headers=${headers}           
    Log To Console  TESTING 3
    #Log To Console   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    [Return]  ${resp}

Service Assign & Activate 
    [Arguments]  ${SO_APIHANDLER_URL}  ${SO_APIHANDLER_PATH}   ${cds-service-model}  ${service-uuid}  ${service-invariantUUID}  ${resp}
    ${time_now}=  Get Time
    @{date_time}=  Split String  ${time_now}
    ${time_stamp}=  Catenate  SEPARATOR=_  @{date_time}[0]  @{date_time}[1]
    ${customized_time_stamp}=  Remove String  ${time_stamp}  :
    ${cds-instance-name}=   Set Variable   cds-vlb-svc-${customized_time_stamp}    #can be changed 
    ${auth}=  Create List  ${GLOBAL_SO_USERNAME}    ${GLOBAL_SO_PASSWORD}        
    ${session}=    Create Session       ServiceAssign   ${SO_APIHANDLER_URL}   
    ${Headers}=  Create Dictionary  Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==  Content-Type=application/json       

    ${vnf-modelname}=  Set Variable   ${resp.json()['serviceVnfs'][0]['modelInfo']['modelName']}
    ${vnf-modeluuid}=  Set Variable   ${resp.json()['serviceVnfs'][0]['modelInfo']['modelUuid']}
    ${vnf-modelinvariantuuid}=  Set Variable  ${resp.json()['serviceVnfs'][0]['modelInfo']['modelInvariantUuid']}
    ${vnf-modelcustomizationuuid}=  Set Variable  ${resp.json()['serviceVnfs'][0]['modelInfo']['modelCustomizationUuid']}
    ${vnf-modelinstancename}=  Set Variable  ${resp.json()['serviceVnfs'][0]['modelInfo']['modelInstanceName']}

    ${vfmodule-0-modelname}=  Set Variable  ${resp.json()['serviceVnfs'][0]['vfModules'][0]['modelInfo']['modelName']}
    ${vfmodule-0-modeluuid}=  Set Variable  ${resp.json()['serviceVnfs'][0]['vfModules'][0]['modelInfo']['modelUuid']}
    ${vfmodule-0-modelinvariantuuid}=  Set Variable  ${resp.json()['serviceVnfs'][0]['vfModules'][0]['modelInfo']['modelInvariantUuid']}
    ${vfmodule-0-modelcustomizationuuid}=  Set Variable  ${resp.json()['serviceVnfs'][0]['vfModules'][0]['modelInfo']['modelCustomizationUuid']}

    ${vfmodule-1-modelname}=  Set Variable  ${resp.json()['serviceVnfs'][0]['vfModules'][1]['modelInfo']['modelName']}
    ${vfmodule-1-modeluuid}=  Set Variable  ${resp.json()['serviceVnfs'][0]['vfModules'][1]['modelInfo']['modelUuid']}
    ${vfmodule-1-modelinvariantuuid}=  Set Variable  ${resp.json()['serviceVnfs'][0]['vfModules'][1]['modelInfo']['modelInvariantUuid']}
    ${vfmodule-1-modelcustomizationuuid}=  Set Variable  ${resp.json()['serviceVnfs'][0]['vfModules'][1]['modelInfo']['modelCustomizationUuid']}

    ${vfmodule-2-modelname}=  Set Variable  ${resp.json()['serviceVnfs'][0]['vfModules'][2]['modelInfo']['modelName']}
    ${vfmodule-2-modeluuid}=  Set Variable  ${resp.json()['serviceVnfs'][0]['vfModules'][2]['modelInfo']['modelUuid']}
    ${vfmodule-2-modelinvariantuuid}=  Set Variable  ${resp.json()['serviceVnfs'][0]['vfModules'][2]['modelInfo']['modelInvariantUuid']}
    ${vfmodule-2-modelcustomizationuuid}=  Set Variable  ${resp.json()['serviceVnfs'][0]['vfModules'][2]['modelInfo']['modelCustomizationUuid']}

    ${vfmodule-3-modelname}=  Set Variable  ${resp.json()['serviceVnfs'][0]['vfModules'][3]['modelInfo']['modelName']}
    ${vfmodule-3-modeluuid}=  Set Variable  ${resp.json()['serviceVnfs'][0]['vfModules'][3]['modelInfo']['modelUuid']}
    ${vfmodule-3-modelinvariantuuid}=  Set Variable  ${resp.json()['serviceVnfs'][0]['vfModules'][3]['modelInfo']['modelInvariantUuid']}
    ${vfmodule-3-modelcustomizationuuid}=  Set Variable  ${resp.json()['serviceVnfs'][0]['vfModules'][3]['modelInfo']['modelCustomizationUuid']}

    ${resp}=  Post Request  ServiceAssign  ${SO_APIHANDLER_PATH}  data={"requestDetails":{"subscriberInfo":{"globalSubscriberId":"${customer}"},"requestInfo":{"suppressRollback":false,"productFamilyId":"a9a77d5a-123e-4ca2-9eb9-0b015d2ee0fb","requestorId":"adt","instanceName":"${cds-instance-name}","source":"VID"},"cloudConfiguration":{"lcpCloudRegionId":"${VLB_INJECTED_REGION}","tenantId":"${VLB_INJECTED_OPENSTACK_TENANT_ID}","cloudOwner":"${cloudOwner}"},"requestParameters":{"subscriptionServiceType":"${subscriptionServiceType}","userParams":[{"Homing_Solution":"none"},{"service":{"instanceParams":[],"instanceName":"${cds-instance-name}","resources":{"vnfs":[{"modelInfo":{"modelName":"${vnf-modelname}","modelVersionId":"${vnf-modeluuid}","modelInvariantUuid":"${vnf-modelinvariantuuid}","modelVersion":"1.0","modelCustomizationId":"${vnf-modelcustomizationuuid}","modelInstanceName":"${vnf-modelinstancename}"},"cloudConfiguration":{"lcpCloudRegionId":"${VLB_INJECTED_REGION}","tenantId":"${VLB_INJECTED_OPENSTACK_TENANT_ID}"},"platform":{"platformName":"test"},"lineOfBusiness":{"lineOfBusinessName":"LOB-Demonstration"},"productFamilyId":"a9a77d5a-123e-4ca2-9eb9-0b015d2ee0fb","instanceName":"${vnf-modelinstancename}","instanceParams":[{"onap_private_net_id":"${VLB_INJECTED_PRIVATE_NET_ID}","onap_private_subnet_id":"${VLB_INJECTED_OPENSTACK_PRIVATE_SUBNET_ID}","pub_key":"${VLB_INJECTED_PUBLIC_KEY}","image_name":"${VLB_INJECTED_UBUNTU_1604_IMAGE}","flavor_name":"${VLB_INJECTED_VM_FLAVOR}","vpg_flavor_name":"${VLB_INJECTED_VM_FLAVOR}","vlb_flavor_name":"${VLB_INJECTED_VM_FLAVOR}","vdns_flavor_name":"${VLB_INJECTED_VM_FLAVOR}","sec_group":"${VLB_INJECTED_OPENSTACK_SECURITY_GROUP}","install_script_version":"${VLB_INJECTED_SCRIPT_VERSION}","demo_artifacts_version":"${VLB_INJECTED_SCRIPT_VERSION}","cloud_env":"${cloud_env}","public_net_id":"${VLB_INJECTED_PUBLIC_NET_ID}","aic-cloud-region":"${VLB_INJECTED_REGION}"}],"vfModules":[{"modelInfo":{"modelName":"${vfmodule-0-modelname}","modelVersionId":"${vfmodule-0-modeluuid}","modelInvariantUuid":"${vfmodule-0-modelinvariantuuid}","modelVersion":"1","modelCustomizationId":"${vfmodule-0-modelcustomizationuuid}"},"instanceName":"${vfmodule-0-modelname}","instanceParams":[{}]},{"modelInfo":{"modelName":"${vfmodule-1-modelname}","modelVersionId":"${vfmodule-1-modeluuid}","modelInvariantUuid":"${vfmodule-1-modelinvariantuuid}","modelVersion":"1","modelCustomizationId":"${vfmodule-1-modelcustomizationuuid}"},"instanceName":"${vfmodule-1-modelname}","instanceParams":[{}]},{"modelInfo":{"modelName":"${vfmodule-2-modelname}","modelVersionId":"${vfmodule-2-modeluuid}","modelInvariantUuid":"${vfmodule-2-modelinvariantuuid}","modelVersion":"1","modelCustomizationId":"${vfmodule-2-modelcustomizationuuid}"},"instanceName":"${vfmodule-2-modelname}","instanceParams":[{}]},{"modelInfo":{"modelName":"${vfmodule-3-modelname}","modelVersionId":"${vfmodule-3-modeluuid}","modelInvariantUuid":"${vfmodule-3-modelinvariantuuid}","modelVersion":"1","modelCustomizationId":"${vfmodule-3-modelcustomizationuuid}"},"instanceName":"${vfmodule-3-modelname}","instanceParams":[{}]}]}]},"modelInfo":{"modelVersion":"1.0","modelVersionId":"${service-uuid}","modelInvariantId":"${service-invariantUUID}","modelName":"${cds-service-model}","modelType":"service"}}}],"aLaCarte":false},"project":{"projectName":"Project-Demonstration"},"owningEntity":{"owningEntityId":"67f2e84c-734d-4e90-a1e4-d2ffa2e75849","owningEntityName":"OE-Demonstration"},"modelInfo":{"modelVersion":"1.0","modelVersionId":"${service-uuid}","modelInvariantId":"${service-invariantUUID}","modelName":"${cds-service-model}","modelType":"service"}}}  headers=${headers}          #not possible to make Get URL as variable containing another variable 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  202    
    Log  \nService Instance Name: ${cds-instance-name}
    [Return]  ${resp.json()['requestReferences']['requestId']}
       
Check Infra Active Requests
    [Arguments]  ${SO_REQUESTDB_URL}  ${SO_REQUESTDB_PATH}  ${cds-requestid}  
    ${auth}=  Create List  ${GLOBAL_SO_USERNAME}    ${GLOBAL_SO_PASSWORD}    
    ${session}=   Create Session        CheckService    ${SO_REQUESTDB_URL}   
    ${Headers}=  Create Dictionary  Authorization=Basic YnBlbDpwYXNzd29yZDEk
    ${get-request-status}=  Catenate  SEPARATOR=/  ${SO_REQUESTDB_PATH}  ${cds-requestid} 
    ${resp}=  Get Request  CheckService  ${get-request-status}  ${Headers}    
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    :FOR  ${retries}  IN RANGE  0  30
    \    Sleep  60
    \    ${session}=    Create Session  CheckReq        ${SO_REQUESTDB_URL} 
    \    ${headers}=  Create Dictionary  Authorization=Basic YnBlbDpwYXNzd29yZDEk
    \    ${resp}=  Get Request  CheckReq   ${get-request-status}  headers=${headers}   
    #\    Log  ${resp.json()}
    \    Set Test Variable  ${requestStatus}  ${resp.json()['requestStatus']}
    \    #Log  Request Status: ${requestStatus}
    \    Set Test Variable  ${statusMessage}  ${resp.json()['statusMessage']}
    \    #Log  Status Message: ${statusMessage}  
    \    Set Test Variable  ${flowStatus}  ${resp.json()['flowStatus']} 
    \    #Log  Flow Status: ${flowStatus}
    \    Set Test Variable  ${retryStatusMessage}  ${resp.json()['retryStatusMessage']} 
    \    #Log  Retry Status Message: ${retryStatusMessage}
    \    Log  requestId: ${cds-requestid}  
    \    Run Keyword If  '${requestStatus}'=='FAILED'  Fail  
    ...    ELSE IF  '${requestStatus}'=='COMPLETE'  Exit For Loop
       
    Run Keyword If  '${requestStatus}'=='IN_PROGRESS'  Fail     #if above for loop finished retries (30mins) and status still IN_PROGRESS, Fail the test 
    Set Global Variable  ${request-Status}  ${requestStatus}
