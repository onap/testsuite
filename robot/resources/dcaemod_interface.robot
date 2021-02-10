*** Settings ***
Library           ONAPLibrary.Templating    WITH NAME    Templating
Library           RequestsLibrary
Resource         ../resources/global_properties.robot
Resource          ../resources/dcae/inventory.robot

*** Variables ***

${CLIENTID}                    robot123
${COMPONENT_SPEC}              dcaemod/dcaemod.jinja
${DEPLOYMENT_SERVER}           ${GLOBAL_DEPLOYMENT_HANDLER_SERVER_PROTOCOL}://${GLOBAL_DEPLOYMENT_HANDLER_SERVER_NAME}:${GLOBAL_DEPLOYMENT_HANDLER_SERVER_PORT}
${DEPLOYMENT_ENDPOINT}         dcae-deployments

*** Keywords ***


Onboard Component Spec
    [Arguments]  ${alias}  ${headers}

    ${dict_values} =  Create Dictionary  name=tralalala
    Templating.Create Environment  dcaemod  ${GLOBAL_TEMPLATE_FOLDER}
    ${componentSpec}=  Templating.Apply Template  dcaemod   ${COMPONENT_SPEC}  ${dict_values}
    ${resp} =  Post Request   ${alias}  /onboarding/components  data=${componentSpec}  headers=${headers}
    Log  ${resp.json()}


Add Registry Client
    [Arguments]  ${alias}  ${headers}
    ${data} =  Set Variable  {"revision": {"version": 0}, "component": {"name": "registry", "uri": "http://dcaemod-nifi-registry:18080"}}
    ${resp} =  Post Request  ${alias}  /nifi-api/controller/registry-clients  data=${data}  headers=${headers}

Add Distribution Target
    [Arguments]  ${alias}  ${headers}
    ${data} =  Set Variable  {"name": "runtime", "runtimeApiUrl": "http://dcaemod-runtime-api:9090"}
    ${resp} =  Post Request  ${alias}  /distributor/distribution-targets  data=${data}  headers=${headers}


Create Process Group
    [Arguments]  ${alias}  ${headers}  ${name}

    ${resp} =  Get Request  ${alias}  /nifi-api/flow/process-groups/root/  headers=${headers}
    Log  ${resp.json()}
    ${parentGroupId} =  Set Variable  ${resp.json().get('processGroupFlow').get('id')}

    ${data} =  Set Variable  {"revision": {"clientId": "${CLIENTID}", "version": 0}, "component" : {"parentGroupId" : "${parentGroupId}", "name" : "${name}"}}
    ${resp} =  Post Request  ${alias}  /nifi-api/process-groups/${parentGroupId}/process-groups  data=${data}  headers=${headers}
    Log  ${resp.json()}

    ${processGroupId} =  Set Variable  ${resp.json().get('id')}

    [Return]  ${processGroupId}

Create Processor
    [Arguments]  ${alias}  ${headers}  ${processGroupId}
    ${data} =  Set Variable  {"revision": {"clientId": "${CLIENTID}", "version": 0},"component": {"parentGroupId": "${processGroupId}", "name": "DcaeDummyAppNginx", "type": "org.onap.dcae.DcaeDummyAppNginx"}}
    ${processGr_resp} =  Post Request  ${alias}  /nifi-api/process-groups/${processGroupId}/processors  data=${data}  headers=${headers}


Save Flow By Version Controlling
    [Arguments]  ${alias}  ${headers}  ${processGroupId}  ${name}

    ${resp} =  Get Request  ${alias}  /nifi-api/controller/registry-clients  headers=${headers}
    Log  ${resp.json()}
    ${registryId} =  Set Variable  ${resp.json().get('registries')[0].get('id')}

    ${resp} =  Get Request  ${alias}  /nifi-api/flow/registries/${registryId}/buckets  headers=${headers}
    Log  ${resp.json()}
    ${bucketId} =  Set Variable  ${resp.json().get('buckets')[0].get('id')}

    ${resp} =  Get Request  ${alias}  /nifi-api/versions/process-groups/${processGroupId}  headers=${headers}
    ${currentProcessGrVersion} =  Set Variable  ${resp.json().get('processGroupRevision').get('version')}

    ${data} =  Set Variable  {"versionedFlow": {"flowName": "${name}", "bucketId": "${bucketId}", "registryId": "${registryId}"}, "processGroupRevision": {"clientId": "${CLIENTID}", "version": ${currentProcessGrVersion}}}
    ${versionControl_resp} =  Post Request  ${alias}  /nifi-api/versions/process-groups/${processGroupId}  data=${data}  headers=${headers}


Distribute The Flow
    [Arguments]  ${alias}  ${headers}  ${processGroupId}

    ${resp} =  Get Request  ${alias}  /nifi-api/process-groups/${processGroupId}  headers=${headers}
    Log  ${resp.json()}
    ${flowId} =  Set Variable  ${resp.json().get('component').get('versionControlInformation').get('flowId')}

    ${resp} =  Get Request  ${alias}  /distributor/distribution-targets  headers=${headers}
    Log  ${resp.json()}
    ${distributionId} =  Set Variable  ${resp.json().get('distributionTargets')[0].get('id')}

    ${data} =  Set Variable  {"processGroupId": "${flowId}"}
    ${distribute_resp} =  Post Request  ${alias}  /distributor/distribution-targets/${distributionId}/process-groups  data=${data}  headers=${headers}

Deploy Blueprint From Inventory
    [Arguments]  ${typeName}  ${headers}

    ${resp} =  Get Blueprint From Inventory  ${typeName}
    ${typeId} =  Set Variable  ${resp.json().get('items')[0].get('typeId')}

    ${session}=  Create Session  ${DEPLOYMENT_ENDPOINT}  ${DEPLOYMENT_SERVER}
    ${data} =  Set Variable  {"serviceTypeId": "${typeId}"}
    ${resp}=  Put Request   ${DEPLOYMENT_ENDPOINT}  /${DEPLOYMENT_ENDPOINT}/${typeName}   data=${data}     headers=${headers}



