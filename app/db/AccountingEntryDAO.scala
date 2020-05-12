package db

import java.time.Year

import base.{Account, AccountingEntry, MonetaryValue}
import cats.Monad
import cats.syntax.flatMap._
import cats.syntax.functor._
import cats.instances.option._
import base.CatsInstances.seq._
import javax.inject.Inject
import play.api.db.slick.{DatabaseConfigProvider, HasDatabaseConfigProvider}
import slick.jdbc.PostgresProfile.api._
import slick.jdbc.PostgresProfile

import scala.concurrent.{ExecutionContext, Future}
import scala.language.higherKinds

class AccountingEntryDAO @Inject()(override protected val dbConfigProvider: DatabaseConfigProvider)
                                  (implicit executionContext: ExecutionContext)
  extends HasDatabaseConfigProvider[PostgresProfile] {
  def findAccountingEntry(accountingEntryID: Int, accountingYear: Year): Future[Option[AccountingEntry]] =
    db.run(AccountingEntryDAO.findAccountingEntryAction(accountingEntryID, accountingYear))

  def deleteAccountingEntry(accountingEntryID: Int, accountingYear: Year): Future[Unit] =
    db.run(AccountingEntryDAO.deleteAccountingEntryAction(accountingEntryID, accountingYear))

  def repsertAccountingEntry(accountingEntry: AccountingEntry): Future[AccountingEntry] =
    db.run(AccountingEntryDAO.repsertAccountingEntryAction(accountingEntry))

  def findAccountingEntriesByYear(accountingYear: Year): Future[Seq[AccountingEntry]] =
    db.run(AccountingEntryDAO.findAccountingEntriesByYearAction(accountingYear))
}

object AccountingEntryDAO {

  def findAccountingEntryAction(accountingEntryID: Int, accountingYear: Year)
                               (implicit ec: ExecutionContext): DBIO[Option[AccountingEntry]] =
    findAccountingEntryWithAction(fetch(accountingEntryID, accountingYear), _.headOption, identity)

  def findAccountingEntriesByYearAction(accountingYear: Year)
                                       (implicit ec: ExecutionContext): DBIO[Seq[AccountingEntry]] =
    findAccountingEntryWithAction(
      Tables.dbAccountingEntryTable.filter(entry => entry.accountingYear === accountingYear.getValue),
      identity,
      _.toSeq
    )

  private type AccountingEntryTriple = (Option[(Account, Account)], DBAccountingEntry, MonetaryValue)

  private def findAccountingEntryWithAction[Container[_] : Monad](query: Query[Tables.DBAccountingEntryDB, DBAccountingEntry, Seq],
                                                                  relevantTriples: Seq[AccountingEntryTriple] => Container[AccountingEntryTriple],
                                                                  fromOption: Option[(Account, Account)] => Container[(Account, Account)])
                                                                 (implicit ec: ExecutionContext): DBIO[Container[AccountingEntry]] = {
    for {
      dbAccountingEntries <- query.result
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
      relevantTriples(triples).flatMap { case (accounts, dbAccountingEntry, mv) =>
        fromOption(accounts).map { case (credit, debit) =>
          AccountingEntry(
            id = dbAccountingEntry.id,
            accountingYear = Year.of(dbAccountingEntry.accountingYear),
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
            accountingYear = Year.of(dbEntry.accountingYear),
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