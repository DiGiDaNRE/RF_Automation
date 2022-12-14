*** Settings ***
Library     SeleniumLibrary
Library     RequestsLibrary
Library     Collections
Library     Process 
Library     String

*** Variables ***
${Timeout}    60

*** Keywords ***
Launch Browser
    [Arguments]    ${browser}    ${url}
    Run Keyword If    '${browser}'=='chrome'    Launch Chrome   ${url}
    ...    ELSE IF    '${browser}'=='ie'        Launch IE    ${url} 
    ...    ELSE IF    '${browser}'=='edge'      Launch Edge     ${url} 

Launch Chrome
    [Arguments]    ${url} 
    ${chrome_options}	Evaluate	sys.modules['selenium.webdriver'].ChromeOptions()	sys,selenium.webdriver
    Call Method	${chrome_options}	add_argument	ignore-certificate-errors
    Call Method	${chrome_options}	add_argument	--start-maximized
    ${chrome_options}	Call Method	${chrome_options}	to_capabilities
    SeleniumLibrary.Open Browser	${url}	chrome    desired_capabilities=${chrome_options}
    Maximize Browser Window

Launch IE
    [Arguments]    ${url} 
    [Documentation]    Configures security settings in the registry and launches IE
    ${IsBrowserOpened}    Run Keyword And Return Status    SeleniumLibrary.Open Browser    ${url}    ie
    Return From Keyword If    ${IsBrowserOpened}
    SeleniumLibrary.Open Browser    ${url}    ie
    Maximize Browser Window

Launch Edge
    [Arguments]    ${url} 
    [Documentation]    Opens edge with ssl certificate issues bypassed
    ${edge_options}    Evaluate    msedge.selenium_tools.EdgeOptions()    msedge.selenium_tools
    Call Method    ${edge_options}    add_argument    --ignore-certificate-errors
    Call Method    ${edge_options}    add_argument    --ignore-ssl-errors\=yes
    Call Method    ${edge_options}    add_argument    --start-maximized
    Call Method    ${edge_options}    set_capability    acceptSslCerts    ${True}
    Call Method    ${edge_options}    set_capability    acceptInsecureCerts    ${True}
    ${edge_options.use_chromium}    Set Variable    true
    ${edge_capabilities}    Call Method    ${edge_options}    to_capabilities
    SeleniumLibrary.Open Browser    ${url}    edge    desired_capabilities=${edge_capabilities}
    Maximize Browser Window

Exit Browser    
    SeleniumLibrary.Go Back
    SeleniumLibrary.Close Browser

Wait Until Page Loads
    Wait Until Keyword Succeeds    5x    1s    Wait For Condition    return document.readyState === 'complete'    ${Timeout} 

Wait For Element
    [Arguments]    ${Locator}
    Wait Until Page Loads
    Wait Until Page Contains Element    ${Locator}    ${Timeout}
    Wait Until Element Is Visible       ${Locator}    ${Timeout}
    Wait Until Element Is Enabled       ${Locator}    ${Timeout}

Press A Button/Element
    [Arguments]    ${Locator}
    Wait For Element    ${Locator}
    Click Element    ${Locator}

Input in Textbox
    [Arguments]    ${Locator}    ${text}
    Wait For Element    ${Locator}
    Input Text          ${Locator}    ${text}

Checkbox Select    
    [Arguments]    ${Locator}    
    Wait For Element               ${Locator}
    Select Checkbox                ${Locator}
    Checkbox Should Be Selected    ${Locator}

Validate Current Table 
#Clean Table and converted to list for possible comparison in future use [For Excel TestData Validation]
    [Arguments]    ${Locator}      
    Wait For Element    ${Locator}
    ${TableData}=    SeleniumLibrary.Get Text    ${Locator}
    ${Word}=    Strip String    ${TableData}
    @{CleanedTableData}=    Split String    ${Word}    \n
    ${webData}    Create List    ${EMPTY}
    FOR    ${EQvalue}    IN    @{CleanedTableData}
        ${Replace}    Replace String    ${EQvalue}    \u00A0    ${SPACE}
        ${Strip}    Strip String    ${Replace}
        Append To List    ${webData}    ${Strip}
    END
    ${webList}=    Convert To List    ${webData}
    log    ${webList}

Validate Images 
#Check image if its valid and not broken
    [Arguments]    ${Locator}      
    Wait For Element    ${Locator}
    ${Element_Attribute}    Get Element Attribute    ${Locator}     src
    log    ${Element_Attribute}
    ${Response}    Run Keyword And Ignore Error   RequestsLibrary.Get    ${Element_Attribute}   
    Log    ${Response}