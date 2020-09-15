module Pages.LinkUtil exposing (..)

import Url.Builder exposing (Root(..))


type Path
    = StartPage
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


linkServer : String
linkServer = "http://localhost:9000"

linkAccount : String
linkAccount= "account"

linkAccountingEntry : String
linkAccountingEntry= "accountingEntry"

linkAccountingEntryTemplate : String
linkAccountingEntryTemplate = "accountingEntryTemplate"

linkCompany : String
linkCompany = "company"

linkReports : String
linkReports = "reports"

linkJournal : String
linkJournal = "journal"

linkNominalAccounts : String
linkNominalAccounts = "nominalAccounts"

linkDelete : String
linkDelete = "delete"

linkInsert : String
linkInsert = "insert"

linkReplace : String
linkReplace = "replace"

linkGetAll : String
linkGetAll = "getAll"

linkFind : String
linkFind = "find"

linkFindByYear : String
linkFindByYear = "findByYear"

linkMoveUp : String
linkMoveUp = "moveUp"

linkMoveDown : String
linkMoveDown = "moveDown"