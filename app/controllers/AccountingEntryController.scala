package controllers

import java.time.Year

import base.Id2
import db.{AccountingEntryDAO, AccountingEntry}
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

  def findAccountingEntry(id: Int, accountingYear: Int): Action[AnyContent] = Action.async {
    accountingEntryDAO.findAccountingEntry(id, Year.of(accountingYear)).map {
      x =>
        Ok(x.asJson)
    }
  }

  def findAccountingEntriesByYear(accountingYear: Int): Action[AnyContent] = Action.async {
    accountingEntryDAO.findAccountingEntriesByYear(Year.of(accountingYear)).map {
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
    val accountIdCandidate = request.body.as[Id2[Int, Year]]
    accountIdCandidate match {
      case Right(value) =>
        accountingEntryDAO.deleteAccountingEntry(value.id1, value.id2).map(_ => Ok(s"Accounting Entry ${value.id1} from Year ${value.id2} was deleted successfully."))
      case Left(decodingFailure) =>
        Future(BadRequest(s"Could not parse ${request.body} as valid accounting entry Id: $decodingFailure."))
    }
  }

}
