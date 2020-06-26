package controllers


import base.Id.CompanyKey
import db.{Company, CompanyDAO}
import io.circe.Json
import io.circe.syntax._
import javax.inject.{Inject, Singleton}
import play.api.libs.circe.Circe
import play.api.mvc.{Action, AnyContent, BaseController, ControllerComponents}

import scala.concurrent.{ExecutionContext, Future}


@Singleton
class CompanyController @Inject()(val controllerComponents: ControllerComponents,
                                  val companyDAO: CompanyDAO)
                                 (implicit ec: ExecutionContext)
  extends BaseController with Circe {


  def findCompany(id: Int): Action[AnyContent] = Action.async {
    companyDAO.findCompany(CompanyKey(id = id)).map {
      x =>
        Ok(x.asJson)
    }
  }

  def repsert: Action[Json] = Action.async(circe.json) { request =>
    val companyCandidate = request.body.as[Company]
    companyCandidate match {
      case Right(value) =>
        companyDAO.repsertCompany(value).map(acc => Ok(acc.asJson))
      case Left(decodingFailure) =>
        Future(BadRequest(s"Could not parse ${request.body} as valid company: $decodingFailure"))
    }
  }

  def delete: Action[Json] = Action.async(circe.json) { request =>
    val companyIdCandidate = request.body.as[CompanyKey]
    companyIdCandidate match {
      case Right(value) =>
        companyDAO.deleteCompany(value).map(_ => Ok(s"Company ${value} was deleted successfully."))
          .recover { case ex => InternalServerError(ex.getMessage)}
      case Left(decodingFailure) =>
        Future(BadRequest(s"Could not parse ${request.body} as valid company Id: $decodingFailure."))
    }
  }

  def getAllCompanies: Action[AnyContent] = Action.async {
    companyDAO.getAllCompanies.map {
      x =>
        Ok(x.asJson)
    }
  }
}



