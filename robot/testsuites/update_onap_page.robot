*** Settings ***
Documentation	  Initializes ONAP Test Web Page and Password

Library    Collections
Library    OperatingSystem
Library    ONAPLibrary.Templating
Resource          ../resources/openstack/keystone_interface.robot
Resource          ../resources/openstack/nova_interface.robot


Test Timeout    5 minutes

*** Variables ***
${URLS_HTML_TEMPLATE}   index.html.jinja

${HOSTS_PREFIX}   vm
${WEB_USER}       test
${WEB_PASSWORD}

${URLS_HTML}   html/index.html
${CREDENTIALS_FILE}   /etc/lighttpd/authorization
#${CREDENTIALS_FILE}   authorization

*** Test Cases ***
Update ONAP Page
    [Tags]   UpdateWebPage
    Run Keyword If   '${WEB_PASSWORD}' == ''   Fail   "WEB Password must not be empty"
    Run Openstack Auth Request    auth
    ${server_map}=    Get Openstack Servers    auth
    ${oam_ip_map}=   Create Dictionary
    Set To Dictionary    ${oam_ip_map}   10.0.0.1=onapdns
    Set To Dictionary    ${oam_ip_map}   ${GLOBAL_INJECTED_AAI1_IP_ADDR}=aai1
    Set To Dictionary    ${oam_ip_map}   ${GLOBAL_INJECTED_AAI2_IP_ADDR}=aai2
    Set To Dictionary    ${oam_ip_map}   ${GLOBAL_INJECTED_APPC_IP_ADDR}=appc
    Set To Dictionary    ${oam_ip_map}   ${GLOBAL_INJECTED_DCAE_IP_ADDR}=dcae_controller
    Set To Dictionary    ${oam_ip_map}   ${GLOBAL_INJECTED_SO_IP_ADDR}=mso
    Set To Dictionary    ${oam_ip_map}   ${GLOBAL_INJECTED_MR_IP_ADDR}=message_router
    Set To Dictionary    ${oam_ip_map}   ${GLOBAL_INJECTED_BC_IP_ADDR}=bus_controller
    Set To Dictionary    ${oam_ip_map}   ${GLOBAL_INJECTED_POLICY_IP_ADDR}=policy
    Set To Dictionary    ${oam_ip_map}   ${GLOBAL_INJECTED_PORTAL_IP_ADDR}=portal
    Set To Dictionary    ${oam_ip_map}   ${GLOBAL_INJECTED_SDC_IP_ADDR}=sdc
    Set To Dictionary    ${oam_ip_map}   ${GLOBAL_INJECTED_SDNC_IP_ADDR}=sdnc
    Set To Dictionary    ${oam_ip_map}   ${GLOBAL_INJECTED_MSB_IP_ADDR}=openo
    Set To Dictionary    ${oam_ip_map}   ${GLOBAL_INJECTED_CLAMP_IP_ADDR}=clamp
    Set To Dictionary    ${oam_ip_map}   ${GLOBAL_INJECTED_VID_IP_ADDR}=vid
    Set To Dictionary    ${oam_ip_map}   10.0.4.105=dcae_cdap
    Set To Dictionary    ${oam_ip_map}   10.0.4.102=dcae_coll
    Set To Dictionary    ${oam_ip_map}   10.0.10.1=robot

    ${values}=   Create Dictionary
    ${keys}=    Get Dictionary Keys    ${oam_ip_map}
    :FOR   ${oam_ip}   IN    @{keys}
    \    ${value_name}=   Get From Dictionary    ${oam_ip_map}   ${oam_ip}
    \    Set Public Ip    ${server_map}    ${oam_ip}   ${value_name}   ${values}
    Log    ${values}
    Run Keyword If   '${WEB_PASSWORD}' != ''   Create File   ${CREDENTIALS_FILE}   ${WEB_USER}:${WEB_PASSWORD}
    Set To Dictionary    ${values}   GLOBAL_INJECTED_ARTIFACTS_VERSION=${GLOBAL_INJECTED_ARTIFACTS_VERSION}
    Set To Dictionary    ${values}   GLOBAL_INJECTED_NETWORK=${GLOBAL_INJECTED_NETWORK}
    Set To Dictionary    ${values}   GLOBAL_INJECTED_NEXUS_DOCKER_REPO=${GLOBAL_INJECTED_NEXUS_DOCKER_REPO}
    Set To Dictionary    ${values}   GLOBAL_INJECTED_OPENSTACK_TENANT_ID=${GLOBAL_INJECTED_OPENSTACK_TENANT_ID}
    Set To Dictionary    ${values}   GLOBAL_INJECTED_REGION=${GLOBAL_INJECTED_REGION}
    Set To Dictionary    ${values}   GLOBAL_INJECTED_KEYSTONE=${GLOBAL_INJECTED_KEYSTONE}
    Set To Dictionary    ${values}   GLOBAL_INJECTED_VM_FLAVOR=${GLOBAL_INJECTED_VM_FLAVOR}
    Set To Dictionary    ${values}   GLOBAL_INJECTED_VM_IMAGE_NAME=${GLOBAL_INJECTED_VM_IMAGE_NAME}
    Set To Dictionary    ${values}   GLOBAL_INJECTED_PUBLIC_NET_ID=${GLOBAL_INJECTED_PUBLIC_NET_ID}
    Set To Dictionary    ${values}   prefix=${HOSTS_PREFIX}
    Create File From Template   ${URLS_HTML_TEMPLATE}   ${URLS_HTML}   ${values}

*** Keywords ***
Create File From Template
    [Arguments]    ${template}   ${file}   ${values}
    Create Environment    web    ${GLOBAL_TEMPLATE_FOLDER}
    ${data}=   Apply Template    web   ${template}    ${values}
    Create File     ${file}   ${data}

Set Public Ip
    [Arguments]   ${server_map}    ${oam_ip}   ${value_name}   ${values}
    ${status}   ${public_ip}=   Run Keyword And Ignore Error  Get Public Ip   ${server_map}    ${oam_ip}
    ${public_ip}=   Set Variable If   '${status}' == 'PASS'   ${public_ip}   ${oam_ip}
    Set To Dictionary   ${values}   ${value_name}   ${public_ip}

Get Public Ip
    [Arguments]   ${server_map}    ${oam_ip}
    ${servers}   Get Dictionary Values    ${server_map}
    :FOR   ${server}   IN   @{servers}
    \    ${status}   ${public_ip}   Run Keyword And Ignore Error   Search Addresses   ${server}   ${oam_ip}
    \    Return From Keyword If   '${status}'=='PASS'   ${public_ip}
    Fail  ${oam_ip} Server Not Found

Search Addresses
    [Arguments]   ${server}   ${oam_ip}
    ${addresses}   Get From Dictionary   ${server}   addresses
    ${status}   ${public_ip}=   Run Keyword And Ignore Error   Find Rackspace   ${addresses}   ${oam_ip}
    Return From Keyword If   '${status}'=='PASS'   ${public_ip}
    ${status}   ${public_ip}=   Run Keyword And Ignore Error   Find Openstack   ${addresses}   ${oam_ip}
    Return From Keyword If   '${status}'=='PASS'   ${public_ip}
    ${status}   ${public_ip}=   Run Keyword And Ignore Error   Find Openstack 2   ${addresses}   ${oam_ip}
    Return From Keyword If   '${status}'=='PASS'   ${public_ip}
    Fail  ${oam_ip} Server Not Found

Find Rackspace
    [Arguments]   ${addresses}   ${oam_ip}
    ${public_ips}   Get From Dictionary   ${addresses}   public
    ${public_ip}=   Get V4 IP   ${public_ips}
    ${oam_ips}   Get From Dictionary   ${addresses}   ${GLOBAL_INJECTED_NETWORK}
    ${this_oam_ip}=   Get V4 IP   ${oam_ips}
    Return From Keyword If   '${this_oam_ip}' == '${oam_ip}'   ${public_ip}
    Fail  ${oam_ip} Server Not Found

Find Openstack
    [Arguments]   ${addresses}   ${oam_ip}
    ${public_ip}=   Get V4 IP Openstack   ${addresses}   external
    ${this_oam_ip}=    Get V4 IP Openstack   ${addresses}   ${GLOBAL_INJECTED_NETWORK}
    Return From Keyword If   '${this_oam_ip}'=='${oam_ip}'   ${public_ip}
    Fail  ${oam_ip} Server Not Found

Find Openstack 2
    [Arguments]   ${addresses}   ${oam_ip}
    ${ipmaps}=   Get From DIctionary   ${addresses}   ${GLOBAL_INJECTED_NETWORK}
    ${public_ip}=   Get V4 IP Openstack 2  ${ipmaps}   floating
    ${this_oam_ip}=    Get V4 IP Openstack 2   ${ipmaps}   fixed
    Return From Keyword If   '${this_oam_ip}'=='${oam_ip}'   ${public_ip}
    Fail  ${oam_ip} Server Not Found

Get V4 IP
    [Arguments]   ${ipmaps}
    :FOR   ${ipmap}   IN   @{ipmaps}
    \    ${ip}   Get From Dictionary   ${ipmap}   addr
    \    ${version}   Get From Dictionary   ${ipmap}   version
    \    Return from Keyword if   '${version}' == '4'   ${ip}
    Fail  No Version 4 IP

Get V4 IP Openstack
    [Arguments]   ${addresses}   ${testtype}
    ${ipmaps}=   Get From Dictionary   ${addresses}   ${testtype}
    :FOR   ${ipmap}   IN   @{ipmaps}
    \    ${ip}   Get From Dictionary   ${ipmap}   addr
    \    ${version}   Get From Dictionary   ${ipmap}   version
    \    Return from Keyword if   '${version}'=='4'   ${ip}
    Fail  No Version 4 IP

Get V4 IP Openstack 2
    [Arguments]   ${ipmaps}   ${testtype}
    :FOR   ${ipmap}   IN   @{ipmaps}
    \    ${type}   Get From Dictionary   ${ipmap}   OS-EXT-IPS:type
    \    ${ip}   Get From Dictionary   ${ipmap}   addr
    \    ${version}   Get From Dictionary   ${ipmap}   version
    \    Return from Keyword if   '${version}'=='4' and '${type}'=='${testtype}'   ${ip}
    Fail  No Version 4 IP