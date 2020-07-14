module Api.Types.AccountKey exposing (..)

import Json.Decode as Decode
import Json.Decode.Pipeline exposing (..)
import Json.Encode as Encode


type alias AccountKey = { companyId: Int, id: Int }


decoderAccountKey : Decode.Decoder AccountKey
decoderAccountKey = Decode.succeed AccountKey |> required "companyId" Decode.int |> required "id" Decode.int


encoderAccountKey : AccountKey -> Encode.Value
encoderAccountKey obj = Encode.object [ ("companyId", Encode.int obj.companyId), ("id", Encode.int obj.id) ]