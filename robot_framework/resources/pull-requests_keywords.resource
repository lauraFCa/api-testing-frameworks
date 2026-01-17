*** Settings ***
Library           RequestsLibrary
Library           JSONLibrary
Resource          variables.robot
Resource    base_keywords.resource

*** Variables ***
${PR_URI}          ${BASE_URL}/pulls
${SESSION_NAME}         pull-requests_tests


*** Keywords ***
## Base Keywords
pull-requests session request
    [Documentation]    Creates an API session
    [Arguments]    ${session_name}=${SESSION_NAME} 
    Create Session    ${session_name}    ${BASE_URL}
    
status code should be ${expected_code}
    Should Be Equal As Integers    ${RESPONSE.status_code}    ${expected_code}

JSON field '${field}' should be ${value}
    [Arguments]            ${json_field_path}
    ${json_resp}=          Convert String to JSON      ${RESPONSE.content}
    ${real_value0}=        Get Value From Json         ${json_resp}          ${json_field_path}
    ${real_value}=         Set Variable                ${real_value0[0]}
    ${compared_value}=     Convert To String           ${real_value}
    Should Be Equal        ${compared_value}           ${value}

JSON array field should have ${amount} items
    [Arguments]       ${json_field_path}
    ${json_resp}=     Convert String to JSON      ${RESPONSE.content}
    ${real_value}=    Get Value From Json         ${json_resp}       ${json_field_path}
    ${expected_amount}=    Convert To Integer        ${amount}
    ${real_amount}=       Get Length                ${real_value[0]}
    Should Be Equal As Numbers    ${real_amount}    ${expected_amount}


## PULL REQUESTS Keywords

user requests all Pull Requests
    [Arguments]    ${session_name}=${SESSION_NAME}    ${expected_status_code}=200
    &{github_header}=    Set_Github_Header
    ${response}=    GET On Session    ${session_name}    ${PR_URI}    headers=&{github_header}    expected_status=ANY
    Fail_response_message          ${expected_status_code}    ${response}
    Should Be Equal As Integers    ${expected_status_code}    ${response.status_code}
    Set Suite Variable    ${RESPONSE}    ${response}


user try to update Pull Request with ID ${pr_id}
    [Arguments]    ${update_payload}    ${session_name}=${SESSION_NAME}    ${expected_status_code}=200
    &{github_header}=    Set_Github_Header
    ${response}=    PATCH On Session    ${session_name}    ${PR_URI}/${pr_id}    json=${update_payload}    headers=&{github_header}    expected_status=ANY
    Fail_response_message          ${expected_status_code}    ${response}
    Should Be Equal As Integers    ${expected_status_code}    ${response.status_code}
    Set Suite Variable    ${RESPONSE}    ${response}


user requests all Comments in Pull Request with ID ${pr_id}
    [Arguments]    ${session_name}=${SESSION_NAME}    ${expected_status_code}=200
    &{github_header}=    Set_Github_Header
    ${response}=    GET On Session    ${session_name}    ${PR_URI}/${pr_id}/comments    headers=&{github_header}    expected_status=ANY
    Fail_response_message    ${expected_status_code}    ${response}
    Should Be Equal As Integers    ${expected_status_code}    ${response.status_code}
    Set Suite Variable    ${RESPONSE}    ${response}

