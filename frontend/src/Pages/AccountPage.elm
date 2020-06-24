module Pages.AccountPage exposing (..)

import Api.General.AccountUtil as AccountUtil
import Api.Types.Account exposing (Account, decoderAccount, encoderAccount)
import Api.Types.AccountKey exposing (encoderAccountKey)
import Browser
import Dropdown exposing (Item)
import Html exposing (Attribute, Html, button, div, input, label, p, text)
import Html.Attributes exposing (disabled, placeholder, style, value)
import Html.Events exposing (onClick, onInput)
import Http exposing (Error)
import Json.Decode as Decode
import Pages.HttpUtil as HttpUtil




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
    { companyID : Int
    , contentID : String
    , account : Account
    , allAccounts : List Account
    , response : String
    , error : String
    , validationFeedback : String
    , buttonPressed : Bool
    , selectedValue : Maybe String
    }


updateContentID : Model -> String -> Model
updateContentID model contentID =
    { model | contentID = contentID }


updateAccount : Model -> Account -> Model
updateAccount model account =
    { model | account = account }


updateError : Model -> String -> Model
updateError model validationFeedback =
    { model | validationFeedback = validationFeedback }


type alias Flags =
    ()


dropdownOptions : List Account -> Dropdown.Options Msg
dropdownOptions allAccounts =
    let
        defaultOptions =
            Dropdown.defaultOptions DropdownChanged
    in
    { defaultOptions
        | items =
            List.sortBy .value (List.map accountForDropdown allAccounts)
        , emptyItem = Just { value = "0", text = "[Please Select]", enabled = True }
    }


init : Flags -> ( Model, Cmd Msg )
init _ =
    ( { companyID = 1
      , contentID = ""
      , account = AccountUtil.updateCompanyID AccountUtil.empty 1
      , allAccounts = []
      , response = ""
      , error = ""
      , validationFeedback = "Account ID must be non-zero, positive 5-digit number."
      , buttonPressed = False
      , selectedValue = Nothing
      }
    , getAccounts 1
    )



-- UPDATE


type Msg
    = ShowAllAccounts
    | GotResponseForAllAccounts (Result Error (List Account))
    | GotResponseCreate (Result Error Account)
    | GotResponseDelete (Result Error ())
    | ChangeID String
    | ChangeName String
    | CreateAccount
    | DeleteAccount
    | DropdownChanged (Maybe String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ShowAllAccounts ->
            ( { model | buttonPressed = True }, getAccounts model.companyID )

        GotResponseForAllAccounts result ->
            case result of
                Ok value ->
                    ( { model
                        | allAccounts = value
                        , response = value |> List.sortBy .id |> List.map AccountUtil.show |> String.join ",\n"
                        , error = ""
                      }
                    , Cmd.none
                    )

                Err error ->
                    ( { model | error = HttpUtil.errorToString error }, Cmd.none )

        GotResponseCreate result ->
            case result of
                Ok value ->
                    ( resetOnSuccessfulPost model, getAccounts model.companyID)

                Err error ->
                    ( { model | error = HttpUtil.errorToString error }, Cmd.none )

        GotResponseDelete result ->
            case result of
                Ok value ->
                    ( { model | selectedValue = Nothing }, getAccounts model.companyID )

                Err error ->
                    ( { model | error = HttpUtil.errorToString error, selectedValue = Nothing }, Cmd.none )

        ChangeID newContent ->
            let
                newAccountAndFeedback =
                    parseAccount model.account newContent

                newModel =
                    model
                        |> (\md -> updateAccount md newAccountAndFeedback.account)
                        |> (\md -> updateContentID md newContent)
                        |> (\md -> updateError md newAccountAndFeedback.validationFeedback)
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

        DeleteAccount ->
            ( model, deleteAccount model.selectedValue model.companyID )

        DropdownChanged selectedValue ->
            ( { model | selectedValue = selectedValue }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none

errorToString : Http.Error -> String
errorToString error = ""

-- VIEW


view : Model -> Html Msg
view model =
    let
        responseArea =
            if model.buttonPressed then
                [ div [] [ text "List of all accounts : " ]
                , div [] [ text model.response ]
                ]

            else
                []
    in
    div []
        [ input [ placeholder "Account ID", value model.contentID, onInput ChangeID ] []
        , input [ placeholder "Account Name", value model.account.title, onInput ChangeName ] []
        , viewValidation model.validationFeedback
        , viewValidatedInput model
        , div [] ([ button [ onClick ShowAllAccounts ] [ text "Get All Accounts" ] ] ++ responseArea)
        , Html.form []
            [ p []
                [ label []
                    [ Dropdown.dropdown
                        (dropdownOptions model.allAccounts)
                        []
                        model.selectedValue
                    ]
                ]
            ]
        , deleteButton model.selectedValue
        , div [] [ text model.error ]
        ]


getAccounts : Int -> Cmd Msg
getAccounts companyId =
    Http.get
        { url = "http://localhost:9000/account/getAllAccounts/" ++ String.fromInt companyId
        , expect = HttpUtil.expectJson GotResponseForAllAccounts (Decode.list decoderAccount)
        }


postAccount : Account -> Cmd Msg
postAccount account =
    Http.post
        { url = "http://localhost:9000/account/repsert"
        , expect = HttpUtil.expectJson GotResponseCreate decoderAccount
        , body = Http.jsonBody (encoderAccount account)
        }


deleteAccount : Maybe String -> Int -> Cmd Msg
deleteAccount selectedValue company_id =
    case selectedValue of
        Just value ->
            let
                id =
                    stringIsValidId value
            in
            if id.valid then
                Http.post
                    { url = "http://localhost:9000/account/delete "
                    , expect = HttpUtil.expectWhatever GotResponseDelete
                    , body = Http.jsonBody (encoderAccountKey { id = id.id, companyID = company_id })
                    }

            else
                Cmd.none

        Nothing ->
            Cmd.none


viewValidation : String -> Html Msg
viewValidation error =
    if String.isEmpty error then
        div [ style "color" "green" ] [ text "Account ID is valid." ]

    else
        div [ style "color" "red" ] [ text error ]


viewValidatedInput : Model -> Html Msg
viewValidatedInput model =
    if not (String.isEmpty model.validationFeedback) || String.isEmpty model.account.title then
        button [ disabled True, onClick CreateAccount ] [ text "Create new Account" ]

    else
        button [ disabled False, onClick CreateAccount ] [ text "Create new Account" ]


deleteButton : Maybe String -> Html Msg
deleteButton selectedValue =
    case selectedValue of
        Just value ->
            button [ disabled False, onClick DeleteAccount ] [ text "Delete" ]

        Nothing ->
            button [ disabled True, onClick DeleteAccount ] [ text "Delete" ]


parseAccount : Account -> String -> { account : Account, validationFeedback : String }
parseAccount baseAccount newId =
    let
        errorMessage =
            "Account ID must be non-zero, positive 5-digit number."

        id =
            stringIsValidId newId
    in
    if id.valid then
        { account = AccountUtil.updateId baseAccount id.id, validationFeedback = "" }

    else
        { account = baseAccount, validationFeedback = errorMessage }


type alias ValidID =
    { id : Int
    , valid : Bool
    }


stringIsValidId : String -> ValidID
stringIsValidId id =
    case String.toInt id of
        Just int ->
            if int > 10000 && int <= 99999 then
                { id = int, valid = True }

            else
                { id = 0, valid = False }

        Nothing ->
            { id = 0, valid = False }


accountForDropdown : Account -> Item
accountForDropdown acc =
    let
        id =
            String.fromInt acc.id
    in
    { value = id, text = id ++ " - " ++ acc.title, enabled = True }


resetOnSuccessfulPost : Model -> Model
resetOnSuccessfulPost model =
    { model
        | contentID = ""
        , account = AccountUtil.empty
        , response = ""
        , error = ""
        , validationFeedback = "Account ID must be non-zero, positive 5-digit number."
        , buttonPressed = False
        , selectedValue = Nothing
    }
