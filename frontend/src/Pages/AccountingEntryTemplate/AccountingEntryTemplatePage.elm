module Pages.AccountingEntryTemplate.AccountingEntryTemplatePage exposing (Msg, init, update, view)

import Api.General.AccountingEntryTemplateUtil as AccountingEntryTemplateUtil
import Api.General.HttpUtil as HttpUtil
import Api.Types.Account exposing (Account, decoderAccount)
import Api.Types.AccountingEntryTemplate exposing (AccountingEntryTemplate, decoderAccountingEntryTemplate, encoderAccountingEntryTemplate)
import Api.Types.AccountingEntryTemplateCreationParams exposing (encoderAccountingEntryTemplateCreationParams)
import Api.Types.AccountingEntryTemplateKey exposing (AccountingEntryTemplateKey, encoderAccountingEntryTemplateKey)
import Api.Types.LanguageComponents exposing (LanguageComponents)
import Browser
import Dropdown exposing (Item)
import Html exposing (Html, button, div, input, label, p, table, td, text, th, tr)
import Html.Attributes exposing (class, disabled, for, id, placeholder, style, value)
import Html.Events exposing (onClick, onInput)
import Http exposing (Error)
import Json.Decode as Decode
import Pages.AccountingEntryTemplate.AccountingEntryTemplatePageModel as Model exposing (Flags, Model, insertData, reset, updateAccountingEntryTemplate)
import Pages.AccountingEntryTemplate.ParseAndUpdateUtil exposing (handleSelection, parseAndUpdateAmount, parseAndUpdateCredit, parseAndUpdateDebit, updateCredit, updateDebit)
import Pages.LinkUtil as LinkUtil exposing (makeLinkCompanyId)
import Pages.SharedViewComponents exposing (accountForDropdown, accountListForDropdown, backToEntryPage)
import Pages.Util.AuthorizedAccess exposing (AuthorizedAccess)



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


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( Model.init flags
    , Cmd.batch
        [ getAccounts flags.authorizedAccess flags.companyId
        , getAccountingEntryTemplates flags.authorizedAccess flags.companyId
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
                    ( reset model, getAccountingEntryTemplates model.authorizedAccess model.companyId )

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
                    ( reset model, getAccountingEntryTemplates model.authorizedAccess model.companyId )

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
            ( model, createAccountingEntryTemplate model.authorizedAccess model.aet )

        ReplaceAccountingEntryTemplate ->
            ( model, replaceAccountingEntryTemplate model.authorizedAccess model.aet )

        DeleteAccountingEntryTemplate ->
            ( model, deleteAccountingEntryTemplate model.authorizedAccess model.aet )

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
    div [ class "page", class "templateInputArea" ]
        [ backToEntryPage model.lang.back model.companyId model.accountingYear model.lang.short
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
            [ input [ placeholder model.lang.description, value model.contentDescription, onInput ChangeDescription ] []
            , viewCreditInput model
            , viewDebitInput model
            , div [] [ input [ id "amountFieldTemplate", placeholder model.lang.amount, value model.contentAmount.text, onInput ChangeAmount ] [], label [] [ text model.error ] ]
            , div [] [ text (AccountingEntryTemplateUtil.show model.aet) ]
            , div []
                [ viewUpdateButton model.lang model.aet (model.selectedCredit /= model.selectedDebit)
                , button [ class "deleteButton", onClick DeleteAccountingEntryTemplate ] [ text model.lang.delete ]
                , button [ class "cancelButton", onClick DeactivateEditView ] [ text model.lang.cancel ]
                ]
            ]

    else
        div []
            [ div [] [ input [ placeholder model.lang.description, value model.contentDescription, onInput ChangeDescription ] [] ]
            , viewCreditInput model
            , viewDebitInput model
            , div [] [ input [ id "amountFieldTemplate", placeholder model.lang.amount, value model.contentAmount.text, onInput ChangeAmount ] [], label [] [ text model.error ] ]
            , div [] [ text (AccountingEntryTemplateUtil.show model.aet) ]
            , viewCreateButton model.lang model.aet (model.selectedCredit /= model.selectedDebit)
            ]


viewCreditInput : Model -> Html Msg
viewCreditInput model =
    div []
        [ label [ class "accountLabel" ] [ text (model.lang.credit ++ ": ") ]
        , input [ class "accountIdField", placeholder model.lang.accountId, value model.contentCreditID, onInput ChangeCredit ] []
        , Dropdown.dropdown
            (dropdownOptionsCredit model.lang.noValidAccount (accountListForDropdown model.allAccounts model.selectedDebit))
            []
            model.selectedCredit
        ]


viewDebitInput : Model -> Html Msg
viewDebitInput model =
    div []
        [ label [ class "accountLabel" ] [ text (model.lang.debit ++ ": ") ]
        , input [ class "accountIdField", placeholder model.lang.accountId, value model.contentDebitID, onInput ChangeDebit ] []
        , Dropdown.dropdown
            (dropdownOptionsDebit model.lang.noValidAccount (accountListForDropdown model.allAccounts model.selectedCredit))
            []
            model.selectedDebit
        ]


dropdownOptionsCredit : String -> List Account -> Dropdown.Options Msg
dropdownOptionsCredit text allAccounts =
    let
        defaultOptions =
            Dropdown.defaultOptions DropdownCreditChanged
    in
    { defaultOptions
        | items =
            List.map (\acc -> accountForDropdown acc) allAccounts
        , emptyItem = Just { value = "0", text = text, enabled = True }
    }


dropdownOptionsDebit : String -> List Account -> Dropdown.Options Msg
dropdownOptionsDebit text allAccounts =
    let
        defaultOptions =
            Dropdown.defaultOptions DropdownDebitChanged
    in
    { defaultOptions
        | items =
            List.map (\acc -> accountForDropdown acc) allAccounts
        , emptyItem = Just { value = "0", text = text, enabled = True }
    }


viewCreateButton : LanguageComponents -> AccountingEntryTemplate -> Bool -> Html Msg
viewCreateButton lang aet validSelection =
    let
        aetIsValid =
            AccountingEntryTemplateUtil.isValid aet
    in
    if aetIsValid && not validSelection then
        div []
            [ button [ class "saveButton", disabled True, onClick CreateAccountingEntryTemplate ] [ text lang.create ]
            , div [ style "color" "red" ] [ text lang.equalAccountsWarning ]
            ]

    else
        button [ class "saveButton", disabled (not (aetIsValid && validSelection)), onClick CreateAccountingEntryTemplate ] [ text lang.create ]


viewUpdateButton : LanguageComponents -> AccountingEntryTemplate -> Bool -> Html Msg
viewUpdateButton lang aet validSelection =
    let
        aetIsValid =
            AccountingEntryTemplateUtil.isValid aet
    in
    if aetIsValid && not validSelection then
        div []
            [ div [ style "color" "red" ] [ text lang.equalAccountsWarning ]
            , button [ class "saveButton", disabled True, onClick ReplaceAccountingEntryTemplate ] [ text lang.saveChanges ]
            ]

    else if aetIsValid && validSelection then
        button [ class "saveButton", disabled False, onClick ReplaceAccountingEntryTemplate ] [ text lang.saveChanges ]

    else
        button [ class "saveButton", disabled True, onClick ReplaceAccountingEntryTemplate ] [ text lang.saveChanges ]


viewAccountingEntryTemplateList : Model -> Html Msg
viewAccountingEntryTemplateList model =
    if model.buttonPressed then
        div []
            [ div [] [ button [ class "showButton", onClick HideAllAccountingEntryTemplates ] [ text model.lang.hideTemplateList ] ]
            , div []
                [ table
                    [ id "allAccountingEntryTemplates" ]
                    (tr [ class "tableHeader" ]
                        [ th [] [ label [ for "description" ] [ text model.lang.description ] ]
                        , th [] [ label [ for "credit" ] [ text model.lang.credit ] ]
                        , th [] [ label [ for "debit" ] [ text model.lang.debit ] ]
                        , th [] [ label [ for "amount" ] [ text model.lang.amount ] ]
                        ]
                        :: List.map (mkTableLine model.lang.edit) model.allAccountingEntryTemplates
                    )
                ]
            ]

    else
        div [] [ button [ class "showButton", onClick ShowAllAccountingEntryTemplates ] [ text model.lang.manageTemplates ] ]


mkTableLine : String -> AccountingEntryTemplate -> Html Msg
mkTableLine txt aet =
    tr []
        [ td [ class "textColumn" ] [ text aet.description ]
        , td [ class "numberColumn" ] [ text (String.fromInt aet.credit) ]
        , td [ class "numberColumn" ] [ text (String.fromInt aet.debit) ]
        , td [ class "numberColumn" ] [ text (AccountingEntryTemplateUtil.showAmount aet) ]
        , td [ class "buttonColumn" ] [ button [ class "editButton", onClick (ActivateEditView aet) ] [ text txt ] ]
        ]



-- COMMUNICATION


getAccountingEntryTemplates : AuthorizedAccess -> Int -> Cmd Msg
getAccountingEntryTemplates authorizedAccess companyId =
    HttpUtil.get
        { url = LinkUtil.backendPage authorizedAccess.configuration [ "accountingEntryTemplate", "getAll", makeLinkCompanyId companyId ]
        , expect = HttpUtil.expectJson GotResponseAllAccountingEntryTemplates (Decode.list decoderAccountingEntryTemplate)
        , jwt = authorizedAccess.jwt
        }


createAccountingEntryTemplate : AuthorizedAccess -> AccountingEntryTemplate -> Cmd Msg
createAccountingEntryTemplate authorizedAccess aet =
    HttpUtil.post
        { url = LinkUtil.backendPage authorizedAccess.configuration [ "accountingEntryTemplate", " insert" ]
        , expect = HttpUtil.expectJson GotResponseCreateOrReplace decoderAccountingEntryTemplate
        , body = Http.jsonBody (encoderAccountingEntryTemplateCreationParams (AccountingEntryTemplateUtil.getAccountingEntryTemplateCreationParams aet))
        , jwt = authorizedAccess.jwt
        }


replaceAccountingEntryTemplate : AuthorizedAccess -> AccountingEntryTemplate -> Cmd Msg
replaceAccountingEntryTemplate authorizedAccess aet =
    HttpUtil.post
        { url = LinkUtil.backendPage authorizedAccess.configuration [ "accountingEntryTemplate", "replace" ]
        , expect = HttpUtil.expectJson GotResponseCreateOrReplace decoderAccountingEntryTemplate
        , body = Http.jsonBody (encoderAccountingEntryTemplate aet)
        , jwt = authorizedAccess.jwt
        }


deleteAccountingEntryTemplate : AuthorizedAccess -> AccountingEntryTemplate -> Cmd Msg
deleteAccountingEntryTemplate authorizedAccess aet =
    HttpUtil.post
        { url = LinkUtil.backendPage authorizedAccess.configuration [ "accountingEntryTemplate", "delete" ]
        , expect = HttpUtil.expectWhatever GotResponseDelete
        , body = Http.jsonBody (encoderAccountingEntryTemplateKey { id = aet.id })
        , jwt = authorizedAccess.jwt
        }


getAccounts : AuthorizedAccess -> Int -> Cmd Msg
getAccounts authorizedAccess companyId =
    HttpUtil.get
        { url = LinkUtil.backendPage authorizedAccess.configuration [ "account", "getAll", makeLinkCompanyId companyId ]
        , expect = HttpUtil.expectJson GotResponseAllAccounts (Decode.list decoderAccount)
        , jwt = authorizedAccess.jwt
        }
