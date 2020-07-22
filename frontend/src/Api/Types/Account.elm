module Api.Types.Account exposing (..)

import Json.Decode as Decode
import Json.Decode.Pipeline exposing (..)
import Json.Encode as Encode


type alias Account = { id: Int, title: String, companyId: Int, category: String, accountType: String }


decoderAccount : Decode.Decoder Account
decoderAccount = Decode.succeed Account |> required "id" Decode.int |> required "title" Decode.string |> required "companyId" Decode.int |> required "category" Decode.string |> required "accountType" Decode.string


encoderAccount : Account -> Encode.Value
encoderAccount obj = Encode.object [ ("id", Encode.int obj.id), ("title", Encode.string obj.title), ("companyId", Encode.int obj.companyId), ("category", Encode.string obj.category), ("accountType", Encode.string obj.accountType) ]