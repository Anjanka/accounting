package db

import javax.inject.Inject
import play.api.db.slick.{DatabaseConfigProvider, HasDatabaseConfigProvider}
import slick.jdbc.PostgresProfile
import slick.jdbc.PostgresProfile.api._

import scala.concurrent.{ExecutionContext, Future}

class AccountDAO @Inject()(override protected val dbConfigProvider: DatabaseConfigProvider)
                          (implicit executionContext: ExecutionContext)
  extends HasDatabaseConfigProvider[PostgresProfile] {
  def findAccount(companyID: Int, accountID: Int): Future[Option[Account]] = db.run(AccountDAO.findAccountAction(companyID, accountID))

  def deleteAccount(companyID: Int, accountID: Int): Future[Unit] = db.run(AccountDAO.deleteAccountAction(companyID, accountID))

  def repsertAccount(account: Account): Future[Account] = db.run(AccountDAO.repsertAccountAction(account))

  def getAllAccountsByCompany(companyID: Int): Future[Seq[Account]] = db.run(AccountDAO.getAllAccountsByCompanyAction(companyID))
}

object AccountDAO {

  def findAccountAction(companyID: Int, accountID: Int): DBIO[Option[Account]] = Tables.accountTable.filter(acc => acc.id === accountID && acc.companyId === companyID).result.headOption

  def deleteAccountAction(companyID: Int, accountID: Int)(implicit ec: ExecutionContext): DBIO[Unit] = Tables.accountTable.filter(acc => acc.id === accountID && acc.companyId === companyID).delete.map(_ => ())

  def repsertAccountAction(account: Account)(implicit ec: ExecutionContext): DBIO[Account] = Tables.accountTable.returning(Tables.accountTable).insertOrUpdate(account).map {
    case Some(value) => value
    case None => account
  }

  def getAllAccountsByCompanyAction(companyID: Int): DBIO[Seq[Account]] = Tables.accountTable.filter(acc => acc.companyId === companyID).result

}
