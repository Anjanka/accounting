package base

import io.circe.generic.JsonCodec

@JsonCodec
case class ReportLanguageComponents(
    journal: String,
    nominalAccounts: String,
    bookingDate: String,
    number: String,
    receiptNumber: String,
    description: String,
    debit: String,
    credit: String,
    amount: String,
    sum: String,
    revenue: String,
    openingBalance: String,
    balance: String,
    offsetAccount: String,
    bookedUntil: String,
    account: String,
    from : String,
    to : String
)
