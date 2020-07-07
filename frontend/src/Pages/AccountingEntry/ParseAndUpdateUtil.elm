module Pages.AccountingEntry.ParseAndUpdateUtil exposing (..)


import Api.General.AccountUtil as AccountUtil
import Api.General.AccountingEntryUtil as AccountingEntryUtil
import Api.General.DateUtil as DateUtil
import Api.Types.Account exposing (Account)
import List.Extra
import Pages.AccountingEntry.AccountingEntryPageModel exposing (Model)





parseAndUpdateCredit : Model -> String -> Model
parseAndUpdateCredit =
    parseWith (\m nc -> { m | contentCreditID = nc, accountingEntry = AccountingEntryUtil.updateCredit m.accountingEntry 0, selectedCredit = Nothing }) (\m nc acc -> { m | contentCreditID = nc, accountingEntry = AccountingEntryUtil.updateCredit m.accountingEntry acc.id, selectedCredit = Just nc })


parseAndUpdateDebit : Model -> String -> Model
parseAndUpdateDebit =
    parseWith (\m nc -> { m | contentDebitID = nc, accountingEntry = AccountingEntryUtil.updateDebit m.accountingEntry 0, selectedDebit = Nothing }) (\m nc acc -> { m | contentDebitID = nc, accountingEntry = AccountingEntryUtil.updateDebit m.accountingEntry acc.id, selectedDebit = Just nc })


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


updateCredit : Model -> String -> Model
updateCredit =
    updateWith (\m  -> m ) (\m nsv id -> { m | contentCreditID = nsv, accountingEntry = AccountingEntryUtil.updateCredit m.accountingEntry id})


updateDebit : Model -> String -> Model
updateDebit =
    updateWith (\m -> m) (\m nsv id -> { m | contentDebitID = nsv, accountingEntry = AccountingEntryUtil.updateDebit m.accountingEntry id })


updateWith : (Model -> Model) -> (Model -> String -> Int -> Model) -> Model -> String -> Model
updateWith nothing just model newSelectedValue =

            let
                id =
                    String.toInt newSelectedValue
            in
            case id of
                Just int ->
                    just model newSelectedValue int
                Nothing ->
                    nothing model



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
        { model | contentAmount = "", accountingEntry = AccountingEntryUtil.updateCompleteAmount model.accountingEntry 0 0 }

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
                                                    { model | contentAmount = String.concat [ String.fromInt whole, ",", String.fromInt change ], accountingEntry = AccountingEntryUtil.updateAmountWhole (AccountingEntryUtil.updateAmountChange model.accountingEntry (change * 10)) whole }

                                                else if change < 10 && String.length changeString >= 2 then
                                                    { model | contentAmount = String.concat [ String.fromInt whole, ",0", String.fromInt change ], accountingEntry = AccountingEntryUtil.updateAmountWhole (AccountingEntryUtil.updateAmountChange model.accountingEntry change) whole }

                                                else
                                                    { model | contentAmount = String.concat [ String.fromInt whole, ",", String.fromInt change ], accountingEntry = AccountingEntryUtil.updateAmountWhole (AccountingEntryUtil.updateAmountChange model.accountingEntry change) whole }

                                            Nothing ->
                                                { model | contentAmount = String.concat [ String.fromInt whole, "," ], accountingEntry = AccountingEntryUtil.updateCompleteAmount model.accountingEntry whole 0 }

                                    Nothing ->
                                        { model | contentAmount = newContent, accountingEntry = AccountingEntryUtil.updateCompleteAmount model.accountingEntry whole 0 }

                            Nothing ->
                                { model | contentAmount = newContent, accountingEntry = AccountingEntryUtil.updateCompleteAmount model.accountingEntry whole 0 }

                    Nothing ->
                        model

            Nothing ->
                model


parseDate : Model -> String -> Model
parseDate model newContent =
    if String.isEmpty newContent then
        { model | contentBookingDate = "" }

    else
        let
            dayAndMonth =
                String.split "." newContent
        in
        case List.head dayAndMonth of
            Just dayString ->
                case toValidDay dayString of
                    Just day ->
                        if String.length dayString == 2 && day /= 0 then
                            case List.tail dayAndMonth of
                                Just tailList ->
                                    case List.head tailList of
                                        Just monthString ->
                                            case toValidMonth monthString day model.accountingYear of
                                                Just month ->
                                                    { model
                                                        | contentBookingDate = DateUtil.showDay day ++ "." ++ DateUtil.showMonth month
                                                        , accountingEntry = AccountingEntryUtil.updateBookingDate model.accountingEntry { day = day, month = month, year = model.accountingYear }
                                                    }

                                                Nothing ->
                                                    { model
                                                        | contentBookingDate = DateUtil.showDay day ++ "."
                                                        , accountingEntry = AccountingEntryUtil.updateBookingDate model.accountingEntry { day = day, month = 0, year = model.accountingYear }
                                                    }

                                        Nothing ->
                                            { model
                                                | contentBookingDate = DateUtil.showDay day ++ "."
                                                , accountingEntry = AccountingEntryUtil.updateBookingDate model.accountingEntry { day = day, month = 0, year = model.accountingYear }
                                            }

                                Nothing ->
                                    { model
                                        | contentBookingDate = DateUtil.showDay day
                                        , accountingEntry = AccountingEntryUtil.updateBookingDate model.accountingEntry { day = day, month = 0, year = model.accountingYear }
                                    }

                        else
                            { model
                                | contentBookingDate = DateUtil.showDay day
                                , accountingEntry = AccountingEntryUtil.updateBookingDate model.accountingEntry { day = day, month = 0, year = model.accountingYear }
                            }

                    Nothing ->
                        model

            Nothing ->
                model


toValidDay : String -> Maybe Int
toValidDay dayCandidateString =
    case String.toInt dayCandidateString of
        Just dayCandidateInt ->
            if dayCandidateInt == 0 && String.length dayCandidateString <= 2 then
                Just 0

            else if 1 <= dayCandidateInt && dayCandidateInt <= 31 then
                Just dayCandidateInt

            else
                Nothing

        Nothing ->
            Nothing


toValidMonth : String -> Int -> Int -> Maybe Int
toValidMonth monthCandidateString day year =
    case String.toInt monthCandidateString of
        Just monthCandidateInt ->
            if monthCandidateInt == 0 && String.length monthCandidateString <= 2 then
                Just 0

            else if day == 29 && isLeap year && monthCandidateInt == 2 then
                Just monthCandidateInt

            else if day <= 28 && monthCandidateInt == 2 then
                Just monthCandidateInt

            else if day >= 29 && monthCandidateInt == 2 then
                Nothing

            else if day == 31 && List.member monthCandidateInt [ 1, 3, 5, 7, 8, 10, 12 ] then
                Just monthCandidateInt

            else if day <= 30 && monthCandidateInt <= 12 then
                Just monthCandidateInt

            else
                Nothing

        Nothing ->
            Nothing


isLeap : Int -> Bool
isLeap year =
    if modBy 4 year == 0 then
        True

    else
        False

