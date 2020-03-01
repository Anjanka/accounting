package db

import base.Account
import slick.jdbc.PostgresProfile.api._

import scala.concurrent.ExecutionContext

object AccountConnection {

  def findAccountAction(accountID: Int): DBIO[Option[Account]] = Tables.accountTable.filter(acc => acc.id === accountID).result.headOption

  def deleteAccountAction(accountID: Int)(implicit ec: ExecutionContext): DBIO[Unit] = Tables.accountTable.filter(acc => acc.id === accountID).delete.map(_ => ())

  def repsertAccountAction(account: Account)(implicit ec: ExecutionContext): DBIO[Account] = Tables.accountTable.returning(Tables.accountTable).insertOrUpdate(account).map {
    case Some(value) => value
    case None => account
  }

}
