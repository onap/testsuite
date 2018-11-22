'''
This metadata identifies the folders to be zipped and uploaded to SDC for model distribution for a given VNF
'''
GLOBAL_SERVICE_FOLDER_MAPPING = {"vFW" : ['vFW'], \
                                 "vLB" : ['vLB'], \
                                 "vVG" : ['vVG'], \
                                 "vCPE" : ['vCPE/infra', 'vCPE/vbng', 'vCPE/vbrgemu', 'vCPE/vgmux', 'vCPE/vgw'],
                                 "vFWCL" : ['vFWCL/vFWSNK', 'vFWCL/vPKG'],
                                 "vFWNG" : ['vFW_NextGen/templates'],
                                 "vCPEInfra" : ['vCPE/infra'],
                                 "vCPEvBNG" : ['vCPE/vbng'],
                                 "vCPEvBRGEMU" : ['vCPE/vbrgemu'],
                                 "vCPEvGMUX" : ['vCPE/vgmux'],
                                 "vCPEvGW" : ['vCPE/vgw'],
                                 }

'''
Map the service to the list of VNFs to be orchestrated
'''
GLOBAL_SERVICE_VNF_MAPPING = {
    "vFW"  : ['vFW'],
    "vLB"  : ['vLB'],
    "vVG"  : ['vVG'],
    "vCPE" : ['vCPE'],
    "vFWCL"  : ['vFWSNK', 'vPKG'],
    "vFWNG"  : ['vFWNG'],
    "vCPEInfra" : ['vCPEInfra'],
    "vCPEvBNG" : ['vCPEvBNG'],
    "vCPEvBRGEMU" : ['vCPEvBRGEMU'],
    "vCPEvGMUX" : ['vCPEvGMUX'],
    "vCPEvGW" : ['vCPEvGW'],
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
    "vFW" :[],
    "vLB" :[],
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
	"vFW"  : [{"isBase" : "true", "template" : "vfw_preload.template", "name_pattern": "base_vfw"}],
    "vLB"  : [{"isBase" : "true",   "template" : "vlb_preload.template", "name_pattern": "base_vlb"},
              {"isBase" : "false",  "template" : "dnsscaling_preload.template", "name_pattern": "dnsscaling", "prefix" : "vDNS_"}],
    "vVG"  : [{"isBase" : "true",   "template" : "vvg_preload.template", "name_pattern": "base_vvg"}],
    "vCPE" : [{"isBase" : "true",  "template" : "vcpe_preload.template", "name_pattern": "base_clearwater"}],
    "vFWSNK" : [{"isBase" : "true",   "template" : "vfwsnk_preload.template", "name_pattern": "base_vfw"}],
    "vPKG"   : [{"isBase" : "true",  "template" : "vpkg_preload.template", "name_pattern": "base_vpkg"}],
    "vFWCL"   : [{"isBase" : "true",   "template" : "vfwsnk_preload.template", "name_pattern": "base_vfw"},
                 {"isBase" : "true",  "template" : "vpkg_preload.template", "name_pattern": "base_vpkg"}],
    "vCPEInfra" : [{"isBase" : "true",  "template" : "vcpe_infra_preload.template", "name_pattern": "base_infra"}],
    "vCPEvBNG" : [{"isBase" : "true",  "template" : "vcpe_vbng_preload.template", "name_pattern": "base_vbng"}],
    "vCPEvBRGEMU" : [{"isBase" : "true",  "template" : "vcpe_vbrgemu_preload.template", "name_pattern": "base_vbrgemu"}],
    "vCPEvGMUX" : [{"isBase" : "true",  "template" : "vcpe_vgmux_preload.template", "name_pattern": "base_vgmux"}],
    "vCPEvGW" : [{"isBase" : "true",  "template" : "vcpe_vgw_preload.template", "name_pattern": "base_vgw"}],
}

'''
Used by the Heatbridge Validate Query to A&AI to locate the vserver name
'''
GLOBAL_VALIDATE_NAME_MAPPING = {"vFW" : 'vfw_name_0',
                                 "vLB" : 'vlb_name_0',
                                 "vVG" : '',
                                 "vCPE" : 'vgw_name_0',
                                 "vCPEvGW" : 'vgw_name_0',
                                 "vCPEvDNS" : 'vdns_name_0',
                                 "vCPEvAAA" : 'vaaa_name_0',
                                 "vCPEvWEB" : 'vweb_name_0',
                                 "vCPEvDHCP" : 'vdhcp_name_0',
                                 "vCPEvGMUX" : 'vgmux_name_0',
                                 "vFWSNK" : 'vfw_name_0',
                                 "vPKG" : 'vpg_name_0',
                                 }

