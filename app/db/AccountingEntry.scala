package db

import java.sql.Date

import io.circe.generic.JsonCodec
import base.JsonCodecs.Implicits._

@JsonCodec
case class AccountingEntry(companyId: Int,
                           id: Int,
                           accountingYear: Int,
                           bookingDate: Date,
                           receiptNumber: String,
                           description: String,
                           credit: Int,
                           debit: Int,
                           amountWhole: Int,
                           amountChange: Int)
