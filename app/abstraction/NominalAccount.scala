package abstraction

import abstraction.NominalAccountEntry.{ Credit, Debit }
import base.MonetaryValue

case class NominalAccount(accountId: Int, accountName: String, entries: Seq[NominalAccountEntry]) {

  val debitBalance: MonetaryValue =
    MonetaryValue.fromAllCents(
      entries
        .map(entry => entry.amount)
        .collect { case Debit(monetaryValue) => monetaryValue.toAllCents }
        .sum
    )

  val creditBalance: MonetaryValue =
    MonetaryValue.fromAllCents(
      entries
        .map(entry => entry.amount)
        .collect { case Credit(value) => value.toAllCents }
        .sum
    )

  val balance: MonetaryValue = {
    MonetaryValue.fromAllCents(creditBalance.toAllCents - debitBalance.toAllCents)
  }

}
