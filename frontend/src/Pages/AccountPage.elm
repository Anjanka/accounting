module Pages.AccountPage exposing (..)

import Api.General.AccountUtil as AccountUtil
import Api.Types.Account exposing (Account, decoderAccount, encoderAccount)
import Browser
import Html exposing (Html, Attribute, button, div, input, text)
import Html.Attributes exposing (disabled, placeholder, style, value)
import Html.Events exposing (onClick, onInput)
import Http exposing (Error)
import Json.Decode as Decode



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
    { contentID : String
    , account : Account
    , response : String
    , feedback : String
    , error : String
    , buttonPressed : Bool
    }


updateContentID : Model -> String -> Model
updateContentID model contentID =
    { model | contentID = contentID }


updateAccount : Model -> Account -> Model
updateAccount model account =
    { model | account = account }


updateError : Model -> String -> Model
updateError model error =
    { model | error = error }


type alias Flags =
    ()


init : Flags -> ( Model, Cmd Msg )
init _ =
    ( { contentID = ""
      , account = AccountUtil.empty
      , response = ""
      , feedback = ""
      , error = "Account ID must be non-zero, positive 5-digit number."
      , buttonPressed = False
     }
    , Cmd.none
    )



-- UPDATE


type Msg
    = GetAccounts
    | GotResponse (Result Error (List Account))
    | GotResponse2 (Result Error Account)
    | ChangeID String
    | ChangeName String
    | CreateAccount




update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetAccounts ->
            ( { model | buttonPressed = True }, getAccounts )

        GotResponse result ->
            case result of
                Ok value ->
                    ( { model
                        | response = value |> List.map AccountUtil.show |> String.join ",\n"
                        , feedback = ""
                      }
                    , Cmd.none
                    )

                Err error ->
                    ( { model | feedback = Debug.toString error }, Cmd.none )

        GotResponse2 result ->
            ( resetOnSuccessfulPost, Cmd.none )

        ChangeID newContent ->
            let
                newAccountAndFeedback =
                    parseAccount model.account newContent

                newModel =
                    model
                        |> (\md -> updateAccount md newAccountAndFeedback.account)
                        |> (\md -> updateContentID md newContent)
                        |> (\md -> updateError md newAccountAndFeedback.error)
            in
            ( { newModel | contentID = newContent }, Cmd.none )

        ChangeName newContent ->
            let
                newModel =
                    model.account
                        |> (\acc -> AccountUtil.updateTitle acc newContent)
                        |> updateAccount model
            in
            ( newModel, Cmd.none )

        CreateAccount ->
            ( model, postAccount model.account )



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
        [ input [ placeholder "Account ID", value model.contentID, onInput ChangeID ] []
        , input [ placeholder "Account Name", value model.account.title, onInput ChangeName ] []
        , viewValidation model.error
        , viewValidatedInput model
        , div [] ([ button [ onClick GetAccounts ] [ text "Get All Accounts" ] ] ++ responseArea)
         ]






-- Communication with backend


getAccounts : Cmd Msg
getAccounts =
    Http.get
        { url = "http://localhost:9000/account/getAllAccounts"
        , expect = Http.expectJson GotResponse (Decode.list decoderAccount)
        }


postAccount : Account -> Cmd Msg
postAccount account =
    Http.post
        { url = "http://localhost:9000/account/repsert"
        , expect = Http.expectJson GotResponse2 decoderAccount
        , body = Http.jsonBody (encoderAccount account)
        }


viewValidation : String -> Html Msg
viewValidation error =
    if String.isEmpty error then
        div [ style "color" "green" ] [ text "Account ID is valid." ]

    else
        div [ style "color" "red" ] [ text error ]


viewValidatedInput : Model -> Html Msg
viewValidatedInput model =
    if not (String.isEmpty model.error) || String.isEmpty model.account.title then
        button [ disabled True, onClick CreateAccount ] [ text "Create new Account" ]

    else
        button [ disabled False, onClick CreateAccount ] [ text "Create new Account" ]


parseAccount : Account -> String -> { account : Account, error : String }
parseAccount baseAccount newId =
    let
        errorMessage =
            "Account ID must be non-zero, positive 5-digit number."
    in
    case String.toInt newId of
        Just int ->
            if int > 10000 && int <= 99999 then
                { account = AccountUtil.updateId baseAccount int, error = "" }

            else
                { account = baseAccount, error = errorMessage }

        Nothing ->
            { account = baseAccount, error = errorMessage }


resetOnSuccessfulPost : Model
resetOnSuccessfulPost =
    { contentID = ""
    , account = AccountUtil.empty
    , response = ""
    , feedback = ""
    , error = "Account ID must be non-zero, positive 5-digit number."
    , buttonPressed = False
    }
