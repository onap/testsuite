*** Settings ***
Documentation	  SO Cloud Config Test Cases
Test Timeout    1 minute


Resource          ../resources/so/create_cloud_config.robot


*** Test Cases ***
Create Cloud Config Test
    [TAGS]    mso    cloudconfig
    Run Create Cloud Configuration    Dallas   DFW   DFW   RAX_KEYSTONE   https://identity.api.rackspacecloud.com/v2.0    RACKSPACE_ACCOUNT_ID    RACKSPACE_ACCOUNT_APIKEY    service    admin    KEYSTONE    RACKSPACE_APIKEY