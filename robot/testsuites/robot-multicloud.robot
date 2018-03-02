*** Settings ***
Documentation     Testing ecomp components are available via calls.
...
...                   Testing ecomp components are available via calls.

Resource          ../resources/msb_interface.robot

*** Test Cases ***
multicloud API Health Check
     Run MSB Get Request  /api/multicloud/v0/swagger.json

multicloud-ocata API Health Check
     Run MSB Get Request  /api/multicloud-ocata/v0/swagger.json

multicloud-titanium_cloud API Health Check
     Run MSB Get Request  /api/multicloud-titanium_cloud/v0/swagger.json

multicloud-vio API Health Check
     Run MSB Get Request  /api/multicloud-vio/v0/swagger.json
