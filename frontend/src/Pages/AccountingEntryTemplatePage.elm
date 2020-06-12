module Pages.AccountingEntryTemplatePage exposing (..)

import Api.General.AccountUtil as AccountUtil
import Api.Types.AccountingEntryTemplate exposing (AccountingEntryTemplate, decoderAccountingEntryTemplate, encoderAccountingEntryTemplate)
import Browser
import Html exposing (Html, button, div, input, label, text)
import Html.Attributes exposing (disabled, placeholder, style, value)
import Html.Events exposing (onClick, onInput)
import Http exposing (Error)
import Json.Decode as Decode
import Api.General.AccountUtil as AccountUtil
import Api.Types.Account exposing (Account, decoderAccount, encoderAccount)
import Api.General.AccountingEntryTemplateUtil as AccountingEntryTemplateUtil
import Api.Types.AccountingEntryTemplate



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
    { contentDescription : String
    , contentDebitID : String
    , contentDebitName : String
    , contentCreditID : String
    , contentCreditName : String
    , contentAmount : String
    , aet : AccountingEntryTemplate
    , allAccounts : List Account
    , response : String
    , feedback : String
    , error : String
    , buttonPressed : Bool

    }


updateAccountingEntryTemplate : Model -> AccountingEntryTemplate -> Model
updateAccountingEntryTemplate model aet =
    { model | aet = aet }


updateError : Model -> String -> Model
updateError model error =
    { model | error = error }

type alias Flags =
    ()


init : Flags -> ( Model, Cmd Msg )
init _ =
    ( { contentDescription = ""
      , contentDebitID = ""
      , contentDebitName = "test"
      , contentCreditID = ""
      , contentCreditName = "test"
      , contentAmount = ""
      , aet = AccountingEntryTemplateUtil.empty
      , allAccounts = []
      , response = ""
      , feedback = ""
      , error = ""
      , buttonPressed = False
      }
    , getAccounts
    )



-- UPDATE


type Msg
    = GetAccountingEntryTemplates
    | ChangeDescription String
    | ChangeDebit String
    | ChangeCredit String
    | ChangeAmount String
    | GotResponse (Result Error (List AccountingEntryTemplate))
    | GotResponse2 (Result Error AccountingEntryTemplate)
    | GotResponse3 (Result Error (List Account))



update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetAccountingEntryTemplates ->
            ( { model | buttonPressed = True }, getAccountingEntryTemplates )


        GotResponse result ->
            case result of
                Ok value ->
                    ( { model
                        | response = value |> List.map AccountingEntryTemplateUtil.show |> String.join ",\n"
                        , feedback = ""
                      }
                    , Cmd.none
                    )

                Err error ->
                    ( { model | feedback = Debug.toString error }, Cmd.none )

        GotResponse2 result ->
                    ( model, Cmd.none )


        GotResponse3 result ->
            case result of
                Ok value ->
                    ( { model | allAccounts = value}, Cmd.none)

                Err error ->
                    ( { model | allAccounts = [] }, Cmd.none )

        ChangeDescription newContent ->
             let
                            newModel =
                                    model.aet
                                          |> (\aet -> AccountingEntryTemplateUtil.updateDescription aet newContent)
                                          |> updateAccountingEntryTemplate model
             in ( { newModel | contentDescription = newContent }, Cmd.none )


        ChangeDebit newContent ->
                   ( { model | contentDebitID = newContent, contentDebitName = findAccountName model.allAccounts newContent}, Cmd.none )

        ChangeCredit newContent ->
                   ( { model | contentCreditID = newContent, contentCreditName = findAccountName model.allAccounts newContent}, Cmd.none )

        ChangeAmount newContent ->
                  ( { model | contentAmount = newContent, aet = parseAndUpdateAmount newContent model.aet  }, Cmd.none )





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
        [ div [] [input [ placeholder "Description", value model.contentDescription, onInput ChangeDescription ] []]
        , div [] [input [ placeholder "Debit Account", value model.contentDebitID, onInput ChangeDebit ] [], label [] [text model.contentDebitName] ]
        , div [] [input [ placeholder "Crebit Account", value model.contentCreditID, onInput ChangeCredit ] [], label [] [text model.contentCreditName] ]
        , div [] [input [ placeholder "Amount", value model.contentAmount, onInput ChangeAmount ] []]
        , div [] [ text (AccountingEntryTemplateUtil.show model.aet) ]
        , div [] ([ button [ onClick GetAccountingEntryTemplates ] [ text "Get All Accounting Entry Templates" ] ] ++ responseArea)
        ]



-- Communication with backend


getAccountingEntryTemplates : Cmd Msg
getAccountingEntryTemplates =
    Http.get
        { url = "http://localhost:9000/accountingEntryTemplate/getAllAccountingEntryTemplates"
        , expect = Http.expectJson GotResponse (Decode.list decoderAccountingEntryTemplate)
        }


postAccountingEntryTemplate : AccountingEntryTemplate -> Cmd Msg
postAccountingEntryTemplate aet =
    Http.post
        { url = "http://localhost:9000/accountingEntryTemplate/repsert "
        , expect = Http.expectJson GotResponse2 decoderAccountingEntryTemplate
        , body = Http.jsonBody (encoderAccountingEntryTemplate aet)
        }

getAccounts : Cmd Msg
getAccounts =
    Http.get
        { url = "http://localhost:9000/account/getAllAccounts"
        , expect = Http.expectJson GotResponse3 (Decode.list decoderAccount)
        }


findAccountName : List Account -> String -> String
findAccountName  accounts id =
    case String.toInt id of
            Just int ->
                case List.head (List.filter (\acc -> acc.id == int) accounts) of
                    Just value ->
                        value.title

                    Nothing ->
                        ""
            Nothing ->
                ""


parseAndUpdateAmount : String -> AccountingEntryTemplate -> AccountingEntryTemplate
parseAndUpdateAmount a aet =
    let wholeAndChange = String.split "," a
    in
      case List.head wholeAndChange of
          Just wholeString->
              case String.toInt wholeString of
                  Just whole ->
                      case List.tail wholeAndChange of
                          Just tailList ->
                               case List.head tailList of
                                   Just changeString ->
                                      case String.toInt changeString of
                                          Just change ->
                                              {aet | amountWhole = whole, amountChange = change}
                                          Nothing ->
                                               {aet | amountWhole = whole }
                                   Nothing ->
                                       {aet | amountWhole = whole }
                          Nothing ->
                               {aet | amountWhole = whole }
                  Nothing ->
                       aet
          Nothing ->
              aet

