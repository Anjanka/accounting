module Api.General.Amount exposing (..)

import Basics.Extra exposing (flip)
import Pages.FromInput as FromInput exposing (FromInput)
import Parser exposing ((|.), (|=), Parser, andThen, oneOf, succeed, symbol)


type alias Amount =
    { whole : Int, change : Int }


amountParser : Parser Amount
amountParser =
    oneOf
        [ Parser.backtrackable (wholeParser |. Parser.end) |> Parser.map (\whole -> { whole = whole, change = 0 })
        , Parser.backtrackable (Parser.succeed (\whole change -> { whole = whole, change = change }) |= wholeParser |. Parser.symbol "," |= changeParser)
        ]


wholeParser : Parser Int
wholeParser =
    Parser.int


typedToken : (a -> String) -> a -> Parser a
typedToken show a =
    symbol (show a) |> andThen (\_ -> succeed a)


digit : Parser Int
digit =
    oneOf (List.map (typedToken String.fromInt) (List.range 0 9))


changeParser : Parser Int
changeParser =
    Parser.oneOf
        [ Parser.backtrackable (Parser.succeed ((*) 10) |= digit |. Parser.end)
        , Parser.backtrackable
            (Parser.succeed (\t o -> 10 * t + o)
                |= digit
                |= digit
                |. Parser.end
            )
        , Parser.succeed 0 |. Parser.end
        ]


display : Amount -> String
display amount =
    let
        separator =
            if amount.change <= 9 then
                ",0"

            else
                ","

        changeString =
            String.fromInt amount.change

        wholeString =
            String.fromInt amount.whole
    in
    String.concat [ wholeString, separator, changeString ]


zero : Amount
zero =
    { whole = 0, change = 0 }


partialAmount : String -> Bool
partialAmount str =
    case String.split "," str of
        whole :: rest :: [] ->
            String.all Char.isDigit whole && String.length rest <= 2 && String.all Char.isDigit rest

        whole :: [] ->
            String.all Char.isDigit whole

        _ ->
            False


parseAmount : String -> Result String Amount
parseAmount =
    Parser.run amountParser >> Result.mapError (\_ -> "Not a valid amount")


amountFromInput : FromInput Amount
amountFromInput =
    FromInput.emptyText
        { value = zero
        , ifEmptyValue = zero
        , parse = parseAmount
        , isPartial = partialAmount
        }


toCents : Amount -> Int
toCents amount =
    amount.whole * 100 + amount.change


updateAmountInFromInput : FromInput Amount -> Amount -> FromInput Amount
updateAmountInFromInput input amount =
    input
        |> flip FromInput.updateText (display amount)
        |> flip FromInput.updateValue amount
