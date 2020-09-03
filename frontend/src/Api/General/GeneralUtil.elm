module Api.General.GeneralUtil exposing (..)


isNothing : Maybe a -> Bool
isNothing maybe =
    case maybe of
        Just _ ->
            False

        Nothing ->
            True

isJust : Maybe a -> Bool
isJust =
    isNothing >> not