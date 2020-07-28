module Pages.AccountingEntryTemplate.AccountingEntryTemplatePageModel exposing (..)

import Api.Types.Account exposing (Account)
import Api.Types.AccountingEntryTemplate exposing (AccountingEntryTemplate)
import Api.Types.Language exposing (LanguageComponents)


type alias Model =
    { lang : LanguageComponents
    , companyId : Int
    , accountingYear : Maybe Int
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
