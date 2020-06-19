module Api.General.AccountingEntryUtil exposing (..)

import Api.Types.AccountingEntry exposing (AccountingEntry)
import Api.Types.AccountingEntryTemplate exposing (AccountingEntryTemplate)
import Api.Types.Date exposing (Date)


empty : AccountingEntry
empty = { id = 0
        , accountingYear = 0
        , bookingDate = {year = 0, month = 0, day = 0}
        , receiptNumber = ""
        , description = ""
        , credit = 0
        , debit = 0
        , amountWhole = 0
        , amountChange =  0
        }


updateId : AccountingEntry -> Int -> AccountingEntry
updateId accountingEntry id = { accountingEntry | id = id }

updateAccountingYear : AccountingEntry -> Int -> AccountingEntry
updateAccountingYear accountingEntry year = { accountingEntry | accountingYear = year }

updateBookingDate : AccountingEntry -> Date -> AccountingEntry
updateBookingDate accountingEntry date = {accountingEntry | bookingDate = date}

updateReceiptNumber : AccountingEntry -> String -> AccountingEntry
updateReceiptNumber accountingEntry rNumber = {accountingEntry | receiptNumber = rNumber}

updateDescription : AccountingEntry -> String -> AccountingEntry
updateDescription accountingEntry description = { accountingEntry | description = description }

updateCredit : AccountingEntry -> Int -> AccountingEntry
updateCredit accountingEntry credit = { accountingEntry | credit = credit }

updateDebit : AccountingEntry -> Int -> AccountingEntry
updateDebit accountingEntry debit = { accountingEntry | debit = debit }

updateAmountWhole : AccountingEntry -> Int -> AccountingEntry
updateAmountWhole accountingEntry whole = { accountingEntry | amountWhole = whole }

updateAmountChange : AccountingEntry -> Int -> AccountingEntry
updateAmountChange accountingEntry change = { accountingEntry | amountChange = change }

updateWithTemplate : AccountingEntry -> AccountingEntryTemplate -> AccountingEntry
updateWithTemplate accountingEntry aet =
    {accountingEntry | description = aet.description, credit = aet.credit, debit = aet.debit, amountWhole = aet.amountWhole, amountChange = aet.amountChange}


show : AccountingEntry -> String
show accountingEntry =
    String.concat [stringFromDate accountingEntry.bookingDate, " No.", accountingEntry.receiptNumber, " - ", accountingEntry.description, ": ", String.fromInt accountingEntry.amountWhole, ",", giveDoubleDigitChange accountingEntry.amountChange, "€ from credit: ", String.fromInt accountingEntry.credit, " - to debit: ", String.fromInt accountingEntry.debit]


stringFromDate : Date -> String
stringFromDate date =
    (String.fromInt date.day ++ "." ++ String.fromInt date.month ++ "." ++ String.fromInt date.year)


giveDoubleDigitChange : Int -> String
giveDoubleDigitChange change =
    if change < 10 then
       String.concat ["0", String.fromInt change]
    else String.fromInt change