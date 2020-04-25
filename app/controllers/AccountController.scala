package controllers

import db.AccountDAO
import javax.inject.{Inject, Singleton}
import play.api.mvc.{Action, AnyContent, BaseController, ControllerComponents}
import io.circe.syntax._

import scala.concurrent.ExecutionContext

@Singleton
class AccountController @Inject()(val controllerComponents: ControllerComponents,
                                  val accountDAO: AccountDAO)
                                 (implicit ec: ExecutionContext)
  extends BaseController {


  def getAccount(id: Int): Action[AnyContent] = Action.async {
    accountDAO.findAccount(id).map {
      x =>
        Ok(x.asJson.noSpaces)
    }
  }

}
