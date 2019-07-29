*** Settings ***
Documentation	  Creates VID VNF Instance

Library    SeleniumLibrary    60
Library         String
Library        DateTime
Library 	      RequestsLibrary
Resource          ../global_properties.robot
Resource          vid_interface.robot
Library    ONAPLibrary.SO    WITH NAME    SO

*** Keywords ***
Create VID VNF
    [Documentation]    Creates a VNF instance using VID for passed instance id with the passed service instance name
    [Arguments]    ${service_instance_id}    ${service_instance_name}    ${product_family}    ${lcp_region}    ${tenant}   ${vnf_type}   ${customer}   ${line_of_business}=LOB-Demonstration   ${platform}=Platform-Demonstration
    Go To VID HOME
    Click Link       xpath=//div[@heading = 'Search for Existing Service Instances']/a
    Wait Until Page Contains    Please search by    timeout=${GLOBAL_VID_UI_TIMEOUT_MEDIUM}

    # If we don't wait for this control to be enabled, the submit results in a 'not found' pop-up (UnexpectedAlertPresentException)
    #Input Text When Enabled    //input[@name='selectedServiceInstance']    ${service_instance_id}
    #Select From List By Label    //select[@ng-model='selectedserviceinstancetype']    Service Instance Id
    Select From List By Label    //select[@ng-model='selectedCustomer']    ${customer}
    Click On Button When Enabled    //button[contains(text(),'Submit')]
    Wait Until Page Contains Element    link=View/Edit    timeout=${GLOBAL_VID_UI_TIMEOUT_MEDIUM}
    Click Element     xpath=//a[contains(text(), 'View/Edit')]
    Wait Until Page Contains    View/Edit Service Instance     timeout=${GLOBAL_VID_UI_TIMEOUT_MEDIUM}
    # in slower environment the background load of data from AAI takes time so that the button is not populated yet
    Click On Button When Enabled    //button[contains(text(),'Add node instance')]
    #01681d02-2304-4c91-ab2d 0
    # This is where firefox breaks. Th elink never becomes visible when run with the script.
    ${dataTestsId}=    Catenate   AddVNFOption-${vnf_type}
    Sleep   10s
    Click Element    xpath=//a[contains(text(), '${vnf_type}')]
    Wait Until Page Contains Element    xpath=//input[@parameter-id='instanceName']    ${GLOBAL_VID_UI_TIMEOUT_MEDIUM}
    Wait Until Element Is Enabled    xpath=//input[@parameter-id='instanceName']    ${GLOBAL_VID_UI_TIMEOUT_MEDIUM}
    ## Without this sleep, the input text below gets immediately wiped out.
    ## Wait Until Angular Ready just sleeps for its timeout value
    Sleep    10s
    Input Text 	  xpath=//input[@parameter-id='instanceName']    ${service_instance_name}
    Select From List By Label     xpath=//select[@parameter-id='productFamily']    ${product_family}
    # Fix for Dublin
    ${cloud_owner_uc}=   Convert To Uppercase   ${GLOBAL_AAI_CLOUD_OWNER}
    Select From List By Label    xpath=//select[@parameter-id='lcpRegion']    ${lcp_region} (${cloud_owner_uc})
    Select From List By Label    xpath=//select[@parameter-id='tenant']    ${tenant}
    Sleep    5s
    Click Element   xpath=//multiselect[@parameter-id='lineOfBusiness']
    Sleep    5s
    Click On Button When Enabled    //button[contains(text(),${line_of_business})]
    Select From List By Label    xpath=//select[@parameter-id='platform']    ${platform}
    Click On Button When Enabled    //button[contains(text(),'Confirm')]
 	Wait Until Element Contains    xpath=//pre[@class = 'log ng-binding']    requestState    timeout=${GLOBAL_VID_UI_TIMEOUT_LONG}
    ${response text}=    Get Text    xpath=//pre[@class = 'log ng-binding']
 	Should Not Contain    ${response text}    FAILED
    Click On Button When Enabled    //button[contains(text(),'Close')]
    ${instance_id}=    Parse Instance Id     ${response text}
    Wait Until Page Contains    ${service_instance_name}    ${GLOBAL_VID_UI_TIMEOUT_MEDIUM}
    [Return]     ${instance_id}

Delete VID VNF
    [Arguments]    ${service_instance_id}    ${lcp_region}    ${tenant}    ${vnf_instance_id}
    Go To VID HOME
    Click Link       xpath=//div[@heading = 'Search for Existing Service Instances']/a
    Wait Until Page Contains    Please search by    timeout=60s
    Wait Until Page Contains Element    xpath=//div[@class='statusLine aaiHidden']    timeout=${GLOBAL_VID_UI_TIMEOUT_MEDIUM}
    Wait Until Element Is Not Visible    xpath=//div[@class='statusLine aaiHidden']    timeout=${GLOBAL_VID_UI_TIMEOUT_MEDIUM}

    # If we don't wait for this control to be enabled, the submit results in a 'not found' pop-up (UnexpectedAlertPresentException)
    Input Text When Enabled    //input[@name='selectedServiceInstance']    ${service_instance_id}
    Click On Button When Enabled    //button[contains(text(),'Submit')]
    Wait Until Page Contains Element    link=View/Edit    timeout=${GLOBAL_VID_UI_TIMEOUT_MEDIUM}
    Click Element     link=View/Edit
    Wait Until Page Contains    View/Edit Service Instance     timeout=${GLOBAL_VID_UI_TIMEOUT_MEDIUM}
    Wait Until Page Contains Element    xpath=//div[@class='statusLine']    timeout=${GLOBAL_VID_UI_TIMEOUT_LONG}
    Wait Until Element Is Not Visible    xpath=//div[@class='statusLine aaiHidden']    timeout=${GLOBAL_VID_UI_TIMEOUT_MEDIUM}
    Click On Element When Visible    xpath=//li/div[contains(.,'${vnf_instance_id}')]/a/span[@class='glyphicon glyphicon-remove']    timeout=${GLOBAL_VID_UI_TIMEOUT_LONG}
    ${cloud_owner_uc}=   Convert To Uppercase   ${GLOBAL_AAI_CLOUD_OWNER}
    Select From List By Label    xpath=//select[@parameter-id='lcpRegion']    ${lcp_region} (${cloud_owner_uc})
    Select From List By Label    xpath=//select[@parameter-id='tenant']    ${tenant}
    Click Element    xpath=//div[@class='buttonRow']/button[@ngx-enabled='true']
    #//*[@id="mContent"]/div/div/div/div/table/tbody/tr/td/div/div[2]/div/div[1]/div[5]/button[1]

    ${response text}=    Get Text    xpath=//div[@ng-controller='deletionDialogController']//div[@ng-controller= 'msoCommitController']/pre[@class = 'log ng-binding']
    ${request_id}=    Parse Request Id     ${response text}
    ${auth}=	Create List  ${GLOBAL_SO_USERNAME}    ${GLOBAL_SO_PASSWORD}
    ${resp}=	SO.Run Polling Get Request    ${GLOBAL_SO_ENDPOINT}    ${GLOBAL_SO_STATUS_PATH}${request_id}    auth=${auth}

Create VID VNF module
    [Arguments]    ${service_instance_id}    ${vf_module_name}    ${lcp_region}    ${TENANT}    ${VNF_TYPE}   ${customer}   ${vnf_name}  
    Go To VID HOME
    Click Link       xpath=//div[@heading = 'Search for Existing Service Instances']/a
    Wait Until Page Contains    Please search by    timeout=${GLOBAL_VID_UI_TIMEOUT_MEDIUM}
    Wait Until Page Contains Element    xpath=//div[@class='statusLine aaiHidden']    timeout=${GLOBAL_VID_UI_TIMEOUT_MEDIUM}

     # If we don't wait for this control to be enabled, the submit results in a 'not found' pop-up (UnexpectedAlertPresentException)
    Select From List By Label    //select[@ng-model='selectedCustomer']    ${customer}
    Click On Button When Enabled    //button[contains(text(),'Submit')]
    Wait Until Page Contains Element    link=View/Edit    timeout=${GLOBAL_VID_UI_TIMEOUT_MEDIUM}
    Click Element     link=View/Edit
    Wait Until Keyword Succeeds   300s   5s   Wait For Add VF Module
    Click Element     xpath=//div[contains(.,'${vnf_name}')]/div/button[contains(.,'Add VF-Module')]

    # This is where firefox breaks. Th elink never becomes visible when run with the script.
    Click Element    link=${vnf_type}
    Wait Until Page Contains Element    xpath=//input[@parameter-id='instanceName']    ${GLOBAL_VID_UI_TIMEOUT_SHORT}
    Wait Until Element Is Enabled    xpath=//input[@parameter-id='instanceName']    ${GLOBAL_VID_UI_TIMEOUT_SHORT}

    ## Without this sleep, the input text below gets immediately wiped out.
    ## Wait Until Angular Ready just sleeps for its timeout value
    Sleep    10s
    Input Text 	  xpath=//input[@parameter-id='instanceName']    ${vf_module_name}
    ${cloud_owner_uc}=   Convert To Uppercase   ${GLOBAL_AAI_CLOUD_OWNER}
    Select From List By Label    xpath=//select[@parameter-id='lcpRegion']    ${lcp_region} (${cloud_owner_uc})
    Select From List By Label    xpath=//select[@parameter-id='tenant']    ${tenant}
    Wait Until Element Is Visible    xpath=//input[@parameter-id='sdncPreload']       ${GLOBAL_VID_UI_TIMEOUT_SHORT}
    Wait Until Element Is Enabled    xpath=//input[@parameter-id='sdncPreload']       ${GLOBAL_VID_UI_TIMEOUT_SHORT}
    Select Checkbox    xpath=//input[@parameter-id='sdncPreload']
    Click On Button When Enabled    //button[contains(text(),'Confirm')]
 	Wait Until Element Contains    xpath=//pre[@class = 'log ng-binding']    requestState    timeout=${GLOBAL_VID_UI_TIMEOUT_LONG}
    ${response text}=    Get Text    xpath=//pre[@class = 'log ng-binding']
    Click On Button When Enabled    //button[contains(text(),'Close')]
    ${instance_id}=    Parse Instance Id     ${response text}

    ${request_id}=    Parse Request Id     ${response text}
    ${auth}=	Create List  ${GLOBAL_SO_USERNAME}    ${GLOBAL_SO_PASSWORD}
    ${resp}=	SO.Run Polling Get Request    ${GLOBAL_SO_ENDPOINT}    ${GLOBAL_SO_STATUS_PATH}${request_id}    auth=${auth}
    [Return]     ${instance_id}

Wait For Add VF Module
    [Documentation]   Retry by refresh if the ADD VF-Module is not visible
    Wait Until Page Contains    View/Edit Service Instance     timeout=${GLOBAL_VID_UI_TIMEOUT_MEDIUM}  
    
    ${status}   ${value}   Run Keyword And Ignore Error   Wait Until Element Is Visible    //button[contains(text(),'Add VF-Module')]   timeout=${GLOBAL_VID_UI_TIMEOUT_SHORT}
    Return From Keyword If   '${status}' == 'PASS'
    Reload Page
    Fail    Retry
