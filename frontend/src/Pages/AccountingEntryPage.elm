module Pages.AccountingEntryPage exposing (..)

import Api.General.AccountUtil as AccountUtil
import Api.General.AccountingEntryTemplateUtil as AccountingEntryTemplateUtil
import Api.General.AccountingEntryUtil as AccountingEntryUtil
import Api.General.DateUtil as DateUtil
import Api.Types.Account exposing (Account, decoderAccount, encoderAccount)
import Api.Types.AccountingEntry exposing (AccountingEntry, decoderAccountingEntry, encoderAccountingEntry)
import Api.Types.AccountingEntryTemplate exposing (AccountingEntryTemplate, decoderAccountingEntryTemplate, encoderAccountingEntryTemplate)
import Api.Types.Date exposing (Date, encoderDate)
import Browser
import Dropdown exposing (Item)
import Html exposing (Html, button, div, input, label, table, td, text, th, tr)
import Html.Attributes exposing (class, disabled, for, id, placeholder, style, type_, value)
import Html.Events exposing (onClick, onInput)
import Http exposing (Error)
import Json.Decode as Decode
import Json.Encode as Encode
import List.Extra
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
    { companyId : Int
    , accountingYear : Int
    , contentBookingDate : String
    , contentReceiptNumber : String
    , contentDescription : String
    , contentDebitID : String
    , contentCreditID : String
    , contentAmount : String
    , accountingEntry : AccountingEntry
    , allAccountingEntries : List AccountingEntry
    , allAccounts : List Account
    , allAccountingEntryTemplates : List AccountingEntryTemplate
    , dateValidation : String
    , response : String
    , feedback : String
    , error : String
    , editActive : Bool
    , selectedTemplate : Maybe String
    , selectedCredit : Maybe String
    , selectedDebit : Maybe String
    }


updateAccountingEntry : Model -> AccountingEntry -> Model
updateAccountingEntry model accountingEntry =
    { model | accountingEntry = accountingEntry }


type alias Flags =
    ()


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
      , dateValidation = ""
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
    | PostAccountingEntry
    | GotResponseAllAccountingEntries (Result Error (List AccountingEntry))
    | GotResponseAllAccountingEntryTemplates (Result Error (List AccountingEntryTemplate))
    | GotResponseAllAccounts (Result Error (List Account))
    | GotResponsePost (Result Error AccountingEntry)
    | DropdownTemplateChanged (Maybe String)
    | DropdownCreditChanged (Maybe String)
    | DropdownDebitChanged (Maybe String)
    | EditAccountingEntry AccountingEntry
    | LeaveEditView


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotResponseAllAccountingEntries result ->
            case result of
                Ok value ->
                    ( { model
                        | allAccountingEntries = value |> List.sortBy .id
                        , accountingEntry = AccountingEntryUtil.updateId (AccountingEntryUtil.updateAccountingYear (AccountingEntryUtil.updateCompanyId model.accountingEntry model.companyId) model.accountingYear) 5
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
            ( model, getAccountingEntriesForCurrentYear model.companyId model.accountingYear )

        ChangeBookingDate newContent ->
            ( parseDate model newContent, Cmd.none )

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
            ( parseAndUpdateDebit model newContent, Cmd.none )

        ChangeCredit newContent ->
            ( parseAndUpdateCredit model newContent, Cmd.none )

        ChangeAmount newContent ->
            ( parseAndUpdateAmount model newContent, Cmd.none )

        DropdownTemplateChanged selectedTemplate ->
            ( insertTemplateData model selectedTemplate, Cmd.none )

        DropdownCreditChanged selectedCredit ->
            ( updateCredit model selectedCredit, Cmd.none )

        DropdownDebitChanged selectedDebit ->
            ( updateDebit model selectedDebit, Cmd.none )

        PostAccountingEntry ->
            ( resetOnSuccessfulPost model, postAccountingEntry model.accountingEntry )

        EditAccountingEntry accountingEntry ->
            ( insertForEdit model accountingEntry, Cmd.none )

        LeaveEditView ->
            ( resetOnSuccessfulPost model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ div [] [ label [] [ text "Booking Date: " ], input [ placeholder "dd.mm", value model.contentBookingDate, onInput ChangeBookingDate ] [], label [] [ text (String.fromInt model.accountingYear) ], input [ placeholder "Receipt Number", value model.contentReceiptNumber, onInput ChangeReceiptNumber ] [] ]
        , div []
            [ input [ placeholder "Description", value model.contentDescription, onInput ChangeDescription ] []
            , Dropdown.dropdown
                (dropdownOptionsTemplate model.allAccountingEntryTemplates)
                []
                model.selectedTemplate
            , input [ placeholder "Amount", value model.contentAmount, onInput ChangeAmount ] []
            ]
        , div []
            [ label [] [ text "Debit Account: " ]
            , input [ placeholder "Debit Account ID", value model.contentDebitID, onInput ChangeDebit ] []
            , Dropdown.dropdown
                (dropdownOptionsDebit model.allAccounts)
                []
                model.selectedDebit
            ]
        , div []
            [ label [] [ text "Credit Account: " ]
            , input [ placeholder "Credit Account ID", value model.contentCreditID, onInput ChangeCredit ] []
            , Dropdown.dropdown
                (dropdownOptionsCredit model.allAccounts)
                []
                model.selectedCredit
            ]
        , div [] [ text model.dateValidation ]
        , div [] [ text (AccountingEntryUtil.show model.accountingEntry) ]
        , viewValidatedInput model.accountingEntry model.editActive
        , div [] [ text model.error ]
        , div [ id "allAccountingEntries" ]
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
        ]


getAccountingEntriesForCurrentYear : Int -> Int -> Cmd Msg
getAccountingEntriesForCurrentYear companyId year =
    Http.get
        { url = "http://localhost:9000/accountingEntry/findAccountingEntriesByYear/" ++ String.fromInt companyId ++ "/" ++ String.fromInt year
        , expect = HttpUtil.expectJson GotResponseAllAccountingEntries (Decode.list decoderAccountingEntry)
        }


getAccountingEntryTemplates : Int -> Cmd Msg
getAccountingEntryTemplates companyId =
    Http.get
        { url = "http://localhost:9000/accountingEntryTemplate/getAllAccountingEntryTemplates/" ++ String.fromInt companyId
        , expect = HttpUtil.expectJson GotResponseAllAccountingEntryTemplates (Decode.list decoderAccountingEntryTemplate)
        }


getAccounts : Int -> Cmd Msg
getAccounts companyId =
    Http.get
        { url = "http://localhost:9000/account/getAllAccounts/" ++ String.fromInt companyId
        , expect = HttpUtil.expectJson GotResponseAllAccounts (Decode.list decoderAccount)
        }


postAccountingEntry : AccountingEntry -> Cmd Msg
postAccountingEntry accountingEntry =
    Http.post
        { url = "http://localhost:9000/accountingEntry/repsert"
        , expect = HttpUtil.expectJson GotResponsePost decoderAccountingEntry
        , body = Http.jsonBody (encoderAccountingEntry accountingEntry)
        }


parseAndUpdateCredit : Model -> String -> Model
parseAndUpdateCredit =
    parseWith (\m nc -> { m | contentCreditID = nc, selectedCredit = Nothing }) (\m nc acc -> { m | contentCreditID = nc, accountingEntry = AccountingEntryUtil.updateCredit m.accountingEntry acc.id, selectedCredit = Just nc })


parseAndUpdateDebit : Model -> String -> Model
parseAndUpdateDebit =
    parseWith (\m nc -> { m | contentDebitID = nc, selectedDebit = Nothing }) (\m nc acc -> { m | contentDebitID = nc, accountingEntry = AccountingEntryUtil.updateDebit m.accountingEntry acc.id, selectedDebit = Just nc })


parseWith : (Model -> String -> Model) -> (Model -> String -> Account -> Model) -> Model -> String -> Model
parseWith empty nonEmpty model newContent =
    let
        account =
            findAccountName model.allAccounts newContent
    in
    if String.isEmpty account.title then
        empty model newContent

    else
        nonEmpty model newContent account


updateCredit : Model -> Maybe String -> Model
updateCredit =
    updateWith (\m nsv -> { m | selectedCredit = nsv }) (\m nsv nss id -> { m | contentCreditID = nss, accountingEntry = AccountingEntryUtil.updateCredit m.accountingEntry id, selectedCredit = nsv })


updateDebit =
    updateWith (\m nsv -> { m | selectedDebit = nsv }) (\m nsv nss id -> { m | contentDebitID = nss, accountingEntry = AccountingEntryUtil.updateDebit m.accountingEntry id, selectedDebit = nsv })


updateWith : (Model -> Maybe String -> Model) -> (Model -> Maybe String -> String -> Int -> Model) -> Model -> Maybe String -> Model
updateWith nothing just model newSelectedValue =
    case newSelectedValue of
        Just newSelectedString ->
            let
                id =
                    String.toInt newSelectedString
            in
            case id of
                Just int ->
                    just model newSelectedValue newSelectedString int

                Nothing ->
                    nothing model newSelectedValue

        Nothing ->
            nothing model newSelectedValue


insertTemplateData : Model -> Maybe String -> Model
insertTemplateData model newSelectedTemplate =
    case newSelectedTemplate of
        Just description ->
            let
                selectedTemplate =
                    findEntry newSelectedTemplate model.allAccountingEntryTemplates
            in
            if selectedTemplate.amountWhole /= 0 && selectedTemplate.amountChange /= 0 then
                { model
                    | contentDescription = description
                    , contentCreditID = String.fromInt selectedTemplate.credit
                    , contentDebitID = String.fromInt selectedTemplate.debit
                    , contentAmount = AccountingEntryTemplateUtil.showAmount selectedTemplate
                    , accountingEntry = AccountingEntryUtil.updateWithTemplate model.accountingEntry selectedTemplate
                    , selectedTemplate = newSelectedTemplate
                    , selectedCredit = Just (String.fromInt selectedTemplate.credit)
                    , selectedDebit = Just (String.fromInt selectedTemplate.debit)
                }

            else
                { model
                    | contentDescription = description
                    , contentCreditID = String.fromInt selectedTemplate.credit
                    , contentDebitID = String.fromInt selectedTemplate.debit
                    , contentAmount = ""
                    , accountingEntry = AccountingEntryUtil.updateWithTemplate model.accountingEntry selectedTemplate
                    , selectedTemplate = newSelectedTemplate
                    , selectedCredit = Just (String.fromInt selectedTemplate.credit)
                    , selectedDebit = Just (String.fromInt selectedTemplate.debit)
                }

        Nothing ->
            { model | selectedTemplate = newSelectedTemplate }


insertForEdit : Model -> AccountingEntry -> Model
insertForEdit model accountingEntry =
    { model
        | contentBookingDate = DateUtil.showDayAndMonth accountingEntry.bookingDate
        , contentReceiptNumber = accountingEntry.receiptNumber
        , contentDescription = accountingEntry.description
        , contentCreditID = String.fromInt accountingEntry.credit
        , contentDebitID = String.fromInt accountingEntry.debit
        , contentAmount = AccountingEntryUtil.showAmount accountingEntry
        , accountingEntry = accountingEntry
        , editActive = True
        , selectedTemplate = Nothing
        , selectedCredit = Just (String.fromInt accountingEntry.credit)
        , selectedDebit = Just (String.fromInt accountingEntry.debit)
    }


findAccountName : List Account -> String -> Account
findAccountName accounts id =
    case String.toInt id of
        Just int ->
            case List.Extra.find (\acc -> acc.id == int) accounts of
                Just value ->
                    value

                Nothing ->
                    AccountUtil.empty

        Nothing ->
            AccountUtil.empty


findEntry : Maybe String -> List AccountingEntryTemplate -> AccountingEntryTemplate
findEntry selectedValue allAccountingEntryTemplates =
    case selectedValue of
        Just string ->
            case List.Extra.find (\aet -> aet.description == string) allAccountingEntryTemplates of
                Just value ->
                    value

                Nothing ->
                    AccountingEntryTemplateUtil.empty

        Nothing ->
            AccountingEntryTemplateUtil.empty


parseAndUpdateAmount : Model -> String -> Model
parseAndUpdateAmount model newContent =
    if String.isEmpty newContent then
        { model | contentAmount = "", accountingEntry = AccountingEntryUtil.updateCompleteAmount model.accountingEntry 0 0 }

    else
        let
            wholeAndChange =
                String.split "," newContent
        in
        case List.head wholeAndChange of
            Just wholeString ->
                case String.toInt wholeString of
                    Just whole ->
                        case List.tail wholeAndChange of
                            Just tailList ->
                                case List.head tailList of
                                    Just changeString ->
                                        case String.toInt (String.left 2 changeString) of
                                            Just change ->
                                                if change < 10 && String.length changeString == 1 then
                                                    { model | contentAmount = String.concat [ String.fromInt whole, ",", String.fromInt change ], accountingEntry = AccountingEntryUtil.updateAmountWhole (AccountingEntryUtil.updateAmountChange model.accountingEntry (change * 10)) whole }

                                                else if change < 10 && String.length changeString >= 2 then
                                                    { model | contentAmount = String.concat [ String.fromInt whole, ",0", String.fromInt change ], accountingEntry = AccountingEntryUtil.updateAmountWhole (AccountingEntryUtil.updateAmountChange model.accountingEntry change) whole }

                                                else
                                                    { model | contentAmount = String.concat [ String.fromInt whole, ",", String.fromInt change ], accountingEntry = AccountingEntryUtil.updateAmountWhole (AccountingEntryUtil.updateAmountChange model.accountingEntry change) whole }

                                            Nothing ->
                                                { model | contentAmount = String.concat [ String.fromInt whole, "," ], accountingEntry = AccountingEntryUtil.updateCompleteAmount model.accountingEntry whole 0 }

                                    Nothing ->
                                        { model | contentAmount = newContent, accountingEntry = AccountingEntryUtil.updateCompleteAmount model.accountingEntry whole 0 }

                            Nothing ->
                                { model | contentAmount = newContent, accountingEntry = AccountingEntryUtil.updateCompleteAmount model.accountingEntry whole 0 }

                    Nothing ->
                        model

            Nothing ->
                model


parseDate : Model -> String -> Model
parseDate model newContent =
    if String.isEmpty newContent then
        { model | contentBookingDate = "" }

    else
        let
            dayAndMonth =
                String.split "." newContent
        in
        case List.head dayAndMonth of
            Just dayString ->
                case toValidDay dayString of
                    Just day ->
                        if String.length dayString == 2 && day /= 0 then
                            case List.tail dayAndMonth of
                                Just tailList ->
                                    case List.head tailList of
                                        Just monthString ->
                                            case toValidMonth monthString day model.accountingYear of
                                                Just month ->
                                                    { model
                                                        | contentBookingDate = DateUtil.showDay day ++ "." ++ DateUtil.showMonth month
                                                        , accountingEntry = AccountingEntryUtil.updateBookingDate model.accountingEntry { day = day, month = month, year = model.accountingYear }
                                                    }

                                                Nothing ->
                                                    { model
                                                        | contentBookingDate = DateUtil.showDay day ++ "."
                                                        , accountingEntry = AccountingEntryUtil.updateBookingDate model.accountingEntry { day = day, month = 0, year = model.accountingYear }
                                                    }

                                        Nothing ->
                                            { model
                                                | contentBookingDate = DateUtil.showDay day ++ "."
                                                , accountingEntry = AccountingEntryUtil.updateBookingDate model.accountingEntry { day = day, month = 0, year = model.accountingYear }
                                            }

                                Nothing ->
                                    { model
                                        | contentBookingDate = DateUtil.showDay day
                                        , accountingEntry = AccountingEntryUtil.updateBookingDate model.accountingEntry { day = day, month = 0, year = model.accountingYear }
                                    }

                        else
                            { model
                                | contentBookingDate = DateUtil.showDay day
                                , accountingEntry = AccountingEntryUtil.updateBookingDate model.accountingEntry { day = day, month = 0, year = model.accountingYear }
                            }

                    Nothing ->
                        model

            Nothing ->
                model


toValidDay : String -> Maybe Int
toValidDay dayCandidateString =
    case String.toInt dayCandidateString of
        Just dayCandidateInt ->
            if dayCandidateInt == 0 && String.length dayCandidateString <= 2 then
                Just 0

            else if 1 <= dayCandidateInt && dayCandidateInt <= 31 then
                Just dayCandidateInt

            else
                Nothing

        Nothing ->
            Nothing


toValidMonth : String -> Int -> Int -> Maybe Int
toValidMonth monthCandidateString day year =
    case String.toInt monthCandidateString of
        Just monthCandidateInt ->
            if monthCandidateInt == 0 && String.length monthCandidateString <= 2 then
                Just 0

            else if day == 29 && isLeap year && monthCandidateInt == 2 then
                Just monthCandidateInt

            else if day <= 28 && monthCandidateInt == 2 then
                Just monthCandidateInt

            else if day >= 29 && monthCandidateInt == 2 then
                Nothing

            else if day == 31 && List.member monthCandidateInt [ 1, 3, 5, 7, 8, 10, 12 ] then
                Just monthCandidateInt

            else if day <= 30 && monthCandidateInt <= 12 then
                Just monthCandidateInt

            else
                Nothing

        Nothing ->
            Nothing


isLeap : Int -> Bool
isLeap year =
    if modBy 4 year == 0 then
        True

    else
        False


accountForDropdown : Account -> Item
accountForDropdown acc =
    let
        id =
            String.fromInt acc.id
    in
    { value = id, text = acc.title, enabled = True }


viewValidatedInput : AccountingEntry -> Bool -> Html Msg
viewValidatedInput accountingEntry editActive =
    let
        validEntry =
            AccountingEntryUtil.isValid accountingEntry
    in
    if editActive && validEntry then
        div [] [ button [ disabled False, onClick PostAccountingEntry ] [ text "Commit Edit" ], button [ onClick LeaveEditView ] [ text "Cancel" ] ]

    else if editActive then
        div [] [ button [ disabled True, onClick PostAccountingEntry ] [ text "Commit Edit" ], button [ onClick LeaveEditView ] [ text "Cancel" ] ]

    else if validEntry then
        button [ disabled False, onClick PostAccountingEntry ] [ text "Commit New Entry" ]

    else
        button [ disabled True, onClick PostAccountingEntry ] [ text "Commit New Entry" ]


resetOnSuccessfulPost : Model -> Model
resetOnSuccessfulPost model =
    { model
        | contentDescription = ""
        , contentBookingDate = ""
        , contentReceiptNumber = ""
        , contentDebitID = ""
        , contentCreditID = ""
        , contentAmount = ""
        , accountingEntry = AccountingEntryUtil.empty
        , error = ""
        , editActive = False
        , selectedTemplate = Nothing
        , selectedCredit = Nothing
        , selectedDebit = Nothing
    }


mkTableLine : Bool -> AccountingEntry ->  Html Msg
mkTableLine editInactive accountingEntry  =
    tr []
        [ td [] [ text (String.fromInt accountingEntry.id) ]
        , td [] [ text accountingEntry.receiptNumber ]
        , td [] [ text (AccountingEntryUtil.stringFromDate accountingEntry.bookingDate) ]
        , td [] [ text accountingEntry.description ]
        , td [] [ text (AccountingEntryUtil.showAmount accountingEntry) ]
        , td [] [ text (String.fromInt accountingEntry.credit) ]
        , td [] [ text (String.fromInt accountingEntry.debit) ]
        , if editInactive then button [ disabled True, onClick (EditAccountingEntry accountingEntry) ] [ text "Edit" ]
          else button [ disabled False, onClick (EditAccountingEntry accountingEntry) ] [ text "Edit" ]
        ]
