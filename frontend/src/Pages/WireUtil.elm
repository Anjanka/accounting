module Pages.WireUtil exposing (..)

type Path =
      StartPage
    | CompanyPage
    | AccountPage
    | AccountingEntryPage
    | AccountingEntryTemplatePage




makeLinkPath : Path -> String
makeLinkPath page =
    case page of
        StartPage ->
            ""

        CompanyPage ->
            "Company"

        AccountPage ->
            "Account"

        AccountingEntryPage ->
            "Accounting"

        AccountingEntryTemplatePage ->
            "Template"

makeLinkId : Int -> String
makeLinkId id =
    "/companyId/" ++ String.fromInt id

makeLinkYear : Int -> String
makeLinkYear year =
    "/accountingYear/" ++ String.fromInt year