*** Settings ***
Documentation        store all properties that can change or are used in multiple places here
...                    format is all caps with underscores between words and prepended with GLOBAL
...                   make sure you prepend them with GLOBAL so that other files can easily see it is from this file.


*** Variables ***
${GLOBAL_APPLICATION_ID}           robot-ete
${GLOBAL_SO_STATUS_PATH}    /onap/so/infra/orchestrationRequests/v6/
${GLOBAL_SELENIUM_BROWSER}        chrome
${GLOBAL_SELENIUM_BROWSER_CAPABILITIES}        Create Dictionary
${GLOBAL_SELENIUM_DELAY}          0
${GLOBAL_SELENIUM_BROWSER_IMPLICIT_WAIT}        5
${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT}        15
${GLOBAL_OPENSTACK_HEAT_SERVICE_TYPE}    orchestration
${GLOBAL_OPENSTACK_CINDER_SERVICE_TYPE}    volume
${GLOBAL_OPENSTACK_NOVA_SERVICE_TYPE}    compute
${GLOBAL_OPENSTACK_NEUTRON_SERVICE_TYPE}    network
${GLOBAL_OPENSTACK_GLANCE_SERVICE_TYPE}    image
${GLOBAL_OPENSTACK_KEYSTONE_SERVICE_TYPE}    identity
${GLOBAL_OPENSTACK_STACK_DEPLOYMENT_TIMEOUT}    600s
${GLOBAL_AAI_CLOUD_OWNER}    CloudOwner
${GLOBAL_AAI_CLOUD_OWNER_DEFINED_TYPE}    OwnerType
${GLOBAL_AAI_COMPLEX_NAME}    clli1
${GLOBAL_AAI_PHYSICAL_LOCATION_ID}    clli1
${GLOBAL_AAI_AVAILABILITY_ZONE_NAME}    nova
${GLOBAL_BUILD_NUMBER}    0
${GLOBAL_OWNING_ENTITY_NAME}    OE-Demonstration
${GLOBAL_VID_UI_TIMEOUT_SHORT}    20s
${GLOBAL_VID_UI_TIMEOUT_MEDIUM}    60s
${GLOBAL_VID_UI_TIMEOUT_LONG}    120s
${GLOBAL_AAI_INDEX_PATH}    /aai/v14
${GLOBAL_AAI_ZONE_ID}    nova1
${GLOBAL_AAI_ZONE_NAME}    nova
${GLOBAL_AAI_DESIGN_TYPE}    integration
${GLOBAL_AAI_ZONE_CONTEXT}    labs
${GLOBAL_TEMPLATE_FOLDER}    robot/assets/templates
${GLOBAL_ASSETS_FOLDER}    robot/assets
${GLOBAL_SERVICE_MAPPING_DIRECTORY}    ./demo/service_mapping
${GLOBAL_SO_HEALTH_CHECK_PATH}    /manage/health
${GLOBAL_SO_CLOUD_CONFIG_PATH}    /cloudSite
${GLOBAL_SO_CLOUD_CONFIG_TEMPLATE}    so/create_cloud_config.jinja
${GLOBAL_SDC_DCAE_BE_ENDPOINT}    ${GLOBAL_SDC_SERVER_PROTOCOL}://${GLOBAL_INJECTED_SDC_DCAE_BE_IP_ADDR}:${GLOBAL_SDC_DCAE_BE_PORT}
${GLOBAL_SO_ORCHESTRATION_REQUESTS_PATH}       /onap/so/infra/orchestrationRequests/v7
