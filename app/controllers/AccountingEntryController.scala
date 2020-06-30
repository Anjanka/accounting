package controllers

import base.Id.AccountingEntryKey
import db.AccountingEntryDAO.CompanyYearKey
import db.creation.AccountingEntryCreationParams
import db.{ AccountingEntry, AccountingEntryDAO, Tables }
import io.circe.Json
import javax.inject.{ Inject, Singleton }
import play.api.mvc.{ Action, AnyContent, BaseController, ControllerComponents }

import scala.concurrent.ExecutionContext

@Singleton
class AccountingEntryController @Inject() (
    val controllerComponents: ControllerComponents,
    val accountingEntryDAO: AccountingEntryDAO
)(implicit ec: ExecutionContext)
    extends BaseController {

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

  def find(companyID: Int, id: Int, accountingYear: Int): Action[AnyContent] =
    controller.find(AccountingEntryKey(companyID = companyID, id = id, accountingYear = accountingYear))

  def findByYear(companyID: Int, accountingYear: Int): Action[AnyContent] =
    controller.findPartial(CompanyYearKey(companyID, accountingYear))(AccountingEntryDAO.compareCompanyYearKey)

  def replace: Action[Json] =
    controller.replace

  def insert: Action[Json] =
    controller.insert

  def delete: Action[Json] =
    controller.delete

}
