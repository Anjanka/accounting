module Pages.Company.CompanyPageModel exposing (..)


import Api.Types.Company exposing (Company)

type alias Model =
    { contentStreet : String
    , contentPostalCode : String
    , contentCity : String
    , contentCountry : String
    , company : Company
    , allCompanies : List Company
    , error : String
    , validationFeedback : String
    , selectedValue : Maybe String
    , editViewActivated : Bool
    }