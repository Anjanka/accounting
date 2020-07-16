module Pages.AccountingEntry.AccountingEntryPage exposing (Msg, init, update, view)

import Api.General.AccountingEntryTemplateUtil as AccountingEntryTemplateUtil
import Api.General.AccountingEntryUtil as AccountingEntryUtil exposing (getCreationParams, getKey)
import Api.General.DateUtil as DateUtil
import Api.General.HttpUtil as HttpUtil
import Api.Types.Account exposing (Account, decoderAccount)
import Api.Types.AccountingEntry exposing (AccountingEntry, decoderAccountingEntry, encoderAccountingEntry)
import Api.Types.AccountingEntryCreationParams exposing (AccountingEntryCreationParams, encoderAccountingEntryCreationParams)
import Api.Types.AccountingEntryKey exposing (encoderAccountingEntryKey)
import Api.Types.AccountingEntryTemplate exposing (AccountingEntryTemplate, decoderAccountingEntryTemplate)
import Browser
import Dropdown exposing (Item)
import Html exposing (Html, button, div, input, label, p, table, td, text, th, tr)
import Html.Attributes exposing (action, class, disabled, for, id, placeholder, style, value)
import Html.Events exposing (onClick, onInput)
import Http exposing (Error)
import Json.Decode as Decode
import Pages.AccountingEntry.AccountingEntryPageModel exposing (Model)
import Pages.AccountingEntry.HelperUtil exposing (EntryWithListPosition, Position(..), getBalance, getListWithPosition, handleAccountSelection, handleSelection, insertForEdit, insertTemplateData, reset, unicodeToString)
import Pages.AccountingEntry.InputContent exposing (emptyInputContent)
import Pages.AccountingEntry.ParseAndUpdateUtil exposing (handleParseResultDay, handleParseResultMonth, parseAndUpdateAmount, parseAndUpdateCredit, parseAndUpdateDebit, parseDay, parseMonth, updateCredit, updateDay, updateDebit, updateDescription, updateMonth, updateReceiptNumber)
import Pages.LinkUtil exposing (Path(..), fragmentUrl, makeLinkId, makeLinkPath)
import Pages.SharedViewComponents exposing (accountForDropdown, accountListForDropdown, linkButton)



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
--    { companyId = 1, accountingYear = 2020 }
--
--
--dummyInit : () -> ( Model, Cmd Msg )
--dummyInit _ =
--    init defaultFlags
-- MODEL


type alias Flags =
    { companyId : Int
    , accountingYear : Int
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { companyId = flags.companyId
      , accountingYear = flags.accountingYear
      , content = emptyInputContent
      , accountingEntry = AccountingEntryUtil.emptyWith flags
      , allAccountingEntries = []
      , allAccounts = []
      , allAccountingEntryTemplates = []
      , response = ""
      , feedback = ""
      , error = ""
      , editActive = False
      , accountViewActive = False
      , selectedTemplate = Nothing
      , selectedCredit = Nothing
      , selectedDebit = Nothing
      }
    , Cmd.batch
        [ getAccounts flags.companyId
        , getAccountingEntryTemplates flags.companyId
        , getAccountingEntriesForCurrentYear flags.companyId flags.accountingYear
        ]
    )



-- UPDATE


type Msg
    = ChangeDay String
    | ChangeMonth String
    | ChangeReceiptNumber String
    | ChangeDescription String
    | ChangeDebit String
    | ChangeCredit String
    | ChangeAmount String
    | CreateAccountingEntry
    | ReplaceAccountingEntry
    | DeleteAccountingEntry
    | MoveEntryUp AccountingEntry
    | MoveEntryDown AccountingEntry
    | GotResponseAllAccountingEntries (Result Error (List AccountingEntry))
    | GotResponseAllAccountingEntryTemplates (Result Error (List AccountingEntryTemplate))
    | GotResponseAllAccounts (Result Error (List Account))
    | GotResponsePost (Result Error AccountingEntry)
    | GotResponseDeleteOrSwap (Result Error ())
    | DropdownTemplateChanged (Maybe String)
    | DropdownCreditChanged (Maybe String)
    | DropdownDebitChanged (Maybe String)
    | EditAccountingEntry AccountingEntry
    | LeaveEditView
    | ShowAccountList
    | HideAccountList
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
                    , Cmd.none
                    )

                Err error ->
                    ( { model | error = HttpUtil.errorToString error }, Cmd.none )

        GotResponseAllAccounts result ->
            case result of
                Ok value ->
                    ( { model | allAccounts = List.sortBy .title value }, Cmd.none )

                Err error ->
                    ( { model | allAccounts = [], error = HttpUtil.errorToString error }, Cmd.none )

        GotResponsePost result ->
            case result of
                Ok _ ->
                    ( reset model, getAccountingEntriesForCurrentYear model.companyId model.accountingYear )

                Err error ->
                    ( { model | error = HttpUtil.errorToString error }, Cmd.none )

        GotResponseDeleteOrSwap result ->
            case result of
                Ok _ ->
                    ( reset model, getAccountingEntriesForCurrentYear model.companyId model.accountingYear )

                Err error ->
                    ( { model | error = HttpUtil.errorToString error }, Cmd.none )

        ChangeDay newContent ->
            ( updateDay model (handleParseResultDay model.accountingEntry.bookingDate.day (parseDay model newContent)), Cmd.none )

        ChangeMonth newContent ->
            ( updateMonth model (handleParseResultMonth model.accountingEntry.bookingDate.month (parseMonth model newContent)), Cmd.none )

        ChangeReceiptNumber newContent ->
            ( updateReceiptNumber model newContent, Cmd.none )

        ChangeDescription newContent ->
            ( updateDescription model newContent, Cmd.none )

        ChangeDebit newContent ->
            ( parseAndUpdateDebit model newContent, Cmd.none )

        ChangeCredit newContent ->
            ( parseAndUpdateCredit model newContent, Cmd.none )

        ChangeAmount newContent ->
            ( parseAndUpdateAmount model newContent, Cmd.none )

        DropdownTemplateChanged selectedTemplate ->
            ( handleSelection insertTemplateData { model | selectedTemplate = selectedTemplate } selectedTemplate, Cmd.none )

        DropdownCreditChanged selectedCredit ->
            ( handleAccountSelection updateCredit { model | selectedCredit = selectedCredit } selectedCredit, Cmd.none )

        DropdownDebitChanged selectedDebit ->
            ( handleAccountSelection updateDebit { model | selectedDebit = selectedDebit } selectedDebit, Cmd.none )

        CreateAccountingEntry ->
            ( reset model, createAccountingEntry (getCreationParams model.accountingEntry) )

        ReplaceAccountingEntry ->
            ( reset model, replaceAccountingEntry model.accountingEntry )

        DeleteAccountingEntry ->
            ( reset model, deleteAccountingEntry model.accountingEntry )

        EditAccountingEntry accountingEntry ->
            ( insertForEdit model accountingEntry, Cmd.none )

        MoveEntryUp accountingEntry ->
            ( model, moveAccountingEntryUp accountingEntry )

        MoveEntryDown accountingEntry ->
            ( model, moveAccountingEntryDown accountingEntry )

        LeaveEditView ->
            ( reset model, Cmd.none )

        ShowAccountList ->
            ( { model | accountViewActive = True }, Cmd.none )

        HideAccountList ->
            ( { model | accountViewActive = False }, Cmd.none )

        GoToAccountPage ->
            ( model, Cmd.none )

        GoToAccountingTemplatePage ->
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div [class "page"]
        [ linkButton (fragmentUrl [ makeLinkId model.companyId, makeLinkPath AccountPage ])
            [ class "pageButton", id "accountPageButton", value "Manage Accounts" ]
            []
        , linkButton (fragmentUrl [ makeLinkId model.companyId, makeLinkPath AccountingEntryTemplatePage ])
            [ class "pageButton", id "templatePageButton", value "Manage Templates" ]
            []
        , viewAccountListButton model.accountViewActive
        , p [ id "freeP" ] []
        , viewAccountList model
        , viewInputArea model

        --, div [] [ text (AccountingEntryUtil.show model.accountingEntry) ]
        , viewValidatedInput model.accountingEntry model.editActive (model.selectedDebit /= model.selectedCredit)
        , div [] [ text model.error ]
        , p [] []
        , viewEntryList model
        ]


viewAccountList : Model -> Html Msg
viewAccountList model =
    if model.accountViewActive then
        div [ id "accountList" ]
            [ table
                []
                (tr [ class "tableHeader" ]
                    [ th [] [ label [ for "id" ] [ text "id" ] ]
                    , th [] [ label [ for "name" ] [ text "name" ] ]
                    ]
                    :: List.map mkAccountTableLine model.allAccounts
                )
            ]

    else
        div [] []


viewAccountListButton : Bool -> Html Msg
viewAccountListButton accountViewActive =
    if accountViewActive then
        div [] [ button [ class "showButton", id "AccountListButton", onClick HideAccountList ] [ text "Hide Account List" ] ]

    else
        div [] [ button [ class "showButton", id "AccountListButton", onClick ShowAccountList ] [ text "Show Account List" ] ]


mkAccountTableLine : Account -> Html Msg
mkAccountTableLine account =
    tr []
        [ td [ class "numberColumn" ] [ text (String.fromInt account.id) ]
        , td [ class "textColumn" ] [ text account.title ]
        ]


viewInputArea : Model -> Html Msg
viewInputArea model =
    div [ class "inputArea" ]
        [ div []
            [ label [] [ text "Booking Date: " ]
            , input [ id "dayField", placeholder "dd", value model.content.day, onInput ChangeDay ] []
            , label [] [ text "." ]
            , input [ id "monthField", placeholder "mm", value model.content.month, onInput ChangeMonth ] []
            , label [] [ text (String.fromInt model.accountingYear) ]
            , input [ id "receiptNumberField", placeholder "Receipt No.", value model.content.receiptNumber, onInput ChangeReceiptNumber ] []
            ]
        , div []
            [ input [ id "descriptionField", placeholder "Description", value model.content.description, onInput ChangeDescription ] []
            , viewTemplateSelection model
            , input [ id "amountField", placeholder "Amount", value model.content.amount.text, onInput ChangeAmount ] []
            ]
        , viewCreditInput model
        , viewDebitInput model
        ]


viewValidatedInput : AccountingEntry -> Bool -> Bool -> Html Msg
viewValidatedInput accountingEntry editActive validSelection =
    let
        validEntry =
            AccountingEntryUtil.isValid accountingEntry

        accountWarning =
            div [ style "color" "red" ] [ text "Credit and Debit must not be equal." ]
    in
    if editActive then
        let
            deleteButton =
                button [ class "deleteButton", onClick DeleteAccountingEntry ] [ text "Delete" ]

            cancelButton =
                button [ class "cancelButton", onClick LeaveEditView ] [ text "Cancel" ]

            makeSaveButton : Bool -> Html Msg
            makeSaveButton isDisabled =
                button [ class "saveButton", disabled isDisabled, onClick ReplaceAccountingEntry ] [ text "Save Changes" ]
        in
        if not validSelection && validEntry then
            div [ class "inputArea" ]
                [ makeSaveButton True
                , deleteButton
                , cancelButton
                , accountWarning
                ]

        else if validEntry then
            div [ class "inputArea" ]
                [ makeSaveButton False
                , deleteButton
                , cancelButton
                ]

        else
            div [ class "inputArea" ]
                [ makeSaveButton True
                , deleteButton
                , cancelButton
                ]

    else
        let
            makeCreateButton : Bool -> Html Msg
            makeCreateButton isDisabled =
                button [ class "saveButton", disabled isDisabled, onClick CreateAccountingEntry ] [ text "Commit New Entry" ]
        in
        if not validSelection && validEntry then
            div [ class "inputArea" ]
                [ makeCreateButton True
                , accountWarning
                ]

        else
            div [ class "inputArea" ] [ makeCreateButton (not validEntry) ]


viewEntryList : Model -> Html Msg
viewEntryList model =
    div [ id "allAccountingEntries" ]
        [ table
            [ id "allAccountingEntriesTable" ]
            (tr [ class "tableHeader" ]
                [ th [ class "numberColumn" ] [ label [ for "id" ] [ text "id" ] ]
                , th [ class "numberColumn" ] [ label [ for "receipt number" ] [ text "no." ] ]
                , th [ class "numberColumn" ] [ label [ for "booking date" ] [ text "booking date" ] ]
                , th [ class "textColumn", id "descriptionColumn" ] [ label [ for "description" ] [ text "description" ] ]
                , th [ class "numberColumn" ] [ label [ for "amount" ] [ text "amount" ] ]
                , th [ class "numberColumn" ] [ label [ for "credit account" ] [ text "credit" ] ]
                , th [ class "numberColumn" ] [ label [ for "debit account" ] [ text "debit" ] ]
                ]
                :: List.map (mkTableLine model.editActive) (getListWithPosition model.allAccountingEntries)
            )
        ]


viewCreditInput : Model -> Html Msg
viewCreditInput model =
    div []
        [ label [class "accountLabel"] [ text "Credit: " ]
        , input [ class "accountIdField", placeholder "Account ID", value model.content.creditId, onInput ChangeCredit ] []
        , Dropdown.dropdown
            (dropdownOptionsAccount (accountListForDropdown model.allAccounts model.selectedDebit) DropdownCreditChanged)
            []
            model.selectedCredit
        , label [class "balance"] [ text (getBalance model.content.creditId model.allAccountingEntries) ]
        ]


viewDebitInput : Model -> Html Msg
viewDebitInput model =
    div []
        [ label [class "accountLabel"] [ text "Debit:  " ]
        , input [ class "accountIdField", placeholder "Account ID", value model.content.debitId, onInput ChangeDebit ] []
        , Dropdown.dropdown
            (dropdownOptionsAccount (accountListForDropdown model.allAccounts model.selectedCredit) DropdownDebitChanged)
            []
            model.selectedDebit
        , label [class "balance"] [ text (getBalance model.content.debitId model.allAccountingEntries) ]
        ]


viewTemplateSelection : Model -> Html Msg
viewTemplateSelection model =
    Dropdown.dropdown
        (dropdownOptionsTemplate model.allAccountingEntryTemplates)
        []
        model.selectedTemplate


mkTableLine : Bool -> EntryWithListPosition -> Html Msg
mkTableLine editInactive entryWithPosition =
    let
        upButton =
            case entryWithPosition.position of
                OnlyOne ->
                    td [] []

                First ->
                    td [] []

                _ ->
                    td [ class "buttonColumn" ] [ button [ class "arrowButton", onClick (MoveEntryUp entryWithPosition.accountingEntry) ] [ text (unicodeToString 129045) ] ]

        downButton =
            case entryWithPosition.position of
                OnlyOne ->
                    td [] []

                Last ->
                    td [] []

                _ ->
                    td [ class "buttonColumn" ] [ button [ class "arrowButton", onClick (MoveEntryDown entryWithPosition.accountingEntry) ] [ text (unicodeToString 129047) ] ]
    in
    tr []
        [ td [ class "numberColumn" ] [ text (String.fromInt entryWithPosition.accountingEntry.id) ]
        , td [ class "numberColumn" ] [ text entryWithPosition.accountingEntry.receiptNumber ]
        , td [ class "numberColumn" ] [ text (DateUtil.show entryWithPosition.accountingEntry.bookingDate) ]
        , td [ class "textColumn" ] [ text entryWithPosition.accountingEntry.description ]
        , td [ class "numberColumn" ] [ text (AccountingEntryUtil.showAmount entryWithPosition.accountingEntry) ]
        , td [ class "numberColumn" ] [ text (String.fromInt entryWithPosition.accountingEntry.credit) ]
        , td [ class "numberColumn" ] [ text (String.fromInt entryWithPosition.accountingEntry.debit) ]
        , upButton
        , downButton
        , td [ class "buttonColumn" ] [ button [ class "editButton", disabled editInactive, onClick (EditAccountingEntry entryWithPosition.accountingEntry) ] [ text "Edit" ] ]
        ]



-- List.map g (List.map f xs) = List,map (\x -> g (f x)) xs


dropdownOptionsTemplate : List AccountingEntryTemplate -> Dropdown.Options Msg
dropdownOptionsTemplate allAccountingEntryTemplates =
    let
        defaultOptions =
            Dropdown.defaultOptions DropdownTemplateChanged
    in
    { defaultOptions
        | items =
            List.map (\aet -> { value = aet.description, text = aet.description, enabled = True }) allAccountingEntryTemplates
        , emptyItem = Just { value = "0", text = "[Select Template]", enabled = True }
    }


dropdownOptionsAccount : List Account -> (Maybe String -> Msg) -> Dropdown.Options Msg
dropdownOptionsAccount allAccounts dropdownAccountChanged =
    let
        defaultOptions =
            Dropdown.defaultOptions dropdownAccountChanged
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


createAccountingEntry : AccountingEntryCreationParams -> Cmd Msg
createAccountingEntry accountingEntryCreationParams =
    Http.post
        { url = "http://localhost:9000/accountingEntry/insert"
        , expect = HttpUtil.expectJson GotResponsePost decoderAccountingEntry
        , body = Http.jsonBody (encoderAccountingEntryCreationParams accountingEntryCreationParams)
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
        , expect = HttpUtil.expectWhatever GotResponseDeleteOrSwap
        , body = Http.jsonBody (encoderAccountingEntryKey (getKey accountingEntry))
        }


moveAccountingEntryUp : AccountingEntry -> Cmd Msg
moveAccountingEntryUp accountingEntry =
    Http.post
        { url = "http://localhost:9000/accountingEntry/moveUp"
        , expect = HttpUtil.expectWhatever GotResponseDeleteOrSwap
        , body = Http.jsonBody (encoderAccountingEntryKey (getKey accountingEntry))
        }


moveAccountingEntryDown : AccountingEntry -> Cmd Msg
moveAccountingEntryDown accountingEntry =
    Http.post
        { url = "http://localhost:9000/accountingEntry/moveDown"
        , expect = HttpUtil.expectWhatever GotResponseDeleteOrSwap
        , body = Http.jsonBody (encoderAccountingEntryKey (getKey accountingEntry))
        }
