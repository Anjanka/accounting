package controllers

import base.Id.CompanyKey
import db.creation.CompanyCreationParams
import db.{ Company, CompanyDAO, Tables }
import io.circe.Json
import javax.inject.{ Inject, Singleton }
import play.api.libs.circe.Circe
import play.api.mvc.{ Action, AnyContent, BaseController, ControllerComponents }

import scala.concurrent.ExecutionContext

@Singleton
class CompanyController @Inject() (val controllerComponents: ControllerComponents, val companyDAO: CompanyDAO)(implicit
    ec: ExecutionContext
) extends BaseController
    with Circe {

  val controller: Controller[Company, Tables.CompanyTable, CompanyKey, CompanyCreationParams, Int] =
    Controller[Company, Tables.CompanyTable, CompanyKey, CompanyCreationParams, Int](
      _ => CompanyDAO.nextId,
      CompanyCreationParams.create,
      Company.keyOf,
      companyDAO.dao
    )(
      controllerComponents
    )

  def find(id: Int): Action[AnyContent] =
    controller.find(CompanyKey(id))

  def insert: Action[Json] =
    controller.insert

  def replace: Action[Json] =
    controller.replace

  def delete: Action[Json] =
    controller.delete

  def getAll: Action[AnyContent] =
    controller.getAll

}
