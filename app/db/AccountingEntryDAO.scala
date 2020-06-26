package db

import java.time.Year

import base.Id
import javax.inject.Inject
import play.api.db.slick.{DatabaseConfigProvider, HasDatabaseConfigProvider}
import slick.jdbc.PostgresProfile
import slick.jdbc.PostgresProfile.api._

import scala.concurrent.{ExecutionContext, Future}
import scala.language.higherKinds

class AccountingEntryDAO @Inject()(override protected val dbConfigProvider: DatabaseConfigProvider)
                                  (implicit executionContext: ExecutionContext)
  extends HasDatabaseConfigProvider[PostgresProfile] {
  def findAccountingEntry(accountingEntryKey: Id.AccountingEntryKey): Future[Option[AccountingEntry]] =
    db.run(AccountingEntryDAO.findAccountingEntryAction(accountingEntryKey))

  def deleteAccountingEntry(accountingEntryKey: Id.AccountingEntryKey): Future[Unit] =
    db.run(AccountingEntryDAO.deleteAccountingEntryAction(accountingEntryKey))

  def repsertAccountingEntry(accountingEntry: AccountingEntry): Future[AccountingEntry] =
    db.run(AccountingEntryDAO.repsertAccountingEntryAction(accountingEntry))

  def findAccountingEntriesByCompanyAndYear(companyID: Int, accountingYear: Int): Future[Seq[AccountingEntry]] =
    db.run(AccountingEntryDAO.findAccountingEntriesByCompanyAndYearAction(companyID, accountingYear))
}

object AccountingEntryDAO {

  def findAccountingEntryAction(accountingEntryKey: Id.AccountingEntryKey): DBIO[Option[AccountingEntry]] =
    fetch(accountingEntryKey).result.headOption

  def findAccountingEntriesByCompanyAndYearAction(companyID: Int, accountingYear: Int): DBIO[Seq[AccountingEntry]] =
    Tables.accountingEntryTable.filter(entry => entry.companyId === companyID && entry.accountingYear === accountingYear).result

  def deleteAccountingEntryAction(accountingEntryKey: Id.AccountingEntryKey)
                                 (implicit ec: ExecutionContext): DBIO[Unit] =
    fetch(accountingEntryKey).delete.map(_ => ())

  def repsertAccountingEntryAction(accountingEntry: AccountingEntry)(implicit ec: ExecutionContext): DBIO[AccountingEntry] = {
    Tables.accountingEntryTable.returning(Tables.accountingEntryTable).insertOrUpdate(accountingEntry).flatMap {
      case Some(dbEntry) if accountingEntry.credit == dbEntry.credit && accountingEntry.debit == dbEntry.debit =>
        DBIO.successful(accountingEntry)
      case Some(dbEntry) => DBIO.failed(new Throwable(s"Inserted entry $dbEntry doesn't match given entry $accountingEntry."))
      case None => DBIO.successful(accountingEntry)
    }
  }

  private def fetch(accountingEntryKey: Id.AccountingEntryKey): Query[Tables.AccountingEntryTable, AccountingEntry, Seq] =
    Tables.accountingEntryTable.filter(entry =>
      entry.companyId === accountingEntryKey.companyID &&
        entry.id === accountingEntryKey.id &&
        entry.accountingYear === accountingEntryKey.accountingYear)
}