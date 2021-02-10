*** Settings ***
Library          ONAPLibrary.Templating    WITH NAME    Templating
Library          ONAPLibrary.Utilities
Library          RequestsLibrary
Resource         ../resources/global_properties.robot
Resource         ../resources/dcae/inventory.robot
Resource         ../resources/dcae/deployment.robot

*** Variables ***

${CLIENTID}                    robot123
${COMPONENT_SPEC}              dcaemod/dcaemod.jinja
${COMPONENT_NAME}              friday

*** Keywords ***


Onboard Component Spec
    [Arguments]  ${alias}  ${headers}

    ${dict_values} =  Create Dictionary  name=tralalala
    Templating.Create Environment  dcaemod  ${GLOBAL_TEMPLATE_FOLDER}
    ${componentSpec}=  Templating.Apply Template  dcaemod   ${COMPONENT_SPEC}  ${dict_values}
    ${resp} =  Post Request   ${alias}  /onboarding/components  data=${componentSpec}  headers=${headers}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}


Add Registry Client
    [Arguments]  ${alias}  ${headers}
    ${data} =  Set Variable  {"revision": {"version": 0}, "component": {"name": "registry", "uri": "http://dcaemod-nifi-registry:18080"}}
    ${resp} =  Post Request  ${alias}  /nifi-api/controller/registry-clients  data=${data}  headers=${headers}
    Should Be Equal As Strings  ${resp.status_code}  200

Add Distribution Target
    [Arguments]  ${alias}  ${headers}
    ${data} =  Set Variable  {"name": "runtime", "runtimeApiUrl": "http://dcaemod-runtime-api:9090"}
    ${resp} =  Post Request  ${alias}  /distributor/distribution-targets  data=${data}  headers=${headers}
    Should Be Equal As Strings  ${resp.status_code}  200


Create Process Group
    [Arguments]  ${alias}  ${headers}  ${name}

    ${resp} =  Get Request  ${alias}  /nifi-api/flow/process-groups/root/  headers=${headers}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    ${parentGroupId} =  Set Variable  ${resp.json().get('processGroupFlow').get('id')}

    ${data} =  Set Variable  {"revision": {"clientId": "${CLIENTID}", "version": 0}, "component" : {"parentGroupId" : "${parentGroupId}", "name" : "${name}"}}
    ${resp} =  Post Request  ${alias}  /nifi-api/process-groups/${parentGroupId}/process-groups  data=${data}  headers=${headers}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}

    ${processGroupId} =  Set Variable  ${resp.json().get('id')}

    [Return]  ${processGroupId}

Create Processor
    [Arguments]  ${alias}  ${headers}  ${processGroupId}
    ${data} =  Set Variable  {"revision": {"clientId": "${CLIENTID}", "version": 0},"component": {"parentGroupId": "${processGroupId}", "name": "${COMPONENT_NAME}", "type": "org.onap.dcae.${COMPONENT_NAME}"}}
    ${resp} =  Post Request  ${alias}  /nifi-api/process-groups/${processGroupId}/processors  data=${data}  headers=${headers}
    Should Be Equal As Strings  ${resp.status_code}  200


Save Flow By Version Controlling
    [Arguments]  ${alias}  ${headers}  ${processGroupId}  ${name}

    ${resp} =  Get Request  ${alias}  /nifi-api/controller/registry-clients  headers=${headers}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    ${registryId} =  Set Variable  ${resp.json().get('registries')[0].get('id')}

    ${resp} =  Get Request  ${alias}  /nifi-api/flow/registries/${registryId}/buckets  headers=${headers}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    ${bucketId} =  Set Variable  ${resp.json().get('buckets')[0].get('id')}

    ${resp} =  Get Request  ${alias}  /nifi-api/versions/process-groups/${processGroupId}  headers=${headers}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${currentProcessGrVersion} =  Set Variable  ${resp.json().get('processGroupRevision').get('version')}

    ${data} =  Set Variable  {"versionedFlow": {"flowName": "${name}", "bucketId": "${bucketId}", "registryId": "${registryId}"}, "processGroupRevision": {"clientId": "${CLIENTID}", "version": ${currentProcessGrVersion}}}
    ${versionControl_resp} =  Post Request  ${alias}  /nifi-api/versions/process-groups/${processGroupId}  data=${data}  headers=${headers}
    Should Be Equal As Strings  ${resp.status_code}  200


Distribute The Flow
    [Arguments]  ${alias}  ${headers}  ${processGroupId}

    ${resp} =  Get Request  ${alias}  /nifi-api/process-groups/${processGroupId}  headers=${headers}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    ${flowId} =  Set Variable  ${resp.json().get('component').get('versionControlInformation').get('flowId')}

    ${resp} =  Get Request  ${alias}  /distributor/distribution-targets  headers=${headers}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    ${distributionId} =  Set Variable  ${resp.json().get('distributionTargets')[0].get('id')}

    ${data} =  Set Variable  {"processGroupId": "${flowId}"}
    ${distribute_resp} =  Post Request  ${alias}  /distributor/distribution-targets/${distributionId}/process-groups  data=${data}  headers=${headers}
    Should Be Equal As Strings  ${resp.status_code}  200

Deploy Blueprint From Inventory
    [Arguments]  ${typeName}  ${headers}

    ${resp} =  Get Blueprint From Inventory  ${typeName}
    ${typeId} =  Set Variable  ${resp.json().get('items')[0].get('typeId')}
    ${data} =  Set Variable  {"serviceTypeId": "${typeId}"}
    Deploy Service  ${data}  ${typeName}




