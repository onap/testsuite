import json
import os.path


'''
This metadata identifies the folders to be zipped and uploaded to SDC for model distribution for a given VNF
'''
GLOBAL_SERVICE_FOLDER_MAPPING = {"vFW" : ['vFW'], \
                                 "vLB" : ['vLBMS'], \
                                 "vVG" : ['vVG'], \
                                 "vCPE" : ['vCPE/infra', 'vCPE/vbng', 'vCPE/vbrgemu', 'vCPE/vgmux', 'vCPE/vgw'],
                                 "vFWCL" : ['vFWCL/vFWSNK', 'vFWCL/vPKG'],
                                 "vFWNG" : ['vFW_NextGen/templates'],
                                 "vCPEInfra" : ['vCPE/infra'],
                                 "vCPEvBNG" : ['vCPE/vbng'],
                                 "vCPEvBRGEMU" : ['vCPE/vbrgemu'],
                                 "vCPEvGMUX" : ['vCPE/vgmux'],
                                 "vCPEvGW" : ['vCPE/vgw'],
                                 "vCPEResCust" : ['vCPE/vgw'],
                                 }

'''
Map the service to the list of VNFs to be orchestrated
'''
GLOBAL_SERVICE_VNF_MAPPING = {
    "vFW"  : ['vFW'],
    "vLB"  : ['vLB'],
    "vVG"  : ['vVG'],
    "vCPE" : ['vCPE'],
    "vFWCL"  : ['vFWCLvFWSNK', 'vFWCLvPKG'],
    "vFWNG"  : ['vFWNG'],
    "vCPEInfra" : ['vCPEInfra'],
    "vCPEvBNG" : ['vCPEvBNG'],
    "vCPEvBRGEMU" : ['vCPEvBRGEMU'],
    "vCPEvGMUX" : ['vCPEvGMUX'],
    "vCPEvGW" : ['vCPEvGW'],
    "vCPERestCust" : ['vCPEvGW'],
                                 }

'''

Map the service to the list of Generic Neutron Networks to be orchestrated

'''
GLOBAL_SERVICE_GEN_NEUTRON_NETWORK_MAPPING = {
    "vCPEInfra" : ['CPE_SIGNAL','CPE_PUBLIC'],
    "vCPEvBNG" : ['BRG_BNG', 'BNG_MUX'],
    "vCPEvGMUX" : ['MUX_GW'],
    "vCPEvBRGEMU" :[],
    "vCPEvGW" :[],
    "vCPERestCust" :[],
    "vFW" :[],
    "vLB" :[],
    "vVG" :[],
    "vFWCL" :[],
    "vFWNG" :[],
}
'''

Map the service to the list of Deployment Artifacts for Closed Loop Control

'''
GLOBAL_SERVICE_DEPLOYMENT_ARTIFACT_MAPPING = {
    "vCPEInfra" : [],
    "vCPEvBNG" : [],
    "vCPEvGMUX" : [],
    "vCPEvBRGEMU" :[],
    "vCPEvGW" :[],
    "vCPERestCust" :[],
    "vFW" :[],
    "vLB" :['k8s-tca-clamp-policy-05082019.yaml'],
    "vVG" :[],
    "vFWCL" :[],
    "vFWNG" :[],
}
'''



This metadata identifes the preloads that need to be done for a VNF as there may be more than one (vLB)
"template" maps to the parameters in the preload_paramenters.py
  - GLOBAL_PRELOAD_PARAMETERS[<testcase>][<template>] -
    i.e. GLOBAL_PRELOAD_PARAMETERS['Demo'][dnsscaling_preload.template']
'''
GLOBAL_SERVICE_TEMPLATE_MAPPING = {
        "vFW"  : [{"isBase" : "true", "template" : "vfw_preload.template", "vnf_index": "0", "name_pattern": "base_vfw"}],
    "vLB"  : [{"isBase" : "true",   "template" : "vlb_preload.template", "vnf_index": "0", "name_pattern": "base_vlb"},
              {"isBase" : "false",  "template" : "dnsscaling_preload.template", "vnf_index": "1", "name_pattern": "dnsscaling", "prefix" : "vDNS_"}],
    "vVG"  : [{"isBase" : "true",   "template" : "vvg_preload.template", "vnf_index": "0", "name_pattern": "base_vvg"}],
    "vCPE" : [{"isBase" : "true",  "template" : "vcpe_preload.template", "vnf_index": "0", "name_pattern": "base_clearwater"}],
    "vFWSNK" : [{"isBase" : "true",   "template" : "vfwsnk_preload.template", "vnf_index": "0", "name_pattern": "base_vfw"}],
    "vPKG"   : [{"isBase" : "true",  "template" : "vpkg_preload.template", "vnf_index": "0", "name_pattern": "base_vpkg"}],
    "vFWCL"   : [{"isBase" : "true",   "template" : "vfwsnk_preload.template", "vnf_index": "0", "name_pattern": "base_vfw"},
                 {"isBase" : "true",  "template" : "vpkg_preload.template", "vnf_index": "1", "name_pattern": "base_vpkg"}],
    "vFWCLvFWSNK"   : [{"isBase" : "true",   "template" : "vfwsnk_preload.template", "vnf_index": "0", "name_pattern": "base_vfw"}],
    "vFWCLvPKG"   : [{"isBase" : "true",  "template" : "vpkg_preload.template", "vnf_index": "1" , "name_pattern": "base_vpkg"}],
    "vCPEInfra" : [{"isBase" : "true",  "template" : "vcpe_infra_preload.template", "vnf_index": "0", "name_pattern": "base_infra"}],
    "vCPEvBNG" : [{"isBase" : "true",  "template" : "vcpe_vbng_preload.template", "vnf_index": "0", "name_pattern": "base_vbng"}],
    "vCPEvBRGEMU" : [{"isBase" : "true",  "template" : "vcpe_vbrgemu_preload.template", "vnf_index": "0", "name_pattern": "base_vbrgemu"}],
    "vCPEvGMUX" : [{"isBase" : "true",  "template" : "vcpe_vgmux_preload.template", "vnf_index": "0", "name_pattern": "base_vgmux"}],
    "vCPEvGW" : [{"isBase" : "true",  "template" : "vcpe_vgw_preload.template", "vnf_index": "0", "name_pattern": "base_vgw"}],
    "vCPEResCust" : [{"isBase" : "true",  "template" : "vcpe_vgw_preload.template", "vnf_index": "0", "name_pattern": "base_vgw"}],
}

'''
Used by the Heatbridge Validate Query to A&AI to locate the vserver name
'''
GLOBAL_VALIDATE_NAME_MAPPING = {"vFW" : 'vfw_name_0',
                                 "vLB" : 'vlb_name_0',
                                 "vVG" : '',
                                 "vCPE" : 'vgw_name_0',
                                 "vCPEvGW" : 'vgw_name_0',
                                 "vCPEResCust" : 'vgw_name_0',
                                 "vCPEvDNS" : 'vdns_name_0',
                                 "vCPEvAAA" : 'vaaa_name_0',
                                 "vCPEvWEB" : 'vweb_name_0',
                                 "vCPEvDHCP" : 'vdhcp_name_0',
                                 "vCPEvGMUX" : 'vgmux_name_0',
                                 "vFWSNK" : 'vfw_name_0',
                                 "vPKG" : 'vpg_name_0',
                                 "vFWCLvFWSNK" : 'vfw_name_0',
                                 "vFWCLvPKG" : 'vpg_name_0',
                                 "vDNS" : 'vdns_name_0'
                                 }



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
