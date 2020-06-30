package db

import base.Id.AccountingEntryTemplateKey
import db.DAOCompanion.FindPredicate
import javax.inject.Inject
import play.api.db.slick.{ DatabaseConfigProvider, HasDatabaseConfigProvider }
import slick.jdbc.PostgresProfile
import slick.jdbc.PostgresProfile.api._

import scala.concurrent.ExecutionContext
import scala.language.higherKinds

class AccountingEntryTemplateDAO @Inject() (override protected val dbConfigProvider: DatabaseConfigProvider)(implicit
    executionContext: ExecutionContext
) extends HasDatabaseConfigProvider[PostgresProfile] {

  val dao: DAO[AccountingEntryTemplate, Tables.AccountingEntryTemplateTable, AccountingEntryTemplateKey] =
    DAO(AccountingEntryTemplateDAO.daoCompanion, dbConfigProvider)

}

object AccountingEntryTemplateDAO {

  val daoCompanion
      : DAOCompanion[AccountingEntryTemplate, Tables.AccountingEntryTemplateTable, AccountingEntryTemplateKey] =
    DAOCompanion(
      Tables.accountingEntryTemplateTable,
      (table, key) => table.id === key.id
    )

  val compareByCompany: FindPredicate[Tables.AccountingEntryTemplateTable, Int] =
    (table, companyId) => table.companyId === companyId

  def nextId(implicit ec: ExecutionContext): DBIO[Int] =
    daoCompanion.allAction.map { accountingEntryTemplates =>
      if (accountingEntryTemplates.isEmpty) 1
      else accountingEntryTemplates.maxBy(_.id).id + 1
    }

}
