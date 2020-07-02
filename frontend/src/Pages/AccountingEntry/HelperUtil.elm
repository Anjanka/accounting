module Pages.AccountingEntry.HelperUtil exposing (..)

import Api.General.AccountingEntryTemplateUtil as AccountingEntryTemplateUtil
import Api.General.AccountingEntryUtil as AccountingEntryUtil
import Api.General.DateUtil as DateUtil
import Api.Types.AccountingEntry exposing (AccountingEntry)
import Api.Types.AccountingEntryTemplate exposing (AccountingEntryTemplate)
import List.Extra
import Pages.AccountingEntry.AccountingEntryPageModel exposing (Model)





updateAccountingEntry : Model -> AccountingEntry -> Model
updateAccountingEntry model accountingEntry =
    { model | accountingEntry = accountingEntry }


insertForEdit : Model -> AccountingEntry -> Model
insertForEdit model accountingEntry =
    { model
        | contentBookingDate = DateUtil.showDayAndMonth accountingEntry.bookingDate
        , contentReceiptNumber = accountingEntry.receiptNumber
        , contentDescription = accountingEntry.description
        , contentCreditID = String.fromInt accountingEntry.credit
        , contentDebitID = String.fromInt accountingEntry.debit
        , contentAmount = AccountingEntryUtil.showAmount accountingEntry
        , accountingEntry = accountingEntry
        , editActive = True
        , selectedTemplate = Nothing
        , selectedCredit = Just (String.fromInt accountingEntry.credit)
        , selectedDebit = Just (String.fromInt accountingEntry.debit)
    }


insertTemplateData : Model -> Maybe String -> Model
insertTemplateData model newSelectedTemplate =
    case newSelectedTemplate of
        Just description ->
            let
                selectedTemplate =
                    findEntry newSelectedTemplate model.allAccountingEntryTemplates
            in
            if selectedTemplate.amountWhole /= 0 && selectedTemplate.amountChange /= 0 then
                { model
                    | contentDescription = description
                    , contentCreditID = String.fromInt selectedTemplate.credit
                    , contentDebitID = String.fromInt selectedTemplate.debit
                    , contentAmount = AccountingEntryTemplateUtil.showAmount selectedTemplate
                    , accountingEntry = AccountingEntryUtil.updateWithTemplate model.accountingEntry selectedTemplate
                    , selectedTemplate = newSelectedTemplate
                    , selectedCredit = Just (String.fromInt selectedTemplate.credit)
                    , selectedDebit = Just (String.fromInt selectedTemplate.debit)
                }

            else
                { model
                    | contentDescription = description
                    , contentCreditID = String.fromInt selectedTemplate.credit
                    , contentDebitID = String.fromInt selectedTemplate.debit
                    , contentAmount = ""
                    , accountingEntry = AccountingEntryUtil.updateWithTemplate model.accountingEntry selectedTemplate
                    , selectedTemplate = newSelectedTemplate
                    , selectedCredit = Just (String.fromInt selectedTemplate.credit)
                    , selectedDebit = Just (String.fromInt selectedTemplate.debit)
                }

        Nothing ->
            { model | selectedTemplate = newSelectedTemplate }


reset : Model -> Model
reset model =
    { model
        | contentDescription = ""
        , contentBookingDate = ""
        , contentReceiptNumber = ""
        , contentDebitID = ""
        , contentCreditID = ""
        , contentAmount = ""
        , accountingEntry = AccountingEntryUtil.empty
        , error = ""
        , editActive = False
        , selectedTemplate = Nothing
        , selectedCredit = Nothing
        , selectedDebit = Nothing
    }



findEntry : Maybe String -> List AccountingEntryTemplate -> AccountingEntryTemplate
findEntry selectedValue allAccountingEntryTemplates =
    case selectedValue of
        Just string ->
            case List.Extra.find (\aet -> aet.description == string) allAccountingEntryTemplates of
                Just value ->
                    value

                Nothing ->
                    AccountingEntryTemplateUtil.empty

        Nothing ->
            AccountingEntryTemplateUtil.empty


getBalance : String -> List AccountingEntry -> String
getBalance accountIdCandidate allEntries =
    case String.toInt accountIdCandidate of
        Just accountId ->
            showBalance (getAmount accountId allEntries)

        Nothing ->
            ""


getAmount : Int -> List AccountingEntry -> Int
getAmount accountId allEntries =
    let
        allEntriesCredit =
            List.filter (\entry -> entry.credit == accountId) allEntries

        allEntriesDebit =
            List.filter (\entry -> entry.debit == accountId) allEntries
    in
    List.foldr (+) 0 (List.map (\entry -> (entry.amountWhole * 100) + entry.amountChange) allEntriesCredit) - List.foldr (+) 0 (List.map (\entry -> (entry.amountWhole * 100) + entry.amountChange) allEntriesDebit)


showBalance : Int -> String
showBalance amount =
    let
        amountString =
            String.fromInt amount
    in
    if amount >= 100 || amount <= -100 then
        String.dropRight 2 amountString ++ "," ++ String.right 2 amountString

    else if amount < 100 && amount > 9 then
        "0," ++ amountString

    else if amount > -100 && amount < -9 then
        "-0," ++ amountString

    else if amount < 10 && amount > 0 then
        "0,0" ++ amountString

    else if amount > -10 && amount < 0 then
        "-0,0" ++ String.right 1 amountString

    else
        "0"
