package controllers

import base.Account
import db.AccountDAO
import io.circe.Json
import io.circe.syntax._
import javax.inject.{Inject, Singleton}
import play.api.libs.circe.Circe
import play.api.mvc.{Action, AnyContent, BaseController, ControllerComponents}

import scala.concurrent.{ExecutionContext, Future}

@Singleton
class AccountController @Inject()(val controllerComponents: ControllerComponents,
                                  val accountDAO: AccountDAO)
                                 (implicit ec: ExecutionContext)
  extends BaseController with Circe {


  def getAccount(id: Int): Action[AnyContent] = Action.async {
    accountDAO.findAccount(id).map {
      x =>
        Ok(x.asJson.noSpaces)
    }
  }

  def repsert: Action[Json] = Action.async(circe.json) { request =>
    val accountCandidate = request.body.as[Account]
    accountCandidate match {
      case Right(value) =>
        accountDAO.repsertAccount(value).map(acc => Ok(acc.asJson))
      case Left(decodingFailure) =>
        Future(BadRequest(s"Could not parse ${request.body} as valid account: $decodingFailure"))
    }
  }

}
