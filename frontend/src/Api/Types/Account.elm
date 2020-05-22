module Api.Types.Account exposing (..)

import Json.Decode as Decode
import Json.Decode.Pipeline exposing (..)
import Json.Encode as Encode


type alias Account = { id: Int, title: String }


decoderAccount : Decode.Decoder Account
decoderAccount = Decode.succeed Account |> required "id" Decode.int |> required "title" Decode.string


encoderAccount : Account -> Encode.Value
encoderAccount obj = Encode.object [ ("id", Encode.int obj.id), ("title", Encode.string obj.title) ]