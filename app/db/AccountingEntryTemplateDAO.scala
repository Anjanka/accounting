package db

import base.{Account, AccountingEntryTemplate, MonetaryValue}
import cats.Monad
import cats.implicits._
import javax.inject.Inject
import play.api.db.slick.{DatabaseConfigProvider, HasDatabaseConfigProvider}
import slick.dbio.DBIO
import slick.jdbc.PostgresProfile
import slick.lifted.Query
import slick.jdbc.PostgresProfile.api._
import base.CatsInstances.seq._

import scala.concurrent.{ExecutionContext, Future}
import scala.language.higherKinds

class AccountingEntryTemplateDAO @Inject()(override protected val dbConfigProvider: DatabaseConfigProvider)
                                          (implicit executionContext: ExecutionContext)
  extends HasDatabaseConfigProvider[PostgresProfile] {
  def findAccountingEntryTemplate(description: String): Future[Option[AccountingEntryTemplate]] =
    db.run(AccountingEntryTemplateDAO.findAccountingEntryTemplateAction(description))

  def deleteAccountingEntryTemplate(description: String): Future[Unit] =
    db.run(AccountingEntryTemplateDAO.deleteAccountingEntryTemplateAction(description))

  def repsertAccount(accountingEntryTemplate: AccountingEntryTemplate): Future[AccountingEntryTemplate] =
    db.run(AccountingEntryTemplateDAO.repsertAccountingEntryTemplateAction(accountingEntryTemplate))

  def getAllAccountingEntryTemplates: Future[Seq[AccountingEntryTemplate]] =
    db.run(AccountingEntryTemplateDAO.getAllAccountingEntryTemplatesAction)

}

object AccountingEntryTemplateDAO {

  def findAccountingEntryTemplateAction(description: String)
                                       (implicit ec: ExecutionContext): DBIO[Option[AccountingEntryTemplate]] =
    findAccountingEntryTemplateWithAction(fetch(description), _.headOption, identity)

  def getAllAccountingEntryTemplatesAction (implicit ec: ExecutionContext): DBIO[Seq[AccountingEntryTemplate]] =
    findAccountingEntryTemplateWithAction(Tables.dbAccountingEntryTemplateTable, identity, _.toSeq)

  private type AccountingTemplateTriple = (Option[(Account, Account)], DBAccountingEntryTemplate, MonetaryValue)

  private def findAccountingEntryTemplateWithAction[Container[_] : Monad](query: Query[Tables.DBAccountingEntryTemplateDB, DBAccountingEntryTemplate, Seq],
                                                                          relevantTriples: Seq[AccountingTemplateTriple] => Container[AccountingTemplateTriple],
                                                                          fromOption: Option[(Account, Account)] => Container[(Account, Account)])
                                                                         (implicit ec: ExecutionContext): DBIO[Container[AccountingEntryTemplate]] = {
    for {
      dbAccountingEntryTemplates <- query.result
      xs = dbAccountingEntryTemplates.map {
        db =>
          val accountsOpt = for {
            creditOpt <- AccountDAO.findAccountAction(db.credit)
            debitOpt <- AccountDAO.findAccountAction(db.debit)
          } yield {
            for {
              credit <- creditOpt
              debit <- debitOpt
            } yield (credit, debit)
          }
          val monetaryValue = MonetaryValue.fromAllCents(100 * db.amountWhole + db.amountChange)
          accountsOpt.map(accounts => (accounts, db, monetaryValue))
      }
      triples <- DBIO.sequence(xs)

    } yield {
      relevantTriples(triples).flatMap { case (accounts, dbAccountingEntryTemplate, mv) =>
        fromOption(accounts).map { case (credit, debit) =>
          AccountingEntryTemplate(
            description = dbAccountingEntryTemplate.description,
            credit = credit,
            debit = debit,
            amount = mv
          )
        }

      }
    }
  }

  def deleteAccountingEntryTemplateAction(description: String)
                                         (implicit ec: ExecutionContext): DBIO[Unit] =
    fetch(description).delete.map(_ => ())

  def repsertAccountingEntryTemplateAction(accountingEntryTemplate: AccountingEntryTemplate)(implicit ec: ExecutionContext): DBIO[AccountingEntryTemplate] = {

    val entryTemplate = DBAccountingEntryTemplate(
      accountingEntryTemplate.description,
      accountingEntryTemplate.credit.id,
      accountingEntryTemplate.debit.id,
      accountingEntryTemplate.amount.whole.toInt,
      accountingEntryTemplate.amount.change.toCents.toInt
    )
    Tables.dbAccountingEntryTemplateTable.returning(Tables.dbAccountingEntryTemplateTable).insertOrUpdate(entryTemplate).flatMap {
      case Some(dbEntryTemplate) if accountingEntryTemplate.credit.id == dbEntryTemplate.credit && accountingEntryTemplate.debit.id == dbEntryTemplate.debit =>
        DBIO.successful(
          accountingEntryTemplate.copy(
            description = dbEntryTemplate.description,
            amount = MonetaryValue.fromAllCents(100 * dbEntryTemplate.amountWhole + dbEntryTemplate.amountChange)
          )
        )
      case Some(dbEntryTemplate) => DBIO.failed(new Throwable(s"Inserted entry template $dbEntryTemplate doesn't match given entry template $accountingEntryTemplate."))
      case None => DBIO.successful(accountingEntryTemplate)
    }
  }

  private def fetch(description: String): Query[Tables.DBAccountingEntryTemplateDB, DBAccountingEntryTemplate, Seq] =
    Tables.dbAccountingEntryTemplateTable.filter(entryTemplate => entryTemplate.description === description)
}