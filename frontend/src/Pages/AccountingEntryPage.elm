module Pages.AccountingEntryPage exposing (..)

import Api.General.AccountUtil as AccountUtil
import Api.General.AccountingEntryTemplateUtil as AccountingEntryTemplateUtil
import Api.General.AccountingEntryUtil as AccountingEntryUtil
import Api.Types.Account exposing (Account, decoderAccount, encoderAccount)
import Api.Types.AccountingEntry exposing (AccountingEntry)
import Api.Types.AccountingEntryTemplate exposing (AccountingEntryTemplate, decoderAccountingEntryTemplate, encoderAccountingEntryTemplate)
import Api.Types.Date exposing (Date)
import Browser
import Dropdown exposing (Item)
import Html exposing (Html, button, div, input, label, li, p, text, ul)
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
    { accountingYear : Int
    , contentBookingDate : String
    , contentReceiptNumber : String
    , contentDescription : String
    , contentDebitID : String
    , contentDebitName : String
    , contentCreditID : String
    , contentCreditName : String
    , contentAmount : String
    , accountingEntry : AccountingEntry
    , allAccounts : List Account
    , allAccountingEntryTemplates : List AccountingEntryTemplate
    , response : String
    , feedback : String
    , error : String
    , buttonPressed : Bool
    , selectedTemplate : Maybe String
    , selectedCredit : Maybe String
    , selectedDebit : Maybe String
    }


updateAccountingEntry : Model -> AccountingEntry -> Model
updateAccountingEntry model accountingEntry =
    { model | accountingEntry = accountingEntry }


updateError : Model -> String -> Model
updateError model error =
    { model | error = error }


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
        , emptyItem = Just { value = "0", text = "[Please Select]", enabled = True }
    }


dropdownOptionsCredit : List Account -> String -> Dropdown.Options Msg
dropdownOptionsCredit allAccounts identifier =
    let
        defaultOptions =
            Dropdown.defaultOptions DropdownCreditChanged
    in
    { defaultOptions
        | items =
            List.map (\acc -> accountForDropdown acc) allAccounts
        , emptyItem = Just { value = "0", text = identifier, enabled = True }
    }


dropdownOptionsDebit : List Account -> String -> Dropdown.Options Msg
dropdownOptionsDebit allAccounts identifier =
    let
        defaultOptions =
            Dropdown.defaultOptions DropdownDebitChanged
    in
    { defaultOptions
        | items =
            List.map (\acc -> accountForDropdown acc) allAccounts
        , emptyItem = Just { value = "0", text = identifier, enabled = True }
    }


init : Flags -> ( Model, Cmd Msg )
init _ =
    ( { accountingYear = 0
      , contentBookingDate = ""
      , contentReceiptNumber = ""
      , contentDescription = ""
      , contentDebitID = ""
      , contentDebitName = "no valid account selected"
      , contentCreditID = ""
      , contentCreditName = "no valid account selected"
      , contentAmount = ""
      , accountingEntry = AccountingEntryUtil.empty
      , allAccounts = []
      , allAccountingEntryTemplates = []
      , response = ""
      , feedback = ""
      , error = ""
      , buttonPressed = False
      , selectedTemplate = Nothing
      , selectedCredit = Nothing
      , selectedDebit = Nothing
      }
    , getAccounts
    )



-- UPDATE


type Msg
    = ChangeBookingDate String
    | ChangeReceiptNumber String
    | ChangeDescription String
    | ChangeDebit String
    | ChangeCredit String
    | ChangeAmount String
    | GotResponseAllAccountingEntryTemplates (Result Error (List AccountingEntryTemplate))
    | GotResponseAllAccounts (Result Error (List Account))
    | DropdownTemplateChanged (Maybe String)
    | DropdownCreditChanged (Maybe String)
    | DropdownDebitChanged (Maybe String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotResponseAllAccountingEntryTemplates result ->
            case result of
                Ok value ->
                    ( { model
                        | allAccountingEntryTemplates = value
                        , response = value |> List.map AccountingEntryTemplateUtil.show |> String.join ",\n"
                        , feedback = ""
                      }
                    , Cmd.none
                    )

                Err error ->
                    ( { model | error = Debug.toString error }, Cmd.none )

        GotResponseAllAccounts result ->
            case result of
                Ok value ->
                    ( { model | allAccounts = value }, getAccountingEntryTemplates )

                Err error ->
                    ( { model | allAccounts = [], error = Debug.toString error }, Cmd.none )

        ChangeBookingDate newContent ->
            ( { model | contentBookingDate = newContent }, Cmd.none )

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
            ( { model | selectedTemplate = selectedTemplate }, Cmd.none )

        DropdownCreditChanged selectedCredit ->
            ( { model | selectedCredit = selectedCredit }, Cmd.none )

        DropdownDebitChanged selectedDebit ->
            ( { model | selectedDebit = selectedDebit }, Cmd.none )



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
        [ div [] [ input [ placeholder "Booking Date", value model.contentBookingDate, onInput ChangeBookingDate ] [], label [] [ text (String.fromInt model.accountingYear) ], input [ placeholder "Receipt Number", value model.contentReceiptNumber, onInput ChangeReceiptNumber ] [] ]
        , div [] [ input [ placeholder "Description", value model.contentDescription, onInput ChangeDescription ] [] ]
        , div []
            [ label [] [ text "Debit Account: " ]
            , input [ placeholder "Debit Account ID", value model.contentDebitID, onInput ChangeDebit ] []
            , Dropdown.dropdown
                (dropdownOptionsCredit model.allAccounts model.contentDebitName)
                []
                model.selectedDebit
            ]
        , div []
            [ label [] [ text "Credit Account: " ]
            , input [ placeholder "Credit Account ID", value model.contentCreditID, onInput ChangeCredit ] []
            , Dropdown.dropdown
                (dropdownOptionsCredit model.allAccounts model.contentCreditName)
                []
                model.selectedCredit
            ]
        , div [] [ input [ placeholder "Amount", value model.contentAmount, onInput ChangeAmount ] [], label [] [ text model.error ] ]
        , div [] [ text (AccountingEntryUtil.show model.accountingEntry) ]
        , Html.form []
            [ p []
                [ label []
                    [ Dropdown.dropdown
                        (dropdownOptionsTemplate model.allAccountingEntryTemplates)
                        []
                        model.selectedTemplate
                    ]
                ]
            ]
        , div [] [ text model.error ]
        ]


getAccountingEntryTemplates : Cmd Msg
getAccountingEntryTemplates =
    Http.get
        { url = "http://localhost:9000/accountingEntryTemplate/getAllAccountingEntryTemplates"
        , expect = Http.expectJson GotResponseAllAccountingEntryTemplates (Decode.list decoderAccountingEntryTemplate)
        }


getAccounts : Cmd Msg
getAccounts =
    Http.get
        { url = "http://localhost:9000/account/getAllAccounts"
        , expect = Http.expectJson GotResponseAllAccounts (Decode.list decoderAccount)
        }


parseAndUpdateCredit =
    parseWith (\m nc -> { m | contentCreditID = nc, selectedCredit = Nothing }) (\m nc acc -> { m | contentCreditID = nc, contentCreditName = acc.title, accountingEntry = AccountingEntryUtil.updateCredit m.accountingEntry acc.id })


parseAndUpdateDebit =
    parseWith (\m nc -> { m | contentDebitID = nc, selectedDebit = Nothing }) (\m nc acc -> { m | contentDebitID = nc, contentDebitName = acc.title, accountingEntry = AccountingEntryUtil.updateDebit m.accountingEntry acc.id })


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


findAccountName : List Account -> String -> Account
findAccountName accounts id =
    case String.toInt id of
        Just int ->
            case List.head (List.filter (\acc -> acc.id == int) accounts) of
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
            case List.head (List.filter (\aet -> aet.description == string) allAccountingEntryTemplates) of
                Just value ->
                    value

                Nothing ->
                    AccountingEntryTemplateUtil.empty

        Nothing ->
            AccountingEntryTemplateUtil.empty


parseAndUpdateAmount : Model -> String -> Model
parseAndUpdateAmount model a =
    let
        wholeAndChange =
            String.split "," a
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
                                            { model | contentAmount = String.concat [ String.fromInt whole, "," ], accountingEntry = AccountingEntryUtil.updateAmountWhole model.accountingEntry whole }

                                Nothing ->
                                    { model | contentAmount = a, accountingEntry = AccountingEntryUtil.updateAmountWhole model.accountingEntry whole }

                        Nothing ->
                            { model | contentAmount = a, accountingEntry = AccountingEntryUtil.updateAmountWhole model.accountingEntry whole }

                Nothing ->
                    model

        Nothing ->
            model


accountForDropdown : Account -> Item
accountForDropdown acc =
    let
        id =
            String.fromInt acc.id
    in
    { value = id, text = acc.title, enabled = True }


resetOnSuccessfulPost : Model -> Model
resetOnSuccessfulPost model =
    { model
        | contentDescription = ""
        , contentDebitID = ""
        , contentDebitName = "no account with that ID could be found"
        , contentCreditID = ""
        , contentCreditName = "no account with that ID could be found"
        , contentAmount = ""
        , accountingEntry = AccountingEntryUtil.empty
        , error = ""
        , buttonPressed = False
    }
