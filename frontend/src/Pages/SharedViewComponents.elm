module Pages.SharedViewComponents exposing (..)

import Api.Types.Account exposing (Account)
import Dropdown exposing (Item)


accountListForDropdown : List Account -> Maybe String -> List Account
accountListForDropdown allAccounts selectedValueCandidate =
    selectedValueCandidate
        |> Maybe.andThen String.toInt
        |> Maybe.map (\selectedId -> List.filter (\acc -> acc.id /= selectedId) allAccounts)
        |> Maybe.withDefault allAccounts


accountForDropdown : Account -> Item
accountForDropdown acc =
    let
        id =
            String.fromInt acc.id
    in
    { value = id, text = acc.title, enabled = True }
