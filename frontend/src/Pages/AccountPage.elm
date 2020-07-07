module Pages.AccountPage exposing (..)

import Api.General.AccountUtil as AccountUtil
import Api.General.HttpUtil as HttpUtil
import Api.Types.Account exposing (Account, decoderAccount, encoderAccount)
import Api.Types.AccountKey exposing (encoderAccountKey)
import Browser
import Html exposing (Attribute, Html, button, div, input, label, p, table, td, text, th, tr)
import Html.Attributes exposing (class, disabled, for, id, placeholder, style, value)
import Html.Events exposing (onClick, onInput)
import Http exposing (Error)
import Json.Decode as Decode
import List.Extra



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
    , error : String
    , validationFeedback : String
    , buttonPressed : Bool
    , editViewActive : Bool
    }



type alias Flags =
    ()


init : Flags -> ( Model, Cmd Msg )
init _ =
    ( { companyID = 1
      , contentID = ""
      , account = AccountUtil.updateCompanyID AccountUtil.empty 1
      , allAccounts = []
      , error = ""
      , validationFeedback = "Account ID must be positive number with 3 to 5 digits. Preceding 0s will be ignored"
      , buttonPressed = False
      , editViewActive = False
      }
    , getAccounts 1
    )



-- UPDATE


type Msg
    = ShowAllAccounts
    | HideAllAccounts
    | GotResponseForAllAccounts (Result Error (List Account))
    | GotResponseCreateOrReplace (Result Error Account)
    | GotResponseDelete (Result Error ())
    | ChangeID String
    | ChangeName String
    | ReplaceAccount
    | CreateAccount
    | DeleteAccount
    | ActivateEditView Account
    | DeactivateEditView
    | BackToAccountingEntryPage


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ShowAllAccounts ->
            ( { model | buttonPressed = True }, getAccounts model.companyID )

        HideAllAccounts ->
            ( { model | buttonPressed = False }, Cmd.none )

        GotResponseForAllAccounts result ->
            case result of
                Ok value ->
                    ( { model
                        | allAccounts = List.sortBy .id value
                        , error = ""
                      }
                    , Cmd.none
                    )

                Err error ->
                    ( { model | error = HttpUtil.errorToString error }, Cmd.none )

        GotResponseCreateOrReplace result ->
            case result of
                Ok _ ->
                    ( reset model, getAccounts model.companyID )

                Err error ->
                    ( { model | error = HttpUtil.errorToString error }, Cmd.none )

        GotResponseDelete result ->
            case result of
                Ok _ ->
                    ( reset model, getAccounts model.companyID )

                Err error ->
                    ( { model | error = HttpUtil.errorToString error }, Cmd.none )

        ChangeID newContent ->
            ( parseAndUpdateAccount model newContent, Cmd.none )

        ChangeName newContent ->
            let
                newModel =
                    model.account
                        |> (\acc -> AccountUtil.updateTitle acc newContent)
                        |> updateAccount model
            in
            ( newModel, Cmd.none )

        ReplaceAccount ->
            ( model, replaceAccount model.account )

        CreateAccount ->
            ( model, createAccount model.account )

        DeleteAccount ->
            ( model, deleteAccount model.account )

        ActivateEditView account ->
            ( { model | contentID = String.fromInt account.id, account = account, editViewActive = True }, Cmd.none )

        DeactivateEditView ->
            ( reset model, Cmd.none )

        BackToAccountingEntryPage ->
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ div [] [ button [ onClick BackToAccountingEntryPage ] [ text "Back" ] ]
        , p [] []
        , viewEditOrCreate model
        , label [] [ text (AccountUtil.show model.account) ]
        , p [] []
        , viewAccountList model
        , p [] []
        , div [] [ text model.error ]
        ]


viewEditOrCreate : Model -> Html Msg
viewEditOrCreate model =
    if model.editViewActive then
        div []
            [ label [] [ text model.contentID ]
            , input [ placeholder "Account Name", value model.account.title, onInput ChangeName ] []
            , div []
                [ button
                    [ onClick ReplaceAccount
                    ]
                    [ text "Save Changes" ]
                , button [ onClick DeleteAccount ] [ text "Delete" ]
                , button [ onClick DeactivateEditView ] [ text "Cancel" ]
                ]
            ]

    else
        div []
            [ input [ placeholder "Account ID", value model.contentID, onInput ChangeID ] []
            , input [ placeholder "Account Name", value model.account.title, onInput ChangeName ] []
            , viewCreateButton model
            , viewValidation model.validationFeedback
            ]


viewValidation : String -> Html Msg
viewValidation error =
    if String.isEmpty error then
        div [ style "color" "green" ] [ text "Account ID is valid." ]

    else
        div [ style "color" "red" ] [ text error ]


viewCreateButton : Model -> Html Msg
viewCreateButton model =
    if not (String.isEmpty model.validationFeedback) || String.isEmpty model.account.title then
        button [ disabled True, onClick CreateAccount ] [ text "Create new Account" ]

    else
        button [ disabled False, onClick CreateAccount ] [ text "Create new Account" ]


viewAccountList : Model -> Html Msg
viewAccountList model =
    if model.buttonPressed then
        div []
            [ div [] [ button [ onClick HideAllAccounts ] [ text "Hide Accounts" ] ]
            , div [ id "allAccounts" ]
                [ table
                    []
                    (tr [ class "tableHeader" ]
                        [ th [] [ label [ for "id" ] [ text "id" ] ]
                        , th [] [ label [ for "name" ] [ text "name" ] ]
                        ]
                        :: List.map mkTableLine model.allAccounts
                    )
                ]
            ]

    else
        div [] [ button [ onClick ShowAllAccounts ] [ text "Manage Accounts" ] ]


mkTableLine : Account -> Html Msg
mkTableLine account =
    tr []
        [ td [] [ text (String.fromInt account.id) ]
        , td [] [ text account.title ]
        , button [ onClick (ActivateEditView account) ] [ text "Edit" ]
        ]



-- COMMUNICATION


getAccounts : Int -> Cmd Msg
getAccounts companyId =
    Http.get
        { url = "http://localhost:9000/account/getAll/" ++ String.fromInt companyId
        , expect = HttpUtil.expectJson GotResponseForAllAccounts (Decode.list decoderAccount)
        }


replaceAccount : Account -> Cmd Msg
replaceAccount account =
    Http.post
        { url = "http://localhost:9000/account/replace"
        , expect = HttpUtil.expectJson GotResponseCreateOrReplace decoderAccount
        , body = Http.jsonBody (encoderAccount account)
        }


createAccount : Account -> Cmd Msg
createAccount account =
    Http.post
        { url = "http://localhost:9000/account/insert"
        , expect = HttpUtil.expectJson GotResponseCreateOrReplace decoderAccount
        , body = Http.jsonBody (encoderAccount account)
        }


deleteAccount : Account -> Cmd Msg
deleteAccount account =
    Http.post
        { url = "http://localhost:9000/account/delete "
        , expect = HttpUtil.expectWhatever GotResponseDelete
        , body = Http.jsonBody (encoderAccountKey { id = account.id, companyID = account.companyId })
        }



-- UTILITIES


parseAndUpdateAccount : Model -> String -> Model
parseAndUpdateAccount model idCandidate =
    let
        idNotValid =
            "Account ID must be positive number with 3 to 5 digits. Preceding 0s will be ignored"

        existingAccount =
            "An account with this Id already exists. Use edit to make changes to existing accounts."
    in
    if not (String.isEmpty idCandidate) then
        case String.toInt idCandidate of
            Just int ->
                let
                    accountExist =
                        not (AccountUtil.isEmpty (findAccount int model.allAccounts))
                in
                if int >= 100 && int <= 99999 && not accountExist then
                    { model | contentID = idCandidate, account = AccountUtil.updateId model.account int, validationFeedback = "" }

                else if int >= 100 && int <= 99999 && accountExist then
                    { model | contentID = idCandidate, account = AccountUtil.updateId model.account 0, validationFeedback = existingAccount }

                else if int > 99999 || String.length idCandidate > 5 then
                    model

                else
                    { model | contentID = idCandidate, account = AccountUtil.updateId model.account 0, validationFeedback = idNotValid }

            Nothing ->
                model

    else
        { model | contentID = "", account = AccountUtil.updateId model.account 0, validationFeedback = idNotValid }


findAccount : Int -> List Account -> Account
findAccount id allAccounts =
    case List.Extra.find (\account -> account.id == id) allAccounts of
        Just value ->
            value

        Nothing ->
            AccountUtil.empty



updateAccount : Model -> Account -> Model
updateAccount model account =
    { model | account = account }

reset : Model -> Model
reset model =
    { model
        | contentID = ""
        , account = AccountUtil.updateCompanyID AccountUtil.empty model.companyID
        , error = ""
        , validationFeedback = "Account ID must be positive number with 3 to 5 digits."
        , editViewActive = False
    }
