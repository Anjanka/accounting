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
  def findAccountingEntry(companyID: Int, accountingEntryID: Int, accountingYear: Year): Future[Option[AccountingEntry]] =
    db.run(AccountingEntryDAO.findAccountingEntryAction(companyID, accountingEntryID, accountingYear))

  def deleteAccountingEntry(companyID: Int, accountingEntryID: Int, accountingYear: Year): Future[Unit] =
    db.run(AccountingEntryDAO.deleteAccountingEntryAction(companyID, accountingEntryID, accountingYear))

  def repsertAccountingEntry(accountingEntry: AccountingEntry): Future[AccountingEntry] =
    db.run(AccountingEntryDAO.repsertAccountingEntryAction(accountingEntry))

  def findAccountingEntriesByCompanyAndYear(companyID: Int, accountingYear: Year): Future[Seq[AccountingEntry]] =
    db.run(AccountingEntryDAO.findAccountingEntriesByCompanyAndYearAction(companyID, accountingYear))
}

object AccountingEntryDAO {

  def findAccountingEntryAction(companyID: Int, accountingEntryID: Int, accountingYear: Year): DBIO[Option[AccountingEntry]] =
    fetch(companyID, accountingEntryID, accountingYear).result.headOption

  def findAccountingEntriesByCompanyAndYearAction(companyID: Int, accountingYear: Year): DBIO[Seq[AccountingEntry]] =
    Tables.accountingEntryTable.filter(entry => entry.companyId === companyID && entry.accountingYear === accountingYear.getValue).result

  def deleteAccountingEntryAction(companyID: Int,
                                  accountingEntryID: Int,
                                  accountingYear: Year)
                                 (implicit ec: ExecutionContext): DBIO[Unit] =
    fetch(companyID, accountingEntryID, accountingYear).delete.map(_ => ())

  def repsertAccountingEntryAction(accountingEntry: AccountingEntry)(implicit ec: ExecutionContext): DBIO[AccountingEntry] = {
    Tables.accountingEntryTable.returning(Tables.accountingEntryTable).insertOrUpdate(accountingEntry).flatMap {
      case Some(dbEntry) if accountingEntry.credit == dbEntry.credit && accountingEntry.debit == dbEntry.debit =>
        DBIO.successful(accountingEntry)
      case Some(dbEntry) => DBIO.failed(new Throwable(s"Inserted entry $dbEntry doesn't match given entry $accountingEntry."))
      case None => DBIO.successful(accountingEntry)
    }
  }

  private def fetch(companyID: Int,
                    accountingEntryID: Int,
                    accountingYear: Year): Query[Tables.AccountingEntryDB, AccountingEntry, Seq] =
    Tables.accountingEntryTable.filter(entry =>
      entry.companyId === companyID &&
        entry.id === accountingEntryID &&
        entry.accountingYear === accountingYear.getValue)
}