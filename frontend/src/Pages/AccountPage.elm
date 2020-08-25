module Pages.AccountPage exposing (Model, Msg, init, update, view)

import Api.General.AccountTypeConstants exposing (getCategoryIdsWithDefault)
import Api.General.AccountUtil as AccountUtil exposing (AccountType, AccountCategory, updateAccountType, updateCategory)
import Api.General.HttpUtil as HttpUtil
import Api.General.LanguageComponentConstants exposing (getLanguage)
import Api.Types.Account exposing (Account, decoderAccount, encoderAccount)
import Api.Types.AccountKey exposing (encoderAccountKey)
import Api.Types.LanguageComponents exposing (LanguageComponents)
import Browser
import Browser.Dom as Dom
import Dropdown exposing (Item)
import Html exposing (Attribute, Html, button, div, input, label, p, table, td, text, th, tr)
import Html.Attributes exposing (class, disabled, for, id, placeholder, style, value)
import Html.Events exposing (onClick, onInput)
import Http exposing (Error)
import Json.Decode as Decode
import List.Extra
import Pages.SharedViewComponents exposing (backToEntryPage)
import Task



-- MAIN


main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { lang : LanguageComponents
    , companyId : Int
    , accountingYear : Maybe Int
    , contentId : String
    , account : Account
    , allAccounts : List Account
    , error : String
    , validationFeedback : String
    , buttonPressed : Bool
    , editViewActive : Bool
    , selectedCategory : Maybe String
    , selectedAccountType : Maybe String
    }



--defaultFlags : Flags
--defaultFlags =
--    { companyId = 1,
--    accountingYear = Just 1}
--
--
--dummyInit : () -> ( Model, Cmd Msg )
--dummyInit _ =
--    init defaultFlags
-- MODEL


type alias Flags =
    { companyId : Int
    , accountingYear : Maybe Int
    , lang : String
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { lang = getLanguage flags.lang
      , companyId = flags.companyId
      , accountingYear = flags.accountingYear
      , contentId = ""
      , account = AccountUtil.updateCompanyID AccountUtil.empty flags.companyId
      , allAccounts = []
      , error = ""
      , validationFeedback = ""
      , buttonPressed = False
      , editViewActive = False
      , selectedCategory = Nothing
      , selectedAccountType = Nothing
      }
    , getAccounts flags.companyId
    )



-- UPDATE


type Msg
    = ShowAllAccounts
    | HideAllAccounts
    | GotResponseForAllAccounts (Result Error (List Account))
    | GotResponseCreateOrReplace (Result Error Account)
    | GotResponseDelete (Result Error ())
    | ChangeID String
    | ChangeName String
    | DropdownCategoryChanged (Maybe String)
    | DropdownAccountTypeChanged (Maybe String)
    | ReplaceAccount
    | CreateAccount
    | DeleteAccount
    | ActivateEditView Account
    | DeactivateEditView
    | BackToAccountingEntryPage
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ShowAllAccounts ->
            ( { model | buttonPressed = True }, getAccounts model.companyId )

        HideAllAccounts ->
            ( { model | buttonPressed = False }, Cmd.none )

        GotResponseForAllAccounts result ->
            case result of
                Ok value ->
                    ( { model
                        | allAccounts = List.sortBy .id value
                        , error = ""
                        , validationFeedback = model.lang.accountValidationMessageErr
                      }
                    , Cmd.none
                    )

                Err error ->
                    ( { model | error = HttpUtil.errorToString error, validationFeedback = model.lang.accountValidationMessageErr }, Cmd.none )

        GotResponseCreateOrReplace result ->
            case result of
                Ok _ ->
                    ( reset model, getAccounts model.companyId )

                Err error ->
                    ( { model | error = HttpUtil.errorToString error }, Cmd.none )

        GotResponseDelete result ->
            case result of
                Ok _ ->
                    ( reset model, getAccounts model.companyId )

                Err error ->
                    ( { model | error = HttpUtil.errorToString error }, Cmd.none )

        ChangeID newContent ->
            ( parseAndUpdateAccount model newContent, Cmd.none )

        ChangeName newContent ->
            let
                newModel =
                    model.account
                        |> (\acc -> AccountUtil.updateTitle acc newContent)
                        |> updateAccount model
            in
            ( newModel, Cmd.none )

        DropdownCategoryChanged selectedValue ->
            let
                newModel =
                    model.account
                        |> (\acc -> handleCategorySelection acc selectedValue)
                        |> updateAccount model
            in
            ( updateSelectedCategory newModel selectedValue, Cmd.none )

        DropdownAccountTypeChanged selectedValue ->
            let
                newModel =
                    model.account
                        |> (\acc -> handleAccountTypeSelection acc selectedValue)
                        |> updateAccount model
            in
            ( updateSelectedAccountType newModel selectedValue, Cmd.none )

        ReplaceAccount ->
            ( model, replaceAccount model.account )

        CreateAccount ->
            ( model, createAccount model.account )

        DeleteAccount ->
            ( model, deleteAccount model.account )

        ActivateEditView account ->
            ( updateForEdit model account, resetViewport )

        DeactivateEditView ->
            ( reset model, Cmd.none )

        BackToAccountingEntryPage ->
            ( model, Cmd.none )

        NoOp ->
            ( model, Cmd.none )




-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "page", class "accountInputArea" ]
        [ backToEntryPage model.lang.back model.companyId model.accountingYear model.lang.short
        , p [] []
        , viewEditOrCreate model
        , label [] [ text (AccountUtil.show model.account) ]
        , p [] []
        , viewAccountList model
        , p [] []
        , div [] [ text model.error ]
        ]


viewEditOrCreate : Model -> Html Msg
viewEditOrCreate model =
    if model.editViewActive then
        div []
            [ label [] [ text (model.contentId ++ " - ") ]
            , input [ placeholder model.lang.accountId, value model.account.title, onInput ChangeName ] []
            , viewDropdowns model
            , div []
                [ button
                    [ class "saveButton"
                    , onClick ReplaceAccount
                    ]
                    [ text model.lang.saveChanges ]
                , button [ class "deleteButton", onClick DeleteAccount ] [ text model.lang.delete ]
                , button [ class "cancelButton", onClick DeactivateEditView ] [ text model.lang.cancel ]
                ]
            ]

    else
        div []
            [ input [ class "accountIdField", placeholder model.lang.accountId, value model.contentId, onInput ChangeID ] []
            , input [ placeholder model.lang.accountName, value model.account.title, onInput ChangeName ] []
            , viewDropdowns model
            , viewCreateButton model
            , viewValidation model.lang.accountValidationMessageOk model.validationFeedback
            ]


viewDropdowns : Model -> Html Msg
viewDropdowns model =
    div []
        [ Dropdown.dropdown
            (dropdownOptionsAccountCategory model.lang.pleaseSelectCategory model.lang.accountCategories)
            []
            model.selectedCategory
        , Dropdown.dropdown
            (dropdownOptionsAccountType model.lang.pleaseSelectAccountType (getSelectableTypes model.selectedCategory model.lang.accountTypes))
            []
            model.selectedAccountType
        ]


viewValidation : String -> String -> Html Msg
viewValidation txt error =
    if String.isEmpty error then
        div [ style "color" "green" ] [ text txt ]

    else
        div [ style "color" "red" ] [ text error ]


viewCreateButton : Model -> Html Msg
viewCreateButton model =
    if not (String.isEmpty model.validationFeedback) || String.isEmpty model.account.title then
        button [ class "saveButton", disabled True, onClick CreateAccount ] [ text model.lang.create ]

    else
        button [ class "saveButton", disabled False, onClick CreateAccount ] [ text model.lang.create ]


viewAccountList : Model -> Html Msg
viewAccountList model =
    if model.buttonPressed then
        div []
            [ div [] [ button [ class "showButton", onClick HideAllAccounts ] [ text model.lang.hideAccountList ] ]
            , div [ id "allAccounts" ]
                [ table
                    []
                    (tr [ class "tableHeader" ]
                        [ th [] [ label [ for "id" ] [ text model.lang.id ] ]
                        , th [] [ label [ for "name" ] [ text model.lang.name ] ]
                        ]
                        :: List.map (mkTableLine model.lang.edit) model.allAccounts
                    )
                ]
            ]

    else
        div [] [ button [ class "showButton", onClick ShowAllAccounts ] [ text model.lang.manageAccounts ] ]


mkTableLine : String -> Account -> Html Msg
mkTableLine txt account =
    tr []
        [ td [ class "numberColumn" ] [ text (String.fromInt account.id) ]
        , td [ class "textColumn" ] [ text account.title ]
        , td [ class "buttonColumn" ] [ button [ class "editButton", onClick (ActivateEditView account) ] [ text txt ] ]
        ]


dropdownOptionsAccountCategory : String -> List AccountCategory -> Dropdown.Options Msg
dropdownOptionsAccountCategory text allCategories =
    let
        defaultOptions =
            Dropdown.defaultOptions DropdownCategoryChanged
    in
    { defaultOptions
        | items =
            List.map (\cat -> categoryForDropdown cat) (List.sortBy (\c -> c.name) allCategories)
        , emptyItem = Just { value = "e", text = text, enabled = True }
    }


categoryForDropdown : AccountCategory -> Item
categoryForDropdown cat =
    { value = String.fromInt cat.id, text = cat.name, enabled = True }


dropdownOptionsAccountType : String -> List AccountType -> Dropdown.Options Msg
dropdownOptionsAccountType text selectableTypes =
    let
        defaultOptions =
            Dropdown.defaultOptions DropdownAccountTypeChanged
    in
    { defaultOptions
        | items =
            List.map (\at -> { value = String.fromInt at.id, text = at.name, enabled = not (List.isEmpty selectableTypes) }) selectableTypes
        , emptyItem = Just { value = "e", text = text, enabled = True }
    }


getSelectableTypes : Maybe String -> List AccountType -> List AccountType
getSelectableTypes selectedCategory allTypes =
    selectedCategory
        |> Maybe.andThen String.toInt
        |> Maybe.map (\id -> List.sortBy (\a -> a.name) (List.filter (\at -> List.member id (getCategoryIdsWithDefault at.id)) allTypes))
        |> Maybe.withDefault []


resetViewport : Cmd Msg
resetViewport =
    Task.perform (\_ -> NoOp) (Dom.setViewport 0 0)

-- COMMUNICATION


getAccounts : Int -> Cmd Msg
getAccounts companyId =
    Http.get
        { url = "http://localhost:9000/account/getAll/" ++ String.fromInt companyId
        , expect = HttpUtil.expectJson GotResponseForAllAccounts (Decode.list decoderAccount)
        }


replaceAccount : Account -> Cmd Msg
replaceAccount account =
    Http.post
        { url = "http://localhost:9000/account/replace"
        , expect = HttpUtil.expectJson GotResponseCreateOrReplace decoderAccount
        , body = Http.jsonBody (encoderAccount account)
        }


createAccount : Account -> Cmd Msg
createAccount account =
    Http.post
        { url = "http://localhost:9000/account/insert"
        , expect = HttpUtil.expectJson GotResponseCreateOrReplace decoderAccount
        , body = Http.jsonBody (encoderAccount account)
        }


deleteAccount : Account -> Cmd Msg
deleteAccount account =
    Http.post
        { url = "http://localhost:9000/account/delete "
        , expect = HttpUtil.expectWhatever GotResponseDelete
        , body = Http.jsonBody (encoderAccountKey { id = account.id, companyId = account.companyId })
        }



-- UTILITIES


parseAndUpdateAccount : Model -> String -> Model
parseAndUpdateAccount model idCandidate =
    let
        idNotValid =
            model.lang.accountValidationMessageErr

        existingAccount =
            model.lang.accountValidationMessageExisting
    in
    if not (String.isEmpty idCandidate) then
        case String.toInt idCandidate of
            Just int ->
                let
                    accountExist =
                        not (AccountUtil.isEmpty (findAccount int model.allAccounts))
                in
                if int >= 100 && int <= 99999 && not accountExist then
                    { model | contentId = idCandidate, account = AccountUtil.updateId model.account int, validationFeedback = "" }

                else if int >= 100 && int <= 99999 && accountExist then
                    { model | contentId = idCandidate, account = AccountUtil.updateId model.account 0, validationFeedback = existingAccount }

                else if int > 99999 || String.length idCandidate > 5 then
                    model

                else
                    { model | contentId = idCandidate, account = AccountUtil.updateId model.account 0, validationFeedback = idNotValid }

            Nothing ->
                model

    else
        { model | contentId = "", account = AccountUtil.updateId model.account 0, validationFeedback = idNotValid }


findAccount : Int -> List Account -> Account
findAccount id allAccounts =
    case List.Extra.find (\account -> account.id == id) allAccounts of
        Just value ->
            value

        Nothing ->
            AccountUtil.empty


updateAccount : Model -> Account -> Model
updateAccount model account =
    { model | account = account }


updateSelectedCategory : Model -> Maybe String -> Model
updateSelectedCategory model selectedCategory =
    { model | selectedCategory = selectedCategory }


updateSelectedAccountType : Model -> Maybe String -> Model
updateSelectedAccountType model selectedType =
    { model | selectedAccountType = selectedType }


reset : Model -> Model
reset model =
    { model
        | contentId = ""
        , account = AccountUtil.updateCompanyID AccountUtil.empty model.companyId
        , error = ""
        , validationFeedback = model.lang.accountValidationMessageErr
        , editViewActive = False
        , selectedCategory = Nothing
        , selectedAccountType = Nothing
    }


updateForEdit : Model -> Account -> Model
updateForEdit model account =
    { model
        | contentId = String.fromInt account.id
        , account = account
        , selectedCategory = Just (String.fromInt account.category)
        , selectedAccountType = Just (String.fromInt account.accountType)
        , editViewActive = True
    }


handleCategorySelection : Account -> Maybe String -> Account
handleCategorySelection account selectedCategory =
    selectedCategory
       |> Maybe.andThen String.toInt
       |> Maybe.map (\c -> updateCategory account c)
       |> Maybe.withDefault account


handleAccountTypeSelection : Account -> Maybe String -> Account
handleAccountTypeSelection account selectedType =
    selectedType
       |> Maybe.andThen String.toInt
       |> Maybe.map (\v -> updateAccountType account  v)
       |> Maybe.withDefault account

