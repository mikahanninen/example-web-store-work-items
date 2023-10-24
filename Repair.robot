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
    # TODO. IF %{RC_WORKITEM_ID} IS NOT AVAILABLE THEN CAN'T SEND EMAIL
    ${message_content}=    CATENATE
    ...    Dear ${error_handler}[recipient_name],\n\n
    ...    Please fix the following work item:\n\n
    ...    COPY TO REPLY MESSAGE STARTING FROM BELOW
    ...    WORK ITEM DATA:
    ...    ${work_item}\n\n
    ...    WORK ITEM ID: %{RC_WORKITEM_ID=NA}\n\n
    ...    COPY TO REPLY MESSAGE INCLUDING THE ABOVE
    ...    NOTE! PLEASE DO NOT MODIFY WORK_ITEM_ID!
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
