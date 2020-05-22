module Api.Types.DBAccountingEntry exposing (..)

import Json.Decode as Decode
import Json.Decode.Pipeline exposing (..)
import Json.Encode as Encode
import Api.Types.Date exposing (..)

type alias DBAccountingEntry = { id: Int, accountingYear: Int, bookingDate: Date, receiptNumber: String, description: String, credit: Int, debit: Int, amountWhole: Int, amountChange: Int }


decoderDBAccountingEntry : Decode.Decoder DBAccountingEntry
decoderDBAccountingEntry = Decode.succeed DBAccountingEntry |> required "id" Decode.int |> required "accountingYear" Decode.int |> required "bookingDate" decoderDate |> required "receiptNumber" Decode.string |> required "description" Decode.string |> required "credit" Decode.int |> required "debit" Decode.int |> required "amountWhole" Decode.int |> required "amountChange" Decode.int


encoderDBAccountingEntry : DBAccountingEntry -> Encode.Value
encoderDBAccountingEntry obj = Encode.object [ ("id", Encode.int obj.id), ("accountingYear", Encode.int obj.accountingYear), ("bookingDate", encoderDate obj.bookingDate), ("receiptNumber", Encode.string obj.receiptNumber), ("description", Encode.string obj.description), ("credit", Encode.int obj.credit), ("debit", Encode.int obj.debit), ("amountWhole", Encode.int obj.amountWhole), ("amountChange", Encode.int obj.amountChange) ]