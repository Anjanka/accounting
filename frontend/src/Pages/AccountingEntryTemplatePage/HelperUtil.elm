module Pages.AccountingEntryTemplatePage.HelperUtil exposing (..)



import Api.General.AccountingEntryTemplateUtil as AccountingEntryTemplateUtil
import Api.Types.AccountingEntryTemplate exposing (AccountingEntryTemplate)
import Pages.AccountingEntryTemplatePage.AccountingEntryTemplatePageModel exposing (Model)



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

