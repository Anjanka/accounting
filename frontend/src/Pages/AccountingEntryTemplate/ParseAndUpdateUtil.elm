module Pages.AccountingEntryTemplate.ParseAndUpdateUtil exposing (..)

import Api.General.AccountUtil as AccountUtil
import Api.General.AccountingEntryTemplateUtil as AccountingEntryTemplateUtil
import Api.Types.Account exposing (Account)
import List.Extra
import Pages.AccountingEntryTemplate.AccountingEntryTemplatePageModel exposing (Model, updateAccountingEntryTemplate, updateContentAmount)
import Pages.FromInput as FromInput


handleSelection : (Model -> Int -> Model) -> Model -> Maybe String -> Model
handleSelection updateFunction model selectedValue =
    selectedValue
        |> Maybe.andThen String.toInt
        |> Maybe.map (\id -> updateFunction model id)
        |> Maybe.withDefault model


updateCredit : Model -> Int -> Model
updateCredit model id =
    { model | contentCreditID = String.fromInt id, aet = AccountingEntryTemplateUtil.updateCredit model.aet id }


updateDebit : Model -> Int -> Model
updateDebit model id =
    { model | contentDebitID = String.fromInt id, aet = AccountingEntryTemplateUtil.updateDebit model.aet id }


parseAndUpdateCredit : Model -> String -> Model
parseAndUpdateCredit =
    parseWith (\m nc -> { m | contentCreditID = nc, aet = AccountingEntryTemplateUtil.updateCredit m.aet 0, selectedCredit = Nothing }) (\m nc acc -> { m | contentCreditID = nc, aet = AccountingEntryTemplateUtil.updateCredit m.aet acc.id, selectedCredit = Just nc })


parseAndUpdateDebit : Model -> String -> Model
parseAndUpdateDebit =
    parseWith (\m nc -> { m | contentDebitID = nc, aet = AccountingEntryTemplateUtil.updateDebit m.aet 0, selectedDebit = Nothing }) (\m nc acc -> { m | contentDebitID = nc, aet = AccountingEntryTemplateUtil.updateDebit m.aet acc.id, selectedDebit = Just nc })


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
parseAndUpdateAmount model amountContent =
    FromInput.lift updateContentAmount model.contentAmount amountContent model
        |> (\md ->
                updateAccountingEntryTemplate md
                    (model.aet
                        |> (\aet -> AccountingEntryTemplateUtil.updateCompleteAmount aet md.contentAmount.value)
                    )
           )


