module Api.General.AccountCategoryConstants exposing (..)

import Api.General.AccountUtil exposing (AccountCategory)


type alias AccountCategories =
    { financialAccount : String
    , fixedAssets : String
    , resources : String
    , businessExpenses : String
    , borrowedCapital : String
    , taxAccount : String
    , revenues : String
    , balanceCarriedForward : String
    }


makeCategoryList : AccountCategories -> List AccountCategory
makeCategoryList acs =
    [ { id = 0, name = acs.financialAccount }
    , { id = 1, name = acs.fixedAssets }
    , { id = 2, name = acs.resources }
    , { id = 3, name = acs.businessExpenses }
    , { id = 4, name = acs.borrowedCapital }
    , { id = 5, name = acs.taxAccount }
    , { id = 8, name = acs.revenues }
    , { id = 9, name = acs.balanceCarriedForward }
    ]


englishAccountCategories : AccountCategories
englishAccountCategories =
    { financialAccount = "financial account"
    , fixedAssets = "fixed assets"
    , resources = "resources"
    , businessExpenses = "business expenses"
    , borrowedCapital = "borrowed capital"
    , taxAccount = "tax account"
    , revenues = "revenues"
    , balanceCarriedForward = "balance carried forward"
    }


germanAccountCategories : AccountCategories
germanAccountCategories =
    { financialAccount = "Finanzkonto"
    , fixedAssets = "Anlagevermögen"
    , resources = "Eigenkapital"
    , businessExpenses = "Betriebsausgaben"
    , borrowedCapital = "Fremdkapital"
    , taxAccount = "Steuerkonto"
    , revenues = "Einnahmen"
    , balanceCarriedForward = "Saldovortrag"
    }
