module Pages.AccountingEntryTemplatePage.AccountingEntryTemplatePageModel exposing (..)


import Api.Types.Account exposing (Account)
import Api.Types.AccountingEntryTemplate exposing (AccountingEntryTemplate)
type alias Model =
    { companyId : Int
    , contentDescription : String
    , contentDebitID : String
    , contentCreditID : String
    , contentAmount : String
    , aet : AccountingEntryTemplate
    , allAccounts : List Account
    , allAccountingEntryTemplates : List AccountingEntryTemplate
    , response : String
    , feedback : String
    , error : String
    , selectedCredit : Maybe String
    , selectedDebit : Maybe String
    , buttonPressed : Bool
    , editViewActive : Bool
    }
