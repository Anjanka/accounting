module Api.Types.ReportLanguageComponents exposing (..)

import Json.Decode as Decode
import Json.Decode.Pipeline exposing (..)
import Json.Encode as Encode
import Api.Types.Date exposing (..)

type alias ReportLanguageComponents = { journal: String, nominalAccounts: String, bookingDate: String, number: String, receiptNumber: String, description: String, debit: String, credit: String, amount: String, sum: String, revenue: String, openingBalance: String, balance: String, offsetAccount: String, bookedUntil: String, account: String }


decoderReportLanguageComponents : Decode.Decoder ReportLanguageComponents
decoderReportLanguageComponents = Decode.succeed ReportLanguageComponents |> required "journal" Decode.string |> required "nominalAccounts" Decode.string |> required "bookingDate" Decode.string |> required "number" Decode.string |> required "receiptNumber" Decode.string |> required "description" Decode.string |> required "debit" Decode.string |> required "credit" Decode.string |> required "amount" Decode.string |> required "sum" Decode.string |> required "revenue" Decode.string |> required "openingBalance" Decode.string |> required "balance" Decode.string |> required "offsetAccount" Decode.string |> required "bookedUntil" Decode.string |> required "account" Decode.string


encoderReportLanguageComponents : ReportLanguageComponents -> Encode.Value
encoderReportLanguageComponents obj = Encode.object [ ("journal", Encode.string obj.journal), ("nominalAccounts", Encode.string obj.nominalAccounts), ("bookingDate", Encode.string obj.bookingDate), ("number", Encode.string obj.number), ("receiptNumber", Encode.string obj.receiptNumber), ("description", Encode.string obj.description), ("debit", Encode.string obj.debit), ("credit", Encode.string obj.credit), ("amount", Encode.string obj.amount), ("sum", Encode.string obj.sum), ("revenue", Encode.string obj.revenue), ("openingBalance", Encode.string obj.openingBalance), ("balance", Encode.string obj.balance), ("offsetAccount", Encode.string obj.offsetAccount), ("bookedUntil", Encode.string obj.bookedUntil), ("account", Encode.string obj.account) ]