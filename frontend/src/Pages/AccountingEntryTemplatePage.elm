module Pages.AccountingEntryTemplatePage exposing (..)

import Api.General.AccountUtil as AccountUtil
import Api.General.AccountingEntryTemplateUtil as AccountingEntryTemplateUtil
import Api.General.HttpUtil as HttpUtil
import Api.Types.Account exposing (Account, decoderAccount, encoderAccount)
import Api.Types.AccountingEntryTemplate exposing (AccountingEntryTemplate, decoderAccountingEntryTemplate, encoderAccountingEntryTemplate)
import Api.Types.AccountingEntryTemplateCreationParams exposing (encoderAccountingEntryTemplateCreationParams)
import Api.Types.AccountingEntryTemplateKey exposing (AccountingEntryTemplateKey, encoderAccountingEntryTemplateKey)
import Browser
import Dropdown exposing (Item)
import Html exposing (Html, button, div, input, label, li, p, table, td, text, th, tr, ul)
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
    { companyId : Int
    , contentDescription : String
    , contentDebitID : String
    , contentCreditID : String
    , contentAmount : String
    , aet : AccountingEntryTemplate
    , allAccounts : List Account
    , allAccountingEntryTemplates : List AccountingEntryTemplate
    , response : String
    , feedback : String
    , error : String
    , selectedCredit : Maybe String
    , selectedDebit : Maybe String
    , buttonPressed : Bool
    , editViewActive : Bool
    }


updateAccountingEntryTemplate : Model -> AccountingEntryTemplate -> Model
updateAccountingEntryTemplate model aet =
    { model | aet = aet }


type alias Flags =
    ()


init : Flags -> ( Model, Cmd Msg )
init _ =
    ( { companyId = 1
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
    , getAccounts 1
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
    |BackToAccountingEntryPage


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
                Ok value ->
                    ( reset model, getAccountingEntryTemplates model.companyId )

                Err error ->
                    ( { model | error = HttpUtil.errorToString error }, Cmd.none )

        GotResponseAllAccounts result ->
            case result of
                Ok value ->
                    ( { model | allAccounts = value }, getAccountingEntryTemplates model.companyId )

                Err error ->
                    ( { model | allAccounts = [], error = HttpUtil.errorToString error }, Cmd.none )

        GotResponseDelete result ->
            case result of
                Ok value ->
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
            ( updateCredit model selectedCredit, Cmd.none )

        DropdownDebitChanged selectedDebit ->
            ( updateDebit model selectedDebit, Cmd.none )

        ActivateEditView aet ->
            ( insertData model aet, Cmd.none )

        DeactivateEditView ->
            ( { model | editViewActive = False }, Cmd.none )

        BackToAccountingEntryPage ->
            (model, Cmd.none)



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ div [][button [ onClick BackToAccountingEntryPage ] [ text "Back" ] ]
        , p[][]
        , viewEditOrCreate model
        , p [] []
        , viewAccountingEntryTemplateList model
        , p [] []
        , div [] [ text model.error ]
        ]


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


updateCredit : Model -> Maybe String -> Model
updateCredit =
    updateWith (\m nsv -> { m | selectedCredit = nsv }) (\m nsv nss id -> { m | contentCreditID = nss, aet = AccountingEntryTemplateUtil.updateCredit m.aet id, selectedCredit = nsv })


updateDebit : Model -> Maybe String -> Model
updateDebit =
    updateWith (\m nsv -> { m | selectedDebit = nsv }) (\m nsv nss id -> { m | contentDebitID = nss, aet = AccountingEntryTemplateUtil.updateDebit m.aet id, selectedDebit = nsv })


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


parseAndUpdateCredit : Model -> String -> Model
parseAndUpdateCredit =
    parseWith (\m nc -> { m | contentCreditID = nc, aet = AccountingEntryTemplateUtil.updateCredit m.aet 0, selectedCredit = Nothing }) (\m nc acc -> { m | contentCreditID = nc, aet = AccountingEntryTemplateUtil.updateCredit m.aet acc.id, selectedCredit = Just nc })


parseAndUpdateDebit : Model -> String -> Model
parseAndUpdateDebit =
    parseWith (\m nc -> { m | contentDebitID = nc, aet = AccountingEntryTemplateUtil.updateDebit m.aet 0, selectedDebit = Nothing }) (\m nc acc -> { m | contentDebitID = nc, aet = AccountingEntryTemplateUtil.updateDebit m.aet acc.id, selectedDebit = Just nc })


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
parseAndUpdateAmount model newContent =
    if String.isEmpty newContent then
        { model | contentAmount = "", aet = AccountingEntryTemplateUtil.updateCompleteAmount model.aet 0 0 }

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
                                                    { model | contentAmount = String.concat [ String.fromInt whole, ",", String.fromInt change ], aet = AccountingEntryTemplateUtil.updateAmountWhole (AccountingEntryTemplateUtil.updateAmountChange model.aet (change * 10)) whole }

                                                else if change < 10 && String.length changeString >= 2 then
                                                    { model | contentAmount = String.concat [ String.fromInt whole, ",0", String.fromInt change ], aet = AccountingEntryTemplateUtil.updateAmountWhole (AccountingEntryTemplateUtil.updateAmountChange model.aet change) whole }

                                                else
                                                    { model | contentAmount = String.concat [ String.fromInt whole, ",", String.fromInt change ], aet = AccountingEntryTemplateUtil.updateAmountWhole (AccountingEntryTemplateUtil.updateAmountChange model.aet change) whole }

                                            Nothing ->
                                                { model | contentAmount = String.concat [ String.fromInt whole, "," ], aet = AccountingEntryTemplateUtil.updateCompleteAmount model.aet whole 0 }

                                    Nothing ->
                                        { model | contentAmount = newContent, aet = AccountingEntryTemplateUtil.updateCompleteAmount model.aet whole 0 }

                            Nothing ->
                                { model | contentAmount = newContent, aet = AccountingEntryTemplateUtil.updateCompleteAmount model.aet whole 0 }

                    Nothing ->
                        model

            Nothing ->
                model


viewEditOrCreate : Model -> Html Msg
viewEditOrCreate model =
    if model.editViewActive then
        div []
            [ input [ placeholder "Description", value model.contentDescription, onInput ChangeDescription ] []
            , viewCreditInput model
            , viewDebitInput model
            , div [] [ input [ placeholder "Amount", value model.contentAmount, onInput ChangeAmount ] [], label [] [ text model.error ] ]
            , div [] [ text (AccountingEntryTemplateUtil.show model.aet) ]
            , div []
                [ viewUpdateButton model.aet
                , button [ onClick DeleteAccountingEntryTemplate ] [ text "Delete" ]
                , button [ onClick DeactivateEditView ] [ text "Cancel" ]
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


viewAccountingEntryTemplateList : Model -> Html Msg
viewAccountingEntryTemplateList model =
    if model.buttonPressed then
        div []
            [ div [] [ button [ onClick HideAllAccountingEntryTemplates ] [ text "Hide Accounting Entry Templates" ] ]
            , div [ id "allAccountingEntryTemplates" ]
                [ table
                    []
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
        div [] [ button [ onClick ShowAllAccountingEntryTemplates ] [ text "Manage Accounts" ] ]


mkTableLine : AccountingEntryTemplate -> Html Msg
mkTableLine aet =
    tr []
        [ td [] [ text aet.description ]
        , td [] [ text (String.fromInt aet.credit) ]
        , td [] [ text (String.fromInt aet.debit) ]
        , td [] [ text (AccountingEntryTemplateUtil.showAmount aet) ]
        , button [ onClick (ActivateEditView aet) ] [ text "Edit" ]
        ]


viewCreateButton : AccountingEntryTemplate -> Bool -> Html Msg
viewCreateButton aet validSelection =

    if not validSelection then
             div [] [ button [ disabled True, onClick CreateAccountingEntryTemplate ] [ text "Create new Accounting Entry Template" ]
                   , div [ style "color" "red" ] [ text "Credit and Debit must not be equal." ]]
    else if not (String.isEmpty aet.description) && aet.credit /= 0 && aet.debit /= 0 && validSelection then
          button [ disabled False, onClick CreateAccountingEntryTemplate ] [ text "Create new Accounting Entry Template" ]

    else
        button [ disabled True, onClick CreateAccountingEntryTemplate ] [ text "Create new Accounting Entry Template" ]


viewUpdateButton : AccountingEntryTemplate -> Html Msg
viewUpdateButton aet =
    if not (String.isEmpty aet.description) && aet.credit /= 0 && aet.debit /= 0 then
        button [ disabled False, onClick ReplaceAccountingEntryTemplate ] [ text "Save Changes" ]

    else
        button [ disabled True, onClick ReplaceAccountingEntryTemplate ] [ text "Save Changes" ]


insertData : Model -> AccountingEntryTemplate -> Model
insertData model aet =
    { model
        | contentDescription = aet.description
        , contentDebitID = String.fromInt aet.debit
        , contentCreditID = String.fromInt aet.credit
        , contentAmount = AccountingEntryTemplateUtil.showAmount aet
        , aet = aet
        , error = ""
        , selectedCredit = Just (String.fromInt aet.credit)
        , selectedDebit = Just (String.fromInt aet.debit)
        , editViewActive = True
    }


reset : Model -> Model
reset model =
    { model
        | contentDescription = ""
        , contentDebitID = ""
        , contentCreditID = ""
        , contentAmount = ""
        , aet = AccountingEntryTemplateUtil.updateCompanyId AccountingEntryTemplateUtil.empty model.companyId
        , error = ""
        , buttonPressed = False
        , editViewActive = False
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


accountListForDropdown : List Account -> Maybe String -> List Account
accountListForDropdown allAccounts selectedValueCandidate =
    case selectedValueCandidate of
        Just selectedValue ->
            case String.toInt selectedValue of
                Just selectedId ->
                    List.filter (\acc -> acc.id /= selectedId) allAccounts

                Nothing ->
                    allAccounts

        Nothing ->
            allAccounts


accountForDropdown : Account -> Item
accountForDropdown acc =
    let
        id =
            String.fromInt acc.id
    in
    { value = id, text = acc.title, enabled = True }
