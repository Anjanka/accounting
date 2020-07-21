module Pages.Company.CompanyPage exposing (Msg, init, update, view)

import Api.General.CompanyUtil exposing (empty, getCreationParams, isValid, show, updateAddress, updateCity, updateCountry, updateName, updatePostalCode, updateRevenueOffice, updateTaxNumber)
import Api.General.HttpUtil as HttpUtil
import Api.General.LanguageUtil exposing (getLanguage)
import Api.Types.Company exposing (Company, decoderCompany, encoderCompany)
import Api.Types.CompanyCreationParams exposing (encoderCompanyCreationParams)
import Api.Types.CompanyKey exposing (encoderCompanyKey)
import Browser
import Dropdown exposing (Item)
import Html exposing (Attribute, Html, button, div, input, p, text)
import Html.Attributes exposing (class, disabled, id, placeholder, style, value)
import Html.Events exposing (onClick, onInput)
import Http exposing (Error)
import Json.Decode as Decode
import Pages.Company.CompanyPageModel exposing (Model)
import Pages.Company.ParseAndUpdateUtil exposing (insertData, reset)
import Pages.LinkUtil exposing (Path(..), fragmentUrl, makeLinkPath)
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


type alias Flags =
    {lang : String}


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { lang = getLanguage flags.lang
      , company = empty
      , allCompanies = []
      , error = ""
      , validationFeedback = ""
      , selectedValue = Nothing
      , editViewActivated = False
      }
    , getCompanies
    )



-- UPDATE


type Msg
    = GotResponseForAllCompanies (Result Error (List Company))
    | GotResponseCreateOrUpdate (Result Error Company)
    | GotResponseDelete (Result Error ())
    | ChangeName String
    | ChangeAddress String
    | ChangePostalCode String
    | ChangeCity String
    | ChangeCountry String
    | ChangeTaxNumber String
    | ChangeRevenueOffice String
    | CreateCompany
    | UpdateCompany
    | DeleteCompany
    | DropdownChanged (Maybe String)
    | ActivateEditView
    | DeactivateEditView
    | BackToStartPage


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

        GotResponseCreateOrUpdate result ->
            case result of
                Ok _ ->
                    ( reset model, getCompanies )

                Err error ->
                    ( { model | error = HttpUtil.errorToString error }, Cmd.none )

        GotResponseDelete result ->
            case result of
                Ok _ ->
                    ( reset model, getCompanies )

                Err error ->
                    ( { model | error = HttpUtil.errorToString error, selectedValue = Nothing }, Cmd.none )

        ChangeName newContent ->
            ( { model | company = updateName model.company newContent }, Cmd.none )

        ChangeAddress newContent ->
            ( { model | company = updateAddress model.company newContent }, Cmd.none )

        ChangePostalCode newContent ->
            ( { model | company = updatePostalCode model.company newContent }, Cmd.none )

        ChangeCity newContent ->
            ( { model | company = updateCity model.company newContent }, Cmd.none )

        ChangeCountry newContent ->
            ( { model | company = updateCountry model.company newContent }, Cmd.none )

        ChangeTaxNumber newContent ->
            ( { model | company = updateTaxNumber model.company newContent }, Cmd.none )

        ChangeRevenueOffice newContent ->
            ( { model | company = updateRevenueOffice model.company newContent }, Cmd.none )

        CreateCompany ->
            ( model, createCompany model.company )

        UpdateCompany ->
            ( model, updateCompany model.company )

        DeleteCompany ->
            ( model, deleteCompany model.selectedValue )

        DropdownChanged selectedValue ->
            ( { model | selectedValue = selectedValue }, Cmd.none )

        ActivateEditView ->
            ( insertData model, Cmd.none )

        DeactivateEditView ->
            ( reset model, Cmd.none )

        BackToStartPage ->
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "page", class "companyInputArea" ]
        [ linkButton (fragmentUrl [ makeLinkPath StartPage ])
            [ class "backButton"][text model.lang.back ]

        , p [] []
        , div []
            [ if model.editViewActivated then
                viewEdit model

              else
                viewCreation model
            ]
        ]


viewCreation : Model -> Html Msg
viewCreation model =
    div []
        [ div []
            [ input [ placeholder model.lang.companyName, value model.company.name, onInput ChangeName ] []
            ]
        , div [] [ input [ placeholder model.lang.address, value model.company.address, onInput ChangeAddress ] [] ]
        , div []
            [ input [ placeholder model.lang.postalCode, value model.company.postalCode, onInput ChangePostalCode ] []
            , input [ placeholder model.lang.city, value model.company.city, onInput ChangeCity ] []
            ]
        , div [] [ input [ placeholder model.lang.country, value model.company.country, onInput ChangeCountry ] [] ]
        , div [] [ input [ placeholder model.lang.taxNumber, value model.company.taxNumber, onInput ChangeTaxNumber ] [] ]
        , div [] [ input [ placeholder model.lang.revenueOffice, value model.company.revenueOffice, onInput ChangeRevenueOffice ] [] ]
        , div []
            [ div [] [ text (show model.company) ]
            , div [ style "color" "red" ] [ text model.validationFeedback ]
            , viewValidatedInput model
            ]
        , div [ id "companyEditArea" ]
            [ Dropdown.dropdown
                (dropdownOptions model.lang.pleaseSelectCompany model.allCompanies)
                []
                model.selectedValue
            , viewEditButton model.lang.edit model.selectedValue
            ]
        , div [] [ text model.error ]
        ]


viewEdit : Model -> Html Msg
viewEdit model =
    div []
        [ div []
            [ input [ placeholder model.lang.companyName, value model.company.name, onInput ChangeName ] []
            ]
        , div [] [ input [ placeholder model.lang.address, value model.company.address, onInput ChangeAddress ] [] ]
        , div []
            [ input [ placeholder model.lang.postalCode, value model.company.postalCode, onInput ChangePostalCode ] []
            , input [ placeholder model.lang.city, value model.company.city, onInput ChangeCity ] []
            ]
        , div [] [ input [ placeholder model.lang.country, value model.company.country, onInput ChangeCountry ] [] ]
        , div [] [ input [ placeholder model.lang.taxNumber, value model.company.taxNumber, onInput ChangeTaxNumber ] [] ]
        , div [] [ input [ placeholder model.lang.revenueOffice, value model.company.revenueOffice, onInput ChangeRevenueOffice ] [] ]
        , div [] [ text (show model.company) ]
        , div []
            [ button [ class "saveButton", onClick UpdateCompany ] [ text model.lang.saveChanges ]
            , button [ class "deleteButton", onClick DeleteCompany ] [ text model.lang.delete ]
            , button [ class "cancelButton", onClick DeactivateEditView ] [ text model.lang.cancel ]
            ]
        , div [] [ text model.error ]
        ]


viewValidatedInput : Model -> Html Msg
viewValidatedInput model =
    if isValid model.company then
        button [ class "saveButton", disabled False, onClick CreateCompany ] [ text model.lang.create ]

    else
        button [ class "saveButton", disabled True, onClick CreateCompany ] [ text model.lang.create ]


viewEditButton : String -> Maybe String -> Html Msg
viewEditButton txt selectedValue =
    case selectedValue of
        Just _ ->
            button [ class "editCompanyButton", disabled False, onClick ActivateEditView ] [ text txt ]

        Nothing ->
            button [ class "editCompanyButton", disabled True, onClick ActivateEditView ] [ text txt ]


companyForDropdown : Company -> Item
companyForDropdown company =
    let
        id =
            String.fromInt company.id
    in
    { value = id, text = company.name, enabled = True }


dropdownOptions : String -> List Company -> Dropdown.Options Msg
dropdownOptions text allCompanies =
    let
        defaultOptions =
            Dropdown.defaultOptions DropdownChanged
    in
    { defaultOptions
        | items =
            List.sortBy .text (List.map companyForDropdown allCompanies)
        , emptyItem = Just { value = "0", text = text, enabled = True }
    }



--COMMUNICATION


getCompanies : Cmd Msg
getCompanies =
    Http.get
        { url = "http://localhost:9000/company/getAll"
        , expect = HttpUtil.expectJson GotResponseForAllCompanies (Decode.list decoderCompany)
        }


createCompany : Company -> Cmd Msg
createCompany company =
    Http.post
        { url = "http://localhost:9000/company/insert"
        , expect = HttpUtil.expectJson GotResponseCreateOrUpdate decoderCompany
        , body = Http.jsonBody (encoderCompanyCreationParams (getCreationParams company))
        }


updateCompany : Company -> Cmd Msg
updateCompany company =
    Http.post
        { url = "http://localhost:9000/company/replace"
        , expect = HttpUtil.expectJson GotResponseCreateOrUpdate decoderCompany
        , body = Http.jsonBody (encoderCompany company)
        }


deleteCompany : Maybe String -> Cmd Msg
deleteCompany selectedValue =
    case selectedValue of
        Just value ->
            case String.toInt value of
                Just id ->
                    Http.post
                        { url = "http://localhost:9000/company/delete"
                        , expect = HttpUtil.expectWhatever GotResponseDelete
                        , body = Http.jsonBody (encoderCompanyKey { id = id })
                        }

                Nothing ->
                    Cmd.none

        Nothing ->
            Cmd.none
