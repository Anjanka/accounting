module Api.Types.AccountingEntryTemplate exposing (..)

import Json.Decode as Decode
import Json.Decode.Pipeline exposing (..)
import Json.Encode as Encode


type alias AccountingEntryTemplate = { companyId: Int, description: String, credit: Int, debit: Int, amountWhole: Int, amountChange: Int }


decoderAccountingEntryTemplate : Decode.Decoder AccountingEntryTemplate
decoderAccountingEntryTemplate = Decode.succeed AccountingEntryTemplate |> required "companyId" Decode.int |> required "description" Decode.string |> required "credit" Decode.int |> required "debit" Decode.int |> required "amountWhole" Decode.int |> required "amountChange" Decode.int


encoderAccountingEntryTemplate : AccountingEntryTemplate -> Encode.Value
encoderAccountingEntryTemplate obj = Encode.object [ ("companyId", Encode.int obj.companyId), ("description", Encode.string obj.description), ("credit", Encode.int obj.credit), ("debit", Encode.int obj.debit), ("amountWhole", Encode.int obj.amountWhole), ("amountChange", Encode.int obj.amountChange) ]