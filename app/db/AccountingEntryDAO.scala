package db

import base.AccountingEntry
import javax.inject.Inject
import play.api.db.slick.{DatabaseConfigProvider, HasDatabaseConfigProvider}
import slick.jdbc.PostgresProfile.api._
import slick.jdbc.PostgresProfile

import scala.concurrent.ExecutionContext

class AccountingEntryDAO @Inject()(override protected val dbConfigProvider: DatabaseConfigProvider) extends HasDatabaseConfigProvider[PostgresProfile] {

}

 object AccountingEntryDAO {

   def findAccountingEntryAction(accountingEntryID: Int): DBIO[Option[AccountingEntry]] = ???

   def deleteAccountingEntryAction(accountingEntryID: Int)(implicit ec: ExecutionContext): DBIO[Unit] = ???

   def repsertAccountingEntryAction(accountingEntry: AccountingEntry)(implicit ec: ExecutionContext): DBIO[AccountingEntry] = ???
 }