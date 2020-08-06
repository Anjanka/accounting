module Pages.AccountingEntry.AccountingEntryPageModel exposing (..)

import Api.Types.Account exposing (Account)
import Api.Types.AccountingEntry exposing (AccountingEntry)
import Api.Types.AccountingEntryTemplate exposing (AccountingEntryTemplate)
import Api.Types.LanguageComponents exposing (LanguageComponents)
import Pages.AccountingEntry.InputContent exposing (InputContent)


type alias Model =
    { lang : LanguageComponents
    , companyId : Int
    , accountingYear : Int
    , content : InputContent
    , accountingEntry : AccountingEntry
    , allAccountingEntries : List AccountingEntry
    , allAccounts : List Account
    , allAccountingEntryTemplates : List AccountingEntryTemplate
    , feedback : String
    , error : String
    , editActive : Bool
    , accountViewActive: Bool
    , selectedTemplate : Maybe String
    , selectedCredit : Maybe String
    , selectedDebit : Maybe String
    }



updateContent : Model -> InputContent -> Model
updateContent model content =
    {model | content = content}

updateAccountingEntry : Model -> AccountingEntry -> Model
updateAccountingEntry model accountingEntry =
    { model | accountingEntry = accountingEntry }

updateFeedback : Model -> String -> Model
updateFeedback model feedback =
    {model | feedback = feedback}

updateError : Model -> String -> Model
updateError model error =
    {model | error = error}