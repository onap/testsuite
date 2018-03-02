*** Settings ***
Documentation     Testing ecomp components are available via calls.
...
...                   Testing ecomp components are available via calls.

Resource          ../resources/msb_interface.robot

*** Test Cases ***
catalog API Health Check
     Run MSB Get Request  /api/catalog/v1/swagger.json

nslcm API Health Check
     Run MSB Get Request  /api/nslcm/v1/swagger.json

resmgr API Health Check
     Run MSB Get Request  /api/resmgr/v1/swagger.json

usecaseui-gui API Health Check
     Run MSB Get Request  /iui/usecaseui/

vnflcm API Health Check
     Run MSB Get Request  /api/vnflcm/v1/swagger.json

vnfmgr API Health Check
     Run MSB Get Request  /api/vnfmgr/v1/swagger.json

vnfres API Health Check
     Run MSB Get Request  /api/vnfres/v1/swagger.json

workflow API Health Check
     Run MSB Get Request  /api/workflow/v1/swagger.json

