module Pages.AccountingEntry.AccountingEntryPage exposing (Msg, init, update, view)

import Api.General.AccountingEntryUtil as AccountingEntryUtil exposing (creationParams, keyOf)
import Api.General.DateUtil as DateUtil
import Api.General.HttpUtil as HttpUtil
import Api.Types.Account exposing (Account, decoderAccount)
import Api.Types.AccountingEntry exposing (AccountingEntry, decoderAccountingEntry, encoderAccountingEntry)
import Api.Types.AccountingEntryCreationParams exposing (AccountingEntryCreationParams, encoderAccountingEntryCreationParams)
import Api.Types.AccountingEntryKey exposing (encoderAccountingEntryKey)
import Api.Types.AccountingEntryTemplate exposing (AccountingEntryTemplate, decoderAccountingEntryTemplate)
import Api.Types.LanguageComponents exposing (LanguageComponents)
import Api.Types.ReportLanguageComponents exposing (ReportLanguageComponents, encoderReportLanguageComponents)
import Browser
import Browser.Dom as Dom
import Bytes exposing (Bytes)
import Dropdown exposing (Item)
import Html exposing (Html, button, div, input, label, p, table, td, text, th, tr)
import Html.Attributes exposing (class, disabled, for, id, placeholder, style, value)
import Html.Events exposing (onClick, onInput)
import Http exposing (Error(..), Response(..))
import Json.Decode as Decode
import Pages.AccountingEntry.AccountingEntryPageModel as Model exposing (Flags, Model, reset, updateCredit, updateDay, updateDebit, updateDescription, updateMonth, updateReceiptNumber)
import Pages.AccountingEntry.HelperUtil exposing (EntryWithListPosition, Position(..), downloadReport, getBalance, makeListWithPosition, handleAccountSelection, handleSelection, insertForEdit, insertTemplateData, resolve, unicodeToString)
import Pages.AccountingEntry.InputContent
import Pages.AccountingEntry.ParseAndUpdateUtil exposing (handleParseResultDay, handleParseResultMonth, parseAndUpdateAmount, parseAndUpdateCredit, parseAndUpdateDebit, parseDay, parseMonth)
import Pages.LinkUtil exposing (Path(..), fragmentUrl, makeLinkId, makeLinkLang, makeLinkPath, makeLinkYear)
import Pages.SharedViewComponents exposing (accountForDropdown, accountListForDropdown, linkButton)
import Task



-- MAIN


main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( Model.init flags
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
    | GotJournal (Result Http.Error Bytes)
    | GotNominalAccounts (Result Http.Error Bytes)
    | DropdownTemplateChanged (Maybe String)
    | DropdownCreditChanged (Maybe String)
    | DropdownDebitChanged (Maybe String)
    | EditAccountingEntry AccountingEntry
    | LeaveEditView
    | ShowAccountList
    | HideAccountList
    | NoOp
    | GetJournal
    | GetNominalAccounts


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
                        | allAccountingEntryTemplates = value |> List.sortBy .description
                        , feedback = ""
                      }
                    , Cmd.none
                    )

                Err error ->
                    ( { model | error = HttpUtil.errorToString error }, Cmd.none )

        GotResponseAllAccounts result ->
            case result of
                Ok value ->
                    ( { model | allAccounts = List.sortBy .id value }, Cmd.none )

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

        GotJournal result ->
            case result of
                Ok response ->
                    ( model, downloadReport model.lang.reportLanguageComponents.journal model.accountingYear response )

                Err error ->
                    ( { model | error = HttpUtil.errorToString error }, Cmd.none )

        GotNominalAccounts result ->
            case result of
                Ok response ->
                    ( model, downloadReport model.lang.reportLanguageComponents.nominalAccounts model.accountingYear response )

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
            ( reset model, createAccountingEntry (creationParams model.accountingEntry) )

        ReplaceAccountingEntry ->
            ( reset model, replaceAccountingEntry model.accountingEntry )

        DeleteAccountingEntry ->
            ( reset model, deleteAccountingEntry model.accountingEntry )

        EditAccountingEntry accountingEntry ->
            ( insertForEdit model accountingEntry, resetViewport )

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

        NoOp ->
            ( model, Cmd.none )

        GetJournal ->
            ( model, getJournal model.companyId model.accountingYear model.lang.reportLanguageComponents )

        GetNominalAccounts ->
            ( model, getNominalAccounts model.companyId model.accountingYear model.lang.reportLanguageComponents )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "page" ]
        [ linkButton (fragmentUrl [ makeLinkId model.companyId, makeLinkPath AccountPage, makeLinkLang model.lang.short ])
            [ class "navButton", id "accountPageButton" ]
            [ text model.lang.manageAccounts ]
        , linkButton (fragmentUrl [ makeLinkId model.companyId, makeLinkPath AccountingEntryTemplatePage, makeLinkLang model.lang.short ])
            [ class "navButton", id "templatePageButton" ]
            [ text model.lang.manageTemplates ]

        --  , linkButton (Url.Builder.custom (CrossOrigin "http://localhost:9000") [ "reports", "journal", makeLinkId model.companyId, makeLinkYear model.accountingYear ] [] Nothing)
        --      [ class "navButton", id "journalButton" ]
        --      [ text model.lang.printJournal ]
        , button [ class "navButton", id "journalButton", onClick GetJournal ] [ text model.lang.printJournal ]
        , button [ class "navButton", id "journalButton", onClick GetNominalAccounts ] [ text model.lang.printNominalAccounts ]
        , viewAccountListButton model.lang model.accountViewActive
        , p [ id "freeP" ] []
        , viewAccountList model
        , viewInputArea model

        --, div [] [ text (AccountingEntryUtil.show model.accountingEntry) ]
        , viewValidatedInput model.lang model.accountingEntry model.editActive (model.selectedDebit /= model.selectedCredit)
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
                    [ th [] [ label [ for "id" ] [ text model.lang.id ] ]
                    , th [] [ label [ for "name" ] [ text model.lang.name ] ]
                    ]
                    :: List.map mkAccountTableLine model.allAccounts
                )
            ]

    else
        div [] []


viewAccountListButton : LanguageComponents -> Bool -> Html Msg
viewAccountListButton lang accountViewActive =
    if accountViewActive then
        div [] [ button [ class "navButton", id "AccountListButton", onClick HideAccountList ] [ text lang.hideAccountList ] ]

    else
        div [] [ button [ class "navButton", id "AccountListButton", onClick ShowAccountList ] [ text lang.showAccountList ] ]


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
            [ label [] [ text (model.lang.bookingDate ++ ": ") ]
            , input [ id "dayField", placeholder model.lang.day, value model.content.day, onInput ChangeDay ] []
            , label [] [ text "." ]
            , input [ id "monthField", placeholder model.lang.month, value model.content.month, onInput ChangeMonth ] []
            , label [] [ text ("." ++ String.fromInt model.accountingYear) ]
            , input [ id "receiptNumberField", placeholder model.lang.receiptNumber, value model.content.receiptNumber, onInput ChangeReceiptNumber ] []
            ]
        , div []
            [ input [ id "descriptionField", placeholder model.lang.description, value model.content.description, onInput ChangeDescription ] []
            , viewTemplateSelection model
            , input [ id "amountField", placeholder model.lang.amount, value model.content.amount.text, onInput ChangeAmount ] []
            ]
        , viewCreditInput model
        , viewDebitInput model
        ]


viewValidatedInput : LanguageComponents -> AccountingEntry -> Bool -> Bool -> Html Msg
viewValidatedInput lang accountingEntry editActive validSelection =
    let
        validEntry =
            AccountingEntryUtil.isValid accountingEntry

        accountWarning =
            div [ style "color" "red" ] [ text lang.accountValidationMessageExisting ]
    in
    if editActive then
        let
            deleteButton =
                button [ class "deleteButton", onClick DeleteAccountingEntry ] [ text lang.delete ]

            cancelButton =
                button [ class "cancelButton", onClick LeaveEditView ] [ text lang.cancel ]

            makeSaveButton : Bool -> Html Msg
            makeSaveButton isDisabled =
                button [ class "saveButton", disabled isDisabled, onClick ReplaceAccountingEntry ] [ text lang.saveChanges ]
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
                button [ class "saveButton", disabled isDisabled, onClick CreateAccountingEntry ] [ text lang.commitNewEntry ]
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
                [ th [ class "numberColumn" ] [ label [ for "id" ] [] ]
                , th [ class "numberColumn" ] [ label [ for "receipt number" ] [ text model.lang.number ] ]
                , th [ class "numberColumn" ] [ label [ for "booking date" ] [ text model.lang.bookingDate ] ]
                , th [ class "textColumn", id "descriptionColumn" ] [ label [ for "description" ] [ text model.lang.description ] ]
                , th [ class "numberColumn" ] [ label [ for "amount" ] [ text model.lang.amount ] ]
                , th [ class "numberColumn" ] [ label [ for "credit account" ] [ text model.lang.credit ] ]
                , th [ class "numberColumn" ] [ label [ for "debit account" ] [ text model.lang.debit ] ]
                ]
                :: List.map (mkTableLine model.lang model.editActive) (makeListWithPosition model.allAccountingEntries)
            )
        ]


viewCreditInput : Model -> Html Msg
viewCreditInput model =
    div []
        [ label [ class "accountLabel" ] [ text (model.lang.credit ++ ": ") ]
        , input [ class "accountIdField", placeholder model.lang.accountId, value model.content.creditId, onInput ChangeCredit ] []
        , Dropdown.dropdown
            (dropdownOptionsAccount model.lang.noValidAccount (accountListForDropdown model.allAccounts model.selectedDebit) DropdownCreditChanged)
            []
            model.selectedCredit
        , label [ class "balance" ] [ text (getBalance model.lang.balance model.content.creditId model.allAccountingEntries) ]
        ]


viewDebitInput : Model -> Html Msg
viewDebitInput model =
    div []
        [ label [ class "accountLabel" ] [ text (model.lang.debit ++ ": ") ]
        , input [ class "accountIdField", placeholder model.lang.accountId, value model.content.debitId, onInput ChangeDebit ] []
        , Dropdown.dropdown
            (dropdownOptionsAccount model.lang.noValidAccount (accountListForDropdown model.allAccounts model.selectedCredit) DropdownDebitChanged)
            []
            model.selectedDebit
        , label [ class "balance" ] [ text (getBalance model.lang.balance model.content.debitId model.allAccountingEntries) ]
        ]


viewTemplateSelection : Model -> Html Msg
viewTemplateSelection model =
    Dropdown.dropdown
        (dropdownOptionsTemplate model.lang.selectTemplate model.allAccountingEntryTemplates)
        []
        model.selectedTemplate


mkTableLine : LanguageComponents -> Bool -> EntryWithListPosition -> Html Msg
mkTableLine lang editInactive entryWithPosition =
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
        [ td [ class "numberColumn" ] [ text (String.fromInt entryWithPosition.index) ]
        , td [ class "numberColumn" ] [ text entryWithPosition.accountingEntry.receiptNumber ]
        , td [ class "numberColumn" ] [ text (DateUtil.show entryWithPosition.accountingEntry.bookingDate) ]
        , td [ class "textColumn" ] [ text entryWithPosition.accountingEntry.description ]
        , td [ class "numberColumn" ] [ text (AccountingEntryUtil.showAmount entryWithPosition.accountingEntry) ]
        , td [ class "numberColumn" ] [ text (String.fromInt entryWithPosition.accountingEntry.credit) ]
        , td [ class "numberColumn" ] [ text (String.fromInt entryWithPosition.accountingEntry.debit) ]
        , upButton
        , downButton
        , td [ class "buttonColumn" ] [ button [ class "editButton", disabled editInactive, onClick (EditAccountingEntry entryWithPosition.accountingEntry) ] [ text lang.edit ] ]
        ]



-- List.map g (List.map f xs) = List,map (\x -> g (f x)) xs


dropdownOptionsTemplate : String -> List AccountingEntryTemplate -> Dropdown.Options Msg
dropdownOptionsTemplate text allAccountingEntryTemplates =
    let
        defaultOptions =
            Dropdown.defaultOptions DropdownTemplateChanged
    in
    { defaultOptions
        | items =
            List.map (\aet -> { value = aet.description, text = aet.description, enabled = True }) allAccountingEntryTemplates
        , emptyItem = Just { value = "0", text = text, enabled = True }
    }


dropdownOptionsAccount : String -> List Account -> (Maybe String -> Msg) -> Dropdown.Options Msg
dropdownOptionsAccount text allAccounts dropdownAccountChanged =
    let
        defaultOptions =
            Dropdown.defaultOptions dropdownAccountChanged
    in
    { defaultOptions
        | items =
            List.map (\acc -> accountForDropdown acc) allAccounts
        , emptyItem = Just { value = "0", text = text, enabled = True }
    }


resetViewport : Cmd Msg
resetViewport =
    Task.perform (\_ -> NoOp) (Dom.setViewport 0 0)



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
        , body = Http.jsonBody (encoderAccountingEntryKey (keyOf accountingEntry))
        }


moveAccountingEntryUp : AccountingEntry -> Cmd Msg
moveAccountingEntryUp accountingEntry =
    Http.post
        { url = "http://localhost:9000/accountingEntry/moveUp"
        , expect = HttpUtil.expectWhatever GotResponseDeleteOrSwap
        , body = Http.jsonBody (encoderAccountingEntryKey (keyOf accountingEntry))
        }


moveAccountingEntryDown : AccountingEntry -> Cmd Msg
moveAccountingEntryDown accountingEntry =
    Http.post
        { url = "http://localhost:9000/accountingEntry/moveDown"
        , expect = HttpUtil.expectWhatever GotResponseDeleteOrSwap
        , body = Http.jsonBody (encoderAccountingEntryKey (keyOf accountingEntry))
        }


getJournal : Int -> Int -> ReportLanguageComponents -> Cmd Msg
getJournal companyId year langComps =
    Http.post
        { url = "http://localhost:9000/reports/journal/" ++ makeLinkId companyId ++ "/" ++ makeLinkYear year
        , expect = Http.expectBytesResponse GotJournal (resolve Ok)
        , body = Http.jsonBody (encoderReportLanguageComponents langComps)
        }


getNominalAccounts : Int -> Int -> ReportLanguageComponents -> Cmd Msg
getNominalAccounts companyId year langComps =
    Http.post
        { url = "http://localhost:9000/reports/nominalAccounts/" ++ makeLinkId companyId ++ "/" ++ makeLinkYear year
        , expect = Http.expectBytesResponse GotNominalAccounts (resolve Ok)
        , body = Http.jsonBody (encoderReportLanguageComponents langComps)
        }
