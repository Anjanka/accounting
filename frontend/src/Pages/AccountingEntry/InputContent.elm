module Pages.AccountingEntry.InputContent exposing (..)

import Api.General.AccountingEntryTemplateUtil as AccountingEntryTemplateUtil
import Api.General.DateUtil exposing (showDay, showMonth)
import Api.Types.AccountingEntry exposing (AccountingEntry)
import Api.Types.AccountingEntryTemplate exposing (AccountingEntryTemplate)
import Basics.Extra exposing (flip)
import Pages.Amount as Amount exposing (Amount)
import Pages.FromInput as FromInput exposing (FromInput)


type alias InputContent =
    { day : String
    , month : String
    , receiptNumber : String
    , description : String
    , debitId : String
    , creditId : String
    , amount : FromInput Amount
    }


emptyInputContent : InputContent
emptyInputContent =
    { day = ""
    , month = ""
    , receiptNumber = ""
    , description = ""
    , debitId = ""
    , creditId = ""
    , amount = Amount.amountFromInput
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


updateAmount : InputContent -> FromInput Amount -> InputContent
updateAmount inputContent afi =
    { inputContent | amount = afi }


updateWithEntry : InputContent -> AccountingEntry -> InputContent
updateWithEntry inputContent accountingEntry =
    let
        newAmountFI =
            inputContent.amount
                |> flip FromInput.updateText (Amount.displayAmount (Amount.amountOf accountingEntry))
                |> flip FromInput.updateValue (Amount.amountOf accountingEntry)
    in
    { inputContent
        | day = showDay accountingEntry.bookingDate.day
        , month = showMonth accountingEntry.bookingDate.month
        , receiptNumber = accountingEntry.receiptNumber
        , description = accountingEntry.description
        , creditId = String.fromInt accountingEntry.credit
        , debitId = String.fromInt accountingEntry.debit
        , amount = newAmountFI
    }


updateWithTemplate : InputContent -> AccountingEntryTemplate -> InputContent
updateWithTemplate inputContent aet =
    let
        newAmountText =
            if aet.amountWhole /= 0 || aet.amountChange /= 0 then
                AccountingEntryTemplateUtil.showAmount aet

            else
                ""

        newAmountFI =
            inputContent.amount
                |> flip FromInput.updateText newAmountText
                |> flip FromInput.updateValue { whole = aet.amountWhole, change = aet.amountChange }
    in
    { inputContent
        | description = aet.description
        , creditId = String.fromInt aet.credit
        , debitId = String.fromInt aet.debit
        , amount = newAmountFI
    }
