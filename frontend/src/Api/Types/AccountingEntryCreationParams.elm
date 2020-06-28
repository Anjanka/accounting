module Api.Types.AccountingEntryCreationParams exposing (..)

import Json.Decode as Decode
import Json.Decode.Pipeline exposing (..)
import Json.Encode as Encode
import Api.Types.Date exposing (..)

type alias AccountingEntryCreationParams = { accountingYear: Int, bookingDate: Date, receiptNumber: String, description: String, credit: Int, debit: Int, amountWhole: Int, amountChange: Int, companyId: Int }


decoderAccountingEntryCreationParams : Decode.Decoder AccountingEntryCreationParams
decoderAccountingEntryCreationParams = Decode.succeed AccountingEntryCreationParams |> required "accountingYear" Decode.int |> required "bookingDate" decoderDate |> required "receiptNumber" Decode.string |> required "description" Decode.string |> required "credit" Decode.int |> required "debit" Decode.int |> required "amountWhole" Decode.int |> required "amountChange" Decode.int |> required "companyId" Decode.int


encoderAccountingEntryCreationParams : AccountingEntryCreationParams -> Encode.Value
encoderAccountingEntryCreationParams obj = Encode.object [ ("accountingYear", Encode.int obj.accountingYear), ("bookingDate", encoderDate obj.bookingDate), ("receiptNumber", Encode.string obj.receiptNumber), ("description", Encode.string obj.description), ("credit", Encode.int obj.credit), ("debit", Encode.int obj.debit), ("amountWhole", Encode.int obj.amountWhole), ("amountChange", Encode.int obj.amountChange), ("companyId", Encode.int obj.companyId) ]