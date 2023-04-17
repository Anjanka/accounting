module Pages.LinkUtil exposing (..)

import Basics.Extra exposing (flip)
import Configuration exposing (Configuration)
import Url.Builder exposing (Root(..))


type Path
    = StartPage
    | CompanyPage
    | AccountPage
    | AccountingEntryPage
    | AccountingEntryTemplatePage



--makeLinkHost : String
--makeLinkHost =
--    "http://localhost:8080"


makeLinkPath : Path -> String
makeLinkPath page =
    case page of
        StartPage ->
            ""

        CompanyPage ->
            "Company"

        AccountPage ->
            "Accounts"

        AccountingEntryPage ->
            "Accounting"

        AccountingEntryTemplatePage ->
            "Templates"


makeLinkId : Int -> String
makeLinkId id =
    "id/" ++ String.fromInt id


makeLinkCompanyId : Int -> String
makeLinkCompanyId id =
    "companyId/" ++ String.fromInt id


makeLinkYear : Int -> String
makeLinkYear year =
    "accountingYear/" ++ String.fromInt year


makeLinkLang : String -> String
makeLinkLang lang =
    "lang/" ++ lang


fragmentUrl : List String -> String
fragmentUrl parts =
    Url.Builder.custom Relative [] [] (Just (Url.Builder.absolute parts []))


backendPage : Configuration -> List String -> String
backendPage configuration pathSteps =
    (configuration.backendURL :: pathSteps)
        |> flip Url.Builder.relative []

frontendPage : Configuration -> List String -> String
frontendPage configuration pathSteps =
    [ configuration.mainPageURL, "#" ]
        ++ pathSteps
        |> flip Url.Builder.relative []