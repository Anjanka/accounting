module Pages.AccountingEntry.HelperUtil exposing (..)

import Api.General.AccountingEntryTemplateUtil as AccountingEntryTemplateUtil
import Api.General.AccountingEntryUtil as AccountingEntryUtil
import Api.Types.AccountingEntry exposing (AccountingEntry)
import Api.Types.AccountingEntryTemplate exposing (AccountingEntryTemplate)
import Bytes exposing (Bytes)
import File.Download as Download
import Http exposing (Error(..), Response(..))
import List.Extra
import Pages.AccountingEntry.AccountingEntryPageModel exposing (Model, updateAccountingEntry, updateContent)
import Pages.AccountingEntry.InputContent exposing (emptyInputContent, updateWithEntry, updateWithTemplate)
import Pages.Amount exposing (Amount)


insertForEdit : Model -> AccountingEntry -> Model
insertForEdit model accountingEntry =
    let
        newModel =
            model.content
                |> (\c -> updateWithEntry c accountingEntry)
                |> updateContent model
    in
    { newModel
        | accountingEntry = accountingEntry
        , editActive = True
        , selectedTemplate = Nothing
        , selectedCredit = Just (String.fromInt accountingEntry.credit)
        , selectedDebit = Just (String.fromInt accountingEntry.debit)
    }


handleSelection : (Model -> String -> Model) -> Model -> Maybe String -> Model
handleSelection updateFunction model newSelection =
    case newSelection of
        Just selection ->
            updateFunction model selection

        Nothing ->
            model


handleAccountSelection : (Model -> Int -> Model) -> Model -> Maybe String -> Model
handleAccountSelection updateFunction model newSelection =
    newSelection
        |> Maybe.andThen String.toInt
        |> Maybe.map (\id -> updateFunction model id)
        |> Maybe.withDefault model


insertTemplateData : Model -> String -> Model
insertTemplateData model description =
    let
        selectedTemplate =
            findEntry description model.allAccountingEntryTemplates

        modelWithNewEntry =
            model.accountingEntry
                |> (\ae -> AccountingEntryUtil.updateWithTemplate ae selectedTemplate)
                |> updateAccountingEntry model

        modelWithNewContent =
            modelWithNewEntry.content
                |> (\c -> updateWithTemplate c selectedTemplate)
                |> updateContent modelWithNewEntry
    in
    { modelWithNewContent
        | selectedCredit = Just (String.fromInt selectedTemplate.credit)
        , selectedDebit = Just (String.fromInt selectedTemplate.debit)
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


findEntry : String -> List AccountingEntryTemplate -> AccountingEntryTemplate
findEntry description allAccountingEntryTemplates =
    case List.Extra.find (\aet -> aet.description == description) allAccountingEntryTemplates of
        Just value ->
            value

        Nothing ->
            AccountingEntryTemplateUtil.empty


getBalance : String -> String -> List AccountingEntry -> String
getBalance text accountIdCandidate allEntries =
    case String.toInt accountIdCandidate of
        Just accountId ->
            text ++ ": " ++ showBalance (getAmount accountId allEntries)

        Nothing ->
            ""


getAmount : Int -> List AccountingEntry -> Int
getAmount accountId allEntries =
    let
        allEntriesCredit =
            List.filter (\entry -> entry.credit == accountId) allEntries

        allEntriesDebit =
            List.filter (\entry -> entry.debit == accountId) allEntries

        sumOf : List AccountingEntry -> Int
        sumOf entries =
            List.sum (List.map (amountOf >> toCents) entries)
    in
     abs (sumOf allEntriesCredit - sumOf allEntriesDebit)



amountOf : AccountingEntry -> Amount
amountOf entry =
    { whole = entry.amountWhole
    , change = entry.amountChange
    }


toCents : Amount -> Int
toCents amount =
    amount.whole * 100 + amount.change


showBalance : Int -> String
showBalance amount =
    let
        amountString =
            String.fromInt amount
    in
    if amount >= 100 || amount <= -100 then
        String.dropRight 2 amountString ++ "," ++ String.right 2 amountString

    else if amount < 100 && amount > 9 then
        "0," ++ amountString

    else if amount > -100 && amount < -9 then
        "-0," ++ amountString

    else if amount < 10 && amount > 0 then
        "0,0" ++ amountString

    else if amount > -10 && amount < 0 then
        "-0,0" ++ String.right 1 amountString

    else
        "0"


unicodeToString : Int -> String
unicodeToString symbol =
    String.fromChar (Char.fromCode symbol)


type alias EntryWithListPosition =
    { position : Position, index : Int, accountingEntry : AccountingEntry }


type Position
    = OnlyOne
    | First
    | Middle
    | Last


getListWithPosition : List AccountingEntry -> List EntryWithListPosition
getListWithPosition allAccountingEntries =
    if List.length allAccountingEntries <= 1 then
        List.map (\ae -> { position = OnlyOne, index = 1, accountingEntry = ae }) allAccountingEntries

    else
        List.indexedMap
            (\i ae ->
                let
                    pos =
                        if i == 0 then
                            First

                        else if i == List.length allAccountingEntries - 1 then
                            Last

                        else
                            Middle
                in
                { position = pos, index = i + 1, accountingEntry = ae }
            )
            allAccountingEntries

resolve : (body -> Result String a) -> Http.Response body -> Result Http.Error a
resolve toResult response =
    case response of
        BadUrl_ url ->
            Err (BadUrl url)

        Timeout_ ->
            Err Timeout

        NetworkError_ ->
            Err NetworkError

        BadStatus_ metadata _ ->
            Err (BadStatus metadata.statusCode)

        GoodStatus_ _ body ->
            Result.mapError BadBody (toResult body)


downloadReport : String -> Int -> Bytes -> Cmd msg
downloadReport name accountingYear pdfContent =
    Download.bytes (String.concat [name, " ", String.fromInt accountingYear, ".pdf"]) "application/pdf" pdfContent

