*** Settings ***
#Library    REST     ssl_verify=False
Library    RequestsLibrary
#Library    HttpLibrary
#Resource  variables.robot 
Library  String  
Resource         ../resources/test_templates/vnf_orchestration_with_cds_test_template.robot
Resource         ../resources/demo_preload.robot
Resource         ../resources/cds_interface.robot
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
    
	
	
