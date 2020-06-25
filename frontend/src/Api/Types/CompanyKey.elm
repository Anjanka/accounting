module Api.Types.CompanyKey exposing (..)

import Json.Decode as Decode
import Json.Decode.Pipeline exposing (..)
import Json.Encode as Encode


type alias CompanyKey = { id: Int }


decoderCompanyKey : Decode.Decoder CompanyKey
decoderCompanyKey = Decode.succeed CompanyKey |> required "id" Decode.int


encoderCompanyKey : CompanyKey -> Encode.Value
encoderCompanyKey obj = Encode.object [ ("id", Encode.int obj.id)]