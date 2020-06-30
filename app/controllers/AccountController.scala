package controllers

import base.Id.AccountKey
import db.{Account, AccountDAO, Tables}
import io.circe.Json
import io.circe.syntax._
import javax.inject.{Inject, Singleton}
import play.api.libs.circe.Circe
import play.api.mvc.{Action, AnyContent, BaseController, ControllerComponents}
import slick.dbio.DBIO

import scala.concurrent.ExecutionContext

@Singleton
class AccountController @Inject() (val controllerComponents: ControllerComponents, val accountDAO: AccountDAO)(implicit
    ec: ExecutionContext
) extends BaseController
    with Circe {

  val controller: Controller[Account, Tables.AccountTable, AccountKey, Account, Unit] =
    Controller[Account, Tables.AccountTable, AccountKey, Account, Unit](
      _ => DBIO.successful(()),
      (_, ps) => ps,
      Account.keyOf,
      accountDAO.dao
    )(
      controllerComponents
    )

  def find(companyID: Int, id: Int): Action[AnyContent] =
    controller.find(AccountKey(companyID = companyID, id = id))

  def insert: Action[Json] =
    controller.insert

  def replace: Action[Json] =
    controller.replace

  def delete: Action[Json] =
    controller.delete

  def getAll(companyID: Int): Action[AnyContent] =
    Action.async {
      accountDAO.dao.findPartial(companyID)(AccountDAO.compareByCompany).map { x =>
        Ok(x.asJson)
      }
    }

}
