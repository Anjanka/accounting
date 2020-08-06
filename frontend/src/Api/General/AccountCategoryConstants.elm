module Api.General.AccountCategoryConstants exposing (..)

import Api.General.AccountUtil exposing (AccountCategory)


englishAccountCategories : List AccountCategory
englishAccountCategories =
    [ { id = 0, name = "financial account" }
    , { id = 1, name = "fixed assets" }
    , { id = 2, name = "resources" }
    , { id = 3, name = "business expenses" }
    , { id = 4, name = "borrowed capital" }
    , { id = 5, name = "tax account" }
    , { id = 8, name = "revenues" }
    , { id = 9, name = "balance carried forward" }
    ]


germanAccountCategories : List AccountCategory
germanAccountCategories =
    [ { id = 0, name = "Finanzkonto" }
    , { id = 1, name = "Anlagevermögen" }
    , { id = 2, name = "Eigenkapital" }
    , { id = 3, name = "Betriebsausgaben" }
    , { id = 4, name = "Fremdkapital" }
    , { id = 5, name = "Steuerkonto" }
    , { id = 8, name = "Einnahmen" }
    , { id = 9, name = "Saldovortrag" }
    ]
