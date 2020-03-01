package db

import java.time.Year

import base.AccountingEntry
import javax.inject.Inject
import play.api.db.slick.{DatabaseConfigProvider, HasDatabaseConfigProvider}
import slick.jdbc.PostgresProfile.api._
import slick.jdbc.PostgresProfile

import scala.concurrent.ExecutionContext

class AccountingEntryDAO @Inject()(override protected val dbConfigProvider: DatabaseConfigProvider) extends HasDatabaseConfigProvider[PostgresProfile] {

}

object AccountingEntryDAO {

  def findAccountingEntryAction(accountingEntryID: Int, accountingYear: Year): DBIO[Option[AccountingEntry]] = ???

  def deleteAccountingEntryAction(accountingEntryID: Int,
                                  accountingYear: Year)
                                 (implicit ec: ExecutionContext): DBIO[Unit] =
    Tables.dbAccountingEntryTable.filter(entry => entry.id === accountingEntryID && entry.accountingYear === accountingYear.getValue).delete.map(_ => ())

  def repsertAccountingEntryAction(accountingEntry: AccountingEntry)(implicit ec: ExecutionContext): DBIO[AccountingEntry] = ???
}