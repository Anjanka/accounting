module Pages.SharedViewComponents exposing (..)

import Api.Types.Account exposing (Account)
import Dropdown exposing (Item)
import Html exposing (Attribute, Html, div, form, input)
import Html.Attributes exposing (action, type_, value)
import Pages.LinkUtil exposing (Path(..), fragmentUrl, makeLinkId, makeLinkPath, makeLinkYear)


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


linkButton : String -> List (Attribute msg) -> List (Html msg) -> Html msg
linkButton link attrs children =
    form [ action link ]
        [ input (type_ "submit" :: attrs) children ]


backToEntryPage : Int -> Maybe Int -> Html msg
backToEntryPage companyId yearCandidate =
    case yearCandidate of
        Just accountingYear ->
            linkButton (fragmentUrl [ makeLinkId companyId, makeLinkPath AccountingEntryPage, makeLinkYear accountingYear ])
                [ value "Back" ]
                []

        Nothing ->
            div [] []
