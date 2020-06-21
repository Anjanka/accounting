package db

import javax.inject.Inject
import play.api.db.slick.{DatabaseConfigProvider, HasDatabaseConfigProvider}
import slick.dbio.DBIO
import slick.jdbc.PostgresProfile
import slick.jdbc.PostgresProfile.api._
import slick.lifted.Query

import scala.concurrent.{ExecutionContext, Future}
import scala.language.higherKinds

class AccountingEntryTemplateDAO @Inject()(override protected val dbConfigProvider: DatabaseConfigProvider)
                                          (implicit executionContext: ExecutionContext)
  extends HasDatabaseConfigProvider[PostgresProfile] {
  def findAccountingEntryTemplate(companyID: Int, description: String): Future[Option[AccountingEntryTemplate]] =
    db.run(AccountingEntryTemplateDAO.findAccountingEntryTemplateAction(companyID, description))

  def deleteAccountingEntryTemplate(companyID: Int, description: String): Future[Unit] =
    db.run(AccountingEntryTemplateDAO.deleteAccountingEntryTemplateAction(companyID, description))

  def repsertAccount(accountingEntryTemplate: AccountingEntryTemplate): Future[AccountingEntryTemplate] =
    db.run(AccountingEntryTemplateDAO.repsertAccountingEntryTemplateAction(accountingEntryTemplate))

  def getAllAccountingEntryTemplatesByCompany(companyID: Int) : Future[Seq[AccountingEntryTemplate]] =
    db.run(AccountingEntryTemplateDAO.getAllAccountingEntryTemplatesByCompanyAction(companyID))

}

object AccountingEntryTemplateDAO {

  def findAccountingEntryTemplateAction(companyID: Int, description: String): DBIO[Option[AccountingEntryTemplate]] =
    fetch(companyID, description).result.headOption

  def getAllAccountingEntryTemplatesByCompanyAction(companyID: Int): DBIO[Seq[AccountingEntryTemplate]] =
    Tables.accountingEntryTemplateTable.filter(entryTemplate => entryTemplate.companyId === companyID).result

  def deleteAccountingEntryTemplateAction(companyID: Int, description: String)
                                         (implicit ec: ExecutionContext): DBIO[Unit] =
    fetch(companyID, description).delete.map(_ => ())

  def repsertAccountingEntryTemplateAction(accountingEntryTemplate: AccountingEntryTemplate)
                                          (implicit ec: ExecutionContext): DBIO[AccountingEntryTemplate] = {
    Tables.accountingEntryTemplateTable.returning(Tables.accountingEntryTemplateTable).insertOrUpdate(accountingEntryTemplate).flatMap {
      case Some(dbEntryTemplate) if accountingEntryTemplate.credit == dbEntryTemplate.credit && accountingEntryTemplate.debit == dbEntryTemplate.debit =>
        DBIO.successful(accountingEntryTemplate)
      case Some(dbEntryTemplate) => DBIO.failed(new Throwable(s"Inserted entry template $dbEntryTemplate doesn't match given entry template $accountingEntryTemplate."))
      case None => DBIO.successful(accountingEntryTemplate)
    }
  }

  private def fetch(companyID: Int, description: String): Query[Tables.AccountingEntryTemplateDB, AccountingEntryTemplate, Seq] =
    Tables.accountingEntryTemplateTable.filter(entryTemplate => entryTemplate.companyId === companyID && entryTemplate.description === description)
}