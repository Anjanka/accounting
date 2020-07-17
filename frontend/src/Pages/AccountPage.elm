module Pages.AccountPage exposing (Model, Msg, init, update, view)

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
import Pages.SharedViewComponents exposing (backToEntryPage)



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
    { companyId : Int
    , accountingYear : Maybe Int
    , contentId : String
    , account : Account
    , allAccounts : List Account
    , error : String
    , validationFeedback : String
    , buttonPressed : Bool
    , editViewActive : Bool
    }



--defaultFlags : Flags
--defaultFlags =
--    { companyId = 1,
--    accountingYear = Just 1}
--
--
--dummyInit : () -> ( Model, Cmd Msg )
--dummyInit _ =
--    init defaultFlags
-- MODEL


type alias Flags =
    { companyId : Int
    , accountingYear : Maybe Int
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { companyId = flags.companyId
      , accountingYear = flags.accountingYear
      , contentId = ""
      , account = AccountUtil.updateCompanyID AccountUtil.empty flags.companyId
      , allAccounts = []
      , error = ""
      , validationFeedback = "Account ID must be positive number with 3 to 5 digits. Leading 0s will be ignored"
      , buttonPressed = False
      , editViewActive = False
      }
    , getAccounts flags.companyId
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
            ( { model | buttonPressed = True }, getAccounts model.companyId )

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
                    ( reset model, getAccounts model.companyId )

                Err error ->
                    ( { model | error = HttpUtil.errorToString error }, Cmd.none )

        GotResponseDelete result ->
            case result of
                Ok _ ->
                    ( reset model, getAccounts model.companyId )

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
            ( { model | contentId = String.fromInt account.id, account = account, editViewActive = True }, Cmd.none )

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
    div [class "page", class "accountInputArea"]
        [ backToEntryPage model.companyId model.accountingYear
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
            [ label [] [ text (model.contentId ++ " - ") ]
            , input [ placeholder "Account Name", value model.account.title, onInput ChangeName ] []
            , div []
                [ button
                    [ class "saveButton",  onClick ReplaceAccount
                    ]
                    [ text "Save Changes" ]
                , button [ class "deleteButton", onClick DeleteAccount ] [ text "Delete" ]
                , button [ class "cancelButton", onClick DeactivateEditView ] [ text "Cancel" ]
                ]
            ]

    else
        div []
            [ input [ class "accountIdField", placeholder "Account ID", value model.contentId, onInput ChangeID ] []
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
        button [ class "saveButton", disabled True, onClick CreateAccount ] [ text "Create new Account" ]

    else
        button [ class "saveButton", disabled False, onClick CreateAccount ] [ text "Create new Account" ]


viewAccountList : Model -> Html Msg
viewAccountList model =
    if model.buttonPressed then
        div []
            [ div [] [ button [ class "showButton", onClick HideAllAccounts ] [ text "Hide Accounts" ] ]
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
        div [] [ button [ class "showButton", onClick ShowAllAccounts ] [ text "Manage Accounts" ] ]


mkTableLine : Account -> Html Msg
mkTableLine account =
    tr []
        [ td [class "numberColumn"] [ text (String.fromInt account.id) ]
        , td [class "textColumn"] [ text account.title ]
        , td [class "buttonColumn"] [button [ class "editButton", onClick (ActivateEditView account) ] [ text "Edit" ]]
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
        , body = Http.jsonBody (encoderAccountKey { id = account.id, companyId = account.companyId })
        }



-- UTILITIES


parseAndUpdateAccount : Model -> String -> Model
parseAndUpdateAccount model idCandidate =
    let
        idNotValid =
            "Account ID must be positive number with 3 to 5 digits. Leading 0s will be ignored"

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
                    { model | contentId = idCandidate, account = AccountUtil.updateId model.account int, validationFeedback = "" }

                else if int >= 100 && int <= 99999 && accountExist then
                    { model | contentId = idCandidate, account = AccountUtil.updateId model.account 0, validationFeedback = existingAccount }

                else if int > 99999 || String.length idCandidate > 5 then
                    model

                else
                    { model | contentId = idCandidate, account = AccountUtil.updateId model.account 0, validationFeedback = idNotValid }

            Nothing ->
                model

    else
        { model | contentId = "", account = AccountUtil.updateId model.account 0, validationFeedback = idNotValid }


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
        | contentId = ""
        , account = AccountUtil.updateCompanyID AccountUtil.empty model.companyId
        , error = ""
        , validationFeedback = "Account ID must be positive number with 3 to 5 digits."
        , editViewActive = False
    }
