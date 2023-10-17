module Api.Types.Credentials exposing (..)

import Json.Decode as Decode
import Json.Decode.Pipeline exposing (..)
import Json.Encode as Encode


type alias Credentials = { username: String, password: String }


decoderCredentials : Decode.Decoder Credentials
decoderCredentials = Decode.succeed Credentials |> required "username" Decode.string |> required "password" Decode.string


encoderCredentials : Credentials -> Encode.Value
encoderCredentials obj = Encode.object [ ("username", Encode.string obj.username), ("password", Encode.string obj.password) ]