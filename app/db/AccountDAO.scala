package db

import base.Account
import javax.inject.Inject
import slick.jdbc.PostgresProfile.api._

import scala.concurrent.{ExecutionContext, Future}
import play.api.db.slick.{DatabaseConfigProvider, HasDatabaseConfigProvider}
import slick.jdbc.PostgresProfile

class AccountDAO @Inject()(override protected val dbConfigProvider: DatabaseConfigProvider)
                          (implicit executionContext: ExecutionContext)
  extends HasDatabaseConfigProvider[PostgresProfile] {
  def findAccount(accountID: Int): Future[Option[Account]] = db.run(AccountDAO.findAccountAction(accountID))

  def deleteAccount(accountID: Int): Future[Unit] = db.run(AccountDAO.deleteAccountAction(accountID))

  def repsertAccount(account: Account): Future[Account] = db.run(AccountDAO.repsertAccountAction(account))
}

object AccountDAO {

  def findAccountAction(accountID: Int): DBIO[Option[Account]] = Tables.accountTable.filter(acc => acc.id === accountID).result.headOption

  def deleteAccountAction(accountID: Int)(implicit ec: ExecutionContext): DBIO[Unit] = Tables.accountTable.filter(acc => acc.id === accountID).delete.map(_ => ())

  def repsertAccountAction(account: Account)(implicit ec: ExecutionContext): DBIO[Account] = Tables.accountTable.returning(Tables.accountTable).insertOrUpdate(account).map {
    case Some(value) => value
    case None => account
  }

}
