*** Settings ***
Library     Collections
Library     RPA.Robocorp.WorkItems
Library     RPA.Excel.Files
Library     RPA.Tables
Library     RPA.FileSystem
Library     utils.py


*** Variables ***
${ORDER_FILE_NAME}=     orders.xlsx


*** Tasks ***
Split orders file
    [Documentation]    Read orders file from input item and split into outputs
    TRY
        ${email}=    Get Work Item Variable    email
        # ${data}    ${work_item_id}=    Extract Data And Id    ${email}[text]
        @{tables}=    Html Tables To Dicts    ${email}[text]
        IF    len($tables) == 0
            Pass Execution    Could not get work item data from the email
        END
        ${data}=    Set Variable    ${tables}[0][0]
        ${work_item_id}=    Set Variable    ${tables}[0][1]
        ${status}=    Run Keyword and Return Status    Update Workitem    ${work_item_id}    ${data}
        IF    not $status
            Pass Execution    Could not update work item variables
        END
        ${status}=    Run Keyword and Return Status    Retry Workitem    ${work_item_id}
        IF    not $status    Pass Execution    Could not retry work item
    EXCEPT
        # NORMAL WORKFLOW
        TRY
            Get Work Item File    ${ORDER_FILE_NAME}
        EXCEPT    FileNotFoundError    type=START
            Copy file    devdata/work-items-in/split-orders-file-test-input/orders.xlsx    orders.xlsx
        END
        Open Workbook    ${ORDER_FILE_NAME}
        ${table}=    Read Worksheet As Table    header=True
        ${groups}=    Group Table By Column    ${table}    Name
        FOR    ${products}    IN    @{groups}
            ${rows}=    Export Table    ${products}
            @{items}=    Create List
            FOR    ${row}    IN    @{rows}
                ${name}=    Set Variable    ${row}[Name]
                ${zip}=    Set Variable    ${row}[Zip]
                Append To List    ${items}    ${row}[Item]
            END
            ${variables}=    Create Dictionary
            ...    Name=${name}
            ...    Zip=${zip}
            ...    Items=${items}
            Create Output Work Item    variables=${variables}    save=True
        END
    END
