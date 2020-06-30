package controllers

import base.Id.AccountingEntryTemplateKey
import db.creation.AccountingEntryTemplateCreationParams
import db.{ AccountingEntryTemplate, AccountingEntryTemplateDAO, Tables }
import io.circe.Json
import javax.inject.{ Inject, Singleton }
import play.api.mvc.{ Action, AnyContent, BaseController, ControllerComponents }

import scala.concurrent.ExecutionContext

@Singleton
class AccountingEntryTemplateController @Inject() (
    val controllerComponents: ControllerComponents,
    val accountingEntryTemplateDAO: AccountingEntryTemplateDAO
)(implicit ec: ExecutionContext)
    extends BaseController {

  val controller: Controller[
    AccountingEntryTemplate,
    Tables.AccountingEntryTemplateTable,
    AccountingEntryTemplateKey,
    AccountingEntryTemplateCreationParams,
    Int
  ] =
    Controller[
      AccountingEntryTemplate,
      Tables.AccountingEntryTemplateTable,
      AccountingEntryTemplateKey,
      AccountingEntryTemplateCreationParams,
      Int
    ](
      _ => AccountingEntryTemplateDAO.nextId,
      AccountingEntryTemplateCreationParams.create,
      AccountingEntryTemplate.keyOf,
      accountingEntryTemplateDAO.dao
    )(
      controllerComponents
    )

  def find(id: Int): Action[AnyContent] =
    controller.find(AccountingEntryTemplateKey(id = id))

  def insert: Action[Json] =
    controller.insert

  def replace: Action[Json] =
    controller.replace

  def delete: Action[Json] =
    controller.delete

  def findAll(companyID: Int): Action[AnyContent] =
    controller.findPartial(companyID)(AccountingEntryTemplateDAO.compareByCompany)

}
