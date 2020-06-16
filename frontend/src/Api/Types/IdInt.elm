module Api.Types.IdInt exposing (..)

import Json.Decode as Decode
import Json.Decode.Pipeline exposing (..)
import Json.Encode as Encode


type alias IdInt = { id: Int }


decoderIdInt : Decode.Decoder IdInt
decoderIdInt = Decode.succeed IdInt |> required "id" Decode.int


encoderIdInt : IdInt -> Encode.Value
encoderIdInt obj = Encode.object [ ("id", Encode.int obj.id) ]