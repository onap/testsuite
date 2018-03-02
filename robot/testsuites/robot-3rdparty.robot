*** Settings ***
Documentation     Testing ecomp components are available via calls.
...
...                   Testing ecomp components are available via calls.

Resource          ../resources/msb_interface.robot

*** Test Cases ***
emsdriver API Health Check
     Run MSB Get Request  /api/emsdriver/v1/swagger.json

gvnfmdriver API Health Check
     Run MSB Get Request  /api/gvnfmdriver/v1/swagger.json

huaweivnfmdriver API Health Check
     Run MSB Get Request  /api/huaweivnfmdriver/v1/swagger.json

ztesdncdriver API Health Check
     Run MSB Get Request  /api/ztesdncdriver/v1/swagger.json

ztevmanagerdriver API Health Check
     Run MSB Get Request  /api/ztevmanagerdriver/v1/swagger.json
