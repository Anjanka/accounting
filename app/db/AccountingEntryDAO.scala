package db

import java.time.Year

import base.{AccountingEntry, MonetaryValue}
import javax.inject.Inject
import play.api.db.slick.{DatabaseConfigProvider, HasDatabaseConfigProvider}
import slick.jdbc.PostgresProfile.api._
import slick.jdbc.PostgresProfile

import scala.concurrent.ExecutionContext

class AccountingEntryDAO @Inject()(override protected val dbConfigProvider: DatabaseConfigProvider) extends HasDatabaseConfigProvider[PostgresProfile] {

}

object AccountingEntryDAO {

  def findAccountingEntryAction(accountingEntryID: Int, accountingYear: Year)
                               (implicit ec: ExecutionContext): DBIO[Option[AccountingEntry]] = {
    for {
      dbAccountingEntries <- fetch(accountingEntryID, accountingYear).result
      xs = dbAccountingEntries.map {
        db =>
          val accountsOpt = for {
            creditOpt <- AccountDAO.findAccountAction(db.credit)
            debitOpt <- AccountDAO.findAccountAction(db.debit)
          } yield {
            for {
              credit <- creditOpt
              debit <- debitOpt
            } yield (credit, debit)
          }
          val monetaryValue = MonetaryValue.fromAllCents(100 * db.amountWhole + db.amountChange)
          accountsOpt.map(accounts => (accounts, db, monetaryValue))
      }
      triples <- DBIO.sequence(xs)

    } yield {
      for {
        (accounts, dbAccountingEntry, mv) <- triples.headOption
        (credit, debit) <- accounts
      } yield {
        AccountingEntry(
          id = dbAccountingEntry.id,
          accountingYear = new Year(dbAccountingEntry.accountingYear),
          bookingDate = dbAccountingEntry.bookingDate,
          receiptNumber = dbAccountingEntry.receiptNumber,
          description = dbAccountingEntry.description,
          credit = credit,
          debit = debit,
          amount = mv
        )
      }

    }
  }

  def deleteAccountingEntryAction(accountingEntryID: Int,
                                  accountingYear: Year)
                                 (implicit ec: ExecutionContext): DBIO[Unit] =
    fetch(accountingEntryID, accountingYear).delete.map(_ => ())

  def repsertAccountingEntryAction(accountingEntry: AccountingEntry)(implicit ec: ExecutionContext): DBIO[AccountingEntry] = {

    val entry = DBAccountingEntry(
      accountingEntry.id,
      accountingEntry.accountingYear.getValue,
      accountingEntry.bookingDate,
      accountingEntry.receiptNumber,
      accountingEntry.description,
      accountingEntry.credit.id,
      accountingEntry.debit.id,
      accountingEntry.amount.whole.toInt,
      accountingEntry.amount.change.toCents.toInt
    )
    Tables.dbAccountingEntryTable.returning(Tables.dbAccountingEntryTable).insertOrUpdate(entry).flatMap {
      case Some(dbEntry) if accountingEntry.credit.id == dbEntry.credit && accountingEntry.debit.id == dbEntry.debit =>
        DBIO.successful(
          accountingEntry.copy(
            id = dbEntry.id,
            accountingYear = new Year(dbEntry.accountingYear),
            bookingDate = dbEntry.bookingDate,
            receiptNumber = dbEntry.receiptNumber,
            description = dbEntry.description,
            amount = MonetaryValue.fromAllCents(100 * dbEntry.amountWhole + dbEntry.amountChange)
          )
        )
      case Some(dbEntry) => DBIO.failed(new Throwable(s"Inserted entry $dbEntry doesn't match given entry $accountingEntry."))
      case None => DBIO.successful(accountingEntry)
    }
  }

  private def fetch(accountingEntryID: Int,
                    accountingYear: Year): Query[Tables.DBAccountingEntryDB, DBAccountingEntry, Seq] =
    Tables.dbAccountingEntryTable.filter(entry => entry.id === accountingEntryID && entry.accountingYear === accountingYear.getValue)
}