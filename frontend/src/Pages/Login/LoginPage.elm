module Pages.Login.LoginPage exposing (..)

import Api.Auxiliary exposing (JWT)
import Api.General.HttpUtil as HttpUtil
import Api.Types.Credentials exposing (Credentials, encoderCredentials)
import Browser.Navigation
import Configuration exposing (Configuration)
import Html exposing (Html, button, div, input, label, text)
import Html.Attributes exposing (autocomplete, type_)
import Html.Events exposing (onClick, onInput)
import Html.Events.Extra exposing (onEnter)
import Http
import Json.Decode as Decode
import Pages.LinkUtil as LinkUtil
import Ports


type alias Model =
    { credentials : Credentials
    , configuration : Configuration
    , error : String
    }


type alias Flags =
    { configuration : Configuration
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { credentials =
            { username = ""
            , password = ""
            }
      , configuration = flags.configuration
      , error = ""
      }
    , Cmd.none
    )


type Msg
    = SetUsername String
    | SetPassword String
    | Login
    | GotLoginResponse (Result Http.Error JWT)


updateUsername : String -> Credentials -> Credentials
updateUsername username credentials =
    { credentials | username = username }


updatePassword : String -> Credentials -> Credentials
updatePassword password credentials =
    { credentials | password = password }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetUsername username ->
            ( { model | credentials = model.credentials |> updateUsername username }, Cmd.none )

        SetPassword password ->
            ( { model | credentials = model.credentials |> updatePassword password }, Cmd.none )

        Login ->
            ( model
            , login model.configuration model.credentials
            )

        GotLoginResponse result ->
            case result of
                Ok userJwt ->
                    ( model
                    , Cmd.batch
                        [ Ports.storeToken userJwt
                        , LinkUtil.frontendPage model.configuration []
                            |> Browser.Navigation.load
                        ]
                    )

                Err error ->
                    ( { model | error = HttpUtil.errorToString error }, Cmd.none )


login : Configuration -> Credentials -> Cmd Msg
login configuration credentials =
    Http.post
        { url = LinkUtil.backendPage configuration [ "user", "login" ]
        , body = encoderCredentials credentials |> Http.jsonBody
        , expect = HttpUtil.expectJson GotLoginResponse Decode.string
        }


view : Model -> Html Msg
view _ =
    div []
        [ div []
            [ label [] [ text "Username" ]
            , input
                [ autocomplete True
                , onInput SetUsername
                , onEnter Login
                ]
                []
            ]
        , div []
            [ label [] [ text "Password" ]
            , input
                [ type_ "password"
                , autocomplete True
                , onInput SetPassword
                , onEnter Login
                ]
                []
            ]
        , div []
            [ button [ onClick Login ] [ text "Log In" ] ]
        ]
