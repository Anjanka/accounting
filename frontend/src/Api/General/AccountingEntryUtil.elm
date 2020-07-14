module Api.General.AccountingEntryUtil exposing (..)

import Api.General.DateUtil as DateUtil
import Api.Types.AccountingEntry exposing (AccountingEntry)
import Api.Types.AccountingEntryCreationParams exposing (AccountingEntryCreationParams)
import Api.Types.AccountingEntryKey exposing (AccountingEntryKey)
import Api.Types.AccountingEntryTemplate exposing (AccountingEntryTemplate)
import Api.Types.Date exposing (Date)


empty : AccountingEntry
empty =
    { companyId = 0
    , id = 0
    , accountingYear = 0
    , bookingDate = { year = 0, month = 0, day = 0 }
    , receiptNumber = ""
    , description = ""
    , credit = 0
    , debit = 0
    , amountWhole = 0
    , amountChange = 0
    }

emptyWith : {companyId : Int, accountingYear : Int} -> AccountingEntry
emptyWith params =
    {empty
    |companyId = params.companyId
    , accountingYear = params.accountingYear
    , bookingDate = { year = params.accountingYear, month = 0, day = 0 }}

updateCompanyId : AccountingEntry -> Int -> AccountingEntry
updateCompanyId accountingEntry companyId =
    { accountingEntry | companyId = companyId }


updateId : AccountingEntry -> Int -> AccountingEntry
updateId accountingEntry id =
    { accountingEntry | id = id }


updateAccountingYear : AccountingEntry -> Int -> AccountingEntry
updateAccountingYear accountingEntry year =
    { accountingEntry | accountingYear = year }


updateBookingDate : AccountingEntry -> Date -> AccountingEntry
updateBookingDate accountingEntry date =
    { accountingEntry | bookingDate = date }


updateReceiptNumber : AccountingEntry -> String -> AccountingEntry
updateReceiptNumber accountingEntry rNumber =
    { accountingEntry | receiptNumber = rNumber }


updateDescription : AccountingEntry -> String -> AccountingEntry
updateDescription accountingEntry description =
    { accountingEntry | description = description }


updateCredit : AccountingEntry -> Int -> AccountingEntry
updateCredit accountingEntry credit =
    { accountingEntry | credit = credit }


updateDebit : AccountingEntry -> Int -> AccountingEntry
updateDebit accountingEntry debit =
    { accountingEntry | debit = debit }


updateAmountWhole : AccountingEntry -> Int -> AccountingEntry
updateAmountWhole accountingEntry whole =
    { accountingEntry | amountWhole = whole }


updateAmountChange : AccountingEntry -> Int -> AccountingEntry
updateAmountChange accountingEntry change =
    { accountingEntry | amountChange = change }


updateCompleteAmount : AccountingEntry -> Int -> Int -> AccountingEntry
updateCompleteAmount accountingEntry whole change =
    { accountingEntry | amountWhole = whole, amountChange = change }


updateWithTemplate : AccountingEntry -> AccountingEntryTemplate -> AccountingEntry
updateWithTemplate accountingEntry aet =
    { accountingEntry | description = aet.description, credit = aet.credit, debit = aet.debit, amountWhole = aet.amountWhole, amountChange = aet.amountChange }


show : AccountingEntry -> String
show accountingEntry =
    String.concat [ String.fromInt accountingEntry.companyId, " - ", stringFromDate accountingEntry.bookingDate, " No.", accountingEntry.receiptNumber, " - ", accountingEntry.description, ": ", showAmount accountingEntry, "€ from credit: ", String.fromInt accountingEntry.credit, " - to debit: ", String.fromInt accountingEntry.debit ]


stringFromDate : Date -> String
stringFromDate date =
    String.fromInt date.day ++ "." ++ String.fromInt date.month ++ "." ++ String.fromInt date.year


showAmount : AccountingEntry -> String
showAmount accountingEntry =
    String.fromInt accountingEntry.amountWhole ++ "," ++ giveDoubleDigitChange accountingEntry.amountChange


giveDoubleDigitChange : Int -> String
giveDoubleDigitChange change =
    if change < 10 then
        String.concat [ "0", String.fromInt change ]

    else
        String.fromInt change


isValid : AccountingEntry -> Bool
isValid accountingEntry =
    accountingEntry.companyId
        /= 0
        && accountingEntry.accountingYear
        /= 0
        && DateUtil.isNotEmpty accountingEntry.bookingDate
        && not (String.isEmpty accountingEntry.receiptNumber)
        && not (String.isEmpty accountingEntry.description)
        && accountingEntry.credit
        /= 0
        && accountingEntry.debit
        /= 0
        && (accountingEntry.amountWhole /= 0 || accountingEntry.amountChange /= 0)

isEmpty : AccountingEntry -> Bool
isEmpty accountingEntry =
    accountingEntry.companyId == 0
    && accountingEntry.id == 0
    && accountingEntry.accountingYear == 0
    && accountingEntry.bookingDate == { year = 0, month = 0, day = 0 }
    && accountingEntry.receiptNumber == ""
    && accountingEntry.description == ""
    && accountingEntry.credit == 0
    && accountingEntry.debit == 0
    && accountingEntry.amountWhole == 0
    && accountingEntry.amountChange == 0


getCreationParams : AccountingEntry -> AccountingEntryCreationParams
getCreationParams accountingEntry =
    { companyId = accountingEntry.companyId
    , accountingYear = accountingEntry.accountingYear
    , bookingDate = accountingEntry.bookingDate
    , receiptNumber = accountingEntry.receiptNumber
    , description = accountingEntry.description
    , credit = accountingEntry.credit
    , debit = accountingEntry.debit
    , amountWhole = accountingEntry.amountWhole
    , amountChange = accountingEntry.amountChange
    }

getKey : AccountingEntry -> AccountingEntryKey
getKey accountingEntry =
    {companyId = accountingEntry.companyId, accountingYear = accountingEntry.accountingYear, id = accountingEntry.id}