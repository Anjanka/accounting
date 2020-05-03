package controllers

import base.{AccountingEntryTemplate, Id}
import db.AccountingEntryTemplateDAO
import io.circe.Json
import io.circe.syntax._
import javax.inject.{Inject, Singleton}
import play.api.libs.circe.Circe
import play.api.mvc.{Action, AnyContent, BaseController, ControllerComponents}

import scala.concurrent.{ExecutionContext, Future}

@Singleton
class AccountingEntryTemplateController  @Inject()(val controllerComponents: ControllerComponents,
                                                   val accountingEntryTemplateDAO: AccountingEntryTemplateDAO)
                                                  (implicit ec: ExecutionContext)
  extends BaseController with Circe  {


  def getAccountingEntryTemplate(description: String): Action[AnyContent] = Action.async {
    accountingEntryTemplateDAO.findAccountingEntryTemplate(description).map {
      x =>
        Ok(x.asJson)
    }
  }

  def repsert: Action[Json] = Action.async(circe.json) { request =>
    val accountingEntryTemplateCandidate = request.body.as[AccountingEntryTemplate]
    accountingEntryTemplateCandidate match {
      case Right(value) =>
        accountingEntryTemplateDAO.repsertAccount(value).map(acc => Ok(acc.asJson))
      case Left(decodingFailure) =>
        Future(BadRequest(s"Could not parse ${request.body} as valid accounting entry template: $decodingFailure"))
    }
  }

  def delete: Action[Json] = Action.async(circe.json) { request =>
    val accountIdCandidate = request.body.as[Id[String]]
    accountIdCandidate match {
      case Right(value) =>
        accountingEntryTemplateDAO.deleteAccountingEntryTemplate(value.id).map(_ => Ok(s"Accounting entry template '${value.id}' was deleted successfully."))
      case Left(decodingFailure) =>
        Future(BadRequest(s"Could not parse ${request.body} as valid accounting entry template Id: $decodingFailure."))
    }
  }
}
