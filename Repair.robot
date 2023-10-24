*** Settings ***
Library     RPA.Email.ImapSmtp
Library     RPA.Robocorp.Vault
Library     RPA.Robocorp.Storage


*** Keywords ***
Email work item to be fixed
    [Arguments]    ${work_item}
    ${error_handler}=    Get JSON Asset    Web Store Error Handler
    ${secrets}=    Get Secret    gmailtester2
    Authorize
    ...    account=${secrets}[username]
    ...    password=${secrets}[password]
    ...    imap_server=imap.gmail.com
    ...    smtp_server=smtp.gmail.com
    ${message_content}=    Set Variable
    ...    Dear ${error_handler}[recipient_name],\n\nPlease fix the following work item:\n\n${work_item}\n\nWork item ID: %{RC_WORKITEM_ID=NA}
    Send Message    ${error_handler}[respond_to]    ${error_handler}[recipient]
    ...    subject=Problem with work item in process %{RC_PROCESS_NAME=${EMPTY}}
    ...    body=${message_content}
