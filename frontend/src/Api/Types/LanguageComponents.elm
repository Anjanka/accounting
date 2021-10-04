module Api.Types.LanguageComponents exposing (..)


import Api.General.AccountUtil exposing (AccountType, AccountCategory)
import Api.Types.ReportLanguageComponents exposing (ReportLanguageComponents)
type alias LanguageComponents =
    { short : String
    , name : String
    , id : String
    , accountName : String
    , companyName : String
    , description : String
    , saveChanges : String
    , delete : String
    , back : String
    , cancel : String
    , edit : String
    , account : String
    , debit : String
    , credit : String
    , template : String
    , accountingEntry : String
    , company : String
    , pleaseSelectCompany : String
    , pleaseSelectYear : String
    , selectTemplate : String
    , pleaseSelectCategory : String
    , pleaseSelectAccountType : String
    , manageAccounts : String
    , manageTemplates : String
    , manageCompanies : String
    , create : String
    , accountingYear : String
    , bookingDate : String
    , receiptNumber : String
    , address : String
    , city : String
    , postalCode : String
    , country : String
    , taxNumber : String
    , revenueOffice : String
    , commitNewEntry : String
    , amount : String
    , accountId : String
    , hideTemplateList : String
    , hideAccountList : String
    , showAccountList : String
    , number : String
    , noValidAccount : String
    , accountValidationMessageOk : String
    , accountValidationMessageErr : String
    , accountValidationMessageExisting : String
    , balance : String
    , equalAccountsWarning : String
    , day : String
    , month : String
    , printJournal: String
    , printNominalAccounts : String
    , accountCategories : List AccountCategory
    , accountTypes : List AccountType
    , reportLanguageComponents : ReportLanguageComponents
    }



type alias LanguageForList = {
                    short : String
                   ,name : String
                 }


languageList : List LanguageForList
languageList = [
                {short = "en", name = "English"}
              , {short = "de", name = "Deutsch"}
            --  , {short = "fr", name = "Français"}
              ]
