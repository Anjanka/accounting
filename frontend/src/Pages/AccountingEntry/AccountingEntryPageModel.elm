module Pages.AccountingEntry.AccountingEntryPageModel exposing (..)

import Api.General.AccountingEntryUtil as AccountingEntryUtil exposing (updateBookingDate)
import Api.General.DateUtil as DateUtil
import Api.General.LanguageComponentConstants exposing (getLanguage)
import Api.Types.Account exposing (Account)
import Api.Types.AccountingEntry exposing (AccountingEntry)
import Api.Types.AccountingEntryTemplate exposing (AccountingEntryTemplate)
import Api.Types.LanguageComponents exposing (LanguageComponents)
import Pages.AccountingEntry.InputContent as InputContent exposing (InputContent, emptyInputContent, updateCreditId, updateDebitId)


type alias Model =
    { lang : LanguageComponents
    , companyId : Int
    , accountingYear : Int
    , content : InputContent
    , accountingEntry : AccountingEntry
    , allAccountingEntries : List AccountingEntry
    , allAccounts : List Account
    , allAccountingEntryTemplates : List AccountingEntryTemplate
    , feedback : String
    , error : String
    , editActive : Bool
    , accountViewActive : Bool
    , selectedTemplate : Maybe String
    , selectedCredit : Maybe String
    , selectedDebit : Maybe String
    }


type alias Flags =
    { companyId : Int
    , accountingYear : Int
    , lang : String
    }


init : Flags -> Model
init flags =
    { lang = getLanguage flags.lang
    , companyId = flags.companyId
    , accountingYear = flags.accountingYear
    , content = emptyInputContent
    , accountingEntry = AccountingEntryUtil.emptyWith { companyId = flags.companyId, accountingYear = flags.accountingYear }
    , allAccountingEntries = []
    , allAccounts = []
    , allAccountingEntryTemplates = []
    , feedback = ""
    , error = ""
    , editActive = False
    , accountViewActive = False
    , selectedTemplate = Nothing
    , selectedCredit = Nothing
    , selectedDebit = Nothing
    }


reset : Model -> Model
reset model =
    { model
        | content = emptyInputContent
        , accountingEntry = AccountingEntryUtil.emptyWith { companyId = model.companyId, accountingYear = model.accountingYear }
        , error = ""
        , editActive = False
        , selectedTemplate = Nothing
        , selectedCredit = Nothing
        , selectedDebit = Nothing
    }


updateContent : Model -> InputContent -> Model
updateContent model content =
    { model | content = content }


updateAccountingEntry : Model -> AccountingEntry -> Model
updateAccountingEntry model accountingEntry =
    { model | accountingEntry = accountingEntry }



updateDebit : Model -> Int -> Model
updateDebit model debitId =
    let
        modelWithUpdatedEntry =
            model.accountingEntry
                |> (\ae -> AccountingEntryUtil.updateDebit ae debitId)
                |> updateAccountingEntry model

        modelWithUpdatedContent =
            modelWithUpdatedEntry.content
                |> (\c -> updateDebitId c (String.fromInt debitId))
                |> updateContent modelWithUpdatedEntry
    in
    modelWithUpdatedContent


updateCredit : Model -> Int -> Model
updateCredit model creditId =
    let
        modelWithUpdatedEntry =
            model.accountingEntry
                |> (\ae -> AccountingEntryUtil.updateCredit ae creditId)
                |> updateAccountingEntry model

        modelWithUpdatedContent =
            modelWithUpdatedEntry.content
                |> (\c -> updateCreditId c (String.fromInt creditId))
                |> updateContent modelWithUpdatedEntry
    in
    modelWithUpdatedContent



updateReceiptNumber : Model -> String -> Model
updateReceiptNumber model newContent =
    let
        modelWithNewEntry =
            model.accountingEntry
                |> (\ae -> AccountingEntryUtil.updateReceiptNumber ae newContent)
                |> updateAccountingEntry model

        modelWithNewContent =
            modelWithNewEntry.content
                |> (\c -> InputContent.updateReceiptNumber c newContent)
                |> updateContent modelWithNewEntry
    in
    modelWithNewContent


updateDescription : Model -> String -> Model
updateDescription model newContent =
    let
        modelWithNewEntry =
            model.accountingEntry
                |> (\ae -> AccountingEntryUtil.updateDescription ae newContent)
                |> updateAccountingEntry model

        modelWithNewContent =
            modelWithNewEntry.content
                |> (\c -> InputContent.updateDescription c newContent)
                |> updateContent modelWithNewEntry
    in
    modelWithNewContent



updateMonth : Model -> { string : String, int : Int } -> Model
updateMonth model month =
    let
        modelWithUpdatedEntry =
            model.accountingEntry.bookingDate
                |> (\d -> DateUtil.updateMonth d month.int)
                |> updateBookingDate model.accountingEntry
                |> updateAccountingEntry model

        modelWithUpdatedContent =
            modelWithUpdatedEntry.content
                |> (\c -> InputContent.updateMonth c month.string)
                |> updateContent modelWithUpdatedEntry
    in
    modelWithUpdatedContent


updateDay : Model -> { string : String, int : Int } -> Model
updateDay model day =
    let
        modelWithUpdatedEntry =
            model.accountingEntry.bookingDate
                |> (\d -> DateUtil.updateDay d day.int)
                |> updateBookingDate model.accountingEntry
                |> updateAccountingEntry model

        modelWithUpdatedContent =
            modelWithUpdatedEntry.content
                |> (\c -> InputContent.updateDay c day.string)
                |> updateContent modelWithUpdatedEntry
    in
    modelWithUpdatedContent