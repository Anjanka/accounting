package db

import base.Id
import javax.inject.Inject
import play.api.db.slick.{DatabaseConfigProvider, HasDatabaseConfigProvider}
import slick.jdbc.PostgresProfile
import slick.jdbc.PostgresProfile.api._

import scala.concurrent.{ExecutionContext, Future}

class AccountDAO @Inject()(override protected val dbConfigProvider: DatabaseConfigProvider)
                          (implicit executionContext: ExecutionContext)
  extends HasDatabaseConfigProvider[PostgresProfile] {
  def findAccount(accountKey: Id.AccountKey): Future[Option[Account]] = db.run(AccountDAO.findAccountAction(accountKey))

  def deleteAccount(accountKey: Id.AccountKey): Future[Unit] = db.run(AccountDAO.deleteAccountAction(accountKey))

  def repsertAccount(account: Account): Future[Account] = db.run(AccountDAO.repsertAccountAction(account))

  def getAllAccountsByCompany(companyID: Int): Future[Seq[Account]] = db.run(AccountDAO.getAllAccountsByCompanyAction(companyID))
}

object AccountDAO {

  def findAccountAction(accountKey: Id.AccountKey): DBIO[Option[Account]] = Tables.accountTable.filter(acc => acc.id === accountKey.id && acc.companyId === accountKey.companyID).result.headOption

  def deleteAccountAction(accountKey: Id.AccountKey)(implicit ec: ExecutionContext): DBIO[Unit] = Tables.accountTable.filter(acc => acc.id === accountKey.id && acc.companyId === accountKey.companyID).delete.map(_ => ())

  def repsertAccountAction(account: Account)(implicit ec: ExecutionContext): DBIO[Account] = Tables.accountTable.returning(Tables.accountTable).insertOrUpdate(account).map {
    case Some(value) => value
    case None => account
  }

  def getAllAccountsByCompanyAction(companyID: Int): DBIO[Seq[Account]] = Tables.accountTable.filter(acc => acc.companyId === companyID).result

}
