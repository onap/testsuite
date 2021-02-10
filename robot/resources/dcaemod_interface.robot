*** Settings ***

Library           RequestsLibrary
Library           String

*** Variables ***

${CLIENTID}      robot123


*** Keywords ***


Onboard Component Spec
    [Arguments]  ${alias}  ${headers}
    ${compSpec_resp} =  Post Request  ${alias}  /onboarding/component


Add Registry Client
    [Arguments]  ${alias}  ${headers}
    ${data} =  Set Variable  {"revision": {"version": 0}, "component": {"name": "registry", "uri": "http://dcaemod-nifi-registry:18080"}}
    ${registry_resp} =  Post Request  ${alias}  /nifi-api/controller/registry-clients  data=${data}  headers=${headers}

Add Distribution Target
    [Arguments]  ${alias}  ${headers}
    ${data} =  Set Variable  {"name": "runtime", "runtimeApiUrl": "http://dcaemod-runtime-api:9090"}
    ${distribution_resp} =  Post Request  ${alias}  /distributor/distribution-targets  data=${data}  headers=${headers}


Create Process Group
    [Arguments]  ${alias}  ${headers_1}  ${headers_2}  ${name}

    ${parentGroupId} =  Get ID  processGroupFlow    /nifi-api/flow/process-groups/root/  ${alias}  ${headers_2}
    ${data} =  Set Variable  {"revision": {"clientId": "${CLIENTID}", "version": 0}, "component" : {"parentGroupId" : "${parentGroupId}", "name" : "${name}"}}
    ${processGr_resp} =  Post Request  ${alias}  /nifi-api/process-groups/${parentGroupId}/process-groups  data=${data}  headers=${headers_1}


    ${processGroupId} =  Get ID  component  /nifi-api/flow/process-groups/root/  ${alias}  ${headers_2}

    [Return]  ${processGroupId}

Create Processor
    [Arguments]  ${alias}  ${headers}  ${processGroupId}
    ${data} =  Set Variable  {"revision": {"clientId": "${CLIENTID}", "version": 0},"component": {"parentGroupId": "${processGroupId}", "name": "DcaeDummyAppNginx", "type": "org.onap.dcae.DcaeDummyAppNginx"}}
    ${processGr_resp} =  Post Request  ${alias}  /nifi-api/process-groups/${processGroupId}/processors  data=${data}  headers=${headers}



Create Flow By Version Controlling
    [Arguments]  ${alias}  ${headers_1}  ${headers_2}  ${processGroupId}  ${name}

    ${registryId} =  Get ID  component  /nifi-api/controller/registry-clients  ${alias}  ${headers_2}
    ${bucketId} =  Get ID  bucket  /nifi-api/flow/registries/${registryId}/buckets  ${alias}  ${headers_1}

    ${currentProcessGrVersion} =  Get ID  processGroupRevision  /nifi-api/versions/process-groups/${processGroupId}  ${alias}  ${headers_1}
    ${data} =  Set Variable  {"versionedFlow": {"flowName": "${name}", "bucketId": "${bucketId}", "registryId": "${registryId}"}, "processGroupRevision": {"clientId": "${CLIENTID}", "version": ${currentProcessGrVersion}}}
    ${versionControl_resp} =  Post Request  ${alias}  /nifi-api/versions/process-groups/${processGroupId}  data=${data}  headers=${headers_1}


Distribute The Flow
    [Arguments]  ${alias}  ${headers_1}  ${headers_2}  ${processGroupId}

    ${resp} =  Get Request  ${alias}  /nifi-api/process-groups/${processGroupId}  ${headers_1}
    ${flowId} =  Get Regexp Matches  ${resp.text}  .*(flowId\":\")([a-zA-Z0-9-?]{1,}).*  2
    ${flowId} =  Set Variable  ${flowId[0]}

    ${resp} =  Get Request  ${alias}  /distributor/distribution-targets  ${headers_2}
    ${distributionId} =  Get Regexp Matches  ${resp.text}  .*(id\":\")([a-zA-Z0-9-?]{1,}).*  2
    ${distributionId} =  Set Variable  ${flowId[0]}
    ${data} =  Set Variable  {"processGroupId": "${flowId}"}
    ${distribute_resp} =  Post Request  ${alias}  /distributor/distribution-targets/${distributionId}/process-groups  data=${data}  headers=${headers_1}


Get ID
    [Arguments]  ${parameter}  ${uri}    ${alias}  ${headers}
    ${resp} =  Get Request  ${alias}  ${uri}  headers=${headers}
    ${ParamId} =  Get Regexp Matches  ${resp.text}  .*(${parameter}\\":{\\"\\w{2,}\\":)((\\d|\\"([a-zA-Z0-9-?]{1,})\\")).*  4
    ${ParamId} =  Set Variable  ${ParamId[0]}
    [Return]  ${ParamId}




