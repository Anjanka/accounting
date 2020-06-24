module Pages.NumberOrEmpty exposing (..)

-- You need to keep track of whether to display the modal or not

import Browser
import Html exposing (Attribute, Html, div, input, label, text)
import Html.Attributes exposing (value)
import Html.Events exposing (onInput)


type alias Model =
    { intFromInput : IntFromInput }


updateIntFromInput : Model -> IntFromInput -> Model
updateIntFromInput model intFromInput =
    { model | intFromInput = intFromInput }


main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }


type alias Flags =
    ()



-- Initialize your model


init : Flags -> ( Model, Cmd Msg )
init _ =
    ( { intFromInput = mkIntFromInput 0 }, Cmd.none )



-- Define messages for your modal


type Msg
    = Update String



-- Handle modal messages in your update function to enable showing and closing


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Update text ->
            ( lift updateIntFromInput model.intFromInput text model, Cmd.none )



-- Configure your modal view using pipeline friendly functions.


view : Model -> Html Msg
view model =
    div []
        [ input [ onInput Update, value model.intFromInput.text ] []
        , div []
            [ label []
                [ text
                    ("input is considered valid? "
                        ++ (if isValid model.intFromInput then
                                "yes"

                            else
                                "no"
                           )
                    )
                ]
            ]
        , div [] [ label [] [ text ("valid value = " ++ String.fromInt model.intFromInput.number) ] ]
        ]


type alias IntFromInput =
    { number : Int
    , text : String
    }


updateText : IntFromInput -> String -> IntFromInput
updateText intFromInput text =
    { intFromInput | text = text, number = valueFrom text intFromInput.number }


updateNumber : IntFromInput -> Int -> IntFromInput
updateNumber intFromInput number =
    { intFromInput | number = number }


mkIntFromInput : Int -> IntFromInput
mkIntFromInput int =
    { number = int, text = "" }


isValid : IntFromInput -> Bool
isValid intFromInput =
    case String.toInt intFromInput.text of
        Just number -> number == intFromInput.number
        Nothing -> False


lift : (model -> IntFromInput -> model) -> IntFromInput -> String -> model -> model
lift ui intFromInput text model =
    let
        possiblyZero =
            if String.isEmpty text then
                intFromInput
                    |> (\ifi -> updateNumber ifi 0)

            else
                intFromInput
    in
    if String.all Char.isDigit text then
        possiblyZero
            |> (\ifi -> updateText ifi text)
            |> ui model

    else
        model


valueFrom : String -> Int -> Int
valueFrom text dft =
    Maybe.withDefault dft (String.toInt text)
