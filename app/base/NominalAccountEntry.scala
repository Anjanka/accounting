package base

import java.sql.Date

import base.NominalAccountEntry.CreditOrDebit

case class NominalAccountEntry(
    openingBalance: Boolean,
    id: Int,
    receiptNumber: String,
    offsetAccount: Int,
    description: String,
    amount: CreditOrDebit,
    bookingDate: Date
)

object NominalAccountEntry {

  def mkCreditEntry(entry: db.AccountingEntry): NominalAccountEntry =
    base.NominalAccountEntry(
      openingBalance = false,
      id = entry.id,
      receiptNumber = entry.receiptNumber,
      offsetAccount = entry.debit,
      description = entry.description,
      amount = Credit(entry.monetaryValue),
      bookingDate = entry.bookingDate
    )

  def mkDebitEntry(entry: db.AccountingEntry, openingBalanceAccountIds: Set[Int]): NominalAccountEntry =
    base.NominalAccountEntry(
      openingBalance = openingBalanceAccountIds.contains(entry.credit),
      id = entry.id,
      receiptNumber = entry.receiptNumber,
      offsetAccount = entry.credit,
      description = entry.description,
      amount = Debit(entry.monetaryValue),
      bookingDate = entry.bookingDate
    )

  sealed trait CreditOrDebit {
    def monetaryValue: MonetaryValue
  }

  case class Credit(override val monetaryValue: MonetaryValue) extends CreditOrDebit
  case class Debit(override val monetaryValue: MonetaryValue) extends CreditOrDebit
}
