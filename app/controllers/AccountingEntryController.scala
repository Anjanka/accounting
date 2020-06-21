package controllers

import java.time.Year

import base.{Id, Id2}
import db.{AccountingEntry, AccountingEntryDAO}
import io.circe.Json
import io.circe.syntax._
import javax.inject.{Inject, Singleton}
import play.api.libs.circe.Circe
import play.api.mvc.{Action, AnyContent, BaseController, ControllerComponents}

import scala.concurrent.{ExecutionContext, Future}

@Singleton
class AccountingEntryController @Inject()(val controllerComponents: ControllerComponents,
                                          val accountingEntryDAO: AccountingEntryDAO)
                                         (implicit ec: ExecutionContext)
  extends BaseController with Circe {

  def findAccountingEntry(companyID: Int, id: Int, accountingYear: Int): Action[AnyContent] = Action.async {
    accountingEntryDAO.findAccountingEntry(Id.AccountingEntryKey(companyID = companyID, id = id, accountingYear = accountingYear)).map {
      x =>
        Ok(x.asJson)
    }
  }

  def findAccountingEntriesByYear(companyID: Int, accountingYear: Int): Action[AnyContent] = Action.async {
    accountingEntryDAO.findAccountingEntriesByCompanyAndYear(companyID, accountingYear).map {
      x =>
        Ok(x.asJson)
    }
  }

  def repsert: Action[Json] = Action.async(circe.json) { request =>
    val accountingEntryCandidate = request.body.as[AccountingEntry]
    accountingEntryCandidate match {
      case Right(value) =>
        accountingEntryDAO.repsertAccountingEntry(value).map(entry => Ok(entry.asJson))
      case Left(decodingFailure) =>
        Future(BadRequest(s"Could not parse ${request.body} as valid accounting entry: $decodingFailure"))
    }
  }

  def delete: Action[Json] = Action.async(circe.json) { request =>
    val accountIdCandidate = request.body.as[Id.AccountingEntryKey]
    accountIdCandidate match {
      case Right(value) =>
        accountingEntryDAO.deleteAccountingEntry(value).map(_ => Ok(s"Accounting Entry ${value.id} from Year ${value.accountingYear} was deleted successfully."))
      case Left(decodingFailure) =>
        Future(BadRequest(s"Could not parse ${request.body} as valid accounting entry Id: $decodingFailure."))
    }
  }

}
