module Pages.AccountingEntryTemplatePage.AccountingEntryTemplatePage exposing (Msg, init, update, view)

import Api.General.AccountingEntryTemplateUtil as AccountingEntryTemplateUtil
import Api.General.HttpUtil as HttpUtil
import Api.Types.Account exposing (Account, decoderAccount)
import Api.Types.AccountingEntryTemplate exposing (AccountingEntryTemplate, decoderAccountingEntryTemplate, encoderAccountingEntryTemplate)
import Api.Types.AccountingEntryTemplateCreationParams exposing (encoderAccountingEntryTemplateCreationParams)
import Api.Types.AccountingEntryTemplateKey exposing (AccountingEntryTemplateKey, encoderAccountingEntryTemplateKey)
import Browser
import Dropdown exposing (Item)
import Html exposing (Html, button, div, input, label, p, table, td, text, th, tr)
import Html.Attributes exposing (class, disabled, for, id, placeholder, style, value)
import Html.Events exposing (onClick, onInput)
import Http exposing (Error)
import Json.Decode as Decode
import Pages.AccountingEntryTemplatePage.AccountingEntryTemplatePageModel exposing (Model)
import Pages.AccountingEntryTemplatePage.HelperUtil exposing (insertData, reset, updateAccountingEntryTemplate)
import Pages.AccountingEntryTemplatePage.ParseAndUpdateUtil exposing (handleSelection, parseAndUpdateAmount, parseAndUpdateCredit, parseAndUpdateDebit, updateCredit, updateDebit)
import Pages.SharedViewComponents exposing (accountForDropdown, accountListForDropdown, backToEntryPage)



-- MAIN


main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



--defaultFlags : Flags
--defaultFlags =
--    { companyId = 1
--    , accountingYear =  Just 1}
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
      , contentDescription = ""
      , contentDebitID = ""
      , contentCreditID = ""
      , contentAmount = ""
      , aet = AccountingEntryTemplateUtil.updateCompanyId AccountingEntryTemplateUtil.empty 1
      , allAccounts = []
      , allAccountingEntryTemplates = []
      , response = ""
      , feedback = ""
      , error = ""
      , selectedCredit = Nothing
      , selectedDebit = Nothing
      , buttonPressed = False
      , editViewActive = False
      }
    , Cmd.batch
        [ getAccounts flags.companyId
        , getAccountingEntryTemplates flags.companyId
        ]
    )



-- UPDATE


type Msg
    = ShowAllAccountingEntryTemplates
    | HideAllAccountingEntryTemplates
    | ChangeDescription String
    | ChangeDebit String
    | ChangeCredit String
    | ChangeAmount String
    | GotResponseAllAccountingEntryTemplates (Result Error (List AccountingEntryTemplate))
    | GotResponseCreateOrReplace (Result Error AccountingEntryTemplate)
    | GotResponseAllAccounts (Result Error (List Account))
    | GotResponseDelete (Result Error ())
    | CreateAccountingEntryTemplate
    | ReplaceAccountingEntryTemplate
    | DeleteAccountingEntryTemplate
    | DropdownCreditChanged (Maybe String)
    | DropdownDebitChanged (Maybe String)
    | ActivateEditView AccountingEntryTemplate
    | DeactivateEditView
    | BackToAccountingEntryPage


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ShowAllAccountingEntryTemplates ->
            ( { model | buttonPressed = True }, Cmd.none )

        HideAllAccountingEntryTemplates ->
            ( { model | buttonPressed = False }, Cmd.none )

        GotResponseAllAccountingEntryTemplates result ->
            case result of
                Ok value ->
                    ( { model | allAccountingEntryTemplates = List.sortBy .description value }, Cmd.none )

                Err error ->
                    ( { model | error = HttpUtil.errorToString error }, Cmd.none )

        GotResponseCreateOrReplace result ->
            case result of
                Ok _ ->
                    ( reset model, getAccountingEntryTemplates model.companyId )

                Err error ->
                    ( { model | error = HttpUtil.errorToString error }, Cmd.none )

        GotResponseAllAccounts result ->
            case result of
                Ok value ->
                    ( { model | allAccounts = value }, Cmd.none )

                Err error ->
                    ( { model | allAccounts = [], error = HttpUtil.errorToString error }, Cmd.none )

        GotResponseDelete result ->
            case result of
                Ok _ ->
                    ( reset model, getAccountingEntryTemplates model.companyId )

                Err error ->
                    ( { model | error = HttpUtil.errorToString error }, Cmd.none )

        ChangeDescription newContent ->
            let
                newModel =
                    model.aet
                        |> (\aet -> AccountingEntryTemplateUtil.updateDescription aet newContent)
                        |> updateAccountingEntryTemplate model
            in
            ( { newModel | contentDescription = newContent }, Cmd.none )

        ChangeDebit newContent ->
            ( parseAndUpdateDebit model newContent, Cmd.none )

        ChangeCredit newContent ->
            ( parseAndUpdateCredit model newContent, Cmd.none )

        ChangeAmount newContent ->
            ( parseAndUpdateAmount model newContent, Cmd.none )

        CreateAccountingEntryTemplate ->
            ( model, createAccountingEntryTemplate model.aet )

        ReplaceAccountingEntryTemplate ->
            ( model, replaceAccountingEntryTemplate model.aet )

        DeleteAccountingEntryTemplate ->
            ( model, deleteAccountingEntryTemplate model.aet )

        DropdownCreditChanged selectedCredit ->
            ( handleSelection updateCredit { model | selectedCredit = selectedCredit } selectedCredit, Cmd.none )

        DropdownDebitChanged selectedDebit ->
            ( handleSelection updateDebit { model | selectedDebit = selectedDebit } selectedDebit, Cmd.none )

        ActivateEditView aet ->
            ( insertData model aet, Cmd.none )

        DeactivateEditView ->
            ( { model | editViewActive = False }, Cmd.none )

        BackToAccountingEntryPage ->
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div [class "page"]
        [ backToEntryPage model.companyId model.accountingYear
        , p [] []
        , viewEditOrCreate model
        , p [] []
        , viewAccountingEntryTemplateList model
        , p [] []
        , div [] [ text model.error ]
        ]


viewEditOrCreate : Model -> Html Msg
viewEditOrCreate model =
    if model.editViewActive then
        div []
            [ input [ placeholder "Description", value model.contentDescription, onInput ChangeDescription ] []
            , viewCreditInput model
            , viewDebitInput model
            , div [] [ input [ id "amountFieldTemplate", placeholder "Amount", value model.contentAmount, onInput ChangeAmount ] [], label [] [ text model.error ] ]

            --  , div [] [ text (AccountingEntryTemplateUtil.show model.aet) ]
            , div []
                [ viewUpdateButton model.aet (model.selectedCredit /= model.selectedDebit)
                , button [ class "deleteButton", onClick DeleteAccountingEntryTemplate ] [ text "Delete" ]
                , button [ class "cancelButton", onClick DeactivateEditView ] [ text "Cancel" ]
                ]
            ]

    else
        div []
            [ div [] [ input [ placeholder "Description", value model.contentDescription, onInput ChangeDescription ] [] ]
            , viewCreditInput model
            , viewDebitInput model
            , div [] [ input [ placeholder "Amount", value model.contentAmount, onInput ChangeAmount ] [], label [] [ text model.error ] ]
            , div [] [ text (AccountingEntryTemplateUtil.show model.aet) ]
            , viewCreateButton model.aet (model.selectedCredit /= model.selectedDebit)
            ]


viewCreditInput : Model -> Html Msg
viewCreditInput model =
    div []
        [ label [] [ text "Credit: " ]
        , input [ placeholder "Credit Account ID", value model.contentCreditID, onInput ChangeCredit ] []
        , Dropdown.dropdown
            (dropdownOptionsCredit (accountListForDropdown model.allAccounts model.selectedDebit))
            []
            model.selectedCredit
        ]


viewDebitInput : Model -> Html Msg
viewDebitInput model =
    div []
        [ label [] [ text "Debit: " ]
        , input [ placeholder "Debit Account ID", value model.contentDebitID, onInput ChangeDebit ] []
        , Dropdown.dropdown
            (dropdownOptionsDebit (accountListForDropdown model.allAccounts model.selectedCredit))
            []
            model.selectedDebit
        ]


dropdownOptionsCredit : List Account -> Dropdown.Options Msg
dropdownOptionsCredit allAccounts =
    let
        defaultOptions =
            Dropdown.defaultOptions DropdownCreditChanged
    in
    { defaultOptions
        | items =
            List.map (\acc -> accountForDropdown acc) allAccounts
        , emptyItem = Just { value = "0", text = "no valid account selected", enabled = True }
    }


dropdownOptionsDebit : List Account -> Dropdown.Options Msg
dropdownOptionsDebit allAccounts =
    let
        defaultOptions =
            Dropdown.defaultOptions DropdownDebitChanged
    in
    { defaultOptions
        | items =
            List.map (\acc -> accountForDropdown acc) allAccounts
        , emptyItem = Just { value = "0", text = "no valid account selected", enabled = True }
    }


viewCreateButton : AccountingEntryTemplate -> Bool -> Html Msg
viewCreateButton aet validSelection =
    let
        aetIsValid =
            AccountingEntryTemplateUtil.isValid aet
    in
    if aetIsValid && not validSelection then
        div []
            [ button [ class "saveButton", disabled True, onClick CreateAccountingEntryTemplate ] [ text "Create new Accounting Entry Template" ]
            , div [ style "color" "red" ] [ text "Credit and Debit must not be equal." ]
            ]

    else
        button [ class "saveButton", disabled (not (aetIsValid && validSelection)), onClick CreateAccountingEntryTemplate ] [ text "Create new Accounting Entry Template" ]


viewUpdateButton : AccountingEntryTemplate -> Bool -> Html Msg
viewUpdateButton aet validSelection =
    let
        aetIsValid =
            AccountingEntryTemplateUtil.isValid aet
    in
    if aetIsValid && not validSelection then
        div []
            [ div [ style "color" "red" ] [ text "Credit and Debit must not be equal." ]
            , button [ class "saveButton", disabled True, onClick ReplaceAccountingEntryTemplate ] [ text "Save Changes" ]
            ]

    else if aetIsValid && validSelection then
        button [ class "saveButton", disabled False, onClick ReplaceAccountingEntryTemplate ] [ text "Save Changes" ]

    else
        button [ class "saveButton", disabled True, onClick ReplaceAccountingEntryTemplate ] [ text "Save Changes" ]


viewAccountingEntryTemplateList : Model -> Html Msg
viewAccountingEntryTemplateList model =
    if model.buttonPressed then
        div []
            [ div [] [ button [class "showButton", onClick HideAllAccountingEntryTemplates ] [ text "Hide Accounting Entry Templates" ] ]
            , div [  ]
                [ table
                    [id "allAccountingEntryTemplates"]
                    (tr [ class "tableHeader" ]
                        [ th [] [ label [ for "description" ] [ text "description" ] ]
                        , th [] [ label [ for "credit" ] [ text "credit" ] ]
                        , th [] [ label [ for "debit" ] [ text "debit" ] ]
                        , th [] [ label [ for "amount" ] [ text "amount" ] ]
                        ]
                        :: List.map mkTableLine model.allAccountingEntryTemplates
                    )
                ]
            ]

    else
        div [] [ button [ class "showButton", onClick ShowAllAccountingEntryTemplates ] [ text "Manage Accounts" ] ]


mkTableLine : AccountingEntryTemplate -> Html Msg
mkTableLine aet =
    tr []
        [ td [class "textColumn"] [ text aet.description ]
        , td [class "numberColumn"] [ text (String.fromInt aet.credit) ]
        , td [class "numberColumn"] [ text (String.fromInt aet.debit) ]
        , td [class "numberColumn"] [ text (AccountingEntryTemplateUtil.showAmount aet) ]
        , td [class "buttonColumn"] [button [ class "editButton", onClick (ActivateEditView aet) ] [ text "Edit" ]]
        ]



-- COMMUNICATION


getAccountingEntryTemplates : Int -> Cmd Msg
getAccountingEntryTemplates companyId =
    Http.get
        { url = "http://localhost:9000/accountingEntryTemplate/getAll/" ++ String.fromInt companyId
        , expect = HttpUtil.expectJson GotResponseAllAccountingEntryTemplates (Decode.list decoderAccountingEntryTemplate)
        }


createAccountingEntryTemplate : AccountingEntryTemplate -> Cmd Msg
createAccountingEntryTemplate aet =
    Http.post
        { url = "http://localhost:9000/accountingEntryTemplate/insert"
        , expect = HttpUtil.expectJson GotResponseCreateOrReplace decoderAccountingEntryTemplate
        , body = Http.jsonBody (encoderAccountingEntryTemplateCreationParams (AccountingEntryTemplateUtil.getAccountingEntryTemplateCreationParams aet))
        }


replaceAccountingEntryTemplate : AccountingEntryTemplate -> Cmd Msg
replaceAccountingEntryTemplate aet =
    Http.post
        { url = "http://localhost:9000/accountingEntryTemplate/replace"
        , expect = HttpUtil.expectJson GotResponseCreateOrReplace decoderAccountingEntryTemplate
        , body = Http.jsonBody (encoderAccountingEntryTemplate aet)
        }


deleteAccountingEntryTemplate : AccountingEntryTemplate -> Cmd Msg
deleteAccountingEntryTemplate aet =
    Http.post
        { url = "http://localhost:9000/accountingEntryTemplate/delete"
        , expect = HttpUtil.expectWhatever GotResponseDelete
        , body = Http.jsonBody (encoderAccountingEntryTemplateKey { id = aet.id })
        }


getAccounts : Int -> Cmd Msg
getAccounts companyId =
    Http.get
        { url = "http://localhost:9000/account/getAll/" ++ String.fromInt companyId
        , expect = HttpUtil.expectJson GotResponseAllAccounts (Decode.list decoderAccount)
        }
