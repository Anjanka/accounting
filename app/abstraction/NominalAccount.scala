package abstraction

import abstraction.NominalAccountEntry.{ Credit, Debit }
import base.MonetaryValue

case class NominalAccount(accountId: Int, accountName: String, entries: Seq[NominalAccountEntry]) {

  val balance: MonetaryValue = {
    MonetaryValue.fromAllCents(
      entries
        .map(entry =>
          entry.amount match {
            case Debit(value) =>
              -value.toAllCents
            case Credit(value) =>
              value.toAllCents
          }
        )
        .sum
    )
  }

}
