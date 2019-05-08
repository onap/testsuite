import json
import os.path


'''
This metadata identifies the folders to be zipped and uploaded to SDC for model distribution for a given VNF
'''
GLOBAL_SERVICE_FOLDER_MAPPING = {}

'''
Map the service to the list of VNFs to be orchestrated
'''
GLOBAL_SERVICE_VNF_MAPPING = {}

'''
Map the service to the list of Generic Neutron Networks to be orchestrated
'''
GLOBAL_SERVICE_GEN_NEUTRON_NETWORK_MAPPING = {}

'''
Map the service to the list of Deployment Artifacts for Closed Loop Control
'''
GLOBAL_SERVICE_DEPLOYMENT_ARTIFACT_MAPPING = {}

'''
This metadata identifes the preloads that need to be done for a VNF as there may be more than one (vLB)
"template" maps to the parameters in the preload_paramenters.py
  - GLOBAL_PRELOAD_PARAMETERS[<testcase>][<template>] -
    i.e. GLOBAL_PRELOAD_PARAMETERS['Demo'][dnsscaling_preload.template']
'''
GLOBAL_SERVICE_TEMPLATE_MAPPING = {}

'''
Used by the Heatbridge Validate Query to A&AI to locate the vserver name
'''
GLOBAL_VALIDATE_NAME_MAPPING = {}

# Create dictionaries for new MAPPING data to join to original MAPPING data
GLOBAL_SERVICE_FOLDER_MAPPING2 = {}
GLOBAL_SERVICE_VNF_MAPPING2 = {}
GLOBAL_SERVICE_GEN_NEUTRON_NETWORK_MAPPING2 = {}
GLOBAL_SERVICE_DEPLOYMENT_ARTIFACT_MAPPING2 = {}
GLOBAL_SERVICE_TEMPLATE_MAPPING2 = {}
GLOBAL_VALIDATE_NAME_MAPPING2 = {} 



folder=os.path.join('./demo/service_mapping')
subfolders = [d for d in os.listdir(folder) if os.path.isdir(os.path.join(folder, d))]

for service in subfolders:
    filepath=os.path.join('./demo/service_mapping', service, 'service_mapping.json')
    with open(filepath, 'r') as f:
        service_mappings = json.load(f)
    for mapping in service_mappings:
        if mapping == 'GLOBAL_SERVICE_FOLDER_MAPPING':
           GLOBAL_SERVICE_FOLDER_MAPPING2[service]=service_mappings[mapping][service]
        if mapping == 'GLOBAL_SERVICE_VNF_MAPPING':
           GLOBAL_SERVICE_VNF_MAPPING2[service]=service_mappings[mapping][service]
        if mapping == 'GLOBAL_SERVICE_GEN_NEUTRON_NETWORK_MAPPING':
           GLOBAL_SERVICE_GEN_NEUTRON_NETWORK_MAPPING2[service]=service_mappings[mapping][service]
        if mapping == 'GLOBAL_SERVICE_DEPLOYMENT_ARTIFACT_MAPPING':
           GLOBAL_SERVICE_DEPLOYMENT_ARTIFACT_MAPPING2[service]=service_mappings[mapping][service]
        if mapping == 'GLOBAL_SERVICE_TEMPLATE_MAPPING':
        #  service changes for complex vnf
           #GLOBAL_SERVICE_TEMPLATE_MAPPING2[service]=service_mappings[mapping][service]
           for vnftype   in service_mappings[mapping]:
               GLOBAL_SERVICE_TEMPLATE_MAPPING2[vnftype]=service_mappings[mapping][vnftype]
        if mapping == 'GLOBAL_VALIDATE_NAME_MAPPING':
        #  service changes for complex vnf
           #GLOBAL_VALIDATE_NAME_MAPPING2[service]=service_mappings[mapping][service]
           for vnftype   in service_mappings[mapping]:
               GLOBAL_VALIDATE_NAME_MAPPING2[vnftype]=service_mappings[mapping][vnftype]

# Merge dictionaries
GLOBAL_SERVICE_FOLDER_MAPPING =  dict(GLOBAL_SERVICE_FOLDER_MAPPING.items() + GLOBAL_SERVICE_FOLDER_MAPPING2.items())
GLOBAL_SERVICE_VNF_MAPPING =  dict(GLOBAL_SERVICE_VNF_MAPPING.items() + GLOBAL_SERVICE_VNF_MAPPING2.items())
GLOBAL_SERVICE_GEN_NEUTRON_NETWORK_MAPPING =  dict(GLOBAL_SERVICE_GEN_NEUTRON_NETWORK_MAPPING.items() + GLOBAL_SERVICE_GEN_NEUTRON_NETWORK_MAPPING2.items())   
GLOBAL_SERVICE_DEPLOYMENT_ARTIFACT_MAPPING =  dict(GLOBAL_SERVICE_DEPLOYMENT_ARTIFACT_MAPPING.items() + GLOBAL_SERVICE_DEPLOYMENT_ARTIFACT_MAPPING2.items()) 
GLOBAL_SERVICE_TEMPLATE_MAPPING =  dict(GLOBAL_SERVICE_TEMPLATE_MAPPING.items() + GLOBAL_SERVICE_TEMPLATE_MAPPING2.items()) 
GLOBAL_VALIDATE_NAME_MAPPING =  dict(GLOBAL_VALIDATE_NAME_MAPPING.items() + GLOBAL_VALIDATE_NAME_MAPPING2.items()) 
