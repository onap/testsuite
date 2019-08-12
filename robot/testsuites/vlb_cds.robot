*** Settings ***
#Library    REST     ssl_verify=False
Library    RequestsLibrary
#Library    HttpLibrary
#Resource  variables.robot 
Library  String  
Resource         ../resources/test_templates/vnf_orchestration_with_cds_test_template.robot
Resource         ../resources/demo_preload.robot
#Resource         /share/config/robot_properties.py

*** Variables ***

${SDC_SERVICE_CATALOG_URL}    ${GLOBAL_SDC_SERVER_PROTOCOL}://${GLOBAL_INJECTED_SDC_BE_IP_ADDR}:${GLOBAL_SDC_BE_PORT}   
${SO_CATALOGDB_URL}    ${GLOBAL_SO_SERVER_PROTOCOL}://${GLOBAL_INJECTED_SO_CATDB_IP_ADDR}:${GLOBAL_SO_CATDB_SERVER_PORT}
${SO_APIHANDLER_URL}    ${GLOBAL_SO_SERVER_PROTOCOL}://${GLOBAL_INJECTED_SO_APIHAND_IP_ADDR}:${GLOBAL_SO_APIHAND_SERVER_PORT}
${SO_REQUESTDB_URL}    ${GLOBAL_SO_SERVER_PROTOCOL}://${GLOBAL_INJECTED_SO_REQDB_IP_ADDR}:${GLOBAL_SO_REQDB_SERVER_PORT}

${SDC_SERVICE_CATALOG_PATH}    /sdc/v1/catalog/services
${SO_CATALOGDB_PATH}    /ecomp/mso/catalog/v2/serviceVnfs?serviceModelName
${SO_APIHANDLER_PATH}    /onap/so/infra/serviceInstantiation/v7/serviceInstances
${SO_REQUESTDB_PATH}    /infraActiveRequests

${cds-service-model}    demoVLB_CDS

${cloud-region}    ${VLB_INJECTED_REGION}
${customer}    Demonstration
${tenantId}    ${VLB_INJECTED_OPENSTACK_TENANT_ID}
${cloudOwner}    CloudOwner
${subscriptionServiceType}    vLB
${onap_private_net_id}   ${VLB_INJECTED_PRIVATE_NET_ID}
${onap_private_subnet_id}    ${VLB_INJECTED_OPENSTACK_PRIVATE_SUBNET_ID}
${pub_key}   ${VLB_INJECTED_PUBLIC_KEY} 
${image_name}    ${VLB_INJECTED_UBUNTU_1604_IMAGE}
${flavor_name}    ${VLB_INJECTED_VM_FLAVOR}
${sec_group}    ${VLB_INJECTED_OPENSTACK_SECURITY_GROUP}
${install_script_version}    ${VLB_INJECTED_SCRIPT_VERSION}
${demo_artifacts_version}    ${VLB_INJECTED_SCRIPT_VERSION}
${cloud_env}    openstack
${public_net_id}    ${VLB_INJECTED_PUBLIC_NET_ID}
${aic-cloud-region}    ${VLB_INJECTED_REGION}

*** Test Cases ***                         
Instantiate Virtual VLB With CDS                    
    [Tags]    instantiateVLB_CDS
    
    ${status}   ${value}=   Run Keyword And Ignore Error   Distribute Model   vLB_CDS   ${DEMO_PREFIX}VLB_CDS  True
    
    # #CDS #1 - SDC Catalog Service  
    Get All Services Catalog  ${SDC_SERVICE_CATALOG_URL}  ${SDC_SERVICE_CATALOG_PATH}  ${cds-service-model} 

    # #CDS #2 - SO Catalog DB Service VNFs - CDS
    Get Service VNFs  ${SO_CATALOGDB_URL}  ${SO_CATALOGDB_PATH}  ${service-name}
    
    # #CDS #3 - SO Self-Serve Service Assign & Activate  
    Service Assign & Activate  ${SO_APIHANDLER_URL}  ${SO_APIHANDLER_PATH}  ${customer}  ${cloud-region}  ${tenantId}  ${cloudOwner}  ${subscriptionServiceType}  ${onap_private_net_id}  ${onap_private_subnet_id}  ${pub_key}  ${image_name}  ${flavor_name}  ${sec_group}  ${install_script_version}  ${demo_artifacts_version}  ${cloud_env}  ${public_net_id}  ${aic-cloud-region}  ${service-uuid}  ${service-invariantUUID}  ${service-name}

    # #CDS #4 - SO Infra Active Requests - CDS
    Check Infra Active Requests  ${SO_REQUESTDB_URL}  ${SO_REQUESTDB_PATH}  ${cds-requestid}  


*** Keywords ***
Instantiate Virtual VLB With CDS
    Get All Services Catalog  ${cds-instance-name}  ${SDC_SERVICE_CATALOG_URL}  ${SDC_SERVICE_CATALOG_PATH}  ${cds-service-model}  ${service-uuid}  ${service-invariantUUID}  ${service-name}
    Get Service VNFs  ${SO_CATALOGDB_URL}  ${SO_CATALOGDB_PATH}  ${service-name}  ${vnf-modelinfo-modelname}  ${vnf-modelinfo-modeluuid}  ${vnf-modelinfo-modelinvariantuuid}  ${vnf-modelinfo-modelcustomizationuuid}  ${vnf-modelinfo-modelinstancename}  ${vnf-vfmodule-0-modelinfo-modelname}  ${vnf-vfmodule-0-modelinfo-modeluuid}  ${vnf-vfmodule-0-modelinfo-modelinvariantuuid}  ${vnf-vfmodule-0-modelinfo-modelcustomizationuuid}  ${vnf-vfmodule-1-modelinfo-modelname}  ${vnf-vfmodule-1-modelinfo-modeluuid}  ${vnf-vfmodule-1-modelinfo-modelinvariantuuid}  ${vnf-vfmodule-1-modelinfo-modelcustomizationuuid}  ${vnf-vfmodule-2-modelinfo-modelname}  ${vnf-vfmodule-2-modelinfo-modeluuid}  ${vnf-vfmodule-2-modelinfo-modelinvariantuuid}  ${vnf-vfmodule-2-modelinfo-modelcustomizationuuid}  ${vnf-vfmodule-3-modelinfo-modelname}  ${vnf-vfmodule-3-modelinfo-modeluuid}  ${vnf-vfmodule-3-modelinfo-modelinvariantuuid}  ${vnf-vfmodule-3-modelinfo-modelcustomizationuuid}
    Service Assign & Activate  ${SO_APIHANDLER_URL}  ${SO_APIHANDLER_PATH}  ${cds-requestid}  ${cds-instanceid}  ${customer}  ${cds-instance-name}  ${cloud-region}  ${tenantId}  ${cloudOwner}  ${subscriptionServiceType}  ${vnf-modelinfo-modelname}  ${vnf-modelinfo-modeluuid}  ${vnf-modelinfo-modelinvariantuuid}  ${vnf-modelinfo-modelcustomizationuuid}  ${vnf-modelinfo-modelinstancename}  ${vnf-vfmodule-0-modelinfo-modelname}  ${vnf-vfmodule-0-modelinfo-modeluuid}  ${vnf-vfmodule-0-modelinfo-modelinvariantuuid}  ${vnf-vfmodule-0-modelinfo-modelcustomizationuuid}  ${vnf-vfmodule-1-modelinfo-modelname}  ${vnf-vfmodule-1-modelinfo-modeluuid}  ${vnf-vfmodule-1-modelinfo-modelinvariantuuid}  ${vnf-vfmodule-1-modelinfo-modelcustomizationuuid}  ${vnf-vfmodule-2-modelinfo-modelname}  ${vnf-vfmodule-2-modelinfo-modeluuid}  ${vnf-vfmodule-2-modelinfo-modelinvariantuuid}  ${vnf-vfmodule-2-modelinfo-modelcustomizationuuid}  ${vnf-vfmodule-3-modelinfo-modelname}  ${vnf-vfmodule-3-modelinfo-modeluuid}  ${vnf-vfmodule-3-modelinfo-modelinvariantuuid}   ${vnf-vfmodule-3-modelinfo-modelcustomizationuuid}  ${onap_private_net_id}  ${onap_private_subnet_id}  ${pub_key}  ${image_name}  ${flavor_name}  ${sec_group}  ${install_script_version}  ${demo_artifacts_version}  ${cloud_env}  ${public_net_id}  ${aic-cloud-region}  ${service-uuid}  ${service-invariantUUID}  ${service-name}
    Check Infra Active Requests  ${SO_REQUESTDB_URL}  ${SO_REQUESTDB_PATH}  ${cds-requestid} 
    
    
Get All Services Catalog
    [Arguments]  ${SDC_SERVICE_CATALOG_URL}  ${SDC_SERVICE_CATALOG_PATH}  ${cds-service-model}   
    
    ${session}=    Create Session       catalog         ${SDC_SERVICE_CATALOG_URL} 
    ${headers}=  Create Dictionary   Authorization=Basic dmlkOktwOGJKNFNYc3pNMFdYbGhhazNlSGxjc2UyZ0F3ODR2YW9HR21KdlV5MlU=  X-ECOMP-InstanceID=VID
    ${resp}=  Get Request   catalog  ${SDC_SERVICE_CATALOG_PATH}  headers=${headers}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Log  "Lookup service mode in SDC Catalog: ${cds-service-model}
    
    :FOR  ${objects}  IN  @{resp.json()}
    \    Run Keyword If  '${objects['name']}' == '${cds-service-model}'   Exit For Loop
    
    Set Test Variable  ${service-uuid}  ${objects['uuid']} 
    Set Test Variable  ${service-invariantUUID}  ${objects['invariantUUID']}
    Set Test Variable  ${service-name}  ${objects['name']}
    Sleep  2
     
Get Service VNFs
    [Arguments]  ${SO_CATALOGDB_URL}  ${SO_CATALOGDB_PATH}  ${service-name}    
    
    ${session}=  Create Session         VNFs    ${SO_CATALOGDB_URL} 
    ${headers}=  Create Dictionary  Authorization=Basic YnBlbDpwYXNzd29yZDEk
    ${resp}=  Get Request  VNFs  ${SO_CATALOGDB_PATH}=${service-name}  headers=${headers}           
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Set Test Variable  ${vnf-modelinfo-modelname}  ${resp.json()['serviceVnfs'][0]['modelInfo']['modelName']} 
    Set Test Variable  ${vnf-modelinfo-modeluuid}  ${resp.json()['serviceVnfs'][0]['modelInfo']['modelUuid']} 
    Set Test Variable  ${vnf-modelinfo-modelinvariantuuid}  ${resp.json()['serviceVnfs'][0]['modelInfo']['modelInvariantUuid']} 
    Set Test Variable  ${vnf-modelinfo-modelcustomizationuuid}  ${resp.json()['serviceVnfs'][0]['modelInfo']['modelCustomizationUuid']}
    Set Test Variable  ${vnf-modelinfo-modelinstancename}  ${resp.json()['serviceVnfs'][0]['modelInfo']['modelInstanceName']}
        
    Set Test Variable  ${vnf-vfmodule-0-modelinfo-modelname}  ${resp.json()['serviceVnfs'][0]['vfModules'][0]['modelInfo']['modelName']}    
    Set Test Variable  ${vnf-vfmodule-0-modelinfo-modeluuid}  ${resp.json()['serviceVnfs'][0]['vfModules'][0]['modelInfo']['modelUuid']} 
    Set Test Variable  ${vnf-vfmodule-0-modelinfo-modelinvariantuuid}  ${resp.json()['serviceVnfs'][0]['vfModules'][0]['modelInfo']['modelInvariantUuid']}
    Set Test Variable  ${vnf-vfmodule-0-modelinfo-modelcustomizationuuid}  ${resp.json()['serviceVnfs'][0]['vfModules'][0]['modelInfo']['modelCustomizationUuid']}
    
    Set Test Variable  ${vnf-vfmodule-1-modelinfo-modelname}  ${resp.json()['serviceVnfs'][0]['vfModules'][1]['modelInfo']['modelName']}    
    Set Test Variable  ${vnf-vfmodule-1-modelinfo-modeluuid}  ${resp.json()['serviceVnfs'][0]['vfModules'][1]['modelInfo']['modelUuid']} 
    Set Test Variable  ${vnf-vfmodule-1-modelinfo-modelinvariantuuid}  ${resp.json()['serviceVnfs'][0]['vfModules'][1]['modelInfo']['modelInvariantUuid']} 
    Set Test Variable  ${vnf-vfmodule-1-modelinfo-modelcustomizationuuid}  ${resp.json()['serviceVnfs'][0]['vfModules'][1]['modelInfo']['modelCustomizationUuid']}
    
    Set Test Variable  ${vnf-vfmodule-2-modelinfo-modelname}  ${resp.json()['serviceVnfs'][0]['vfModules'][2]['modelInfo']['modelName']}    
    Set Test Variable  ${vnf-vfmodule-2-modelinfo-modeluuid}  ${resp.json()['serviceVnfs'][0]['vfModules'][2]['modelInfo']['modelUuid']} 
    Set Test Variable  ${vnf-vfmodule-2-modelinfo-modelinvariantuuid}  ${resp.json()['serviceVnfs'][0]['vfModules'][2]['modelInfo']['modelInvariantUuid']} 
    Set Test Variable  ${vnf-vfmodule-2-modelinfo-modelcustomizationuuid}  ${resp.json()['serviceVnfs'][0]['vfModules'][2]['modelInfo']['modelCustomizationUuid']}
    
    Set Test Variable  ${vnf-vfmodule-3-modelinfo-modelname}  ${resp.json()['serviceVnfs'][0]['vfModules'][3]['modelInfo']['modelName']}
    Set Test Variable  ${vnf-vfmodule-3-modelinfo-modeluuid}  ${resp.json()['serviceVnfs'][0]['vfModules'][3]['modelInfo']['modelUuid']}
    Set Test Variable  ${vnf-vfmodule-3-modelinfo-modelinvariantuuid}  ${resp.json()['serviceVnfs'][0]['vfModules'][3]['modelInfo']['modelInvariantUuid']}
    Set Test Variable  ${vnf-vfmodule-3-modelinfo-modelcustomizationuuid}  ${resp.json()['serviceVnfs'][0]['vfModules'][3]['modelInfo']['modelCustomizationUuid']}    
    Sleep  2
    
Service Assign & Activate 
    [Arguments]  ${SO_APIHANDLER_URL}  ${SO_APIHANDLER_PATH}  ${customer}  ${cloud-region}  ${tenantId}  ${cloudOwner}  ${subscriptionServiceType}  ${onap_private_net_id}  ${onap_private_subnet_id}  ${pub_key}  ${image_name}  ${flavor_name}  ${sec_group}  ${install_script_version}  ${demo_artifacts_version}  ${cloud_env}  ${public_net_id}  ${aic-cloud-region}  ${service-uuid}  ${service-invariantUUID}  ${service-name}       
    
    ${time_now}=  Get Time
    @{date_time}=  Split String  ${time_now}
    ${time_stamp}=  Catenate  SEPARATOR=_  @{date_time}[0]  @{date_time}[1]
    ${customized_time_stamp}=  Remove String  ${time_stamp}  :
    Set Test Variable  ${cds-instance-name}  cds-vlb-svc-${customized_time_stamp}    #can be changed 
        
    ${session}=    Create Session       ServiceAssign   ${SO_APIHANDLER_URL} 
    ${Headers}=  Create Dictionary  Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==  Content-Type=application/json       
    ${resp}=  Post Request  ServiceAssign  ${SO_APIHANDLER_PATH}  data={"requestDetails":{"subscriberInfo":{"globalSubscriberId":"${customer}"},"requestInfo":{"suppressRollback":false,"productFamilyId":"a9a77d5a-123e-4ca2-9eb9-0b015d2ee0fb","requestorId":"adt","instanceName":"${cds-instance-name}","source":"VID"},"cloudConfiguration":{"lcpCloudRegionId":"${cloud-region}","tenantId":"${tenantId}","cloudOwner":"${cloudOwner}"},"requestParameters":{"subscriptionServiceType":"${subscriptionServiceType}","userParams":[{"Homing_Solution":"none"},{"service":{"instanceParams":[],"instanceName":"${cds-instance-name}","resources":{"vnfs":[{"modelInfo":{"modelName":"${vnf-modelinfo-modelname}","modelVersionId":"${vnf-modelinfo-modeluuid}","modelInvariantUuid":"${vnf-modelinfo-modelinvariantuuid}","modelVersion":"1.0","modelCustomizationId":"${vnf-modelinfo-modelcustomizationuuid}","modelInstanceName":"${vnf-modelinfo-modelinstancename}"},"cloudConfiguration":{"lcpCloudRegionId":"${cloud-region}","tenantId":"${tenantId}"},"platform":{"platformName":"test"},"lineOfBusiness":{"lineOfBusinessName":"LOB-Demonstration"},"productFamilyId":"a9a77d5a-123e-4ca2-9eb9-0b015d2ee0fb","instanceName":"${vnf-modelinfo-modelinstancename}","instanceParams":[{"onap_private_net_id":"${onap_private_net_id}","onap_private_subnet_id":"${onap_private_subnet_id}","pub_key":"${pub_key}","image_name":"${image_name}","flavor_name":"${flavor_name}","vpg_flavor_name":"${flavor_name}","vlb_flavor_name":"${flavor_name}","vdns_flavor_name":"${flavor_name}","sec_group":"${sec_group}","install_script_version":"${install_script_version}","demo_artifacts_version":"${demo_artifacts_version}","cloud_env":"${cloud_env}","public_net_id":"${public_net_id}","aic-cloud-region":"${aic-cloud-region}"}],"vfModules":[{"modelInfo":{"modelName":"${vnf-vfmodule-0-modelinfo-modelname}","modelVersionId":"${vnf-vfmodule-0-modelinfo-modeluuid}","modelInvariantUuid":"${vnf-vfmodule-0-modelinfo-modelinvariantuuid}","modelVersion":"1","modelCustomizationId":"${vnf-vfmodule-0-modelinfo-modelcustomizationuuid}"},"instanceName":"${vnf-vfmodule-0-modelinfo-modelname}","instanceParams":[{"sec_group":"${sec_group}","public_net_id":"olc-net"}]},{"modelInfo":{"modelName":"${vnf-vfmodule-1-modelinfo-modelname}","modelVersionId":"${vnf-vfmodule-1-modelinfo-modeluuid}","modelInvariantUuid":"${vnf-vfmodule-1-modelinfo-modelinvariantuuid}","modelVersion":"1","modelCustomizationId":"${vnf-vfmodule-1-modelinfo-modelcustomizationuuid}"},"instanceName":"${vnf-vfmodule-1-modelinfo-modelname}","instanceParams":[{"sec_group":"${sec_group}","public_net_id":"olc-net"}]},{"modelInfo":{"modelName":"${vnf-vfmodule-2-modelinfo-modelname}","modelVersionId":"${vnf-vfmodule-2-modelinfo-modeluuid}","modelInvariantUuid":"${vnf-vfmodule-2-modelinfo-modelinvariantuuid}","modelVersion":"1","modelCustomizationId":"${vnf-vfmodule-2-modelinfo-modelcustomizationuuid}"},"instanceName":"${vnf-vfmodule-2-modelinfo-modelname}","instanceParams":[{"sec_group":"${sec_group}","public_net_id":"olc-net"}]},{"modelInfo":{"modelName":"${vnf-vfmodule-3-modelinfo-modelname}","modelVersionId":"${vnf-vfmodule-3-modelinfo-modeluuid}","modelInvariantUuid":"${vnf-vfmodule-3-modelinfo-modelinvariantuuid}","modelVersion":"1","modelCustomizationId":"${vnf-vfmodule-3-modelinfo-modelcustomizationuuid}"},"instanceName":"${vnf-vfmodule-3-modelinfo-modelname}","instanceParams":[{"sec_group":"${sec_group}","public_net_id":"olc-net"}]}]}]},"modelInfo":{"modelVersion":"1.0","modelVersionId":"${service-uuid}","modelInvariantId":"${service-invariantUUID}","modelName":"${service-name}","modelType":"service"}}}],"aLaCarte":false},"project":{"projectName":"Project-Demonstration"},"owningEntity":{"owningEntityId":"67f2e84c-734d-4e90-a1e4-d2ffa2e75849","owningEntityName":"OE-Demonstration"},"modelInfo":{"modelVersion":"1.0","modelVersionId":"${service-uuid}","modelInvariantId":"${service-invariantUUID}","modelName":"${service-name}","modelType":"service"}}}  headers=${headers}          #not possible to make Get URL as variable containing another variable 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  202    
       
    Set Test Variable  ${cds-requestid}  ${resp.json()['requestReferences']['requestId']}
    Set Test Variable  ${cds-instanceid}  ${resp.json()['requestReferences']['instanceId']}    

    Log To Console   \nService Instance Name: ${cds-instance-name}\nService Instance ID: ${cds-instanceid}\nRequest ID: ${cds-requestid}

    Sleep  2
       
Check Infra Active Requests
    [Arguments]  ${SO_REQUESTDB_URL}  ${SO_REQUESTDB_PATH}  ${cds-requestid}  
    
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
    Sleep  2
    
    
