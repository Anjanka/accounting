package db

import java.sql.Date

import base.Id.AccountingEntryKey
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

object AccountingEntry {
  def keyOf(accountingEntry: AccountingEntry): AccountingEntryKey =
    AccountingEntryKey(
      companyId = accountingEntry.companyId,
      id = accountingEntry.id,
      accountingYear = accountingEntry.accountingYear
    )
}