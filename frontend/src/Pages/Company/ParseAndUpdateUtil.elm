module Pages.Company.ParseAndUpdateUtil exposing (..)


import Pages.Company.CompanyPageModel exposing (Model)
import Api.General.CompanyUtil as CompanyUtil


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