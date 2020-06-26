package db

import base.Id
import base.Id.AccountingEntryKey
import javax.inject.Inject
import play.api.db.slick.{ DatabaseConfigProvider, HasDatabaseConfigProvider }
import slick.jdbc.PostgresProfile
import slick.jdbc.PostgresProfile.api._

import scala.concurrent.{ ExecutionContext, Future }
import scala.language.higherKinds

class AccountingEntryDAO @Inject() (override protected val dbConfigProvider: DatabaseConfigProvider)(implicit
    executionContext: ExecutionContext
) extends HasDatabaseConfigProvider[PostgresProfile] {

  private val dao = DAO(AccountingEntryDAO.daoCompanion, dbConfigProvider)

  def findAccountingEntry(accountingEntryKey: Id.AccountingEntryKey): Future[Option[AccountingEntry]] =
    dao.find(accountingEntryKey)

  def deleteAccountingEntry(accountingEntryKey: Id.AccountingEntryKey): Future[Unit] =
    dao.delete(accountingEntryKey)

  def repsertAccountingEntry(accountingEntry: AccountingEntry): Future[AccountingEntry] =
    dao.repsert(
      accountingEntry,
      dbEntry => accountingEntry.debit == dbEntry.debit && accountingEntry.credit == dbEntry.credit
    )

  def findAccountingEntriesByCompanyAndYear(companyID: Int, accountingYear: Int): Future[Seq[AccountingEntry]] =
    dao.findPartial((companyID, accountingYear))({
      case (entry, (cId, year)) => entry.companyId === cId && entry.accountingYear === year
    })

}

object AccountingEntryDAO {

  val daoCompanion: DAOCompanion[Tables.AccountingEntryTable, AccountingEntryKey] = DAOCompanion(
    _table = Tables.accountingEntryTable,
    _compare = (entry, key) =>
      entry.companyId === key.companyID &&
        entry.id === key.id &&
        entry.accountingYear === key.accountingYear
  )

}
