*** Settings ***
Documentation        store all properties that can change or are used in multiple places here
...                    format is all caps with underscores between words and prepended with AAI
...                   make sure you prepend them with AAI so that other files can easily see it is from this file.


*** Variables ***
${AAI_UNSUPPORTED_INDEX_PATH}=  /aai/v1
${AAI_AMSTERDAM_INDEX_PATH}=    /aai/v11
${AAI_BEIJING_INDEX_PATH}=      /aai/v13
${AAI_CASABLANCA_INDEX_PATH}=   /aai/v14
${AAI_DUBLIN_INDEX_PATH}=       /aai/v16

${AAI_CLOUDINFRA_PATH}=    /cloud-infrastructure
${AAI_EXTERNALSYS_PATH}=   /external-system
${AAI_BUSINESS_PATH}=      /business
${AAI_SDAC_PATH}=          /service-design-and-creation
${AAI_NETWORK_PATH}=       /network
${AAI_COMMON_PATH}=        /common

${AAI_NODES_PATH}=      /nodes
${AAI_EXAMPLES_PATH}=   /examples

