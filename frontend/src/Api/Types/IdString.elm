module Api.Types.IdString exposing (..)

import Json.Decode as Decode
import Json.Decode.Pipeline exposing (..)
import Json.Encode as Encode


type alias IdString = { id: String }


decoderIdString : Decode.Decoder IdString
decoderIdString = Decode.succeed IdString |> required "id" Decode.string


encoderIdString : IdString -> Encode.Value
encoderIdString obj = Encode.object [ ("id", Encode.string obj.id) ]