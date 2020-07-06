module Pages.FromInput exposing (..)


intParser : String -> Result String Int
intParser =
    String.toInt >> Maybe.map Ok >> Maybe.withDefault (Err "Not an integer")


intPartial : String -> Bool
intPartial text =
    text == "-"


type alias FromInput a =
    { value : a
    , defaultValue : a
    , text : String
    , parser : String -> Result String a
    , partial : String -> Bool
    }


updateText : FromInput a -> String -> FromInput a
updateText intFromInput text =
    { intFromInput | text = text }


updateValue : FromInput a -> a -> FromInput a
updateValue intFromInput value =
    { intFromInput | value = value }


mkFromInput : a -> a -> (String -> Result String a) -> (String -> Bool) -> FromInput a
mkFromInput defaultValue value parser partial =
    { value = value, defaultValue = defaultValue, text = "", parser = parser, partial = partial }


isValid : FromInput a -> Bool
isValid fromInput =
    case fromInput.parser fromInput.text of
        Ok value ->
            value == fromInput.value

        Err _ ->
            False


lift : (model -> FromInput a -> model) -> FromInput a -> String -> model -> model
lift ui fromInput text model =
    let
        possiblyValid =
            if String.isEmpty text || fromInput.partial text then
                fromInput
                    |> (\ifi -> updateValue ifi fromInput.value)
                    |> (\ifi -> updateText ifi text)

            else
                fromInput
    in
    case fromInput.parser text of
        Ok value ->
            possiblyValid
                |> (\ifi -> updateText ifi text)
                |> (\ifi -> updateValue ifi value)
                |> ui model

        Err _ ->
            ui model possiblyValid
