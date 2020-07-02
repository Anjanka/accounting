module Pages.AccountingEntryTemplatePage.ParseAndUpdateUtil exposing (..)

import Api.General.AccountUtil as AccountUtil
import Api.General.AccountingEntryTemplateUtil as AccountingEntryTemplateUtil
import Api.Types.Account exposing (Account)
import List.Extra
import Pages.AccountingEntryTemplatePage.AccountingEntryTemplatePageModel exposing (Model)
updateCredit : Model -> Maybe String -> Model
updateCredit =
    updateWith (\m nsv -> { m | selectedCredit = nsv }) (\m nsv nss id -> { m | contentCreditID = nss, aet = AccountingEntryTemplateUtil.updateCredit m.aet id, selectedCredit = nsv })


updateDebit : Model -> Maybe String -> Model
updateDebit =
    updateWith (\m nsv -> { m | selectedDebit = nsv }) (\m nsv nss id -> { m | contentDebitID = nss, aet = AccountingEntryTemplateUtil.updateDebit m.aet id, selectedDebit = nsv })


updateWith : (Model -> Maybe String -> Model) -> (Model -> Maybe String -> String -> Int -> Model) -> Model -> Maybe String -> Model
updateWith nothing just model newSelectedValue =
    case newSelectedValue of
        Just newSelectedString ->
            let
                id =
                    String.toInt newSelectedString
            in
            case id of
                Just int ->
                    just model newSelectedValue newSelectedString int

                Nothing ->
                    nothing model newSelectedValue

        Nothing ->
            nothing model newSelectedValue


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
parseAndUpdateAmount model newContent =
    if String.isEmpty newContent then
        { model | contentAmount = "", aet = AccountingEntryTemplateUtil.updateCompleteAmount model.aet 0 0 }

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
                                                    { model | contentAmount = String.concat [ String.fromInt whole, ",", String.fromInt change ], aet = AccountingEntryTemplateUtil.updateAmountWhole (AccountingEntryTemplateUtil.updateAmountChange model.aet (change * 10)) whole }

                                                else if change < 10 && String.length changeString >= 2 then
                                                    { model | contentAmount = String.concat [ String.fromInt whole, ",0", String.fromInt change ], aet = AccountingEntryTemplateUtil.updateAmountWhole (AccountingEntryTemplateUtil.updateAmountChange model.aet change) whole }

                                                else
                                                    { model | contentAmount = String.concat [ String.fromInt whole, ",", String.fromInt change ], aet = AccountingEntryTemplateUtil.updateAmountWhole (AccountingEntryTemplateUtil.updateAmountChange model.aet change) whole }

                                            Nothing ->
                                                { model | contentAmount = String.concat [ String.fromInt whole, "," ], aet = AccountingEntryTemplateUtil.updateCompleteAmount model.aet whole 0 }

                                    Nothing ->
                                        { model | contentAmount = newContent, aet = AccountingEntryTemplateUtil.updateCompleteAmount model.aet whole 0 }

                            Nothing ->
                                { model | contentAmount = newContent, aet = AccountingEntryTemplateUtil.updateCompleteAmount model.aet whole 0 }

                    Nothing ->
                        model

            Nothing ->
                model

