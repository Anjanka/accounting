package db

import base.Id.AccountingEntryKey
import db.DAOCompanion.FindPredicate
import javax.inject.Inject
import play.api.db.slick.{ DatabaseConfigProvider, HasDatabaseConfigProvider }
import slick.jdbc.PostgresProfile
import slick.jdbc.PostgresProfile.api._

import scala.concurrent.ExecutionContext
import scala.language.higherKinds

class AccountingEntryDAO @Inject() (override protected val dbConfigProvider: DatabaseConfigProvider)(implicit
    executionContext: ExecutionContext
) extends HasDatabaseConfigProvider[PostgresProfile] {

  val dao: DAO[AccountingEntry, Tables.AccountingEntryTable, AccountingEntryKey] =
    DAO(AccountingEntryDAO.daoCompanion, dbConfigProvider)

}

object AccountingEntryDAO {

  case class CompanyYearKey(companyId: Int, accountingYear: Int)

  val compareCompanyYearKey: FindPredicate[Tables.AccountingEntryTable, CompanyYearKey] =
    (entry, companyYearKey) =>
      entry.companyId === companyYearKey.companyId && entry.accountingYear === companyYearKey.accountingYear

  val daoCompanion: DAOCompanion[AccountingEntry, Tables.AccountingEntryTable, AccountingEntryKey] = DAOCompanion(
    _table = Tables.accountingEntryTable,
    _compare = (entry, key) =>
      entry.companyId === key.companyID &&
        entry.id === key.id &&
        entry.accountingYear === key.accountingYear
  )

}
