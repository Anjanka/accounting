module Api.General.AccountTypeConstants exposing (..)

import Api.General.AccountUtil exposing (AccountType)


englishAccountTypes : List AccountType
englishAccountTypes =
    [ { id = 11, categoryIds = [ 1 ], name = "inferior assets" }
    , { id = 1, categoryIds = [ 0 ], name = "cash account" }
    , { id = 31, categoryIds = [ 3 ], name = "purchased goods" }
    , { id = 32, categoryIds = [ 3 ], name = "telephone costs" }
    , { id = 33, categoryIds = [ 3 ], name = "travel expenses" }
    , { id = 0, categoryIds = [ 7, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0 ], name = "other" }
    , { id = 81, categoryIds = [ 8 ], name = "interest income" }
    , { id = 91, categoryIds = [ 9 ], name = "opening balance" }
    , { id = 82, categoryIds = [ 8 ], name = "sales revenue" }
    , { id = 34, categoryIds = [ 3 ], name = "personnel costs" }
    , { id = 35, categoryIds = [ 3 ], name = "postal charges" }
    , { id = 36, categoryIds = [ 3 ], name = "lease expenses" }
    , { id = 41, categoryIds = [ 4 ], name = "loans" }
    , { id = 42, categoryIds = [ 4 ], name = "debts" }
    , { id = 51, categoryIds = [ 5 ], name = "prepaid tax" }
    , { id = 52, categoryIds = [ 5 ], name = "sales taxes" }
    ]


germanAccountTypes : List AccountType
germanAccountTypes =
    [ { id = 11, categoryIds = [ 1 ], name = "Geringwertige WG" }
    , { id = 1, categoryIds = [ 0 ], name = "Kassenkonto" }
    , { id = 31, categoryIds = [ 3 ], name = "Wareneinkauf" }
    , { id = 32, categoryIds = [ 3 ], name = "Telefonkosten" }
    , { id = 33, categoryIds = [ 3 ], name = "Reisekosten" }
    , { id = 0, categoryIds = [ 7, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0 ], name = "Sonstige" }
    , { id = 81, categoryIds = [ 8 ], name = "Zinserträge" }
    , { id = 91, categoryIds = [ 9 ], name = "Eröffungsbilanz" }
    , { id = 82, categoryIds = [ 8 ], name = "Umsatzerlöse" }
    , { id = 34, categoryIds = [ 3 ], name = "Personalkosten" }
    , { id = 35, categoryIds = [ 3 ], name = "Portokosten" }
    , { id = 36, categoryIds = [ 3 ], name = "Miete" }
    , { id = 41, categoryIds = [ 4 ], name = "Darlehen" }
    , { id = 42, categoryIds = [ 4 ], name = "Verbindlichkeiten" }
    , { id = 51, categoryIds = [ 5 ], name = "Vorsteuer" }
    , { id = 52, categoryIds = [ 5 ], name = "Umsatzsteuer" }
    ]
