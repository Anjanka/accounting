module Pages.SharedViewComponents exposing (..)

import Api.Types.Account exposing (Account)
import Bootstrap.Button
import Dropdown exposing (Item)
import Html exposing (Attribute, Html, div, text)
import Html.Attributes exposing (class, href)
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
        Bootstrap.Button.linkButton
            [ Bootstrap.Button.attrs (href link :: attrs)
            ]
            children

linkButtonWithDisabled : String -> List (Attribute msg) -> List (Html msg) -> Bool ->  Html msg
linkButtonWithDisabled link attrs children isDisabled=
          Bootstrap.Button.linkButton
            [   Bootstrap.Button.disabled True
              , Bootstrap.Button.attrs (href link :: attrs )
            ]
            children


backToEntryPage : String -> Int -> Maybe Int -> String -> Html msg
backToEntryPage txt companyId yearCandidate language =
    case yearCandidate of
        Just accountingYear ->
            linkButton (fragmentUrl [ makeLinkId companyId, makeLinkPath AccountingEntryPage, makeLinkYear accountingYear , makeLinkLang language])
                [ class "backButton"][text txt ]


        Nothing ->
            div [] []
