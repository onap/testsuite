*** Settings ***
Documentation     The main interface for interacting with VID. It handles low level stuff like managing the selenium request library and VID required steps
Library 	    ExtendedSelenium2Library
Library            Collections
Library         String
Library 	      StringTemplater
Library	          UUID      
Resource        vid_interface.robot
Resource        create_vid_vnf.robot
Resource        create_service_instance.robot

*** Variables ***
${VID_ENV}            /vid
${VID_SERVICE_MODELS_SEARCH_URL}  ${GLOBAL_VID_SERVER}${VID_ENV}/serviceModels.htm#/instances/subdetails?selectedSubscriber=\${customer_id}

*** Keywords ***
    
Teardown VID 
    [Documentation]   Teardown the VID This assumes that the any runnign stacks have been torn down
    [Arguments]    ${service_instance_id}    ${lcp_region}    ${tenant}        
    # Keep going to the VID service instance until all  of the remove icons are goe
    Wait Until Keyword Succeeds    300s    1s    Delete VID    ${service_instance_id}    ${lcp_region}    ${tenant}
    

Delete VID   
    [Documentation]    Teardown the next VID entity that has a Remove icon.
    [Arguments]    ${service_instance_id}    ${lcp_region}    ${tenant}    
    Go To    ${VID_SERVICE_MODELS_SEARCH_URL}
    Wait Until Page Contains    Please search by    timeout=60s
    Wait Until Page Contains Element    xpath=//div[@class='statusLine aaiHidden']    timeout=60s
    Wait Until Element Is Not Visible    xpath=//div[@class='statusLine aaiHidden']    timeout=60s
    
    # If we don't wait for this control to be enabled, the submit results in a 'not found' pop-up (UnexpectedAlertPresentException) 
    Input Text When Enabled    //input[@name='selectedServiceInstance']    ${service_instance_id}
    Click Button    button=Submit
    Wait Until Page Contains Element    link=View/Edit    timeout=60s
    Click Element     link=View/Edit   
    Wait Until Page Contains    View/Edit Service Instance     timeout=60s
    ${status}    ${data}=   Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath=//li/div/a/span[@class='glyphicon glyphicon-remove']    timeout=120s
    Return From Keyword If    '${status}' == 'FAIL'
    
    # At least one more Remove!
    
    # This list is a bit ogf a hack to determine the order of removal if there is more than one remove icon.
    # Cannot tell how this will hold up once all of the VID removes are working for all conditions. 
    ${remove_order}=    Create List    Vfmodule_Ete
    :for   ${remove_first}    in    @{remove_order}  
    \    ${status}    ${data}=   Run Keyword And Ignore Error    Page Should Contain Element     xpath=//li/div[contains(.,'${remove_first}')]/a/span[@class='glyphicon glyphicon-remove']
    \    Run Keyword If   '${status}' == 'PASS'   Click On Element When Visible    xpath=//li/div[contains(.,'${remove_first}')]/a/span[@class='glyphicon glyphicon-remove']    timeout=120s
    \    Run Keyword If   '${status}' == 'FAIL'   Click On Element When Visible    xpath=//li/div/a/span[@class='glyphicon glyphicon-remove']    timeout=120s  

    Wait Until Page Contains Element     xpath=//select[@parameter-id='lcpRegion']
    Select From List By Label    xpath=//select[@parameter-id='lcpRegion']    ${lcp_region}      
    Select From List By Label    xpath=//select[@parameter-id='tenant']    ${tenant}      
    Click Element    xpath=//div[@class='buttonRow']/button[@ngx-enabled='true']
    #//*[@id="mContent"]/div/div/div/div/table/tbody/tr/td/div/div[2]/div/div[1]/div[5]/button[1]
    Wait Until Page Contains    Status:COMPLETE -     300s
    ${response text}=    Get Text    xpath=//div[@ng-controller='deletionDialogController']//div[@ng-controller= 'msoCommitController']/pre[@class = 'log ng-binding']
    ${request_id}=    Parse Request Id     ${response text}
    Click Element    button=Close
    Poll MSO Get Request    ${GLOBAL_MSO_STATUS_PATH}${request_id}   COMPLETE
    Fail   Successful VID Delete - continue with next delete
  
