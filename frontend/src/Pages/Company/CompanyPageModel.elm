module Pages.Company.CompanyPageModel exposing (..)


import Api.General.CompanyUtil as CompanyUtil exposing (empty)
import Api.General.LanguageComponentConstants exposing (getLanguage)
import Api.Types.Company exposing (Company)
import Api.Types.LanguageComponents exposing (LanguageComponents)

type alias Model =
    { lang : LanguageComponents
    , company : Company
    , allCompanies : List Company
    , error : String
    , validationFeedback : String
    , selectedValue : Maybe String
    , editViewActivated : Bool
    }


type alias Flags =
    {lang : String}

init : Flags -> Model
init flags = { lang = getLanguage flags.lang
                   , company = empty
                   , allCompanies = []
                   , error = ""
                   , validationFeedback = ""
                   , selectedValue = Nothing
                   , editViewActivated = False
                   }

insertData : Model -> Model
insertData model =
    case model.selectedValue of
        Just value ->
            case String.toInt value of
                Just id ->
                    let
                        companyCandidate =
                            List.filter (\comp -> comp.id == id) model.allCompanies
                    in
                    case List.head companyCandidate of
                        Just company ->
                            { model
                                | company = company
                                , editViewActivated = True
                            }

                        Nothing ->
                            model

                Nothing ->
                    model

        Nothing ->
            model

reset : Model -> Model
reset model =
    { model
        | company = CompanyUtil.empty
        , error = ""
        , validationFeedback = ""
        , selectedValue = Nothing
        , editViewActivated = False
    }