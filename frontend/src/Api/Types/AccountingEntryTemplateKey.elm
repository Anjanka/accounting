module Api.Types.AccountingEntryTemplateKey exposing (..)

import Json.Decode as Decode
import Json.Decode.Pipeline exposing (..)
import Json.Encode as Encode


type alias AccountingEntryTemplateKey = { companyID: Int, description: String }


decoderAccountingEntryTemplateKey : Decode.Decoder AccountingEntryTemplateKey
decoderAccountingEntryTemplateKey = Decode.succeed AccountingEntryTemplateKey |> required "companyID" Decode.int |> required "description" Decode.string


encoderAccountingEntryTemplateKey : AccountingEntryTemplateKey -> Encode.Value
encoderAccountingEntryTemplateKey obj = Encode.object [ ("companyID", Encode.int obj.companyID), ("description", Encode.string obj.description) ]