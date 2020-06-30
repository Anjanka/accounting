package controllers

import base.Id
import db.creation.AccountingEntryTemplateCreationParams
import db.{AccountingEntryTemplate, AccountingEntryTemplateDAO}
import io.circe.Json
import io.circe.syntax._
import javax.inject.{Inject, Singleton}
import play.api.libs.circe.Circe
import play.api.mvc.{Action, AnyContent, BaseController, ControllerComponents}

import scala.concurrent.{ExecutionContext, Future}

@Singleton
class AccountingEntryTemplateController @Inject() (
    val controllerComponents: ControllerComponents,
    val accountingEntryTemplateDAO: AccountingEntryTemplateDAO
)(implicit ec: ExecutionContext)
    extends BaseController
    with Circe {

  def find(id: Int): Action[AnyContent] =
    Action.async {
      accountingEntryTemplateDAO.dao
        .find(Id.AccountingEntryTemplateKey(id = id))
        .map { x =>
          Ok(x.asJson)
        }
    }

  def insert: Action[Json] =
    Action.async(circe.json) { request =>
      val companyCreationParamsCandidate = request.body.as[AccountingEntryTemplateCreationParams]
      companyCreationParamsCandidate match {
        case Right(companyCreationParams) =>
          accountingEntryTemplateDAO.dao
            .insert(AccountingEntryTemplateCreationParams.create)(_ => AccountingEntryTemplateDAO.nextId)(companyCreationParams)
            .map(acc => Ok(acc.asJson))
        case Left(decodingFailure) =>
          Future(BadRequest(s"Could not parse ${request.body} as valid accounting entry template creation params: $decodingFailure"))
      }
    }

  def replace: Action[Json] =
    processAccountingEntryTemplateWith(
      accountingEntryTemplateDAO.dao.replace(_)(AccountingEntryTemplate.keyOf)
    )

  private def processAccountingEntryTemplateWith(
      f: AccountingEntryTemplate => Future[AccountingEntryTemplate]
  ): Action[Json] =
    Action.async(circe.json) { request =>
      val accountingEntryTemplateCandidate = request.body.as[AccountingEntryTemplate]
      accountingEntryTemplateCandidate match {
        case Right(value) =>
          f(value).map(acc => Ok(acc.asJson))
        case Left(decodingFailure) =>
          Future(BadRequest(s"Could not parse ${request.body} as valid accounting entry template: $decodingFailure"))
      }
    }

  def delete: Action[Json] =
    Action.async(circe.json) { request =>
      val accountIdCandidate = request.body.as[Id.AccountingEntryTemplateKey]
      accountIdCandidate match {
        case Right(value) =>
          accountingEntryTemplateDAO.dao
            .delete(value)
            .map(_ => Ok(s"Accounting entry template '${value.id}' was deleted successfully."))
        case Left(decodingFailure) =>
          Future(
            BadRequest(s"Could not parse ${request.body} as valid accounting entry template Id: $decodingFailure.")
          )
      }
    }

  def getAll(companyID: Int): Action[AnyContent] =
    Action.async {
      accountingEntryTemplateDAO.dao.findPartial(companyID)(AccountingEntryTemplateDAO.compareByCompany).map { x =>
        Ok(x.asJson)
      }
    }

}
