module Pages.StartPage exposing (Model, Msg, init, update, view)

import Api.General.HttpUtil as HttpUtil
import Api.Types.Company exposing (Company, decoderCompany)
import Browser
import Dropdown exposing (Item)
import Html exposing (Attribute, Html, button, div, text)
import Html.Attributes exposing (class, disabled, value)
import Html.Events exposing (onClick)
import Http exposing (Error)
import Json.Decode as Decode
import List exposing (range)
import Pages.LinkUtil exposing (Path(..), fragmentUrl, makeLinkId, makeLinkPath, makeLinkYear)
import Pages.SharedViewComponents exposing (linkButton)



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
    { language : String
    , companyId : Int
    , accountingYear : Int
    , selectionState : State
    , allCompanies : List Company
    , error : String
    , validationFeedback : String
    , selectedLanguage : Maybe String
    , selectedCompany : Maybe String
    , selectedYear : Maybe String
    }


type State
    = SelectLanguage
    | SelectCompany
    | SelectYear


type alias Flags =
    ()


init : Flags -> ( Model, Cmd Msg )
init _ =
    ( { language = ""
      , companyId = 0
      , accountingYear = 0
      , selectionState = SelectLanguage
      , allCompanies = []
      , error = ""
      , validationFeedback = ""
      , selectedLanguage = Nothing
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
    | ToCompanySelection
    | ToYearSelection
    | BackToLanguageSelection
    | BackToCompanySelection
    | LanguageDropdownChanged (Maybe String)
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

        ToCompanySelection ->
            ( { model | selectionState = SelectCompany }, Cmd.none )

        ToYearSelection ->
            ( { model | selectionState = SelectYear }, Cmd.none )

        BackToLanguageSelection ->
            ( { model | language = "", selectionState = SelectLanguage, selectedLanguage = Nothing, selectedCompany = Nothing }, Cmd.none )

        BackToCompanySelection ->
            ( { model | accountingYear = 0, selectionState = SelectCompany, selectedCompany = Nothing, selectedYear = Nothing }, Cmd.none )

        LanguageDropdownChanged selectedValue ->
            let
                newModel =
                    updateSelectedLanguage model selectedValue
                        |> (\md -> foldMaybe md (updateLanguage md) selectedValue)
            in
            ( newModel, Cmd.none )

        CompanyDropdownChanged selectedValue ->
            ( updateCompany model selectedValue, Cmd.none )

        YearDropdownChanged selectedValue ->
            ( updateYear model selectedValue, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    case model.selectionState of
        SelectLanguage ->
            viewLanguageSelection model

        SelectCompany ->
            viewCompanySelection model

        SelectYear ->
            viewAccountingYearSelection model


viewLanguageSelection : Model -> Html Msg
viewLanguageSelection model =
    div []
        [ Html.form []
            [ Dropdown.dropdown
                dropdownOptionsLanguage
                []
                model.selectedLanguage
            ]
        , languageButton model.selectedLanguage
        , div [] [ text model.error ]
        ]


viewCompanySelection : Model -> Html Msg
viewCompanySelection model =
    div [class "page"]
        [ Html.form []
            [ Dropdown.dropdown
                (dropdownOptionsCompany model.allCompanies)
                []
                model.selectedCompany
            ]
        , companyButton model.selectedCompany
        , linkButton (fragmentUrl [ makeLinkPath CompanyPage ])
            [class "linkButton", value "Manage Companies" ]
            []
        , button [ class "backButton", onClick BackToLanguageSelection ] [ text "Back" ]
        , div [] [ text model.error ]
        ]


viewAccountingYearSelection : Model -> Html Msg
viewAccountingYearSelection model =
    div []
        [ Html.form []
            [ Dropdown.dropdown
                dropdownOptionsYear
                []
                model.selectedYear
            ]
        , yearButton model
        , button [ class "backButton", onClick BackToCompanySelection ] [ text "Back" ]
        , div [] [ text model.error ]
        ]


languageButton : Maybe String -> Html Msg
languageButton selectedValue =
    button [ class "saveButton", disabled (isNothing selectedValue), onClick ToCompanySelection ] [ text "Ok" ]


companyButton : Maybe String -> Html Msg
companyButton selectedValue =
    button [ class "saveButton", disabled (isNothing selectedValue), onClick ToYearSelection ] [ text "Ok" ]


yearButton : Model -> Html Msg
yearButton model =
    linkButton (fragmentUrl [ makeLinkId model.companyId, makeLinkPath AccountingEntryPage, makeLinkYear model.accountingYear ])
        [ class "saveButton", disabled (isNothing model.selectedYear), value "Ok" ]
        []


isNothing : Maybe a -> Bool
isNothing maybe =
    case maybe of
        Just _ ->
            False

        Nothing ->
            True


dropdownOptionsLanguage : Dropdown.Options Msg
dropdownOptionsLanguage =
    let
        defaultOptions =
            Dropdown.defaultOptions LanguageDropdownChanged
    in
    { defaultOptions
        | items = [ { value = "en", text = "English", enabled = True } ]
        , emptyItem = Just { value = "0", text = "[Please Select Language]", enabled = True }
    }


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



-- COMMUNICATION


getCompanies : Cmd Msg
getCompanies =
    Http.get
        { url = "http://localhost:9000/company/getAll"
        , expect = HttpUtil.expectJson GotResponseForAllCompanies (Decode.list decoderCompany)
        }



-- UTILITIES


updateLanguage : Model -> String -> Model
updateLanguage model language =
    { model | language = language }


updateSelectedLanguage : Model -> Maybe String -> Model
updateSelectedLanguage model selectedLanguage =
    { model | selectedLanguage = selectedLanguage }


updateCompany : Model -> Maybe String -> Model
updateCompany =
    updateWith (\m nsv -> { m | selectedCompany = nsv }) (\m nsv int -> { m | companyId = int, selectedCompany = nsv })


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


foldMaybe : b -> (a -> b) -> Maybe a -> b
foldMaybe b f ma =
    ma
        |> Maybe.map f
        |> Maybe.withDefault b
