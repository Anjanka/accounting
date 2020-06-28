package db.creation

import db.AccountingEntry
import io.circe.generic.JsonCodec
import base.JsonCodecs.Implicits._

@JsonCodec
case class AccountingEntryCreationParams(
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

object AccountingEntryCreationParams {

  def create(id: Int, accountingEntryCreationParams: AccountingEntryCreationParams): AccountingEntry =
    AccountingEntry(
      id = id,
      accountingYear = accountingEntryCreationParams.accountingYear,
      bookingDate = accountingEntryCreationParams.bookingDate,
      receiptNumber = accountingEntryCreationParams.receiptNumber,
      description = accountingEntryCreationParams.description,
      credit = accountingEntryCreationParams.credit,
      debit = accountingEntryCreationParams.debit,
      amountWhole = accountingEntryCreationParams.amountWhole,
      amountChange = accountingEntryCreationParams.amountChange,
      companyId = accountingEntryCreationParams.companyId
    )

}
