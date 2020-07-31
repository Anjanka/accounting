module Api.General.AccountUtil exposing (..)

import Api.Types.Account exposing (Account)


empty : Account
empty =
    { companyId = 0
    , id = 0
    , title = ""
    , category = 0
    , accountType = 0
    }

updateCompanyID: Account -> Int -> Account
updateCompanyID account companyId = { account | companyId = companyId }

updateId : Account -> Int -> Account
updateId account id = { account | id = id }

updateTitle : Account -> String -> Account
updateTitle account title = { account | title = title }

updateCategory : Account -> Int -> Account
updateCategory account category = { account | category = category }

updateAccountType : Account -> Int -> Account
updateAccountType account at = { account | accountType = at }


show: Account -> String
show account =
    String.join ": " [String.fromInt account.id, account.title]

isEmpty: Account -> Bool
isEmpty account =
    account.id == 0 && account.title == "" && account.companyId == 0


type alias Category = {
    id : Int
    , name : String
    }

type alias AccountType = {
     id : Int
   , categoryIds : List Int
   , name : String
 }

