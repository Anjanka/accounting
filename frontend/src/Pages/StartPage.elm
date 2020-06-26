module Pages.StartPage exposing (..)

import Api.General.HttpUtil as HttpUtil
import Api.Types.Company exposing (Company, decoderCompany)
import Browser
import Dropdown exposing (Item)
import Html exposing (Attribute, Html, button, div, label, p, text)
import Html.Attributes exposing (disabled, value)
import Html.Events exposing (onClick)
import Http exposing (Error)
import Json.Decode as Decode
import List exposing (range)



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
    { companyID : Int
    , accountingYear : Int
    , companyWasSelected : Bool
    , allCompanies : List Company
    , error : String
    , validationFeedback : String
    , selectedCompany : Maybe String
    , selectedYear : Maybe String
    }


type alias Flags =
    ()


dropdownOptionsCompany : List Company -> Dropdown.Options Msg
dropdownOptionsCompany allCompanies =
    let
        defaultOptions =
            Dropdown.defaultOptions CompanyDropdownChanged
    in
    { defaultOptions
        | items =
            List.sortBy .value (List.map companyForDropdown allCompanies)
        , emptyItem = Just { value = "0", text = "[Please Select Company]", enabled = True }
    }


dropdownOptionsYear : Dropdown.Options Msg
dropdownOptionsYear =
    let
        defaultOptions =
            Dropdown.defaultOptions YearDropdownChanged
    in
    { defaultOptions
        | items = List.map accountingYearForDropdown (range 2015 2040)
        , emptyItem = Just { value = "0", text = "[Please Select Accounting Year]", enabled = True }
    }


init : Flags -> ( Model, Cmd Msg )
init _ =
    ( { companyID = 0
      , accountingYear = 0
      , companyWasSelected = False
      , allCompanies = []
      , error = ""
      , validationFeedback = ""
      , selectedCompany = Nothing
      , selectedYear = Nothing
      }
    , getCompanies
    )



-- UPDATE


type Msg
    = GotResponseForAllCompanies (Result Error (List Company))
    | ManageCompanies
    | ManageAccountingEntries
    | ToYearSelection
    | BackToCompanySelection
    | CompanyDropdownChanged (Maybe String)
    | YearDropdownChanged (Maybe String)


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

        ManageCompanies ->
            ( model, Cmd.none )

        ManageAccountingEntries ->
            ( model, Cmd.none )

        ToYearSelection ->
            ( { model | companyWasSelected = True }, Cmd.none )

        BackToCompanySelection ->
            ( { model | accountingYear = 0, companyWasSelected = False, selectedCompany = Nothing, selectedYear = Nothing }, Cmd.none )

        CompanyDropdownChanged selectedValue ->
            ( updateCompany model selectedValue, Cmd.none )

        YearDropdownChanged selectedValue ->
            ( updateYear model selectedValue, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    if model.companyWasSelected then
        div []
            [ Html.form []
                [ Dropdown.dropdown
                    dropdownOptionsYear
                    []
                    model.selectedYear
                ]
            , yearButton model.selectedYear
            , button [ onClick BackToCompanySelection ] [ text "Back" ]
            , div [] [ text model.error ]
            ]

    else
        div []
            [ Html.form []
                [ Dropdown.dropdown
                    (dropdownOptionsCompany model.allCompanies)
                    []
                    model.selectedCompany
                ]
            , companyButton model.selectedCompany
            , div [] [ button [ onClick ManageCompanies ] [ text "Manage Companies" ] ]
            , div [] [ text model.error ]
            ]


getCompanies : Cmd Msg
getCompanies =
    Http.get
        { url = "http://localhost:9000/company/getAllCompanies"
        , expect = HttpUtil.expectJson GotResponseForAllCompanies (Decode.list decoderCompany)
        }


updateCompany : Model -> Maybe String -> Model
updateCompany =
    updateWith (\m nsv -> { m | selectedCompany = nsv }) (\m nsv int -> { m | companyID = int, selectedCompany = nsv })


updateYear : Model -> Maybe String -> Model
updateYear =
    updateWith (\m nsv -> { m | selectedYear = nsv }) (\m nsv int -> { m | accountingYear = int, selectedYear = nsv })


updateWith : (Model -> Maybe String -> Model) -> (Model -> Maybe String -> Int -> Model) -> Model -> Maybe String -> Model
updateWith nothing just model newSelectedValue =
    case newSelectedValue of
        Just newSelectedString ->
            let
                id =
                    String.toInt newSelectedString
            in
            case id of
                Just int ->
                    just model newSelectedValue int

                Nothing ->
                    nothing model newSelectedValue

        Nothing ->
            nothing model newSelectedValue


companyButton : Maybe String -> Html Msg
companyButton selectedValue =
    case selectedValue of
        Just value ->
            button [ disabled False, onClick ToYearSelection ] [ text "Ok" ]

        Nothing ->
            button [ disabled True, onClick ToYearSelection ] [ text "Ok" ]


yearButton : Maybe String -> Html Msg
yearButton selectedValue =
    case selectedValue of
        Just value ->
            button [ disabled False, onClick ManageAccountingEntries ] [ text "Ok" ]

        Nothing ->
            button [ disabled True, onClick ManageAccountingEntries ] [ text "Ok" ]


companyForDropdown : Company -> Item
companyForDropdown company =
    let
        id =
            String.fromInt company.id
    in
    { value = id, text = id ++ " - " ++ company.name, enabled = True }


accountingYearForDropdown : Int -> Item
accountingYearForDropdown int =
    let
        year =
            String.fromInt int
    in
    { value = year, text = year, enabled = True }
