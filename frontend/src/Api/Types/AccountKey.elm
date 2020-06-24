module Api.Types.AccountKey exposing (..)

import Json.Decode as Decode
import Json.Decode.Pipeline exposing (..)
import Json.Encode as Encode


type alias AccountKey = { companyID: Int, id: Int }


decoderAccountKey : Decode.Decoder AccountKey
decoderAccountKey = Decode.succeed AccountKey |> required "companyID" Decode.int |> required "id" Decode.int


encoderAccountKey : AccountKey -> Encode.Value
encoderAccountKey obj = Encode.object [ ("companyID", Encode.int obj.companyID), ("id", Encode.int obj.id) ]