module Pages.AccountingMain exposing (..)

import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Html exposing (Html, div, text)
import Pages.AccountPage as Account
import Pages.AccountingEntry.AccountingEntryPage as AccountingEntry
import Pages.AccountingEntry.AccountingEntryPageModel as AccountingEntryModel
import Pages.AccountingEntryTemplate.AccountingEntryTemplatePage as AccountingEntryTemplate
import Pages.AccountingEntryTemplate.AccountingEntryTemplatePageModel as AccountingEntryTemplateModel
import Pages.Company.CompanyPage as Company
import Pages.Company.CompanyPageModel as CompanyModel
import Pages.StartPage as Start
import Url exposing (Protocol(..), Url)
import Url.Parser as Parser exposing ((</>), (<?>), Parser, s)


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , onUrlChange = ChangedUrl
        , onUrlRequest = ClickedLink
        , subscriptions = \_ -> Sub.none
        , update = update
        , view = \model -> { title = titleFor model, body = [ view model ] }
        }


type alias Model =
    { key : Nav.Key
    , page : Page
    }


titleFor : Model -> String
titleFor model =
    case model.page of
        Start _ ->
            "Accounting"

        Company _ ->
            "Manage Companies"

        Account _ ->
            "Manage Accounts"

        AccountingEntry accountingEntryModel ->
            "Accounting: " ++ String.fromInt accountingEntryModel.accountingYear

        AccountingEntryTemplate _ ->
            "Manage Templates"

        NotFound ->
            "Page not Found"


type Page
    = Start Start.Model
    | Company CompanyModel.Model
    | Account Account.Model
    | AccountingEntry AccountingEntryModel.Model
    | AccountingEntryTemplate AccountingEntryTemplateModel.Model
    | NotFound


type Msg
    = ClickedLink UrlRequest
    | ChangedUrl Url
    | StartMsg Start.Msg
    | AccountMsg Account.Msg
    | CompanyMsg Company.Msg
    | AccountingEntryTemplateMsg AccountingEntryTemplate.Msg
    | AccountingEntryMsg AccountingEntry.Msg


init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    updateUrl url { page = NotFound, key = key }


view : Model -> Html Msg
view model =
    case model.page of
        Start start ->
            Html.map StartMsg (Start.view start)

        Company company ->
            Html.map CompanyMsg (Company.view company)

        Account account ->
            Html.map AccountMsg (Account.view account)

        AccountingEntry accountingEntry ->
            Html.map AccountingEntryMsg (AccountingEntry.view accountingEntry)

        AccountingEntryTemplate accountingEntryTemplate ->
            Html.map AccountingEntryTemplateMsg (AccountingEntryTemplate.view accountingEntryTemplate)

        NotFound ->
            div [] [ text "404 - PAGE NOT FOUND" ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClickedLink urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        ChangedUrl url ->
            updateUrl url model

        StartMsg startMsg ->
            case model.page of
                Start start ->
                    stepStart model (Start.update startMsg start)

                _ ->
                    ( model, Cmd.none )

        CompanyMsg companyMsg ->
            case model.page of
                Company company ->
                    stepCompany model (Company.update companyMsg company)

                _ ->
                    ( model, Cmd.none )

        AccountMsg accountMsg ->
            case model.page of
                Account account ->
                    stepAccount model (Account.update accountMsg account)

                _ ->
                    ( model, Cmd.none )

        AccountingEntryMsg accountingEntryMsg ->
            case model.page of
                AccountingEntry accountingEntry ->
                    stepAccountingEntry model (AccountingEntry.update accountingEntryMsg accountingEntry)

                _ ->
                    ( model, Cmd.none )

        AccountingEntryTemplateMsg accountingEntryTemplateMsg ->
            case model.page of
                AccountingEntryTemplate accountingEntryTemplate ->
                    stepAccountingEntryTemplate model (AccountingEntryTemplate.update accountingEntryTemplateMsg accountingEntryTemplate)

                _ ->
                    ( model, Cmd.none )


stepStart : Model -> ( Start.Model, Cmd Start.Msg ) -> ( Model, Cmd Msg )
stepStart model ( start, cmd ) =
    ( { model | page = Start start }, Cmd.map StartMsg cmd )


stepCompany : Model -> ( CompanyModel.Model, Cmd Company.Msg ) -> ( Model, Cmd Msg )
stepCompany model ( company, cmd ) =
    ( { model | page = Company company }, Cmd.map CompanyMsg cmd )


stepAccount : Model -> ( Account.Model, Cmd Account.Msg ) -> ( Model, Cmd Msg )
stepAccount model ( account, cmd ) =
    ( { model | page = Account account }, Cmd.map AccountMsg cmd )


stepAccountingEntry : Model -> ( AccountingEntryModel.Model, Cmd AccountingEntry.Msg ) -> ( Model, Cmd Msg )
stepAccountingEntry model ( accountingEntry, cmd ) =
    ( { model | page = AccountingEntry accountingEntry }, Cmd.map AccountingEntryMsg cmd )


stepAccountingEntryTemplate : Model -> ( AccountingEntryTemplateModel.Model, Cmd AccountingEntryTemplate.Msg ) -> ( Model, Cmd Msg )
stepAccountingEntryTemplate model ( accountingEntryTemplate, cmd ) =
    ( { model | page = AccountingEntryTemplate accountingEntryTemplate }, Cmd.map AccountingEntryTemplateMsg cmd )


type Route
    = StartRoute
    | CompanyRoute String
    | AccountRoute Int String
    | AccountingEntryRoute Int Int String
    | AccountingEntryTemplateRoute Int String


updateUrl : Url -> Model -> ( Model, Cmd Msg )
updateUrl url model =
    let
        yearFromEntryPage =
            case model.page of
                AccountingEntry accountingEntry ->
                    Just accountingEntry.accountingYear

                _ ->
                    Nothing
    in
    case Parser.parse parser (fragmentToPath url) of
        Just StartRoute ->
            Start.init ()
                |> stepStart model

        Just (CompanyRoute lang) ->
            Company.init { lang = lang }
                |> stepCompany model

        Just (AccountRoute companyId lang) ->
            Account.init { companyId = companyId, accountingYear = yearFromEntryPage, lang = lang }
                |> stepAccount model

        Just (AccountingEntryRoute companyId accountingYear lang) ->
            AccountingEntry.init { companyId = companyId, accountingYear = accountingYear, lang = lang }
                |> stepAccountingEntry model

        Just (AccountingEntryTemplateRoute companyId lang) ->
            AccountingEntryTemplate.init { companyId = companyId, accountingYear = yearFromEntryPage, lang = lang }
                |> stepAccountingEntryTemplate model

        Nothing ->
            ( { model | page = NotFound }, Cmd.none )


parser : Parser (Route -> a) a
parser =
    let
        companyIdParser =
            s "companyId" </> Parser.int

        accountingYearParser =
            s "accountingYear" </> Parser.int

        languageParser =
            s "lang" </> Parser.string
    in
    Parser.oneOf
        [ Parser.map StartRoute Parser.top
        , Parser.map CompanyRoute (s "Company" </> languageParser)
        , Parser.map AccountRoute (companyIdParser </> s "Accounts" </> languageParser)
        , Parser.map AccountingEntryTemplateRoute (companyIdParser </> s "Templates" </> languageParser)
        , Parser.map AccountingEntryRoute (companyIdParser </> s "Accounting" </> accountingYearParser </> languageParser)
        ]


fragmentToPath : Url -> Url
fragmentToPath url =
    { url | path = Maybe.withDefault "" url.fragment, fragment = Nothing }
