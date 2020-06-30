module Api.Types.AccountingEntryTemplateCreationParams exposing (..)

import Json.Decode as Decode
import Json.Decode.Pipeline exposing (..)
import Json.Encode as Encode


type alias AccountingEntryTemplateCreationParams = { description: String, credit: Int, debit: Int, amountWhole: Int, amountChange: Int, companyId: Int }


decoderAccountingEntryTemplateCreationParams : Decode.Decoder AccountingEntryTemplateCreationParams
decoderAccountingEntryTemplateCreationParams = Decode.succeed AccountingEntryTemplateCreationParams |> required "description" Decode.string |> required "credit" Decode.int |> required "debit" Decode.int |> required "amountWhole" Decode.int |> required "amountChange" Decode.int |> required "companyId" Decode.int


encoderAccountingEntryTemplateCreationParams : AccountingEntryTemplateCreationParams -> Encode.Value
encoderAccountingEntryTemplateCreationParams obj = Encode.object [ ("description", Encode.string obj.description), ("credit", Encode.int obj.credit), ("debit", Encode.int obj.debit), ("amountWhole", Encode.int obj.amountWhole), ("amountChange", Encode.int obj.amountChange), ("companyId", Encode.int obj.companyId) ]