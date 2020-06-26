module Api.Types.Company exposing (..)

import Json.Decode as Decode
import Json.Decode.Pipeline exposing (..)
import Json.Encode as Encode


type alias Company = { id: Int, name: String, address: String, taxNumber: String, revenueOffice: String}


decoderCompany : Decode.Decoder Company
decoderCompany = Decode.succeed Company
                          |> required "id" Decode.int
                          |> required "name" Decode.string
                          |> required "address" Decode.string
                          |> required "taxNumber" Decode.string
                          |> required "revenueOffice" Decode.string


encoderCompany : Company -> Encode.Value
encoderCompany obj = Encode.object [ ("id", Encode.int obj.id)
                                   , ("name", Encode.string obj.name)
                                   , ("address", Encode.string obj.address)
                                   , ("texNumber", Encode.string obj.taxNumber)
                                   , ("revenueOffice", Encode.string obj.revenueOffice)]