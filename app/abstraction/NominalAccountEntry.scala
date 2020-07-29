package abstraction

import java.sql.Date

import abstraction.NominalAccountEntry.CreditOrDebit
import base.MonetaryValue


case class NominalAccountEntry(offsetAccount: Int, description: String, amount: CreditOrDebit, bookingDate: Date) {



}

object NominalAccountEntry {

  def mkCreditEntry(entry: db.AccountingEntry): NominalAccountEntry =
    NominalAccountEntry(
      offsetAccount = entry.debit,
      description = entry.description,
      amount = Credit(MonetaryValue.fromAllCents(100 * entry.amountWhole + entry.amountChange)),
      bookingDate = entry.bookingDate
    )

  def mkDebitEntry(entry: db.AccountingEntry): NominalAccountEntry =
    NominalAccountEntry(
      offsetAccount = entry.credit,
      description = entry.description,
      amount = Debit(MonetaryValue.fromAllCents(100 * entry.amountWhole + entry.amountChange)),
      bookingDate = entry.bookingDate
    )



  sealed trait CreditOrDebit {
    def monetaryValue: MonetaryValue
  }

  case class Credit(override val monetaryValue: MonetaryValue) extends CreditOrDebit
  case class Debit(override val monetaryValue: MonetaryValue) extends CreditOrDebit
}