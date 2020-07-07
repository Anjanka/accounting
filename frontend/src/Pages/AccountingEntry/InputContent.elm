module Pages.AccountingEntry.InputContent exposing (..)

import Api.General.AccountingEntryTemplateUtil as AccountingEntryTemplateUtil
import Api.General.AccountingEntryUtil exposing (showAmount)
import Api.General.DateUtil exposing (showDay, showMonth)
import Api.Types.AccountingEntry exposing (AccountingEntry)
import Api.Types.AccountingEntryTemplate exposing (AccountingEntryTemplate)


type alias InputContent =
    { day : String
    , month : String
    , receiptNumber : String
    , description : String
    , debitId : String
    , creditId : String
    , amount : String
    }


emptyInputContent : InputContent
emptyInputContent =
    { day = ""
    , month = ""
    , receiptNumber = ""
    , description = ""
    , debitId = ""
    , creditId = ""
    , amount = ""
    }


updateDay : InputContent -> String -> InputContent
updateDay inputContent day =
    { inputContent | day = day }


updateMonth : InputContent -> String -> InputContent
updateMonth inputContent month =
    { inputContent | month = month }


updateReceiptNumber : InputContent -> String -> InputContent
updateReceiptNumber inputContent receiptNumber =
    { inputContent | receiptNumber = receiptNumber }


updateDescription : InputContent -> String -> InputContent
updateDescription inputContent description =
    { inputContent | description = description }


updateCreditId : InputContent -> String -> InputContent
updateCreditId inputContent creditId =
    { inputContent | creditId = creditId }


updateDebitId : InputContent -> String -> InputContent
updateDebitId inputContent debitId =
    { inputContent | debitId = debitId }


updateAmount : InputContent -> String -> InputContent
updateAmount inputContent amount =
    { inputContent | amount = amount }


updateWithEntry : InputContent -> AccountingEntry -> InputContent
updateWithEntry inputContent accountingEntry =
    { inputContent
        | day = showDay accountingEntry.bookingDate.day
        , month = showMonth accountingEntry.bookingDate.month
        , receiptNumber = accountingEntry.receiptNumber
        , description = accountingEntry.description
        , creditId = String.fromInt accountingEntry.credit
        , debitId = String.fromInt accountingEntry.debit
        , amount = showAmount accountingEntry
    }


updateWithTemplate : InputContent -> AccountingEntryTemplate -> InputContent
updateWithTemplate inputContent aet =
    let
        newAmount =
            if aet.amountWhole /= 0 && aet.amountChange /= 0 then
                AccountingEntryTemplateUtil.showAmount aet

            else
                ""
    in
    { inputContent
        | description = aet.description
        , creditId = String.fromInt aet.credit
        , debitId = String.fromInt aet.debit
        , amount = newAmount
    }
