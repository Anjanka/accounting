package controllers

import action.UserAction
import base.Id.AccountKey
import db.{ Account, AccountDAO, Tables }
import io.circe.Json

import javax.inject.{ Inject, Singleton }
import play.api.mvc.{ Action, AnyContent, BaseController, ControllerComponents }
import slick.dbio.DBIO

import scala.concurrent.ExecutionContext

@Singleton
class AccountController @Inject() (
    override protected val controllerComponents: ControllerComponents,
    accountDAO: AccountDAO,
    userAction: UserAction
)(implicit
    ec: ExecutionContext
) extends BaseController {

  val controller: Controller[Account, Tables.AccountTable, AccountKey, Account, Unit] =
    Controller[Account, Tables.AccountTable, AccountKey, Account, Unit](
      _ => DBIO.successful(()),
      (_, ps) => ps,
      Account.keyOf,
      accountDAO.dao,
      userAction
    )(
      controllerComponents
    )

  def find(companyId: Int, id: Int): Action[AnyContent] =
    controller.find(AccountKey(companyId = companyId, id = id))

  def insert: Action[Json] =
    controller.insert

  def replace: Action[Json] =
    controller.replace

  def delete: Action[Json] =
    controller.delete

  def findAll(companyId: Int): Action[AnyContent] =
    controller.findPartial(companyId)(AccountDAO.compareByCompany)

}
