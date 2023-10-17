module Pages.AccountingEntryTemplate.AccountingEntryTemplatePageModel exposing (..)

import Api.General.AccountingEntryTemplateUtil as AccountingEntryTemplateUtil
import Api.General.Amount as Amount exposing (Amount)
import Api.General.LanguageComponentConstants exposing (getLanguage)
import Api.Types.Account exposing (Account)
import Api.Types.AccountingEntryTemplate exposing (AccountingEntryTemplate)
import Api.Types.LanguageComponents exposing (LanguageComponents)
import Pages.FromInput exposing (FromInput)
import Pages.Util.AuthorizedAccess exposing (AuthorizedAccess)


type alias Model =
    { lang : LanguageComponents
    , companyId : Int
    , accountingYear : Maybe Int
    , contentDescription : String
    , contentDebitID : String
    , contentCreditID : String
    , contentAmount : FromInput Amount
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
    , authorizedAccess : AuthorizedAccess
    }


type alias Flags =
    { companyId : Int
    , accountingYear : Maybe Int
    , lang : String
    , authorizedAccess : AuthorizedAccess
    }


init : Flags -> Model
init flags =
    { lang = getLanguage flags.lang
    , companyId = flags.companyId
    , accountingYear = flags.accountingYear
    , contentDescription = ""
    , contentDebitID = ""
    , contentCreditID = ""
    , contentAmount = Amount.amountFromInput
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
    , authorizedAccess = flags.authorizedAccess
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
        , contentAmount = Amount.updateAmountInFromInput model.contentAmount (AccountingEntryTemplateUtil.amountOf aet)
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
        , contentAmount = Amount.amountFromInput
        , aet = AccountingEntryTemplateUtil.updateCompanyId AccountingEntryTemplateUtil.empty model.companyId
        , error = ""
        , editViewActive = False
    }


updateContentAmount : Model -> FromInput Amount -> Model
updateContentAmount model input =
    { model
        | contentAmount = input
    }
