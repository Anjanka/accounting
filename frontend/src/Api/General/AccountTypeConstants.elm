module Api.General.AccountTypeConstants exposing (..)

import Api.General.AccountUtil exposing (AccountType)
import Dict exposing (Dict, get)


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
    [ { id = 11, name = ats.inferiorAssets }
    , { id = 1, name = ats.cashAccount }
    , { id = 31, name = ats.purchasedGoods }
    , { id = 32, name = ats.telephoneCosts }
    , { id = 33, name = ats.travelExpenses }
    , { id = 0, name = ats.other }
    , { id = 81, name = ats.interestIncome }
    , { id = 91, name = ats.openingBalance }
    , { id = 82, name = ats.salesRevenue }
    , { id = 34, name = ats.personnelCosts }
    , { id = 35, name = ats.postalCharges }
    , { id = 36, name = ats.leaseExpenses }
    , { id = 41, name = ats.loans }
    , { id = 42, name = ats.debts }
    , { id = 51, name = ats.prepaidTax }
    , { id = 52, name = ats.salesTaxes }
    ]


categoryIds : Dict Int (List Int)
categoryIds =
    Dict.fromList
        [ ( 11, [ 1 ] )
        , ( 1, [ 0 ] )
        , ( 31, [ 3 ] )
        , ( 32, [ 3 ] )
        , ( 33, [ 3 ] )
        , ( 0, [ 7, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0 ] )
        , ( 81, [ 8 ] )
        , ( 91, [ 9 ] )
        , ( 82, [ 8 ] )
        , ( 34, [ 3 ] )
        , ( 35, [ 3 ] )
        , ( 36, [ 3 ] )
        , ( 41, [ 4 ] )
        , ( 42, [ 4 ] )
        , ( 51, [ 5 ] )
        , ( 52, [ 5 ] )
        ]


getCategoryIdsWithDefault : Int -> List Int
getCategoryIdsWithDefault typeId =
    case get typeId categoryIds of
        Just list ->
            list
        Nothing ->
            []


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
