module Pages.AccountingEntryTemplatePage exposing (..)

import Api.General.AccountUtil as AccountUtil
import Api.General.AccountingEntryTemplateUtil as AccountingEntryTemplateUtil
import Api.Types.Account exposing (Account, decoderAccount, encoderAccount)
import Api.Types.AccountingEntryTemplate exposing (AccountingEntryTemplate, decoderAccountingEntryTemplate, encoderAccountingEntryTemplate)
import Api.Types.AccountingEntryTemplateKey exposing (encoderAccountingEntryTemplateKey)
import Browser
import Dropdown
import Html exposing (Html, button, div, input, label, li, p, text, ul)
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
    { companyId : Int
    , contentDescription : String
    , contentDebitID : String
    , contentDebitName : String
    , contentCreditID : String
    , contentCreditName : String
    , contentAmount : String
    , aet : AccountingEntryTemplate
    , allAccounts : List Account
    , allAccountingEntryTemplates : List AccountingEntryTemplate
    , response : String
    , feedback : String
    , error : String
    , buttonPressed : Bool
    , selectedValue : Maybe String
    }


updateAccountingEntryTemplate : Model -> AccountingEntryTemplate -> Model
updateAccountingEntryTemplate model aet =
    { model | aet = aet }


updateError : Model -> String -> Model
updateError model error =
    { model | error = error }


type alias Flags =
    ()


dropdownOptions : List AccountingEntryTemplate -> Dropdown.Options Msg
dropdownOptions allAccountingEntryTemplates =
    let
        defaultOptions =
            Dropdown.defaultOptions DropdownChanged
    in
    { defaultOptions
        | items =
            List.map (\description -> { value = description, text = description, enabled = True }) (List.map (\aet -> aet.description) allAccountingEntryTemplates)
        , emptyItem = Just { value = "0", text = "[Please Select]", enabled = True }
    }


init : Flags -> ( Model, Cmd Msg )
init _ =
    ( { companyId = 1
      , contentDescription = ""
      , contentDebitID = ""
      , contentDebitName = "no account with that ID could be found"
      , contentCreditID = ""
      , contentCreditName = "no account with that ID could be found"
      , contentAmount = ""
      , aet = AccountingEntryTemplateUtil.updateCompanyId AccountingEntryTemplateUtil.empty 1
      , allAccounts = []
      , allAccountingEntryTemplates = []
      , response = ""
      , feedback = ""
      , error = ""
      , buttonPressed = False
      , selectedValue = Nothing
      }
    , getAccounts 1
    )



-- UPDATE


type Msg
    = ShowAllAccountingEntryTemplates
    | ChangeDescription String
    | ChangeDebit String
    | ChangeCredit String
    | ChangeAmount String
    | GotResponseAllAccountingEntryTemplates (Result Error (List AccountingEntryTemplate))
    | GotResponseCreate (Result Error AccountingEntryTemplate)
    | GotResponseAllAccounts (Result Error (List Account))
    | GotResponseDelete (Result Error ())
    | CreateAccountingEntryTemplate
    | DeleteAccountingEntryTemplate
    | DropdownChanged (Maybe String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ShowAllAccountingEntryTemplates ->
            ( { model | buttonPressed = True }, Cmd.none )

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

        GotResponseCreate result ->
            ( model, getAccountingEntryTemplates model.companyId)

        GotResponseAllAccounts result ->
            case result of
                Ok value ->
                    ( { model | allAccounts = value }, getAccountingEntryTemplates model.companyId )

                Err error ->
                    ( { model | allAccounts = [], error = Debug.toString error }, Cmd.none )

        GotResponseDelete result ->
            case result of
                Ok value ->
                    ( { model | selectedValue = Nothing }, getAccountingEntryTemplates model.companyId)

                Err error ->
                    ( { model | error = Debug.toString error, selectedValue = Nothing }, Cmd.none )

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
            ( resetOnSuccessfulPost model, postAccountingEntryTemplate model.aet )

        DeleteAccountingEntryTemplate ->
            ( model, deleteAccountingEntryTemplate model.selectedValue model.companyId )

        DropdownChanged selectedValue ->
            ( { model | selectedValue = selectedValue }, Cmd.none )



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
        [ div [] [ input [ placeholder "Description", value model.contentDescription, onInput ChangeDescription ] [] ]
        , div [] [ input [ placeholder "Debit Account ID", value model.contentDebitID, onInput ChangeDebit ] [], label [] [ text model.contentDebitName ] ]
        , div [] [ input [ placeholder "Credit Account ID", value model.contentCreditID, onInput ChangeCredit ] [], label [] [ text model.contentCreditName ] ]
        , div [] [ input [ placeholder "Amount", value model.contentAmount, onInput ChangeAmount ] [], label [] [ text model.error ] ]
        , div [] [ text (AccountingEntryTemplateUtil.show model.aet) ]
        , viewValidatedInput model.aet
        , div [] ([ button [ onClick ShowAllAccountingEntryTemplates ] [ text "Get All Accounting Entry Templates" ] ] ++ responseArea)
        , Html.form []
            [ p []
                [ label []
                    [ Dropdown.dropdown
                        (dropdownOptions model.allAccountingEntryTemplates)
                        []
                        model.selectedValue
                    ]
                ]
            ]
        , deleteButton model.selectedValue
        , div [] [ text model.error ]
        ]


getAccountingEntryTemplates : Int -> Cmd Msg
getAccountingEntryTemplates companyId =
    Http.get
        { url = "http://localhost:9000/accountingEntryTemplate/getAllAccountingEntryTemplates/" ++ String.fromInt companyId
        , expect = HttpUtil.expectJson GotResponseAllAccountingEntryTemplates (Decode.list decoderAccountingEntryTemplate)
        }


postAccountingEntryTemplate : AccountingEntryTemplate -> Cmd Msg
postAccountingEntryTemplate aet =
    Http.post
        { url = "http://localhost:9000/accountingEntryTemplate/repsert "
        , expect = HttpUtil.expectJson GotResponseCreate decoderAccountingEntryTemplate
        , body = Http.jsonBody (encoderAccountingEntryTemplate aet)
        }


deleteAccountingEntryTemplate : Maybe String -> Int -> Cmd Msg
deleteAccountingEntryTemplate description companyId =
    case description of
        Just string ->
            Http.post
                { url = "http://localhost:9000/accountingEntryTemplate/delete "
                , expect = HttpUtil.expectWhatever GotResponseDelete
                , body = Http.jsonBody (encoderAccountingEntryTemplateKey { companyID = companyId, description = string })
                }

        Nothing ->
            Cmd.none


getAccounts : Int -> Cmd Msg
getAccounts companyId=
    Http.get
        { url = "http://localhost:9000/account/getAllAccounts/" ++ String.fromInt companyId
        , expect = HttpUtil.expectJson GotResponseAllAccounts (Decode.list decoderAccount)
        }


parseAndUpdateCredit =
    parseWith (\m nc -> { m | contentCreditID = nc }) (\m nc acc -> { m | contentCreditID = nc, contentCreditName = acc.title, aet = AccountingEntryTemplateUtil.updateCredit m.aet acc.id })


parseAndUpdateDebit =
    parseWith (\m nc -> { m | contentDebitID = nc }) (\m nc acc -> { m | contentDebitID = nc, contentDebitName = acc.title, aet = AccountingEntryTemplateUtil.updateDebit m.aet acc.id })


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
                                                { model | contentAmount = String.concat [ String.fromInt whole, ",", String.fromInt change ], aet = AccountingEntryTemplateUtil.updateAmountWhole (AccountingEntryTemplateUtil.updateAmountChange model.aet (change * 10)) whole }

                                            else if change < 10 && String.length changeString >= 2 then
                                                { model | contentAmount = String.concat [ String.fromInt whole, ",0", String.fromInt change ], aet = AccountingEntryTemplateUtil.updateAmountWhole (AccountingEntryTemplateUtil.updateAmountChange model.aet change) whole }

                                            else
                                                { model | contentAmount = String.concat [ String.fromInt whole, ",", String.fromInt change ], aet = AccountingEntryTemplateUtil.updateAmountWhole (AccountingEntryTemplateUtil.updateAmountChange model.aet change) whole }

                                        Nothing ->
                                            { model | contentAmount = String.concat [ String.fromInt whole, "," ], aet = AccountingEntryTemplateUtil.updateAmountWhole model.aet whole }

                                Nothing ->
                                    { model | contentAmount = a, aet = AccountingEntryTemplateUtil.updateAmountWhole model.aet whole }

                        Nothing ->
                            { model | contentAmount = a, aet = AccountingEntryTemplateUtil.updateAmountWhole model.aet whole }

                Nothing ->
                    model

        Nothing ->
            model


viewValidatedInput : AccountingEntryTemplate -> Html Msg
viewValidatedInput aet =
    if not (String.isEmpty aet.description) && aet.credit /= 0 && aet.debit /= 0 then
        button [ disabled False, onClick CreateAccountingEntryTemplate ] [ text "Create new Accounting Entry Template" ]

    else
        button [ disabled True, onClick CreateAccountingEntryTemplate ] [ text "Create new Accounting Entry Template" ]


deleteButton : Maybe String -> Html Msg
deleteButton selectedValue =
    case selectedValue of
        Just value ->
            button [ disabled False, onClick DeleteAccountingEntryTemplate ] [ text "Delete" ]

        Nothing ->
            button [ disabled True, onClick DeleteAccountingEntryTemplate ] [ text "Delete" ]


resetOnSuccessfulPost : Model -> Model
resetOnSuccessfulPost model =
    { model
        | contentDescription = ""
        , contentDebitID = ""
        , contentDebitName = "no account with that ID could be found"
        , contentCreditID = ""
        , contentCreditName = "no account with that ID could be found"
        , contentAmount = ""
        , aet = AccountingEntryTemplateUtil.empty
        , error = ""
        , buttonPressed = False
    }
