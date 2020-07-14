package controllers

import base.Id.AccountingEntryKey
import db.AccountingEntryDAO.CompanyYearKey
import db.creation.AccountingEntryCreationParams
import db.{ AccountingEntry, AccountingEntryDAO, Tables }
import io.circe
import io.circe.Json
import javax.inject.{ Inject, Singleton }
import play.api.libs.circe.Circe
import play.api.mvc.{ Action, AnyContent, BaseController, ControllerComponents }

import scala.concurrent.ExecutionContext

@Singleton
class AccountingEntryController @Inject() (
    val controllerComponents: ControllerComponents,
    val accountingEntryDAO: AccountingEntryDAO
)(implicit ec: ExecutionContext)
    extends BaseController
    with Circe {

  val controller: Controller[
    AccountingEntry,
    Tables.AccountingEntryTable,
    AccountingEntryKey,
    AccountingEntryCreationParams,
    Int
  ] =
    Controller[AccountingEntry, Tables.AccountingEntryTable, AccountingEntryKey, AccountingEntryCreationParams, Int](
      AccountingEntryDAO.nextId,
      AccountingEntryCreationParams.create,
      AccountingEntry.keyOf,
      accountingEntryDAO.dao
    )(
      controllerComponents
    )

  def find(companyId: Int, id: Int, accountingYear: Int): Action[AnyContent] =
    controller.find(AccountingEntryKey(companyId = companyId, id = id, accountingYear = accountingYear))

  def findByYear(companyId: Int, accountingYear: Int): Action[AnyContent] =
    controller.findPartial(CompanyYearKey(companyId, accountingYear))(AccountingEntryDAO.compareCompanyYearKey)

  def replace: Action[Json] =
    controller.replace

  def insert: Action[Json] =
    controller.insert

  def delete: Action[Json] =
    controller.delete

  def moveUp: Action[Json] =
    controller.parseAndProcess("accountingEntryKey", accountingEntryDAO.moveUp)((key, _) =>
      Ok(s"AccountingEntry with key = $key was moved up successfully.")
    )

  def moveDown: Action[Json] =
    controller.parseAndProcess("accountingEntryKey", accountingEntryDAO.moveDown)((key, _) =>
      Ok(s"AccountingEntry with key = $key was moved down successfully.")
    )

}
