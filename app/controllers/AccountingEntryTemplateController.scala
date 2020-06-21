package controllers

import base.Id
import db.{AccountingEntryTemplateDAO, AccountingEntryTemplate}
import io.circe.Json
import io.circe.syntax._
import javax.inject.{Inject, Singleton}
import play.api.libs.circe.Circe
import play.api.mvc.{Action, AnyContent, BaseController, ControllerComponents}

import scala.concurrent.{ExecutionContext, Future}

@Singleton
class AccountingEntryTemplateController @Inject()(val controllerComponents: ControllerComponents,
                                                  val accountingEntryTemplateDAO: AccountingEntryTemplateDAO)
                                                 (implicit ec: ExecutionContext)
  extends BaseController with Circe {


  def findAccountingEntryTemplate(companyID: Int, description: String): Action[AnyContent] = Action.async {
    accountingEntryTemplateDAO.findAccountingEntryTemplate(Id.AccountingEntryTemplateKey(companyID = companyID, description = description)).map {
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
    val accountIdCandidate = request.body.as[Id.AccountingEntryTemplateKey]
    accountIdCandidate match {
      case Right(value) =>
        accountingEntryTemplateDAO.deleteAccountingEntryTemplate(value).map(_ => Ok(s"Accounting entry template '${value.description}' was deleted successfully."))
      case Left(decodingFailure) =>
        Future(BadRequest(s"Could not parse ${request.body} as valid accounting entry template Id: $decodingFailure."))
    }
  }

  def getAllAccountingEntryTemplates(companyID: Int): Action[AnyContent] = Action.async {
    accountingEntryTemplateDAO.getAllAccountingEntryTemplatesByCompany(companyID).map {
      x =>
        Ok(x.asJson)
    }
  }
}
