module Pages.Company.CompanyPageModel exposing (..)


import Api.Types.Company exposing (Company)
import Api.Types.Language exposing (LanguageComponents)

type alias Model =
    { lang : LanguageComponents
    , company : Company
    , allCompanies : List Company
    , error : String
    , validationFeedback : String
    , selectedValue : Maybe String
    , editViewActivated : Bool
    }
