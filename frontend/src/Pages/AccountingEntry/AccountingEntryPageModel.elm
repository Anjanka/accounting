module Pages.AccountingEntry.AccountingEntryPageModel exposing (..)


import Api.Types.Account exposing (Account)
import Api.Types.AccountingEntry exposing (AccountingEntry)
import Api.Types.AccountingEntryTemplate exposing (AccountingEntryTemplate)
type alias Model =
    { companyId : Int
    , accountingYear : Int
    , contentBookingDate : String
    , contentReceiptNumber : String
    , contentDescription : String
    , contentDebitID : String
    , contentCreditID : String
    , contentAmount : String
    , accountingEntry : AccountingEntry
    , allAccountingEntries : List AccountingEntry
    , allAccounts : List Account
    , allAccountingEntryTemplates : List AccountingEntryTemplate
    , dateValidation : String
    , response : String
    , feedback : String
    , error : String
    , editActive : Bool
    , selectedTemplate : Maybe String
    , selectedCredit : Maybe String
    , selectedDebit : Maybe String
    }
