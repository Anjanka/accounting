package db

import java.sql.Date
import io.circe.generic.JsonCodec
import base.JsonCodecs.Implicits._

@JsonCodec
case class AccountingEntry(
    id: Int,
    accountingYear: Int,
    bookingDate: java.sql.Date,
    receiptNumber: String,
    description: String,
    credit: Int,
    debit: Int,
    amountWhole: Int,
    amountChange: Int,
    companyId: Int
)
