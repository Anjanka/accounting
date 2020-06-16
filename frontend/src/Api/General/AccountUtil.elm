module Api.General.AccountUtil exposing (..)

import Api.Types.Account exposing (Account)


empty : Account
empty =
    { id = 0
    , title = ""
    }

updateId : Account -> Int -> Account
updateId account id = { account | id = id }

updateTitle : Account -> String -> Account
updateTitle account title = { account | title = title }

show: Account -> String
show account =
    String.join ": " [String.fromInt account.id, account.title]