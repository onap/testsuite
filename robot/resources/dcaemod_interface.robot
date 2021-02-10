*** Settings ***

Library           RequestsLibrary
Library           String

*** Variables ***

${CLIENTID}      robot123


*** Keywords ***


Onboard Component Spec
    [Arguments]  ${alias}  ${headers}
    ${resp} =  Post Request  ${alias}  /onboarding/component


Add Registry Client
    [Arguments]  ${alias}  ${headers}
    ${data} =  Set Variable  {"revision": {"version": 0}, "component": {"name": "registry", "uri": "http://dcaemod-nifi-registry:18080"}}
    ${resp} =  Post Request  ${alias}  /nifi-api/controller/registry-clients  data=${data}  headers=${headers}

Add Distribution Target
    [Arguments]  ${alias}  ${headers}
    ${data} =  Set Variable  {"name": "runtime", "runtimeApiUrl": "http://dcaemod-runtime-api:9090"}
    ${resp} =  Post Request  ${alias}  /distributor/distribution-targets  data=${data}  headers=${headers}


Create Process Group
    [Arguments]  ${alias}  ${headers_1}  ${headers_2}  ${name}

    ${resp} =  Get Request  ${alias}  /nifi-api/flow/process-groups/root/  ${headers_2}
    ${parentGroupId} =  Set Variable  ${resp.json().get('processGroupFlow').get('id')}

    ${data} =  Set Variable  {"revision": {"clientId": "${CLIENTID}", "version": 0}, "component" : {"parentGroupId" : "${parentGroupId}", "name" : "${name}"}}
    ${resp} =  Post Request  ${alias}  /nifi-api/process-groups/${parentGroupId}/process-groups  data=${data}  headers=${headers_1}

    ${processGroupId} =  Set Variable  ${resp.json().get('id')}

    [Return]  ${processGroupId}

Create Processor
    [Arguments]  ${alias}  ${headers}  ${processGroupId}
    ${data} =  Set Variable  {"revision": {"clientId": "${CLIENTID}", "version": 0},"component": {"parentGroupId": "${processGroupId}", "name": "DcaeDummyAppNginx", "type": "org.onap.dcae.DcaeDummyAppNginx"}}
    ${processGr_resp} =  Post Request  ${alias}  /nifi-api/process-groups/${processGroupId}/processors  data=${data}  headers=${headers}


Create Flow By Version Controlling
    [Arguments]  ${alias}  ${headers_1}  ${headers_2}  ${processGroupId}  ${name}

    ${resp} =  Get Request  ${alias}  /nifi-api/controller/registry-clients  ${headers_2}
    ${registryId} =  Set Variable  ${resp.json().get('registries')[0].get('id')}

    ${resp} =  Get Request  ${alias}  /nifi-api/flow/registries/${registryId}/buckets  ${headers_2}
    ${bucketId} =  Set Variable  ${resp.json().get('buckets')[0].get('id')}

    ${resp} =  Get Request  ${alias}  /nifi-api/versions/process-groups/${processGroupId}
    ${currentProcessGrVersion} =  Set Variable  ${resp.json().get('processGroupRevision').get('version')}

    ${data} =  Set Variable  {"versionedFlow": {"flowName": "${name}", "bucketId": "${bucketId}", "registryId": "${registryId}"}, "processGroupRevision": {"clientId": "${CLIENTID}", "version": ${currentProcessGrVersion}}}
    ${versionControl_resp} =  Post Request  ${alias}  /nifi-api/versions/process-groups/${processGroupId}  data=${data}  headers=${headers_1}


Distribute The Flow
    [Arguments]  ${alias}  ${headers_1}  ${headers_2}  ${processGroupId}

    ${resp} =  Get Request  ${alias}  /nifi-api/process-groups/${processGroupId}  ${headers_1}
    ${flowId} =  Set Variable  ${resp.json().get('component').get('versionControlInformation').get('flowId')}

    ${resp} =  Get Request  ${alias}  /distributor/distribution-targets  ${headers_2}
    ${distributionId} =  Set Variable  ${resp.json().get('distributionTargets')[0].get('id')}

    ${data} =  Set Variable  {"processGroupId": "${flowId}"}
    ${distribute_resp} =  Post Request  ${alias}  /distributor/distribution-targets/${distributionId}/process-groups  data=${data}  headers=${headers_1}





