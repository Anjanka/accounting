module Api.General.ReportLanguageComponentConstants exposing (..)

import Api.Types.ReportLanguageComponents exposing (ReportLanguageComponents)


englishReportLanguageComponents : ReportLanguageComponents
englishReportLanguageComponents =
    { journal = "Journal"
    , nominalAccounts = "Nominal Accounts"
    , bookingDate = "Receipt Date"
    , number = "No."
    , receiptNumber = "Receipt No."
    , description = "Posting Text"
    , debit = "DEBIT"
    , credit = "CREDIT"
    , amount = "Amount"
    , sum = "Sum"
    , revenue = "Revenue"
    , openingBalance = "OB value:"
    , balance = "Balance:"
    , offsetAccount = "Offset Account"
    , bookedUntil = "booked until"
    , account = "Account: "
    , from = " from "
    , to = " to "
    }


germanReportLanguageComponents : ReportLanguageComponents
germanReportLanguageComponents =
    { journal = "Journal"
    , nominalAccounts = "Sachkonten"
    , bookingDate = "Beleg- datum"
    , number = "Nr."
    , receiptNumber = "Beleg- nr."
    , description = "Buchungstext"
    , debit = "SOLL"
    , credit = "HABEN"
    , amount = "Betrag"
    , sum = "Summe"
    , revenue = "Einnahmen"
    , openingBalance = "EB-Wert:"
    , balance = "Saldo:"
    , offsetAccount = "Gegen- konto"
    , bookedUntil = "gebucht bis"
    , account = "Konto: "
    , from = " vom "
    , to = " bis "
    }
