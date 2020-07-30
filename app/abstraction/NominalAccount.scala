package abstraction

import abstraction.NominalAccountEntry.{ Credit, Debit }
import base.MonetaryValue
import Numeric.Implicits._

case class NominalAccount(accountId: Int, accountName: String, entries: Seq[NominalAccountEntry]) {

  val debitBalance: MonetaryValue =
    entries
      .map(entry => entry.amount)
      .collect { case Debit(monetaryValue) => monetaryValue }
      .sum

  val creditBalance: MonetaryValue =
    entries
      .map(entry => entry.amount)
      .collect { case Credit(value) => value }
      .sum

  val balance: MonetaryValue = {
    (creditBalance - debitBalance).abs
  }

}
