*** Settings ***
Library     RPA.Email.ImapSmtp
Library     RPA.Robocorp.Vault
Library     RPA.Robocorp.Storage


*** Keywords ***
Email work item to be fixed
    [Arguments]    ${work_item_variables}    ${work_item}    ${error_message}=${NONE}
    ${error_handler}=    Get JSON Asset    Web Store Error Handler
    ${secrets}=    Get Secret    gmailtester2
    Authorize
    ...    account=${secrets}[username]
    ...    password=${secrets}[password]
    ...    imap_server=imap.gmail.com
    ...    smtp_server=smtp.gmail.com
    ${work_item_id}=    Evaluate    $work_item.id
    ${message_content}=    CATENATE
    ...    Dear ${error_handler}[recipient_name],\n\n
    ...    Please fix the following work item.\n\n
    ...    INSTRUCTIONS:\n
    ...    1. REPLY TO THIS MESSAGE (reply address is automatically correct to trigger Control Room process)\n
    ...    2. INCLUDE in the reply the text "WORK ITEM DATA: " (and values including {} characters)\n
    ...    3. CORRECT faulty data in the "WORK ITEM DATA"\n
    ...    4. INCLUDE in the reply the text "WORK ITEM ID: " (and its value (DO NOT MODIFY THE ID))\n
    ...    5. SEND reply\n\n
    ...    --------------------------------------------\n
    ...    WORK ITEM DATA:\n
    ...    ${work_item_variables}\n\n
    ...    WORK ITEM ID: ${work_item_id}\n\n
    ...    --------------------------------------------\n
    IF    "${error_message}" != "${NONE}"
        ${message_content}=    CATENATE
        ...    ${message_content}\n\n
        ...    ---ORIGINAL ERROR MESSAGE---\n
        ...    ${error_message}\n
    END
    Send Message    ${secrets}[username]    ${error_handler}[recipient]
    ...    subject=Problem with work item in process %{RC_PROCESS_NAME=${EMPTY}}
    ...    body=${message_content}
    ...    reply_to=${error_handler}[respond_to]
