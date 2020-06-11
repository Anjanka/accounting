package db

import java.time.Year

import javax.inject.Inject
import play.api.db.slick.{DatabaseConfigProvider, HasDatabaseConfigProvider}
import slick.jdbc.PostgresProfile
import slick.jdbc.PostgresProfile.api._

import scala.concurrent.{ExecutionContext, Future}
import scala.language.higherKinds

class AccountingEntryDAO @Inject()(override protected val dbConfigProvider: DatabaseConfigProvider)
                                  (implicit executionContext: ExecutionContext)
  extends HasDatabaseConfigProvider[PostgresProfile] {
  def findAccountingEntry(accountingEntryID: Int, accountingYear: Year): Future[Option[DBAccountingEntry]] =
    db.run(AccountingEntryDAO.findAccountingEntryAction(accountingEntryID, accountingYear))

  def deleteAccountingEntry(accountingEntryID: Int, accountingYear: Year): Future[Unit] =
    db.run(AccountingEntryDAO.deleteAccountingEntryAction(accountingEntryID, accountingYear))

  def repsertAccountingEntry(accountingEntry: DBAccountingEntry): Future[DBAccountingEntry] =
    db.run(AccountingEntryDAO.repsertAccountingEntryAction(accountingEntry))

  def findAccountingEntriesByYear(accountingYear: Year): Future[Seq[DBAccountingEntry]] =
    db.run(AccountingEntryDAO.findAccountingEntriesByYearAction(accountingYear))
}

object AccountingEntryDAO {

  def findAccountingEntryAction(accountingEntryID: Int, accountingYear: Year): DBIO[Option[DBAccountingEntry]] =
    fetch(accountingEntryID, accountingYear).result.headOption

  def findAccountingEntriesByYearAction(accountingYear: Year): DBIO[Seq[DBAccountingEntry]] =
    Tables.dbAccountingEntryTable.filter(entry => entry.accountingYear === accountingYear.getValue).result

  def deleteAccountingEntryAction(accountingEntryID: Int,
                                  accountingYear: Year)
                                 (implicit ec: ExecutionContext): DBIO[Unit] =
    fetch(accountingEntryID, accountingYear).delete.map(_ => ())

  def repsertAccountingEntryAction(accountingEntry: DBAccountingEntry)(implicit ec: ExecutionContext): DBIO[DBAccountingEntry] = {
    Tables.dbAccountingEntryTable.returning(Tables.dbAccountingEntryTable).insertOrUpdate(accountingEntry).flatMap {
      case Some(dbEntry) if accountingEntry.credit == dbEntry.credit && accountingEntry.debit == dbEntry.debit =>
        DBIO.successful(accountingEntry)
      case Some(dbEntry) => DBIO.failed(new Throwable(s"Inserted entry $dbEntry doesn't match given entry $accountingEntry."))
      case None => DBIO.successful(accountingEntry)
    }
  }

  private def fetch(accountingEntryID: Int,
                    accountingYear: Year): Query[Tables.DBAccountingEntryDB, DBAccountingEntry, Seq] =
    Tables.dbAccountingEntryTable.filter(entry => entry.id === accountingEntryID && entry.accountingYear === accountingYear.getValue)
}