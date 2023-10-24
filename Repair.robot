*** Settings ***
Library     RPA.Email.ImapSmtp
Library     RPA.Robocorp.Vault
Library     RPA.Robocorp.Storage


*** Keywords ***
Email work item to be fixed
    [Arguments]    ${work_item}    ${error_message}=${NONE}
    ${error_handler}=    Get JSON Asset    Web Store Error Handler
    ${secrets}=    Get Secret    gmailtester2
    Authorize
    ...    account=${secrets}[username]
    ...    password=${secrets}[password]
    ...    imap_server=imap.gmail.com
    ...    smtp_server=smtp.gmail.com
    ${message_content}=    CATENATE
    ...    Dear ${error_handler}[recipient_name],\n\n
    ...    Please fix the following work item:\n\n
    ...    ---WORK ITEM---\n
    ...    ${work_item}\n
    ...    ---------------\n\n
    ...    WORK_ITEM_ID: %{RC_WORKITEM_ID=NA}\n
    ...    NOTE! PLEASE DO NOT MODIFY WORK_ITEM_ID!
    IF    "${error_message}" != "${NONE}"
        ${message_content}=    Set Variable    ${message_content}\n
        ...    ---ORIGINAL ERROR MESSAGE---\n
        ...    ${error_message}\n
        ...    ------------------\n\n
    END
    Send Message    ${secrets}[username]    ${error_handler}[recipient]
    ...    subject=Problem with work item in process %{RC_PROCESS_NAME=${EMPTY}}
    ...    body=${message_content}
    ...    reply_to=${error_handler}[respond_to]
