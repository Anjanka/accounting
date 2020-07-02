module Pages.AccountingEntry.AccountingEntryPage exposing (..)

import Api.General.AccountingEntryTemplateUtil as AccountingEntryTemplateUtil
import Api.General.AccountingEntryUtil as AccountingEntryUtil exposing (getCreationParams)

import Api.General.HttpUtil as HttpUtil
import Api.Types.Account exposing (Account, decoderAccount)
import Api.Types.AccountingEntry exposing (AccountingEntry, decoderAccountingEntry, encoderAccountingEntry)
import Api.Types.AccountingEntryCreationParams exposing (encoderAccountingEntryCreationParams)
import Api.Types.AccountingEntryKey exposing (encoderAccountingEntryKey)
import Api.Types.AccountingEntryTemplate exposing (AccountingEntryTemplate, decoderAccountingEntryTemplate)
import Browser
import Dropdown exposing (Item)
import Html exposing (Html, button, div, input, label, p, table, td, text, th, tr)
import Html.Attributes exposing (class, disabled, for, id, placeholder, style, value)
import Html.Events exposing (onClick, onInput)
import Http exposing (Error)
import Json.Decode as Decode
import Pages.AccountingEntry.AccountingEntryPageModel exposing (Model)
import Pages.AccountingEntry.HelperUtil exposing (getBalance, insertForEdit, insertTemplateData, reset, updateAccountingEntry)
import Pages.AccountingEntry.ParseAndUpdateUtil as ParseAndUpdateUtil
import Pages.SharedViewComponents exposing (accountForDropdown, accountListForDropdown)



-- MAIN


main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- MODEL


type alias Flags =
    ()


init : Flags -> ( Model, Cmd Msg )
init _ =
    ( { companyId = 1
      , accountingYear = 2020
      , contentBookingDate = ""
      , contentReceiptNumber = ""
      , contentDescription = ""
      , contentDebitID = ""
      , contentCreditID = ""
      , contentAmount = ""
      , accountingEntry = AccountingEntryUtil.updateCompanyId AccountingEntryUtil.empty 1
      , allAccountingEntries = []
      , allAccounts = []
      , allAccountingEntryTemplates = []
      , response = ""
      , feedback = ""
      , error = ""
      , editActive = False
      , selectedTemplate = Nothing
      , selectedCredit = Nothing
      , selectedDebit = Nothing
      }
    , getAccounts 1
    )



-- UPDATE


type Msg
    = ChangeBookingDate String
    | ChangeReceiptNumber String
    | ChangeDescription String
    | ChangeDebit String
    | ChangeCredit String
    | ChangeAmount String
    | CreateAccountingEntry
    | ReplaceAccountingEntry
    | DeleteAccountingEntry
    | GotResponseAllAccountingEntries (Result Error (List AccountingEntry))
    | GotResponseAllAccountingEntryTemplates (Result Error (List AccountingEntryTemplate))
    | GotResponseAllAccounts (Result Error (List Account))
    | GotResponsePost (Result Error AccountingEntry)
    | GotResponseDelete (Result Error ())
    | DropdownTemplateChanged (Maybe String)
    | DropdownCreditChanged (Maybe String)
    | DropdownDebitChanged (Maybe String)
    | EditAccountingEntry AccountingEntry
    | LeaveEditView
    | GoToAccountPage
    | GoToAccountingTemplatePage


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotResponseAllAccountingEntries result ->
            case result of
                Ok value ->
                    ( { model
                        | allAccountingEntries = value |> List.sortBy .id
                        , accountingEntry = AccountingEntryUtil.updateAccountingYear (AccountingEntryUtil.updateCompanyId model.accountingEntry model.companyId) model.accountingYear
                      }
                    , Cmd.none
                    )

                Err error ->
                    ( { model | error = HttpUtil.errorToString error }, Cmd.none )

        GotResponseAllAccountingEntryTemplates result ->
            case result of
                Ok value ->
                    ( { model
                        | allAccountingEntryTemplates = value
                        , response = value |> List.sortBy .description |> List.map AccountingEntryTemplateUtil.show |> String.join ",\n"
                        , feedback = ""
                      }
                    , getAccountingEntriesForCurrentYear model.companyId model.accountingYear
                    )

                Err error ->
                    ( { model | error = HttpUtil.errorToString error }, Cmd.none )

        GotResponseAllAccounts result ->
            case result of
                Ok value ->
                    ( { model | allAccounts = List.sortBy .title value }, getAccountingEntryTemplates model.companyId )

                Err error ->
                    ( { model | allAccounts = [], error = HttpUtil.errorToString error }, Cmd.none )

        GotResponsePost result ->
            case result of
                Ok value ->
                    ( reset model, getAccountingEntriesForCurrentYear model.companyId model.accountingYear )

                Err error ->
                    ( { model | error = HttpUtil.errorToString error }, Cmd.none )

        GotResponseDelete result ->
            case result of
                Ok value ->
                    ( reset model, getAccountingEntriesForCurrentYear model.companyId model.accountingYear )

                Err error ->
                    ( { model | error = HttpUtil.errorToString error }, Cmd.none )

        ChangeBookingDate newContent ->
            ( ParseAndUpdateUtil.parseDate model newContent, Cmd.none )

        ChangeReceiptNumber newContent ->
            ( { model | contentReceiptNumber = newContent, accountingEntry = AccountingEntryUtil.updateReceiptNumber model.accountingEntry newContent }, Cmd.none )

        ChangeDescription newContent ->
            let
                newModel =
                    model.accountingEntry
                        |> (\ae -> AccountingEntryUtil.updateDescription ae newContent)
                        |> updateAccountingEntry model
            in
            ( { newModel | contentDescription = newContent }, Cmd.none )

        ChangeDebit newContent ->
            ( ParseAndUpdateUtil.parseAndUpdateDebit model newContent, Cmd.none )

        ChangeCredit newContent ->
            ( ParseAndUpdateUtil.parseAndUpdateCredit model newContent, Cmd.none )

        ChangeAmount newContent ->
            ( ParseAndUpdateUtil.parseAndUpdateAmount model newContent, Cmd.none )

        DropdownTemplateChanged selectedTemplate ->
            ( insertTemplateData model selectedTemplate, Cmd.none )

        DropdownCreditChanged selectedCredit ->
            ( ParseAndUpdateUtil.updateCredit model selectedCredit, Cmd.none )

        DropdownDebitChanged selectedDebit ->
            ( ParseAndUpdateUtil.updateDebit model selectedDebit, Cmd.none )

        CreateAccountingEntry ->
            ( reset model, createAccountingEntry model.accountingEntry )

        ReplaceAccountingEntry ->
            ( reset model, replaceAccountingEntry model.accountingEntry )

        DeleteAccountingEntry ->
            ( reset model, deleteAccountingEntry model.accountingEntry )

        EditAccountingEntry accountingEntry ->
            ( insertForEdit model accountingEntry, Cmd.none )

        LeaveEditView ->
            ( reset model, Cmd.none )

        GoToAccountPage ->
            ( model, Cmd.none )

        GoToAccountingTemplatePage ->
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ div [] [ button [ onClick GoToAccountPage ] [ text "Manage Accounts" ], button [ onClick GoToAccountingTemplatePage ] [ text "Manage Templates" ] ]
        , p [] []
        , viewInputArea model

        --   , div [] [ text (AccountingEntryUtil.show model.accountingEntry) ]
        , viewValidatedInput model.accountingEntry model.editActive (model.selectedDebit /= model.selectedCredit)
        , div [] [ text model.error ]
        , p [] []
        , viewEntryList model
        ]


viewInputArea : Model -> Html Msg
viewInputArea model =
    div []
        [ div [] [ label [] [ text "Booking Date: " ], input [ placeholder "dd.mm", value model.contentBookingDate, onInput ChangeBookingDate ] [], label [] [ text (String.fromInt model.accountingYear) ], input [ placeholder "Receipt Number", value model.contentReceiptNumber, onInput ChangeReceiptNumber ] [] ]
        , div []
            [ input [ placeholder "Description", value model.contentDescription, onInput ChangeDescription ] []
            , viewTemplateSelection model
            , input [ placeholder "Amount", value model.contentAmount, onInput ChangeAmount ] []
            ]
        , viewCreditInput model
        , viewDebitInput model
        ]


viewValidatedInput : AccountingEntry -> Bool -> Bool -> Html Msg
viewValidatedInput accountingEntry editActive validSelection =
    let
        validEntry =
            AccountingEntryUtil.isValid accountingEntry
    in
    if editActive && not validSelection && validEntry then
        div []
            [ button [ disabled True, onClick ReplaceAccountingEntry ] [ text "Save Changes" ]
            , button [ onClick DeleteAccountingEntry ] [ text "Delete" ]
            , button [ onClick LeaveEditView ] [ text "Cancel" ]
            , div [ style "color" "red" ] [ text "Credit and Debit must not be equal." ]
            ]

    else if editActive && validEntry then
        div [] [ button [ disabled False, onClick ReplaceAccountingEntry ] [ text "Save Changes" ], button [ onClick DeleteAccountingEntry ] [ text "Delete" ], button [ onClick LeaveEditView ] [ text "Cancel" ] ]

    else if editActive then
        div [] [ button [ disabled True, onClick ReplaceAccountingEntry ] [ text "Save Changes" ], button [ onClick DeleteAccountingEntry ] [ text "Delete" ], button [ onClick LeaveEditView ] [ text "Cancel" ] ]

    else if not validSelection && validEntry then
        div []
            [ button [ disabled True, onClick CreateAccountingEntry ] [ text "Commit New Entry" ]
            , div [ style "color" "red" ] [ text "Credit and Debit must not be equal." ]
            ]

    else if validEntry then
        button [ disabled False, onClick CreateAccountingEntry ] [ text "Commit New Entry" ]

    else
        button [ disabled True, onClick CreateAccountingEntry ] [ text "Commit New Entry" ]


viewEntryList : Model -> Html Msg
viewEntryList model =
    div [ id "allAccountingEntries" ]
        [ table
            []
            (tr [ class "tableHeader" ]
                [ th [] [ label [ for "id" ] [ text "id" ] ]
                , th [] [ label [ for "receipt number" ] [ text "receipt number" ] ]
                , th [] [ label [ for "booking date" ] [ text "booking date" ] ]
                , th [] [ label [ for "description" ] [ text "description" ] ]
                , th [] [ label [ for "amount" ] [ text "amount" ] ]
                , th [] [ label [ for "credit account" ] [ text "credit account" ] ]
                , th [] [ label [ for "debit account" ] [ text "debit account" ] ]
                ]
                :: List.map (mkTableLine model.editActive) model.allAccountingEntries
            )
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
        , label [] [ text (getBalance model.contentCreditID model.allAccountingEntries) ]
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
        , label [] [ text (getBalance model.contentDebitID model.allAccountingEntries) ]
        ]


viewTemplateSelection : Model -> Html Msg
viewTemplateSelection model =
    Dropdown.dropdown
        (dropdownOptionsTemplate model.allAccountingEntryTemplates)
        []
        model.selectedTemplate


mkTableLine : Bool -> AccountingEntry -> Html Msg
mkTableLine editInactive accountingEntry =
    tr []
        [ td [] [ text (String.fromInt accountingEntry.id) ]
        , td [] [ text accountingEntry.receiptNumber ]
        , td [] [ text (AccountingEntryUtil.stringFromDate accountingEntry.bookingDate) ]
        , td [] [ text accountingEntry.description ]
        , td [] [ text (AccountingEntryUtil.showAmount accountingEntry) ]
        , td [] [ text (String.fromInt accountingEntry.credit) ]
        , td [] [ text (String.fromInt accountingEntry.debit) ]
        , if editInactive then
            button [ disabled True, onClick (EditAccountingEntry accountingEntry) ] [ text "Edit" ]

          else
            button [ disabled False, onClick (EditAccountingEntry accountingEntry) ] [ text "Edit" ]
        ]


dropdownOptionsTemplate : List AccountingEntryTemplate -> Dropdown.Options Msg
dropdownOptionsTemplate allAccountingEntryTemplates =
    let
        defaultOptions =
            Dropdown.defaultOptions DropdownTemplateChanged
    in
    { defaultOptions
        | items =
            List.map (\description -> { value = description, text = description, enabled = True }) (List.map (\aet -> aet.description) allAccountingEntryTemplates)
        , emptyItem = Just { value = "0", text = "[Select Template]", enabled = True }
    }


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



-- COMMUNICATION


getAccountingEntriesForCurrentYear : Int -> Int -> Cmd Msg
getAccountingEntriesForCurrentYear companyId year =
    Http.get
        { url = "http://localhost:9000/accountingEntry/findByYear/" ++ String.fromInt companyId ++ "/" ++ String.fromInt year
        , expect = HttpUtil.expectJson GotResponseAllAccountingEntries (Decode.list decoderAccountingEntry)
        }


getAccountingEntryTemplates : Int -> Cmd Msg
getAccountingEntryTemplates companyId =
    Http.get
        { url = "http://localhost:9000/accountingEntryTemplate/getAll/" ++ String.fromInt companyId
        , expect = HttpUtil.expectJson GotResponseAllAccountingEntryTemplates (Decode.list decoderAccountingEntryTemplate)
        }


getAccounts : Int -> Cmd Msg
getAccounts companyId =
    Http.get
        { url = "http://localhost:9000/account/getAll/" ++ String.fromInt companyId
        , expect = HttpUtil.expectJson GotResponseAllAccounts (Decode.list decoderAccount)
        }


createAccountingEntry : AccountingEntry -> Cmd Msg
createAccountingEntry accountingEntry =
    Http.post
        { url = "http://localhost:9000/accountingEntry/insert"
        , expect = HttpUtil.expectJson GotResponsePost decoderAccountingEntry
        , body = Http.jsonBody (encoderAccountingEntryCreationParams (getCreationParams accountingEntry))
        }


replaceAccountingEntry : AccountingEntry -> Cmd Msg
replaceAccountingEntry accountingEntry =
    Http.post
        { url = "http://localhost:9000/accountingEntry/replace"
        , expect = HttpUtil.expectJson GotResponsePost decoderAccountingEntry
        , body = Http.jsonBody (encoderAccountingEntry accountingEntry)
        }


deleteAccountingEntry : AccountingEntry -> Cmd Msg
deleteAccountingEntry accountingEntry =
    Http.post
        { url = "http://localhost:9000/accountingEntry/delete"
        , expect = HttpUtil.expectWhatever GotResponseDelete
        , body = Http.jsonBody (encoderAccountingEntryKey { companyID = accountingEntry.companyId, id = accountingEntry.id, accountingYear = accountingEntry.accountingYear })
        }
