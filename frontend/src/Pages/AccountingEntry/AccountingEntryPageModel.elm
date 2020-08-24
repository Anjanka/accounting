module Pages.AccountingEntry.AccountingEntryPageModel exposing (..)

import Api.General.AccountingEntryUtil as AccountingEntryUtil
import Api.General.LanguageComponentConstants exposing (getLanguage)
import Api.Types.Account exposing (Account)
import Api.Types.AccountingEntry exposing (AccountingEntry)
import Api.Types.AccountingEntryTemplate exposing (AccountingEntryTemplate)
import Api.Types.LanguageComponents exposing (LanguageComponents)
import Pages.AccountingEntry.InputContent exposing (InputContent, emptyInputContent)


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
    , accountViewActive : Bool
    , selectedTemplate : Maybe String
    , selectedCredit : Maybe String
    , selectedDebit : Maybe String
    }


type alias Flags =
    { companyId : Int
    , accountingYear : Int
    , lang : String
    }


init : Flags -> Model
init flags =
    { lang = getLanguage flags.lang
    , companyId = flags.companyId
    , accountingYear = flags.accountingYear
    , content = emptyInputContent
    , accountingEntry = AccountingEntryUtil.emptyWith { companyId = flags.companyId, accountingYear = flags.accountingYear }
    , allAccountingEntries = []
    , allAccounts = []
    , allAccountingEntryTemplates = []
    , feedback = ""
    , error = ""
    , editActive = False
    , accountViewActive = False
    , selectedTemplate = Nothing
    , selectedCredit = Nothing
    , selectedDebit = Nothing
    }


reset : Model -> Model
reset model =
    { model
        | content = emptyInputContent
        , accountingEntry = AccountingEntryUtil.emptyWith { companyId = model.companyId, accountingYear = model.accountingYear }
        , error = ""
        , editActive = False
        , selectedTemplate = Nothing
        , selectedCredit = Nothing
        , selectedDebit = Nothing
    }


updateContent : Model -> InputContent -> Model
updateContent model content =
    { model | content = content }


updateAccountingEntry : Model -> AccountingEntry -> Model
updateAccountingEntry model accountingEntry =
    { model | accountingEntry = accountingEntry }


updateFeedback : Model -> String -> Model
updateFeedback model feedback =
    { model | feedback = feedback }


updateError : Model -> String -> Model
updateError model error =
    { model | error = error }
