package db

import base.{AccountingEntryTemplate, MonetaryValue}
import javax.inject.Inject
import play.api.db.slick.{DatabaseConfigProvider, HasDatabaseConfigProvider}
import slick.dbio.DBIO
import slick.jdbc.PostgresProfile
import slick.lifted.Query
import slick.jdbc.PostgresProfile.api._

import scala.concurrent.ExecutionContext

class AccountingEntryTemplateDAO @Inject()(override protected val dbConfigProvider: DatabaseConfigProvider) extends HasDatabaseConfigProvider[PostgresProfile] {

}

object AccountingEntryTemplateDAO {
  def findAccountingEntryTemplateAction(description: String)
                                       (implicit ec: ExecutionContext): DBIO[Option[AccountingEntryTemplate]] = {
    for {
      dbAccountingEntryTemplates <- fetch(description).result
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
      for {
        (accounts, dbAccountingEntry, mv) <- triples.headOption
        (credit, debit) <- accounts
      } yield {
        AccountingEntryTemplate(
          description = dbAccountingEntry.description,
          credit = credit,
          debit = debit,
          amount = mv
        )
      }
    }
  }

  def deleteAccountingEntryAction(description: String)
                                 (implicit ec: ExecutionContext): DBIO[Unit] =
    fetch(description).delete.map(_ => ())

  def repsertAccountingEntryAction(accountingEntryTemplate: AccountingEntryTemplate)(implicit ec: ExecutionContext): DBIO[AccountingEntryTemplate] = {

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