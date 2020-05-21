module Pages.AccountPage exposing (..)

import Browser
import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)
import Http exposing (Error)



-- MAIN


main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { response : String
    , feedback : String
    , buttonPressed : Bool
    }


type alias Flags =
    ()


init : Flags -> ( Model, Cmd Msg )
init _ =
    ( { response = "", feedback = "", buttonPressed = False }, Cmd.none )



-- UPDATE


type Msg
    = GetAccounts
    | GotResponse (Result Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetAccounts ->
            ( { model | buttonPressed = True }, getAccounts )

        GotResponse result ->
            case result of
                Ok value ->
                    ( { model | response = value, feedback = "" }, Cmd.none )

                Err error ->
                    ( { model | feedback = Debug.toString error }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    let
        responseArea =
            if model.buttonPressed then
                [ div [] [ text ("feedback : " ++ model.feedback) ]
                , div [] [ text model.response ]
                ]

            else
                []
    in
    div []
        ([ button [ onClick GetAccounts ] [ text "Get All Accounts" ] ] ++ responseArea)



-- Communication with backend


getAccounts : Cmd Msg
getAccounts =
    Http.get
        { url = "http://localhost:9000/account/getAllAccounts"
        , expect = Http.expectString GotResponse
        }
