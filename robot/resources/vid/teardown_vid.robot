*** Settings ***
Documentation     The main interface for interacting with VID. It handles low level stuff like managing the selenium request library and VID required steps
Library 	    SeleniumLibrary
Library            Collections
Library         String
Library 	      StringTemplater
Library	          UUID
Library    ONAPLibrary.SO
Resource        vid_interface.robot
Resource        create_vid_vnf.robot
Resource        create_service_instance.robot
Resource         ../heatbridge.robot

*** Variables ***
${VID_ENV}            /vid
${VID_SERVICE_MODELS_SEARCH_URL}  ${GLOBAL_VID_SERVER_PROTOCOL}://${GLOBAL_INJECTED_VID_IP_ADDR}:${GLOBAL_VID_SERVER_PORT}${VID_ENV}/serviceModels.htm#/instances/services
${TEARDOWN_STATUS}   FAIL

*** Keywords ***

Teardown VID
    [Documentation]   Teardown the VID This assumes that the any runnign stacks have been torn down
    [Arguments]    ${service_instance_id}    ${lcp_region}    ${tenant}   ${customer}
    Return From Keyword If   len('${service_instance_id}') == 0
    # Keep going to the VID service instance until we get the pop-up alert that there is no service instance
    Set Test Variable    ${TEARDOWN_STATUS}    FAIL
    Wait Until Keyword Succeeds    300s    1s    Delete VID    ${service_instance_id}    ${lcp_region}    ${tenant}   ${customer}
    Return From Keyword If   '${TEARDOWN_STATUS}' == 'PASS'
    Fail   ${TEARDOWN_STATUS}


Delete VID
    [Documentation]    Teardown the next VID entity that has a Remove icon.
    [Arguments]    ${service_instance_id}    ${lcp_region}    ${tenant}   ${customer}
    # For vLB closed loop, we may have 2 vf modules and the vDNS one needs to be removed first.
    ${remove_order}=    Create List    vDNS_Ete   vPKG   Vfmodule_Ete

    # FAIL status is returned in ${vfmodule} because FAIL are ignored during teardown
    ${status}    ${vfmodule}=   Run Keyword and Ignore Error   Delete Next VID Entity    ${service_instance_id}    ${lcp_region}    ${tenant}   ${remove_order}   ${customer}
    Return From Keyword If    '${status}' == 'FAIL'
    Return From Keyword If    '${vfmodule}' == 'FAIL'
    # After tearing down a VF module, execute the reverse HB for it to remove the references from A&AI
    Run Keyword If   'Vfmodule_Ete' in '${vfmodule}'    Execute Reverse Heatbridge
    Fail    Continue with Next Remove

Delete Next VID Entity
    [Documentation]    Teardown the next VID entity that has a Remove icon.
    [Arguments]    ${service_instance_id}    ${lcp_region}    ${tenant}   ${remove_order}   ${customer}
    ${vfmodule}=    Catenate
    Go To    ${VID_SERVICE_MODELS_SEARCH_URL}
    Wait Until Page Contains    Please search by    timeout=${GLOBAL_VID_UI_TIMEOUT_MEDIUM}
    Wait Until Page Contains Element    xpath=//div[@class='statusLine aaiHidden']    timeout=${GLOBAL_VID_UI_TIMEOUT_MEDIUM}
    Wait Until Element Is Not Visible    xpath=//div[@class='statusLine aaiHidden']    timeout=${GLOBAL_VID_UI_TIMEOUT_MEDIUM}

    # If we don't wait for this control to be enabled, the submit results in a 'not found' pop-up (UnexpectedAlertPresentException)
    Select From List By Label    //select[@ng-model='selectedCustomer']    ${customer}
    Click Button    button=Submit

    # When Handle VID Alert detects a pop-up. it will return FAIL and we are done
    # Return from Keyword is required because FAIL is inored during teardown
    Set Test Variable   ${TEARDOWN_STATUS}   PASS
    ${status}   ${value}   Run Keyword And Ignore Error    Handle VID Alert
    Return From Keyword If   '${status}' == 'FAIL'   ${status}
    ${status}   ${value}   Run Keyword And Ignore Error    Wait Until Page Contains Element    link=View/Edit    timeout=${GLOBAL_VID_UI_TIMEOUT_MEDIUM}
    Return From Keyword If   '${status}' == 'FAIL'   ${status}
    Set Test Variable   ${TEARDOWN_STATUS}   FAIL


    Click Element     link=View/Edit
    Wait Until Page Contains    View/Edit Service Instance     timeout=${GLOBAL_VID_UI_TIMEOUT_MEDIUM}
    Wait Until Element Is Visible    xpath=//a/span[@class='glyphicon glyphicon-remove']    timeout=${GLOBAL_VID_UI_TIMEOUT_LONG}

    :FOR   ${remove_first}    IN    @{remove_order}
    \    ${remove_xpath}=    Set Variable   //li/div[contains(.,'${remove_first}')]/a/span[@class='glyphicon glyphicon-remove']
    \    ${status}    ${data}=   Run Keyword And Ignore Error    Page Should Contain Element     xpath=${remove_xpath}
    \    Exit For Loop If    '${status}' == 'PASS'
    \   ${remove_xpath}=    Set Variable   //li/div/a/span[@class='glyphicon glyphicon-remove']
    Click On Element When Visible    xpath=${remove_xpath}

    ${status}   ${value}=   Run Keyword and Ignore Error   Wait Until Page Contains Element     xpath=//select[@parameter-id='lcpRegion']
    Run Keyword If   '${status}'=='PASS'   Select From List By Label    xpath=//select[@parameter-id='lcpRegion']    ${lcp_region}
    Run Keyword If   '${status}'=='PASS'   Select From List By Label    xpath=//select[@parameter-id='tenant']    ${tenant}
    ${status}   ${vfmodule}=    Run Keyword And Ignore Error    Get Text    xpath=//td[contains(text(), 'Vf Module Name')]/../td[2]
    Click Element    xpath=//div[@class='buttonRow']/button[@ngx-enabled='true']
    #//*[@id="mContent"]/div/div/div/div/table/tbody/tr/td/div/div[2]/div/div[1]/div[5]/button[1]
    Wait Until Page Contains    100 %     300s
    ${response text}=    Get Text    xpath=//div[@ng-controller='deletionDialogController']//div[@ng-controller= 'msoCommitController']/pre[@class = 'log ng-binding']
    ${request_id}=    Parse Request Id     ${response text}
    Click Element    xpath=//div[@class='ng-scope']/div[@class = 'buttonRow']/button[text() = 'Close']
    ${auth}=	Create List  ${GLOBAL_MSO_USERNAME}    ${GLOBAL_MSO_PASSWORD}
    ${resp}=	ONAPLibrary.SO.Run Polling Get Request    ${MSO_ENDPOINT}    ${GLOBAL_MSO_STATUS_PATH}${request_id}    auth=${auth}
    [Return]   ${vfmodule}

Handle VID Alert
    [Documentation]   When service instance has been deleted, an alert will be triggered on the search to end the loop
    ...   The various Alert keywords did not prevent the alert exception on the Click ELement, hence this roundabout way of handling the alert
    Run Keyword And Ignore Error    Click Element    button=Submit
    ${status}   ${t}=    Run Keyword And Ignore Error    Handle Alert 
    Return From Keyword If   '${status}' == 'FAIL'
    Fail    ${t}
