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
  def findAccountingEntryTemplate(description: String): Future[Option[DBAccountingEntryTemplate]] =
    db.run(AccountingEntryTemplateDAO.findAccountingEntryTemplateAction(description))

  def deleteAccountingEntryTemplate(description: String): Future[Unit] =
    db.run(AccountingEntryTemplateDAO.deleteAccountingEntryTemplateAction(description))

  def repsertAccount(accountingEntryTemplate: DBAccountingEntryTemplate): Future[DBAccountingEntryTemplate] =
    db.run(AccountingEntryTemplateDAO.repsertAccountingEntryTemplateAction(accountingEntryTemplate))

  def getAllAccountingEntryTemplates: Future[Seq[DBAccountingEntryTemplate]] =
    db.run(AccountingEntryTemplateDAO.getAllAccountingEntryTemplatesAction)

}

object AccountingEntryTemplateDAO {

  def findAccountingEntryTemplateAction(description: String): DBIO[Option[DBAccountingEntryTemplate]] =
    fetch(description).result.headOption

  def getAllAccountingEntryTemplatesAction: DBIO[Seq[DBAccountingEntryTemplate]] =
    Tables.dbAccountingEntryTemplateTable.result

  def deleteAccountingEntryTemplateAction(description: String)
                                         (implicit ec: ExecutionContext): DBIO[Unit] =
    fetch(description).delete.map(_ => ())

  def repsertAccountingEntryTemplateAction(accountingEntryTemplate: DBAccountingEntryTemplate)
                                          (implicit ec: ExecutionContext): DBIO[DBAccountingEntryTemplate] = {
    Tables.dbAccountingEntryTemplateTable.returning(Tables.dbAccountingEntryTemplateTable).insertOrUpdate(accountingEntryTemplate).flatMap {
      case Some(dbEntryTemplate) if accountingEntryTemplate.credit == dbEntryTemplate.credit && accountingEntryTemplate.debit == dbEntryTemplate.debit =>
        DBIO.successful(accountingEntryTemplate)
      case Some(dbEntryTemplate) => DBIO.failed(new Throwable(s"Inserted entry template $dbEntryTemplate doesn't match given entry template $accountingEntryTemplate."))
      case None => DBIO.successful(accountingEntryTemplate)
    }
  }

  private def fetch(description: String): Query[Tables.DBAccountingEntryTemplateDB, DBAccountingEntryTemplate, Seq] =
    Tables.dbAccountingEntryTemplateTable.filter(entryTemplate => entryTemplate.description === description)
}