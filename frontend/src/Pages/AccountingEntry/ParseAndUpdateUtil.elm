module Pages.AccountingEntry.ParseAndUpdateUtil exposing (..)

import Api.General.AccountUtil as AccountUtil
import Api.General.AccountingEntryUtil as AccountingEntryUtil
import Api.Types.Account exposing (Account)
import List.Extra
import Pages.AccountingEntry.AccountingEntryPageModel exposing (Model, updateAccountingEntry, updateContent)
import Pages.AccountingEntry.InputContent exposing (updateAmount, updateCreditId, updateDebitId)
import Pages.FromInput as FromInput




handleParseResultDay : Int -> Result DateError Int -> { string : String, int : Int }
handleParseResultDay oldContent dayCandidate =
    case dayCandidate of
        Ok day ->
            { string =
                if day == 0 then
                    ""

                else
                    String.fromInt day
            , int = day
            }

        Err Empty ->
            { string = "", int = 0 }

        Err NotEmpty ->
            { string = String.fromInt oldContent, int = oldContent }




handleParseResultMonth : Int -> Result DateError Int -> { string : String, int : Int }
handleParseResultMonth oldContent monthCandidate =
    case monthCandidate of
        Ok month ->
            { string =
                if month == 0 then
                    ""

                else
                    String.fromInt month
            , int = month
            }

        Err Empty ->
            { string = "", int = 0 }

        Err NotEmpty ->
            { string = String.fromInt oldContent, int = oldContent }




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






findAccountName : List Account -> String -> Account
findAccountName accounts id =
    String.toInt id
        |> Maybe.andThen (\int -> List.Extra.find (\acc -> acc.id == int) accounts)
        |> Maybe.withDefault AccountUtil.empty



--   case String.toInt id of
--       Just int ->
--           case List.Extra.find (\acc -> acc.id == int) accounts of
--               Just value ->
--                   value
--               Nothing ->
--                   AccountUtil.empty
--       Nothing ->
--           AccountUtil.empty


parseAndUpdateAmount : Model -> String -> Model
parseAndUpdateAmount model amountContent =
    FromInput.lift updateAmount model.content.amount amountContent model.content
        |> updateContent model
        |> (\md ->
                updateAccountingEntry md
                    (model.accountingEntry
                        |> (\ae -> AccountingEntryUtil.updateCompleteAmount ae md.content.amount.value.whole md.content.amount.value.change)
                    )
           )



--parseAndUpdateAmount : Model -> String -> Model
--parseAndUpdateAmount model newContent =
--    if String.isEmpty newContent then
--        { model
--            | content = updateAmount model.content ""
--            , accountingEntry = AccountingEntryUtil.updateCompleteAmount model.accountingEntry 0 0
--        }
--    else
--        let
--            wholeAndChange =
--                String.split "," newContent
--        in
--        case List.head wholeAndChange of
--            Just wholeString ->
--                case String.toInt wholeString of
--                    Just whole ->
--                        case List.tail wholeAndChange of
--                            Just tailList ->
--                                case List.head tailList of
--                                    Just changeString ->
--                                        case String.toInt (String.left 2 changeString) of
--                                            Just change ->
--                                                if change < 10 && String.length changeString == 1 then
--                                                    { model
--                                                        | content = updateAmount model.content (String.concat [ String.fromInt whole, ",", String.fromInt change ])
--                                                        , accountingEntry = AccountingEntryUtil.updateAmountWhole (AccountingEntryUtil.updateAmountChange model.accountingEntry (change * 10)) whole
--                                                    }
--                                                else if change < 10 && String.length changeString >= 2 then
--                                                    { model
--                                                        | content = updateAmount model.content (String.concat [ String.fromInt whole, ",0", String.fromInt change ])
--                                                        , accountingEntry = AccountingEntryUtil.updateAmountWhole (AccountingEntryUtil.updateAmountChange model.accountingEntry change) whole
--                                                    }
--                                                else
--                                                    { model
--                                                        | content = updateAmount model.content (String.concat [ String.fromInt whole, ",", String.fromInt change ])
--                                                        , accountingEntry = AccountingEntryUtil.updateAmountWhole (AccountingEntryUtil.updateAmountChange model.accountingEntry change) whole
--                                                    }
--                                            Nothing ->
--                                                { model
--                                                    | content = updateAmount model.content (String.concat [ String.fromInt whole, "," ])
--                                                    , accountingEntry = AccountingEntryUtil.updateCompleteAmount model.accountingEntry whole 0
--                                                }
--                                    Nothing ->
--                                        { model | content = updateAmount model.content newContent, accountingEntry = AccountingEntryUtil.updateCompleteAmount model.accountingEntry whole 0 }
--                            Nothing ->
--                                { model | content = updateAmount model.content newContent, accountingEntry = AccountingEntryUtil.updateCompleteAmount model.accountingEntry whole 0 }
--                    Nothing ->
--                        model
--            Nothing ->
--                model


parseDay : Model -> String -> Result DateError Int
parseDay model newDay =
    if String.isEmpty newDay then
        Err Empty

    else
        String.toInt newDay
            |> filterMaybe (\dayCandidate -> validDate dayCandidate model.accountingEntry.bookingDate.month model.accountingYear)
            |> Maybe.map Ok
            |> Maybe.withDefault (Err NotEmpty)



-- case String.toInt newDay of
--     Just dayCandidate ->
--         if validDate dayCandidate model.accountingEntry.bookingDate.month model.accountingYear then
--             Ok dayCandidate
--         else
--             Err NotEmpty
--
--     Nothing ->
--         Err NotEmpty


parseMonth : Model -> String -> Result DateError Int
parseMonth model newMonth =
    if String.isEmpty newMonth then
        Err Empty

    else
        String.toInt newMonth
            |> filterMaybe (\monthCandidate -> validDate model.accountingEntry.bookingDate.day monthCandidate model.accountingYear)
            |> Maybe.map Ok
            |> Maybe.withDefault (Err NotEmpty)


filterMaybe : (a -> Bool) -> Maybe a -> Maybe a
filterMaybe p maybe =
    case maybe of
        Just a ->
            if p a then
                maybe

            else
                Nothing

        Nothing ->
            Nothing


validDate : Int -> Int -> Int -> Bool
validDate dayCandidate monthCandidate year =
    (List.member monthCandidate [ 0, 1, 3, 5, 7, 8, 10, 12 ] && dayCandidate >= 0 && dayCandidate <= 31)
        || (List.member monthCandidate [ 4, 6, 9, 11 ] && dayCandidate >= 0 && dayCandidate <= 30)
        || (dayCandidate <= 28 && monthCandidate >= 1 && monthCandidate <= 12)
        || (monthCandidate == 2 && isLeap year && dayCandidate == 29)


isLeap : Int -> Bool
isLeap year =
    modBy 4 year == 0


type DateError
    = Empty
    | NotEmpty
