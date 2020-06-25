module Pages.NumberOrEmpty exposing (..)

-- You need to keep track of whether to display the modal or not

import Browser
import Html exposing (Attribute, Html, div, input, label, text)
import Html.Attributes exposing (value)
import Html.Events exposing (onInput)


type alias Model =
    { intFromInput : FromInput Int}


updateIntFromInput : Model -> FromInput Int -> Model
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
    ( { intFromInput = mkFromInput 0 0 intParser intPartial }, Cmd.none )

intParser : String -> Result String Int
intParser = String.toInt >> Maybe.map Ok >> Maybe.withDefault (Err "Not an integer")

intPartial : String -> Bool
intPartial text = text == "-"

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
        , div [] [ label [] [ text ("valid value = " ++ String.fromInt model.intFromInput.value) ] ]
        ]


type alias FromInput a =
    { value : a
    , defaultValue : a
    , text : String
    , parser : String -> Result String a
    , partial : String -> Bool
    }


updateText : FromInput a -> String -> FromInput a
updateText intFromInput text =
    { intFromInput | text = text }


updateValue : FromInput a -> a -> FromInput a
updateValue intFromInput value =
    { intFromInput | value = value }


mkFromInput : a -> a -> (String -> Result String a) -> (String -> Bool) -> FromInput a
mkFromInput defaultValue value parser partial =
    { value = value, defaultValue = defaultValue, text = "", parser = parser, partial = partial }


isValid : FromInput a -> Bool
isValid fromInput =
    case fromInput.parser fromInput.text of
        Ok value ->
            value == fromInput.value

        Err _ ->
            False


lift : (model -> FromInput a -> model) -> FromInput a -> String -> model -> model
lift ui fromInput text model =
    let
        possiblyValid =
            if String.isEmpty text || fromInput.partial text then
                fromInput
                    |> (\ifi -> updateValue ifi fromInput.defaultValue)
                    |> (\ifi -> updateText ifi text)
            else
                fromInput
    in
    case fromInput.parser text of
        Ok value ->
            possiblyValid
                |> (\ifi -> updateText ifi text)
                |> (\ifi -> updateValue ifi value)
                |> ui model

        Err _ ->
            ui model possiblyValid
