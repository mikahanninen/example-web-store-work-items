*** Settings ***
Library     RPA.Email.ImapSmtp
Library     RPA.Robocorp.Vault
Library     RPA.Robocorp.Storage
Library     utils.py


*** Keywords ***
Email work item to be fixed
    [Arguments]    ${work_item_variables}    ${work_item}=${NONE}    ${error_message}=${NONE}
    ${error_handler}=    Get JSON Asset    Web Store Error Handler
    ${secrets}=    Get Secret    gmailtester2
    Authorize
    ...    account=${secrets}[username]
    ...    password=${secrets}[password]
    ...    imap_server=imap.gmail.com
    ...    smtp_server=smtp.gmail.com
    ${work_item_id}=    Evaluate    $work_item.id
    ${var_table}=    Dict To Html Table    ${work_item_variables}    ${work_item_id}
    ${message_content}=    CATENATE
    ...    Dear ${error_handler}[recipient_name],<br><br>
    ...    Please fix the following work item.<br><br>
    ...    <h3>INSTRUCTIONS:</h3>
    ...    1. REPLY TO THIS MESSAGE (reply address is automatically correct to trigger Control Room process)<br>
    ...    2. INCLUDE in the reply the text "WORK ITEM DATA: " (and values including {} characters)<br>
    ...    3. CORRECT faulty data in the "WORK ITEM DATA"<br>
    # ...    4. INCLUDE in the reply the text "WORK ITEM ID: " (and its value - DO NOT MODIFY THE ID!)\n
    ...    4. CHECK that reply content does not contain original message as a copy<br>
    ...    5. SEND reply<br><br>
    # ...    ---------------------------------<br>
    # ...    WORK ITEM DATA:<br>
    ...    ${var_table}<br>
    # ...    ---------------------------------<br>
    IF    "${error_message}" != "${NONE}"
        ${message_content}=    CATENATE
        ...    ${message_content}<br><br>
        ...    <h5>---ORIGINAL ERROR MESSAGE---</h5>
        ...    ${error_message}<br>
    END
    Send Message    ${secrets}[username]    ${error_handler}[recipient]
    ...    subject=Problem with work item in process %{RC_PROCESS_NAME=${EMPTY}}
    ...    body=${message_content}
    ...    reply_to=${error_handler}[respond_to]
    ...    html=${TRUE}
    RETURN    ${message_content}
