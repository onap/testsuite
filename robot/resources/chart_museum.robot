*** Settings ***
Documentation     The main interface for interacting with CDS. It handles low level stuff like managing the http request library and CDS required fields
Library           RequestsLibrary
Resource          global_properties.robot
Library           SSHLibrary
Library           OperatingSystem
Library           String

*** Variables ***
${registry_ovveride}                                            ${GLOBAL_INJECTED_NEXUS_DOCKER_REPO}

*** Keywords ***
Add chart repository
    [Documentation]  Add chart repository to helm in robot/xtesting pod
    [Arguments]                         ${chart_repo_name}                  ${chart_repo_fqdn}      ${chart_repo_username}      ${chart_repo_password}
    ${helm_repo_add}=                   Set Variable                        helm repo add ${chart_repo_name} ${chart_repo_fqdn} --password ${chart_repo_password} --username ${chart_repo_username}
    ${command_output} =                 Run And Return Rc And Output        ${helm_repo_add}
    Should Be Equal As Integers         ${command_output[0]}                0
    ${command_output} =                 Run And Return Rc And Output        helm repo update
    Should Be Equal As Integers         ${command_output[0]}                0

Remove chart repository
    [Documentation]  Remove chart repository from helm in robot/xtesting pod
    [Arguments]                         ${chart_repo_name}
    ${helm_repo_remove}=                Set Variable                            helm repo remove ${chart_repo_name}
    ${command_output} =                 Run And Return Rc And Output            ${helm_repo_remove}
    Should Be Equal As Integers         ${command_output[0]}                    0

Package and add charts to repository
    [Documentation]  Package and add charts to k8s chart repository in robot/xtesting pod
    [Arguments]                         ${chart_repo_name}                  ${chart_directory}      ${destination_directory}    ${chart_version}
    ${helm_package}=                    Set Variable                        helm package --dependency-update --destination ${destination_directory} ${chart_directory} --version ${chart_version}
    ${command_output} =                 Run And Return Rc And Output        ${helm_package}
    Should Be Equal As Integers         ${command_output[0]}                0
    ${helm_chart_name}=                 Fetch From Right                    ${chart_directory}      /
    ${helm_push}=                       Set Variable                        helm push  ${destination_directory}/${helm_chart_name}-${chart_version}.tgz ${chart_repo_name}
    ${command_output} =                 Run And Return Rc And Output        ${helm_push}
    Should Be Equal As Integers         ${command_output[0]}                0


Install helm charts
    [Documentation]  Install DCAE Servcie using helm charts
    [Arguments]                             ${chart_repo_name}                      ${dcae_servcie_helm_charts}         ${dcae_service_helm_name}       ${wait_time}=2 min    ${set_values_override}=${EMPTY}
    ${helm_install}=                        Set Variable                            helm install ${dcae_service_helm_name} ${chart_repo_name}/${dcae_servcie_helm_charts} --set global.repository=${registry_ovveride} ${set_values_override}
    ${helm_install_command_output} =        Run And Return Rc And Output            ${helm_install}
    Should Be Equal As Integers             ${helm_install_command_output[0]}       0
    Wait Until Keyword Succeeds             ${wait_time}                            20 sec                             Checking Status Of Deployed Appliction Using Helm      ${dcae_servcie_helm_charts}                 ${dcae_service_helm_name}

Install helm charts from folder
    [Documentation]  Install DCAE Servcie using helm charts not in repo
    [Arguments]                             ${chart_folder}                         ${dcae_service_helm_name}       ${wait_time}=2 min  ${set_values_override}=${EMPTY}
    ${helm_dependency_update}=              Set Variable                            helm dependency update ${chart_folder}
    ${helm_dependency_update_output} =      Run And Return Rc And Output            ${helm_dependency_update}
    Should Be Equal As Integers             ${helm_dependency_update_output[0]}     0
    ${rest}  ${dcae_servcie_helm_charts} = 	Split String From Right 	            ${chart_folder} 	            / 	        1
    ${helm_install}=                        Set Variable                            helm install ${dcae_service_helm_name} ${chart_folder} --set global.repository=${registry_ovveride} ${set_values_override}
    ${helm_install_command_output} =        Run And Return Rc And Output            ${helm_install}
    Should Be Equal As Integers             ${helm_install_command_output[0]}       0
    Wait Until Keyword Succeeds             ${wait_time}                            20 sec                             Checking Status Of Deployed Appliction Using Helm      ${dcae_servcie_helm_charts}                 ${dcae_service_helm_name}

Checking Status Of Deployed Appliction Using Helm
    [Arguments]                         ${dcae_servcie_helm_charts}                 ${dcae_service_helm_name}
    ${pod_status}=                      Set Variable                                kubectl get pods -n onap | grep ${dcae_service_helm_name} | awk '{print $3}'
    ${pod_status_command_output} =      Run And Return Rc And Output                ${pod_status}
    Should Be Equal As Integers         ${pod_status_command_output[0]}             0
    Should Be Equal As Strings          ${pod_status_command_output[1]}             Running
    ${pod_ready}=                       Set Variable                                kubectl get pods -n onap | grep ${dcae_service_helm_name} | awk '{print $2}'
    ${pod_ready_command_output} =       Run And Return Rc And Output                ${pod_ready}
    Should Be Equal As Integers         ${pod_ready_command_output[0]}              0
    ${pre}       ${post} = 	Split String 	${pod_ready_command_output[1]} 	        / 	    1
    Should Be Equal As Strings          ${pre}                                      ${post}

Uninstall helm charts
    [Documentation]  Uninstall DCAE Servcie using helm charts
    [Arguments]                             ${dcae_service_helm_name}
    ${helm_uninstall}=                      Set Variable                                    helm uninstall ${dcae_service_helm_name}
    ${helm_uninstall_command_output}=       Run And Return Rc And Output                    ${helm_uninstall}
    Should Be Equal As Integers             ${helm_uninstall_command_output[0]}             0








