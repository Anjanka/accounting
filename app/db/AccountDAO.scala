package db

import javax.inject.Inject
import play.api.db.slick.{DatabaseConfigProvider, HasDatabaseConfigProvider}
import slick.jdbc.PostgresProfile
import slick.jdbc.PostgresProfile.api._

import scala.concurrent.{ExecutionContext, Future}

class AccountDAO @Inject()(override protected val dbConfigProvider: DatabaseConfigProvider)
                          (implicit executionContext: ExecutionContext)
  extends HasDatabaseConfigProvider[PostgresProfile] {
  def findAccount(accountID: Int): Future[Option[DBAccount]] = db.run(AccountDAO.findAccountAction(accountID))

  def deleteAccount(accountID: Int): Future[Unit] = db.run(AccountDAO.deleteAccountAction(accountID))

  def repsertAccount(account: DBAccount): Future[DBAccount] = db.run(AccountDAO.repsertAccountAction(account))

  def getAllAccounts: Future[Seq[DBAccount]] = db.run(AccountDAO.getAllAccountsAction)
}

object AccountDAO {

  def findAccountAction(accountID: Int): DBIO[Option[DBAccount]] = Tables.accountTable.filter(acc => acc.id === accountID).result.headOption

  def deleteAccountAction(accountID: Int)(implicit ec: ExecutionContext): DBIO[Unit] = Tables.accountTable.filter(acc => acc.id === accountID).delete.map(_ => ())

  def repsertAccountAction(account: DBAccount)(implicit ec: ExecutionContext): DBIO[DBAccount] = Tables.accountTable.returning(Tables.accountTable).insertOrUpdate(account).map {
    case Some(value) => value
    case None => account
  }

  def getAllAccountsAction : DBIO[Seq[DBAccount]] = Tables.accountTable.result

}
