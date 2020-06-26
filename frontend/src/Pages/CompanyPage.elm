module Pages.CompanyPage exposing (..)

import Api.General.CompanyUtil as CompanyUtil
import Api.General.HttpUtil as HttpUtil
import Api.Types.Company exposing (Company, decoderCompany, encoderCompany)
import Api.Types.CompanyKey exposing (encoderCompanyKey)
import Browser
import Dropdown exposing (Item)
import Html exposing (Attribute, Html, button, div, input, label, p, text)
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
    { contentCompanyID : String
    , contentName : String
    , contentStreet : String
    , contentPostalCode : String
    , contentCity : String
    , contentCountry : String
    , contentTaxNumber : String
    , contentRevenueOffice : String
    , company : Company
    , allCompanies : List Company
    , error : String
    , validationFeedback : String
    , selectedValue : Maybe String
    }


type alias Flags =
    ()


dropdownOptions : List Company -> Dropdown.Options Msg
dropdownOptions allCompanies =
    let
        defaultOptions =
            Dropdown.defaultOptions DropdownChanged
    in
    { defaultOptions
        | items =
            List.sortBy .value (List.map companyForDropdown allCompanies)
        , emptyItem = Just { value = "0", text = "[Please Select]", enabled = True }
    }


init : Flags -> ( Model, Cmd Msg )
init _ =
    ( { contentCompanyID = ""
      , contentName = ""
      , contentStreet = ""
      , contentPostalCode = ""
      , contentCity = ""
      , contentCountry = ""
      , contentTaxNumber = ""
      , contentRevenueOffice = ""
      , company = CompanyUtil.empty
      , allCompanies = []
      , error = ""
      , validationFeedback = ""
      , selectedValue = Nothing
      }
    , getCompanies
    )



-- UPDATE


type Msg
    = GotResponseForAllCompanies (Result Error (List Company))
    | GotResponseCreate (Result Error Company)
    | GotResponseDelete (Result Error ())
    | ChangeID String
    | ChangeName String
    | ChangeStreet String
    | ChangePostalCode String
    | ChangeCity String
    | ChangeCountry String
    | ChangeTaxNumber String
    | ChangeRevenueOffice String
    | CreateCompany
    | DeleteCompany
    | DropdownChanged (Maybe String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotResponseForAllCompanies result ->
            case result of
                Ok value ->
                    ( { model
                        | allCompanies = value |> List.sortBy .id
                        , error = ""
                      }
                    , Cmd.none
                    )

                Err error ->
                    ( { model | error = HttpUtil.errorToString error }, Cmd.none )

        GotResponseCreate result ->
            case result of
                Ok value ->
                    ( resetOnSuccessfulPost model, getCompanies )

                Err error ->
                    ( { model | error = HttpUtil.errorToString error }, Cmd.none )

        GotResponseDelete result ->
            case result of
                Ok value ->
                    ( { model | selectedValue = Nothing }, getCompanies )

                Err error ->
                    ( { model | error = HttpUtil.errorToString error, selectedValue = Nothing }, Cmd.none )

        ChangeID newContent ->
            ( parseAndUpdateID model newContent, Cmd.none )

        ChangeName newContent ->
            ( { model | company = CompanyUtil.updateName model.company newContent }, Cmd.none )

        ChangeStreet newContent ->
            ( updateAddress { model | contentStreet = newContent }, Cmd.none )

        ChangePostalCode newContent ->
            ( updateAddress { model | contentPostalCode = newContent }, Cmd.none )

        ChangeCity newContent ->
            ( updateAddress { model | contentCity = newContent }, Cmd.none )

        ChangeCountry newContent ->
            ( updateAddress { model | contentCountry = newContent }, Cmd.none )

        ChangeTaxNumber newContent ->
            ( { model | company = CompanyUtil.updateTaxNumber model.company newContent }, Cmd.none )

        ChangeRevenueOffice newContent ->
            ( { model | company = CompanyUtil.updateRevenueOffice model.company newContent }, Cmd.none )

        CreateCompany ->
            ( model, postCompany model.company )

        DeleteCompany ->
            ( model, deleteCompany model.selectedValue )

        DropdownChanged selectedValue ->
            ( { model | selectedValue = selectedValue }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ div []
            [ input [ placeholder "Company ID", value model.contentCompanyID, onInput ChangeID ] []
            , input [ placeholder "Company Name", value model.company.name, onInput ChangeName ] []
            ]
        , div [] [ input [ placeholder "Street", value model.contentStreet, onInput ChangeStreet ] [] ]
        , div []
            [ input [ placeholder "Postal Code", value model.contentPostalCode, onInput ChangePostalCode ] []
            , input [ placeholder "City", value model.contentCity, onInput ChangeCity ] []
            ]
        , div [] [ input [ placeholder "Country", value model.contentCountry, onInput ChangeCountry ] [] ]
        , div [] [ input [ placeholder "Tax Number", value model.company.taxNumber, onInput ChangeTaxNumber ] [] ]
        , div [] [ input [ placeholder "Revenue Office", value model.company.revenueOffice, onInput ChangeRevenueOffice ] [] ]
        , div []
            [ div [] [ text (CompanyUtil.show model.company) ]
            , div [ style "color" "red" ] [ text model.validationFeedback ]
            , viewValidatedInput model
            , Html.form []
                [ p []
                    [ label []
                        [ Dropdown.dropdown
                            (dropdownOptions model.allCompanies)
                            []
                            model.selectedValue
                        ]
                    ]
                ]
            , deleteButton model.selectedValue
            , div [] [ text model.error ]
            ]
        ]


getCompanies : Cmd Msg
getCompanies =
    Http.get
        { url = "http://localhost:9000/company/getAllCompanies"
        , expect = HttpUtil.expectJson GotResponseForAllCompanies (Decode.list decoderCompany)
        }


postCompany : Company -> Cmd Msg
postCompany company =
    Http.post
        { url = "http://localhost:9000/company/repsert"
        , expect = HttpUtil.expectJson GotResponseCreate decoderCompany
        , body = Http.jsonBody (encoderCompany company)
        }


deleteCompany : Maybe String -> Cmd Msg
deleteCompany selectedValue =
    case selectedValue of
        Just value ->
            case String.toInt value of
                Just id ->
                    Http.post
                        { url = "http://localhost:9000/company/delete "
                        , expect = HttpUtil.expectWhatever GotResponseDelete
                        , body = Http.jsonBody (encoderCompanyKey { id = id })
                        }

                Nothing ->
                    Cmd.none

        Nothing ->
            Cmd.none


viewValidatedInput : Model -> Html Msg
viewValidatedInput model =
    if CompanyUtil.isValid model.company then
        if String.isEmpty model.validationFeedback then
            button [ disabled False, onClick CreateCompany ] [ text "Create new Company" ]

        else
            button [ disabled False, onClick CreateCompany ] [ text "Update existing Company" ]

    else
        button [ disabled True, onClick CreateCompany ] [ text "Create new Company" ]


deleteButton : Maybe String -> Html Msg
deleteButton selectedValue =
    case selectedValue of
        Just value ->
            button [ disabled False, onClick DeleteCompany ] [ text "Delete" ]

        Nothing ->
            button [ disabled True, onClick DeleteCompany ] [ text "Delete" ]


updateAddress : Model -> Model
updateAddress model =
    if
        not (String.isEmpty model.contentStreet)
            && not (String.isEmpty model.contentPostalCode)
            && not (String.isEmpty model.contentCity)
            && not (String.isEmpty model.contentCountry)
    then
        { model | company = CompanyUtil.updateAddress model.company (makeAddressString model) }

    else
        model


makeAddressString : Model -> String
makeAddressString model =
    String.concat [ model.contentStreet, ", ", model.contentPostalCode, " ", model.contentCity, ", ", model.contentCountry ]


parseAndUpdateID : Model -> String -> Model
parseAndUpdateID model newContent =
    if not (String.isEmpty newContent) then
        case String.toInt newContent of
            Just id ->
                if List.isEmpty (List.filter (\com -> com.id == id) model.allCompanies) then
                    { model | contentCompanyID = newContent, company = CompanyUtil.updateId model.company id, validationFeedback = "" }

                else
                    { model | contentCompanyID = newContent, company = CompanyUtil.updateId model.company id, validationFeedback = "A Company with that ID already exists!" }

            Nothing ->
                model

    else
        { model | contentCompanyID = "", company = CompanyUtil.updateId model.company 0, validationFeedback = "" }


companyForDropdown : Company -> Item
companyForDropdown company =
    let
        id =
            String.fromInt company.id
    in
    { value = id, text = id ++ " - " ++ company.name, enabled = True }


resetOnSuccessfulPost : Model -> Model
resetOnSuccessfulPost model =
    { model
        | contentCompanyID = ""
        , contentName = ""
        , contentStreet = ""
        , contentPostalCode = ""
        , contentCity = ""
        , contentCountry = ""
        , contentTaxNumber = ""
        , contentRevenueOffice = ""
        , company = CompanyUtil.empty
        , error = ""
        , validationFeedback = ""
        , selectedValue = Nothing
    }
