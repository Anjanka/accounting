package controllers

import base.Id
import db.{AccountDAO, Account}
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


  def find(companyID: Int, id: Int): Action[AnyContent] = Action.async {
    accountDAO.dao.find(Id.AccountKey(companyID = companyID, id = id)).map {
      x =>
        Ok(x.asJson)
    }
  }

  def repsert: Action[Json] = Action.async(circe.json) { request =>
    val accountCandidate = request.body.as[Account]
    accountCandidate match {
      case Right(value) =>
        accountDAO.dao.repsert(value).map(acc => Ok(acc.asJson))
      case Left(decodingFailure) =>
        Future(BadRequest(s"Could not parse ${request.body} as valid account: $decodingFailure"))
    }
  }

  def delete: Action[Json] = Action.async(circe.json) { request =>
    val accountIdCandidate = request.body.as[Id.AccountKey]
    accountIdCandidate match {
      case Right(value) =>
        accountDAO.dao.delete(value).map(_ => Ok(s"Account ${value.id} was deleted successfully."))
          .recover { case ex => InternalServerError(ex.getMessage)}
      case Left(decodingFailure) =>
        Future(BadRequest(s"Could not parse ${request.body} as valid account Id: $decodingFailure."))
    }
  }

  def getAll(companyID: Int): Action[AnyContent] = Action.async {
    accountDAO.dao.findPartial(companyID)(AccountDAO.compareByCompany).map {
      x =>
        Ok(x.asJson)
    }
  }
}
