module Api.Types.AccountingEntryTemplateKey exposing (..)

import Json.Decode as Decode
import Json.Decode.Pipeline exposing (..)
import Json.Encode as Encode


type alias AccountingEntryTemplateKey = { id: Int }


decoderAccountingEntryTemplateKey : Decode.Decoder AccountingEntryTemplateKey
decoderAccountingEntryTemplateKey = Decode.succeed AccountingEntryTemplateKey |> required "id" Decode.int


encoderAccountingEntryTemplateKey : AccountingEntryTemplateKey -> Encode.Value
encoderAccountingEntryTemplateKey obj = Encode.object [ ("id", Encode.int obj.id) ]