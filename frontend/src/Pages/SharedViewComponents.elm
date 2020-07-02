module Pages.SharedViewComponents exposing (..)


import Api.Types.Account exposing (Account)
import Dropdown exposing (Item)



accountListForDropdown : List Account -> Maybe String -> List Account
accountListForDropdown allAccounts selectedValueCandidate =
    case selectedValueCandidate of
        Just selectedValue ->
            case String.toInt selectedValue of
                Just selectedId ->
                    List.filter (\acc -> acc.id /= selectedId) allAccounts

                Nothing ->
                    allAccounts

        Nothing ->
            allAccounts


accountForDropdown : Account -> Item
accountForDropdown acc =
    let
        id =
            String.fromInt acc.id
    in
    { value = id, text = acc.title, enabled = True }
