module Api.Types.DBAccountingEntryTemplate exposing (..)

import Json.Decode as Decode
import Json.Decode.Pipeline exposing (..)
import Json.Encode as Encode


type alias DBAccountingEntryTemplate = { description: String, credit: Int, debit: Int, amountWhole: Int, amountChange: Int }


decoderDBAccountingEntryTemplate : Decode.Decoder DBAccountingEntryTemplate
decoderDBAccountingEntryTemplate = Decode.succeed DBAccountingEntryTemplate |> required "description" Decode.string |> required "credit" Decode.int |> required "debit" Decode.int |> required "amountWhole" Decode.int |> required "amountChange" Decode.int


encoderDBAccountingEntryTemplate : DBAccountingEntryTemplate -> Encode.Value
encoderDBAccountingEntryTemplate obj = Encode.object [ ("description", Encode.string obj.description), ("credit", Encode.int obj.credit), ("debit", Encode.int obj.debit), ("amountWhole", Encode.int obj.amountWhole), ("amountChange", Encode.int obj.amountChange) ]