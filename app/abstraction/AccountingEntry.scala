package abstraction

import java.sql.Date
import java.time.Year

import base.CatsInstances.seq._
import base.MonetaryValue
import cats.instances.option._
import cats.syntax.contravariantSemigroupal._
import cats.syntax.traverse._

case class AccountingEntry(id: Int,
                           accountingYear: Year,
                           //Todo #7 switch to own Date type
                           bookingDate: Date,
                           receiptNumber: String,
                           description: String,
                           credit: Account, //SOLL
                           debit: Account, //HABEN
                           amount: MonetaryValue)

object AccountingEntry {
  def build(dbEntries: Seq[db.AccountingEntry], dbAccounts: Seq[db.Account]): Option[Seq[AccountingEntry]] = {
    val map = dbAccounts.map(acc => acc.id -> Account.fromDB(acc)).toMap
    dbEntries.traverse { entry =>
      (map.get(entry.credit), map.get(entry.debit)).mapN { (credit, debit) =>
        AccountingEntry(
          id = entry.id,
          accountingYear = Year.of(entry.accountingYear),
          bookingDate = entry.bookingDate,
          receiptNumber = entry.receiptNumber,
          description = entry.description,
          credit = credit,
          debit = debit,
          amount = MonetaryValue.fromAllCents(100 * entry.amountWhole + entry.amountChange)
        )
      }
    }
  }
}