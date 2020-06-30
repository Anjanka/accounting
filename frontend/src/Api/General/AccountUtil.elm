module Api.General.AccountUtil exposing (..)

import Api.Types.Account exposing (Account)


empty : Account
empty =
    { companyId = 0
    , id = 0
    , title = ""
    }

updateCompanyID: Account -> Int -> Account
updateCompanyID account companyId = { account | companyId = companyId }

updateId : Account -> Int -> Account
updateId account id = { account | id = id }

updateTitle : Account -> String -> Account
updateTitle account title = { account | title = title }

show: Account -> String
show account =
    String.join ": " [String.fromInt account.id, account.title]

isEmpty: Account -> Bool
isEmpty account =
    account.id == 0 && account.title == "" && account.companyId == 0
