package db

import base.Id.AccountingEntryKey
import cats.data.OptionT
import db.DAOCompanion.FindPredicate
import db.creation.AccountingEntryCreationParams
import javax.inject.Inject
import play.api.db.slick.{ DatabaseConfigProvider, HasDatabaseConfigProvider }
import slick.jdbc.PostgresProfile
import slick.jdbc.PostgresProfile.api._
import base.CatsInstances.dbio._

import scala.concurrent.{ ExecutionContext, Future }
import scala.language.higherKinds

class AccountingEntryDAO @Inject() (override protected val dbConfigProvider: DatabaseConfigProvider)(implicit
    executionContext: ExecutionContext
) extends HasDatabaseConfigProvider[PostgresProfile] {

  val dao: DAO[AccountingEntry, Tables.AccountingEntryTable, AccountingEntryKey] =
    DAO(AccountingEntryDAO.daoCompanion, dbConfigProvider)

  def moveUp(accountingEntryKey: AccountingEntryKey): Future[Unit] =
    db.run(AccountingEntryDAO.moveUpAction(accountingEntryKey))

  def moveDown(accountingEntryKey: AccountingEntryKey): Future[Unit] =
    db.run(AccountingEntryDAO.moveDownAction(accountingEntryKey))

}

object AccountingEntryDAO {

  case class CompanyYearKey(companyId: Int, accountingYear: Int)

  val compareCompanyYearKey: FindPredicate[Tables.AccountingEntryTable, CompanyYearKey] =
    (entry, companyYearKey) =>
      entry.companyId === companyYearKey.companyId && entry.accountingYear === companyYearKey.accountingYear

  val daoCompanion: DAOCompanion[AccountingEntry, Tables.AccountingEntryTable, AccountingEntryKey] = DAOCompanion(
    _table = Tables.accountingEntryTable,
    _compare = (entry, key) =>
      entry.companyId === key.companyId &&
        entry.id === key.id &&
        entry.accountingYear === key.accountingYear
  )

  def nextId(accountingEntryCreationParams: AccountingEntryCreationParams)(implicit ec: ExecutionContext): DBIO[Int] =
    daoCompanion
      .findPartialAction(
        CompanyYearKey(accountingEntryCreationParams.companyId, accountingEntryCreationParams.accountingYear)
      )(compareCompanyYearKey)
      .map { accountingEntries =>
        if (accountingEntries.isEmpty) 1
        else accountingEntries.maxBy(_.id).id + 1
      }

  def swapAction(companyYearKey: CompanyYearKey, accountingEntryId1: Int, accountingEntryId2: Int)(implicit
      ec: ExecutionContext
  ): DBIO[Unit] = {
    val accountingEntryKey1 = AccountingEntryKey(
      companyId = companyYearKey.companyId,
      accountingYear = companyYearKey.accountingYear,
      id = accountingEntryId1
    )
    val accountingEntryKey2 = AccountingEntryKey(
      companyId = companyYearKey.companyId,
      accountingYear = companyYearKey.accountingYear,
      id = accountingEntryId2
    )
    val transformer = for {
      accountingEntry1 <- OptionT(daoCompanion.findAction(accountingEntryKey1))
      accountingEntry2 <- OptionT(daoCompanion.findAction(accountingEntryKey2))
      newAccountingEntry1 = accountingEntry2.copy(id = accountingEntry1.id)
      newAccountingEntry2 = accountingEntry1.copy(id = accountingEntry2.id)
      _ <- OptionT.liftF[DBIO, AccountingEntry](daoCompanion.replaceAction(newAccountingEntry1)(AccountingEntry.keyOf))
      _ <- OptionT.liftF[DBIO, AccountingEntry](daoCompanion.replaceAction(newAccountingEntry2)(AccountingEntry.keyOf))
    } yield ()
    transformer.getOrElseF(
      DBIO.failed(
        new Throwable(
          s"One of the Ids was not found: companyYearKey = $companyYearKey, id1 = $accountingEntryId1, id2 = $accountingEntryId2."
        )
      )
    )
  }

  def moveUpAction(accountingEntryKey: AccountingEntryKey)(implicit ec: ExecutionContext): DBIO[Unit] = {
    for {
      lowerIds <-
        daoCompanion.table
          .filter(ae =>
            ae.companyId === accountingEntryKey.companyId &&
              ae.accountingYear === accountingEntryKey.accountingYear && ae.id < accountingEntryKey.id
          )
          .map(_.id)
          .result
      result <- {
        if (lowerIds.isEmpty) DBIO.successful(())
        else
          swapAction(
            companyYearKey = CompanyYearKey(
              companyId = accountingEntryKey.companyId,
              accountingYear = accountingEntryKey.accountingYear
            ),
            accountingEntryId1 = accountingEntryKey.id,
            accountingEntryId2 = lowerIds.max
          )
      }
    } yield result
  }

  def moveDownAction(accountingEntryKey: AccountingEntryKey)(implicit ec: ExecutionContext): DBIO[Unit] = {
    for {
      lowerIds <-
        daoCompanion.table
          .filter(ae =>
            ae.companyId === accountingEntryKey.companyId &&
              ae.accountingYear === accountingEntryKey.accountingYear && ae.id > accountingEntryKey.id
          )
          .map(_.id)
          .result
      result <- {
        if (lowerIds.isEmpty) DBIO.successful(())
        else
          swapAction(
            companyYearKey = CompanyYearKey(
              companyId = accountingEntryKey.companyId,
              accountingYear = accountingEntryKey.accountingYear
            ),
            accountingEntryId1 = accountingEntryKey.id,
            accountingEntryId2 = lowerIds.min
          )
      }
    } yield result
  }

}
