package db

import java.sql.Date

import io.circe.generic.JsonCodec

@JsonCodec
case class AccountingEntry(id: Int,
                           accountingYear: Int,
                           bookingDate: Date,
                           receiptNumber: String,
                           description: String,
                           credit: Int,
                           debit: Int,
                           amountWhole: Int,
                           amountChange: Int)
