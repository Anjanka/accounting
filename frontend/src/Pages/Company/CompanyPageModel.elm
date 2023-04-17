module Pages.Company.CompanyPageModel exposing (..)

import Api.General.CompanyUtil as CompanyUtil exposing (empty)
import Api.General.LanguageComponentConstants exposing (getLanguage)
import Api.Types.Company exposing (Company)
import Api.Types.LanguageComponents exposing (LanguageComponents)
import List.Extra
import Pages.Util.AuthorizedAccess exposing (AuthorizedAccess)


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
    { lang : String
    , authorizedAccess : AuthorizedAccess
    }


init : Flags -> Model
init flags =
    { lang = getLanguage flags.lang
    , company = empty
    , allCompanies = []
    , error = ""
    , validationFeedback = ""
    , selectedValue = Nothing
    , editViewActivated = False
    }


insertData : Model -> Model
insertData model =
    model.selectedValue
        |> Maybe.andThen String.toInt
        |> Maybe.andThen (\id -> List.Extra.find (\comp -> comp.id == id) model.allCompanies)
        |> Maybe.map (\company -> { model | company = company, editViewActivated = True })
        |> Maybe.withDefault model


reset : Model -> Model
reset model =
    { model
        | company = CompanyUtil.empty
        , error = ""
        , validationFeedback = ""
        , selectedValue = Nothing
        , editViewActivated = False
    }
