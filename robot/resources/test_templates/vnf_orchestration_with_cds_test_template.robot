*** Settings ***
Documentation	  This test template encapsulates the VNF Orchestration use case.

Resource        ../vid/create_service_instance.robot
Resource        ../vid/vid_interface.robot
Resource        ../aai/service_instance.robot
Resource        ../vid/create_vid_vnf.robot
Resource        ../vid/teardown_vid.robot
Resource        ../sdngc_interface.robot
Resource        model_test_template.robot

Resource        ../aai/create_zone.robot
Resource        ../aai/create_customer.robot
Resource        ../aai/create_complex.robot
Resource        ../aai/create_tenant.robot
Resource        ../aai/create_service.robot
Resource        ../openstack/neutron_interface.robot
Resource        ../heatbridge.robot

Resource    	../global_properties.robot
Resource    	../so_interface.robot

Library         ONAPLibrary.Openstack
Library	        ONAPLibrary.Utilities
Library	        ONAPLibrary.Templating    WITH NAME    Templating
Library	        Collections
Library         String
Library         ONAPLibrary.JSON

Library         RequestsLibrary
Library         Collections

*** Variables ***
${service_template}    robot/assets/cds/service-Vfirewall0911-template.yml
${env}      robot/assets/cds/env.yml
${so_request_template}    so/cds_request.jinja    
${vnf_template_name} 	so/cds_vnf.jinja
${vfmodule_template_name} 	so/cds_vfmodule.jinja
${so_uri_path}		/onap/so/infra/serviceInstantiation/v7/serviceInstances

*** Keywords ***
Orchestrate VNF With CDS Template
    [Documentation]   Use openECOMP to Orchestrate a service.
    [Arguments]    ${customer_name}    ${service_instance_name}    ${product_family}
    ${uuid}=    Generate UUID4
    Orchestrate VNF With CDS	${customer_name}_${uuid}    ${service_instance_name}${uuid}    ${product_family}

Orchestrate VNF With CDS
    [Documentation]   Use openECOMP to Orchestrate a service.
    [Arguments]    ${customer_name}    ${service_instance_name}    ${product_family}    ${project_name}=Project-Demonstration   ${owning_entity}=OE-Demonstration
    ${lcp_region}=   Get Openstack Region
    ${dict}=  Create Dictionary
    Set To Dictionary	${dict}	  service_instance_name=${service_instance_name}

    ${templatedata}=    Template Yaml To Json    ${service_template}
    ${jsondata}=     Evaluate     json.loads('''${templatedata}''')      json
    Set To Dictionary   ${dict}   service_type=${jsondata['metadata']['type']}
    Set To Dictionary   ${dict}   service_model_name=${jsondata['metadata']['name']}
    Set To Dictionary   ${dict}   service_model_UUID=${jsondata['metadata']['UUID']}
    Set To Dictionary   ${dict}   service_model_invariantUUID=${jsondata['metadata']['invariantUUID']}
    
    ${envdata}=    Env Yaml To Json    ${env}
    ${envjson}=    Evaluate     json.loads('''${envdata}''')      json
    Set To Dictionary   ${dict}   subscriber_id=${envjson['subscriber_id']}
    Set To Dictionary	${dict}	  subscription_service_type=${envjson['subscription_service_type']}
    Set To Dictionary   ${dict}   cloud_region=${envjson['cloud_region']}
    Set To Dictionary   ${dict}   tenant_id=${envjson['tenant_id']}

    ${vnfs}=   Get From Dictionary    ${jsondata['topology_template']}   node_templates
    ${keys}=   Get Dictionary Keys    ${vnfs}
    Templating.Create Environment    cds    ${GLOBAL_TEMPLATE_FOLDER}
    :FOR   ${key}  IN  @{keys}
    \	 ${vnf}=   Get From Dictionary	  ${vnfs}   ${key}
    \    Get VNF Info	${key} 	${vnf}	${dict}
    \	 ${vf_modules}=    Get From Dictionary   ${jsondata['topology_template']}    groups
    \    ${value}= 	Evaluate 	"${key}".replace("-","").replace(" ","")
    \    ${value}= 	Convert To Lowercase 	${value}
    \    ${vfmodules}=	Get VFModule Info	 ${jsondata}	${value}	  ${dict}
    \	 Set To Dictionary	${dict}	  vf_modules=${vfmodules}
    \    ${vnf_payload}=   Templating.Apply Template    cds		${vnf_template_name}		${dict}
    \	 ${data}= 	Catenate	[${vnf_payload}]
   
    Set To Dictionary 		${dict}		vnfs=${data}
    ${request}=     Templating.Apply Template    cds    ${so_request_template}    ${dict}
    Log     --------request--------
    Log     ${request}
    Log     --------end request--------
    ${resp}=	Run MSO Post Request	${so_uri_path}		${request}
    Log 	--------response-------
    ${json_string}=    Evaluate    json.dumps(${resp.json()})    json
    Log	${json_string}
    Log    instanceId=${resp.json()['requestReferences']['instanceId']}
    ${requestId}=    Catenate    ${resp.json()['requestReferences']['requestId']}
    Log    requestId=${requestId}
    Log	-------end response-------
    # Poll MSO Get Request    ${GLOBAL_MSO_STATUS_PATH}${request_id}   COMPLETE


Get VNF Info
    [Documentation] 	Get VNF Info
    [Arguments] 	${vnf_name} 	${vnfjson}	${dict}
    ${metadata}= 	Get From Dictionary	${vnfjson}	metadata
    Set To Dictionary	${dict}	  vnf_name=${vnf_name}
    Set To Dictionary   ${dict}	  vnf_model_name=${metadata['name']}
    Set To Dictionary   ${dict}	  vnf_model_version_id=${metadata['UUID']}
    Set To Dictionary   ${dict}	  vnf_model_customization_name=${metadata['name']}
    Set To Dictionary   ${dict}	  vnf_model_customization_id=${metadata['customizationUUID']}
	

Get VFModule Info
    [Documentation]   Dig the vf module names from the VID service model
    [Arguments]   ${jsondata}	${vnf}   ${dict}
    ${vfModules}=   Get From Dictionary    ${jsondata['topology_template']}   groups
    ${keys}=   Get Dictionary Keys    ${vfModules}
    ${data}=   Catenate
    ${delim}=   Catenate
    Templating.Create Environment    cds    ${GLOBAL_TEMPLATE_FOLDER}
    :FOR   ${key}  IN  @{keys}
    \    ${module}=   Get From Dictionary    ${vfModules}   ${key}
    \    Log 	${vnf} ${key}
    \    Run keyword if 	"${vnf}" in "${key}"	set vfmodule param	${key}	  ${module}	${dict}
    \    ${vfmodule_payload}= 	Templating.Apply Template		cds    ${vfmodule_template_name}		${dict}
    \	 ${data}= 	Catenate    ${data}   ${delim}   ${vfmodule_payload}
    \	 ${delim}= 	Catenate	,
    Log 	${data}
    [Return] 	${data}

set vfmodule param
    [Documentation]    Set vfmodule parameters
    [Arguments]		${vfmodule_name}   ${vfmodule}	${dict}
    Set To Dictionary   ${dict}   vf_module_model_type=${vfmodule['type']}
    Set To Dictionary   ${dict}	  vf_module_model_name=${vfmodule['metadata']['vfModuleModelName']}
    Set To Dictionary   ${dict}	  vf_module_model_version_id=${vfmodule['metadata']['vfModuleModelUUID']}
    Set To Dictionary 	${dict}	  vf_module_model_customization_id=${vfmodule['metadata']['vfModuleModelCustomizationUUID']}
    Set To Dictionary   ${dict}   vf_module_name=${vfmodule_name}

