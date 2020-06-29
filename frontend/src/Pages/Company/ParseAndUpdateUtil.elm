module Pages.Company.ParseAndUpdateUtil exposing (..)


import Pages.Company.CompanyPageModel exposing (Model)
import Api.General.CompanyUtil as CompanyUtil


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
                                | contentStreet = ""
                                , contentPostalCode = ""
                                , contentCity = ""
                                , contentCountry = ""
                                , company = company
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
        | contentStreet = ""
        , contentPostalCode = ""
        , contentCity = ""
        , contentCountry = ""
        , company = CompanyUtil.empty
        , error = ""
        , validationFeedback = ""
        , selectedValue = Nothing
        , editViewActivated = False
    }