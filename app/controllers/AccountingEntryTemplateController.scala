package controllers

import action.UserAction
import base.Id.AccountingEntryTemplateKey
import db.creation.AccountingEntryTemplateCreationParams
import db.{ AccountingEntryTemplate, AccountingEntryTemplateDAO, Tables }
import io.circe.Json

import javax.inject.{ Inject, Singleton }
import play.api.mvc.{ Action, AnyContent, BaseController, ControllerComponents }

import scala.concurrent.ExecutionContext

@Singleton
class AccountingEntryTemplateController @Inject() (
    override protected val controllerComponents: ControllerComponents,
    accountingEntryTemplateDAO: AccountingEntryTemplateDAO,
    userAction: UserAction
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
      accountingEntryTemplateDAO.dao,
      userAction
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

  def findAll(companyId: Int): Action[AnyContent] =
    controller.findPartial(companyId)(AccountingEntryTemplateDAO.compareByCompany)

}
