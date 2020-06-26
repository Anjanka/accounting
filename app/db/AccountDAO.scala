package db

import base.Id
import base.Id.AccountKey
import javax.inject.Inject
import play.api.db.slick.{DatabaseConfigProvider, HasDatabaseConfigProvider}
import slick.jdbc.PostgresProfile
import slick.jdbc.PostgresProfile.api._

import scala.concurrent.{ExecutionContext, Future}

class AccountDAO @Inject()(override protected val dbConfigProvider: DatabaseConfigProvider)
                          (implicit executionContext: ExecutionContext)
  extends HasDatabaseConfigProvider[PostgresProfile] {
  private val dao: DAO[Tables.AccountTable, AccountKey] = DAO(AccountDAO.daoCompanion, dbConfigProvider)

  def findAccount(accountKey: Id.AccountKey): Future[Option[Account]] = dao.find(accountKey)

  def deleteAccount(accountKey: Id.AccountKey): Future[Unit] = dao.delete(accountKey)

  def repsertAccount(account: Account): Future[Account] = dao.repsert(account)

  def getAllAccountsByCompany(companyID: Int): Future[Seq[Account]] =
    dao.findPartial(companyID)((acc, cId) => acc.companyId === cId)
}

object AccountDAO {

  import PostgresProfile.api._

  val daoCompanion: DAOCompanion[Tables.AccountTable, AccountKey] = DAOCompanion(
    _table = Tables.accountTable,
    _compare = (acc, accountKey) => acc.id === accountKey.id && acc.companyId === accountKey.companyID
  )

}
