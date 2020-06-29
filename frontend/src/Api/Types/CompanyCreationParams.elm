module Api.Types.CompanyCreationParams exposing (..)

import Json.Decode as Decode
import Json.Decode.Pipeline exposing (..)
import Json.Encode as Encode


type alias CompanyCreationParams = { name: String, address: String, taxNumber: String, revenueOffice: String }


decoderCompanyCreationParams : Decode.Decoder CompanyCreationParams
decoderCompanyCreationParams = Decode.succeed CompanyCreationParams |> required "name" Decode.string |> required "address" Decode.string |> required "taxNumber" Decode.string |> required "revenueOffice" Decode.string


encoderCompanyCreationParams : CompanyCreationParams -> Encode.Value
encoderCompanyCreationParams obj = Encode.object [ ("name", Encode.string obj.name), ("address", Encode.string obj.address), ("taxNumber", Encode.string obj.taxNumber), ("revenueOffice", Encode.string obj.revenueOffice) ]