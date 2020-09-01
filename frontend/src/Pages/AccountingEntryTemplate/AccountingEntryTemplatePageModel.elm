module Pages.AccountingEntryTemplate.AccountingEntryTemplatePageModel exposing (..)

import Api.General.AccountingEntryTemplateUtil as AccountingEntryTemplateUtil
import Api.General.LanguageComponentConstants exposing (getLanguage)
import Api.Types.Account exposing (Account)
import Api.Types.AccountingEntryTemplate exposing (AccountingEntryTemplate)
import Api.Types.LanguageComponents exposing (LanguageComponents)


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


type alias Flags =
    { companyId : Int
    , accountingYear : Maybe Int
    , lang : String
    }


init : Flags -> Model
init flags =
    { lang = getLanguage flags.lang
    , companyId = flags.companyId
    , accountingYear = flags.accountingYear
    , contentDescription = ""
    , contentDebitID = ""
    , contentCreditID = ""
    , contentAmount = ""
    , aet = AccountingEntryTemplateUtil.updateCompanyId AccountingEntryTemplateUtil.empty flags.companyId
    , allAccounts = []
    , allAccountingEntryTemplates = []
    , response = ""
    , feedback = ""
    , error = ""
    , selectedCredit = Nothing
    , selectedDebit = Nothing
    , buttonPressed = False
    , editViewActive = False
    }



updateAccountingEntryTemplate : Model -> AccountingEntryTemplate -> Model
updateAccountingEntryTemplate model aet =
    { model | aet = aet }





insertData : Model -> AccountingEntryTemplate -> Model
insertData model aet =
    { model
        | contentDescription = aet.description
        , contentDebitID = String.fromInt aet.debit
        , contentCreditID = String.fromInt aet.credit
        , contentAmount = AccountingEntryTemplateUtil.showAmount aet
        , aet = aet
        , error = ""
        , selectedCredit = Just (String.fromInt aet.credit)
        , selectedDebit = Just (String.fromInt aet.debit)
        , editViewActive = True
    }


reset : Model -> Model
reset model =
    { model
        | contentDescription = ""
        , contentDebitID = ""
        , contentCreditID = ""
        , contentAmount = ""
        , aet = AccountingEntryTemplateUtil.updateCompanyId AccountingEntryTemplateUtil.empty model.companyId
        , error = ""
        , editViewActive = False
    }

