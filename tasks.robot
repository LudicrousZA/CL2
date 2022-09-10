*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library             RPA.Browser.Selenium    auto_close=${False}
Library             RPA.HTTP
Library             RPA.Tables
Library             RPA.PDF
Library             RPA.Archive
Library             Dialogs
Library             RPA.Robocorp.Vault


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    ${orders}=    Get orders
    # Close the annoying modal
    # ${first}=    Get table row    ${orders}    0
    # Fill the form    ${first}
    # Preview the robot
    # Submit the order
    # ${pdf}=    Store the receipt as a PDF file    ${first}[Order number]
    # ${screenshot}=    Take a screenshot of the robot    ${first}[Order number]
    # Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
    # Go to order another robot

    FOR    ${row}    IN    @{orders}
        Close the annoying modal
        Fill the form    ${row}
        Preview the robot
        Submit the order
        ${pdf}=    Store the receipt as a PDF file    ${row}[Order number]
        ${screenshot}=    Take a screenshot of the robot    ${row}[Order number]
        Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
        Go to order another robot
    END
    Create a ZIP file of the receipts
    Close Browser


*** Keywords ***
Open the robot order website
    ${secret_URL}=    Get Secret    secret_URL
    Open Available Browser    ${secret_URL}[URL]

Get orders
    ${URL}=    Get Value From User
    ...    Please provide the URL of the orders CSV file.
    ...    https://robotsparebinindustries.com/orders.csv
    Download    ${URL}    overwrite=True
    ${table}=    Read table from CSV    orders.csv
    RETURN    ${table}

Close the annoying modal
    Wait Until Element Is Visible    class:alert-buttons
    Click Button    OK

Fill the form
    [Arguments]    ${row}
    Select From List By Value    id:head    ${row}[Head]
    Select Radio Button    body    ${row}[Body]
    Input Text    class:form-control    ${row}[Legs]
    Input Text    id:address    ${row}[Address]

Preview the robot
    Click Button    id:preview

Submit the order
    ${res}=    Is Element Visible    id:order
    WHILE    ${res}
        Wait Until Keyword Succeeds    5x    2 sec    Click Button    id:order
        ${res}=    Is Element Visible    id:order
    END

Store the receipt as a PDF file
    [Arguments]    ${order}
    Wait Until Element Is Visible    id:receipt
    ${receipt}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${receipt}    ${OUTPUT_DIR}${/}Receipts${/}${order}.pdf

    RETURN    ${OUTPUT_DIR}${/}Receipts${/}${order}.pdf

Take a screenshot of the robot
    [Arguments]    ${order}
    Screenshot    id:robot-preview-image    ${OUTPUT_DIR}${/}${order}.png

    RETURN    ${OUTPUT_DIR}${/}${order}.png

Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${screenshot}    ${pdf}
    ${files}=    Create List    ${screenshot}:align=center
    Add Files To Pdf    ${files}    ${pdf}    True

Go to order another robot
    Click Button    id:order-another

Create a ZIP file of the receipts
    ${zip_file_name}=    Set Variable    ${OUTPUT_DIR}/Receipts_PDFs.zip
    Archive Folder With Zip
    ...    ${OUTPUT_DIR}${/}Receipts
    ...    ${zip_file_name}
