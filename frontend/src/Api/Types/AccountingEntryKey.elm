module Api.Types.AccountingEntryKey exposing (..)

import Json.Decode as Decode
import Json.Decode.Pipeline exposing (..)
import Json.Encode as Encode


type alias AccountingEntryKey = { companyId: Int, id: Int, accountingYear: Int }


decoderAccountingEntryKey : Decode.Decoder AccountingEntryKey
decoderAccountingEntryKey = Decode.succeed AccountingEntryKey |> required "companyId" Decode.int |> required "id" Decode.int |> required "accountingYear" Decode.int


encoderAccountingEntryKey : AccountingEntryKey -> Encode.Value
encoderAccountingEntryKey obj = Encode.object [ ("companyId", Encode.int obj.companyId), ("id", Encode.int obj.id), ("accountingYear", Encode.int obj.accountingYear) ]