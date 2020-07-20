module Pages.SharedViewComponents exposing (..)

import Api.Types.Account exposing (Account)
import Dropdown exposing (Item)
import Html exposing (Attribute, Html, div, form, input)
import Html.Attributes exposing (action, class, type_, value)
import Pages.LinkUtil exposing (Path(..), fragmentUrl, makeLinkId, makeLinkLang, makeLinkPath, makeLinkYear)


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


backToEntryPage : String -> Int -> Maybe Int -> String -> Html msg
backToEntryPage text companyId yearCandidate language =
    case yearCandidate of
        Just accountingYear ->
            linkButton (fragmentUrl [ makeLinkId companyId, makeLinkPath AccountingEntryPage, makeLinkYear accountingYear , makeLinkLang language])
                [ class "backButton", value text ]
                []

        Nothing ->
            div [] []
