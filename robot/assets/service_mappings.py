'''
This metadata identifies the folders to be zipped and uploaded to SDC for model distribution for a given VNF 
'''
GLOBAL_SERVICE_FOLDER_MAPPING = {"vFW" : ['base_vfw'], \
                                 "vLB" : ['base_vlb'], \
                                 "vVG" : ['base_vvg'], \
                                 "vIMS" : ['base_clearwater'], \
                                 }

'''
This metadata identifes the preloads that need to be done for a VNF as there may be more than one (vLB)
"template" maps to the key value in the preload_paramenters.py  - GLOBAL_PRELOAD_PARAMETERS[<testcase>][<template>] -
    GLOBAL_PRELOAD_PARAMETERS['Demo'][dnsscaling_preload.template']
It no longer refers to a template file as all have been collapsed into preload.template
'''                                 
GLOBAL_SERVICE_TEMPLATE_MAPPING = {"vFW" : [{"isBase" : "true", "template" : "vfw_preload.template", "name_pattern": "base_vfw"}], \
                                 "vLB" : [{"isBase" : "true", "template" : "vlb_preload.template", "name_pattern": "base_vlb"},
                                          {"isBase" : "false", "template" : "dnsscaling_preload.template", "name_pattern": "dnsscaling", "prefix" : "vDNS_"}],
                                 "vVG" : [{"isBase" : "true", "template" : "vvg_preload.template", "name_pattern": "base_vvg"}], \
                                 "vIMS" : [{"isBase" : "true", "template" : "vims_preload.template", "name_pattern": "base_clearwater"}], \
                                 }

''' 
Used by the Heatbridge Validate Query to A&AI to locate the vserver name
'''
GLOBAL_VALIDATE_NAME_MAPPING = {"vFW" : 'vfw_name_0',
                                 "vLB" : 'vlb_name_0',
                                 "vVG" : '' 
                                 }
