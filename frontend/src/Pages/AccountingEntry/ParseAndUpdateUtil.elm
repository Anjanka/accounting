module Pages.AccountingEntry.ParseAndUpdateUtil exposing (..)

import Api.General.AccountUtil as AccountUtil
import Api.General.AccountingEntryUtil as AccountingEntryUtil exposing (updateBookingDate)
import Api.General.DateUtil as DateUtil
import Api.Types.Account exposing (Account)
import List.Extra
import Pages.AccountingEntry.AccountingEntryPageModel exposing (Model, updateAccountingEntry, updateContent)
import Pages.AccountingEntry.InputContent as InputContent exposing (updateAmount, updateCreditId, updateDebitId)


updateDay : Model -> Int -> Model
updateDay model day =
    let
        dayString =
            if day == -1 then
                ""

            else
                DateUtil.showDay day

        modelWithUpdatedEntry =
            model.accountingEntry.bookingDate
                |> (\d -> DateUtil.updateDay d day)
                |> updateBookingDate model.accountingEntry
                |> updateAccountingEntry model

        modelWithUpdatedContent =
            modelWithUpdatedEntry.content
                |> (\c -> InputContent.updateDay c dayString)
                |> updateContent modelWithUpdatedEntry
    in
    modelWithUpdatedContent


updateMonth : Model -> Int -> Model
updateMonth model month =
    let
        monthString =
            if month == -1 then
                ""

            else
                DateUtil.showMonth month

        modelWithUpdatedEntry =
            model.accountingEntry.bookingDate
                |> (\d -> DateUtil.updateMonth d month)
                |> updateBookingDate model.accountingEntry
                |> updateAccountingEntry model

        modelWithUpdatedContent =
            modelWithUpdatedEntry.content
                |> (\c -> InputContent.updateMonth c monthString)
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


parseAndUpdateCredit : Model -> String -> Model
parseAndUpdateCredit =
    parseWith (\m nc -> { m | content = updateCreditId m.content nc, accountingEntry = AccountingEntryUtil.updateCredit m.accountingEntry 0, selectedCredit = Nothing }) (\m nc acc -> { m | content = updateCreditId m.content nc, accountingEntry = AccountingEntryUtil.updateCredit m.accountingEntry acc.id, selectedCredit = Just nc })


parseAndUpdateDebit : Model -> String -> Model
parseAndUpdateDebit =
    parseWith (\m nc -> { m | content = updateDebitId m.content nc, accountingEntry = AccountingEntryUtil.updateDebit m.accountingEntry 0, selectedDebit = Nothing }) (\m nc acc -> { m | content = updateDebitId m.content nc, accountingEntry = AccountingEntryUtil.updateDebit m.accountingEntry acc.id, selectedDebit = Just nc })


parseWith : (Model -> String -> Model) -> (Model -> String -> Account -> Model) -> Model -> String -> Model
parseWith empty nonEmpty model newContent =
    let
        account =
            findAccountName model.allAccounts newContent
    in
    if String.isEmpty account.title then
        empty model newContent

    else
        nonEmpty model newContent account


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


findAccountName : List Account -> String -> Account
findAccountName accounts id =
    case String.toInt id of
        Just int ->
            case List.Extra.find (\acc -> acc.id == int) accounts of
                Just value ->
                    value

                Nothing ->
                    AccountUtil.empty

        Nothing ->
            AccountUtil.empty


parseAndUpdateAmount : Model -> String -> Model
parseAndUpdateAmount model newContent =
    if String.isEmpty newContent then
        { model
            | content = updateAmount model.content ""
            , accountingEntry = AccountingEntryUtil.updateCompleteAmount model.accountingEntry 0 0
        }

    else
        let
            wholeAndChange =
                String.split "," newContent
        in
        case List.head wholeAndChange of
            Just wholeString ->
                case String.toInt wholeString of
                    Just whole ->
                        case List.tail wholeAndChange of
                            Just tailList ->
                                case List.head tailList of
                                    Just changeString ->
                                        case String.toInt (String.left 2 changeString) of
                                            Just change ->
                                                if change < 10 && String.length changeString == 1 then
                                                    { model
                                                        | content = updateAmount model.content (String.concat [ String.fromInt whole, ",", String.fromInt change ])
                                                        , accountingEntry = AccountingEntryUtil.updateAmountWhole (AccountingEntryUtil.updateAmountChange model.accountingEntry (change * 10)) whole
                                                    }

                                                else if change < 10 && String.length changeString >= 2 then
                                                    { model
                                                        | content = updateAmount model.content (String.concat [ String.fromInt whole, ",0", String.fromInt change ])
                                                        , accountingEntry = AccountingEntryUtil.updateAmountWhole (AccountingEntryUtil.updateAmountChange model.accountingEntry change) whole
                                                    }

                                                else
                                                    { model
                                                        | content = updateAmount model.content (String.concat [ String.fromInt whole, ",", String.fromInt change ])
                                                        , accountingEntry = AccountingEntryUtil.updateAmountWhole (AccountingEntryUtil.updateAmountChange model.accountingEntry change) whole
                                                    }

                                            Nothing ->
                                                { model
                                                    | content = updateAmount model.content (String.concat [ String.fromInt whole, "," ])
                                                    , accountingEntry = AccountingEntryUtil.updateCompleteAmount model.accountingEntry whole 0
                                                }

                                    Nothing ->
                                        { model | content = updateAmount model.content newContent, accountingEntry = AccountingEntryUtil.updateCompleteAmount model.accountingEntry whole 0 }

                            Nothing ->
                                { model | content = updateAmount model.content newContent, accountingEntry = AccountingEntryUtil.updateCompleteAmount model.accountingEntry whole 0 }

                    Nothing ->
                        model

            Nothing ->
                model


parseDay : Model -> String -> Model
parseDay model newDay =
    if String.isEmpty newDay then
        updateDay model -1

    else
        case String.toInt newDay of
            Just dayCandidate ->
                if validDate dayCandidate model.accountingEntry.bookingDate.month model.accountingYear then
                    updateDay model dayCandidate

                else
                    model

            Nothing ->
                model


parseMonth : Model -> String -> Model
parseMonth model newMonth =
    if String.isEmpty newMonth then
        updateMonth model -1

    else
        case String.toInt newMonth of
            Just monthCandidate ->
                if validDate  model.accountingEntry.bookingDate.day monthCandidate model.accountingYear then
                    updateMonth model monthCandidate

                else
                    model

            Nothing ->
                model


validDate : Int -> Int -> Int -> Bool
validDate dayCandidate monthCandidate year =
    (List.member monthCandidate [ 0, 1, 3, 5, 7, 8, 10, 12 ] && dayCandidate >= 0 && dayCandidate <= 31)
        || (List.member monthCandidate [ 4, 6, 9, 11 ] && dayCandidate >= 0 && dayCandidate <= 30)
        || (dayCandidate <= 28 && monthCandidate >= 1 && monthCandidate <= 12)
        || (monthCandidate == 2 && isLeap year && dayCandidate == 29)


isLeap : Int -> Bool
isLeap year =
    if modBy 4 year == 0 then
        True

    else
        False
