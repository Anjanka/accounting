module Api.General.AccountTypeConstants exposing (..)

import Api.General.AccountUtil exposing (AccountType)


type alias AccountTypes =
    { inferiorAssets : String
    , cashAccount : String
    , purchasedGoods : String
    , telephoneCosts : String
    , travelExpenses : String
    , other : String
    , interestIncome : String
    , openingBalance : String
    , salesRevenue : String
    , personnelCosts : String
    , postalCharges : String
    , leaseExpenses : String
    , loans : String
    , debts : String
    , prepaidTax : String
    , salesTaxes : String
    }


makeTypeList : AccountTypes -> List AccountType
makeTypeList ats =
    [ { id = 11, categoryIds = [ 1 ], name = ats.inferiorAssets }
    , { id = 1, categoryIds = [ 0 ], name = ats.cashAccount }
    , { id = 31, categoryIds = [ 3 ], name = ats.purchasedGoods }
    , { id = 32, categoryIds = [ 3 ], name = ats.telephoneCosts }
    , { id = 33, categoryIds = [ 3 ], name = ats.travelExpenses }
    , { id = 0, categoryIds = [ 7, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0 ], name = ats.other }
    , { id = 81, categoryIds = [ 8 ], name = ats.interestIncome }
    , { id = 91, categoryIds = [ 9 ], name = ats.openingBalance }
    , { id = 82, categoryIds = [ 8 ], name = ats.salesRevenue }
    , { id = 34, categoryIds = [ 3 ], name = ats.personnelCosts }
    , { id = 35, categoryIds = [ 3 ], name = ats.postalCharges }
    , { id = 36, categoryIds = [ 3 ], name = ats.leaseExpenses }
    , { id = 41, categoryIds = [ 4 ], name = ats.loans }
    , { id = 42, categoryIds = [ 4 ], name = ats.debts }
    , { id = 51, categoryIds = [ 5 ], name = ats.prepaidTax }
    , { id = 52, categoryIds = [ 5 ], name = ats.salesTaxes }
    ]


englishAccountTypes : AccountTypes
englishAccountTypes =
    { inferiorAssets = "inferior assets"
    , cashAccount = "cash account"
    , purchasedGoods = "purchased goods"
    , telephoneCosts = "telephone costs"
    , travelExpenses = "travel expenses"
    , other = "other"
    , interestIncome = "interest income"
    , openingBalance = "opening balance"
    , salesRevenue = "sales revenue"
    , personnelCosts = "personnel costs"
    , postalCharges = "postal charges"
    , leaseExpenses = "lease expenses"
    , loans = "loans"
    , debts = "debts"
    , prepaidTax = "prepaid tax"
    , salesTaxes = "sales taxes"
    }


germanAccountTypes : AccountTypes
germanAccountTypes =
    { inferiorAssets = "Geringwertige WG"
    , cashAccount = "Kassenkonto"
    , purchasedGoods = "Wareneinkauf"
    , telephoneCosts = "Telefonkosten"
    , travelExpenses = "Reisekosten"
    , other = "Sonstige"
    , interestIncome = "Zinserträge"
    , openingBalance = "Eröffungsbilanz"
    , salesRevenue = "Umsatzerlöse"
    , personnelCosts = "Personalkosten"
    , postalCharges = "Portokosten"
    , leaseExpenses = "Miete"
    , loans = "Darlehen"
    , debts = "Verbindlichkeiten"
    , prepaidTax = "Vorsteuer"
    , salesTaxes = "Umsatzsteuer"
    }
