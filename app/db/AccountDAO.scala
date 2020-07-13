package db

import base.Id.AccountKey
import db.DAOCompanion.FindPredicate
import javax.inject.Inject
import play.api.db.slick.{DatabaseConfigProvider, HasDatabaseConfigProvider}
import slick.jdbc.PostgresProfile

import scala.concurrent.ExecutionContext

class AccountDAO @Inject() (override protected val dbConfigProvider: DatabaseConfigProvider)(implicit
    executionContext: ExecutionContext
) extends HasDatabaseConfigProvider[PostgresProfile] {
  val dao: DAO[Account, Tables.AccountTable, AccountKey] = DAO(AccountDAO.daoCompanion, dbConfigProvider)
}

object AccountDAO {

  import PostgresProfile.api._

  val compareByCompany: FindPredicate[Tables.AccountTable, Int] =
    (acc, cId) => acc.companyId === cId

  val daoCompanion: DAOCompanion[Account, Tables.AccountTable, AccountKey] = DAOCompanion(
    _table = Tables.accountTable,
    _compare = (acc, accountKey) => acc.id === accountKey.id && acc.companyId === accountKey.companyId
  )

}
