package controllers

import controllers.syntax._
import db.DAO
import io.circe.syntax._
import io.circe.{ Decoder, DecodingFailure, Encoder, Json }
import play.api.libs.circe.Circe
import play.api.mvc.{ Action, AnyContent, BaseController, ControllerComponents, Result }
import slick.dbio.DBIO
import slick.relational.RelationalProfile

import scala.concurrent.{ ExecutionContext, Future }

trait Controller[Content, Table <: RelationalProfile#Table[Content], Key, CreationParams, Id]
    extends BaseController
    with Circe {

  protected implicit def executionContext: ExecutionContext
  protected implicit def encoderContent: Encoder[Content]
  protected implicit def decoderContent: Decoder[Content]

  protected implicit def creationParamsDecoder: Decoder[CreationParams]
  protected implicit def keyDecoder: Decoder[Key]
  def nextId: CreationParams => DBIO[Id]
  def constructor: (Id, CreationParams) => Content
  def keyOf: Content => Key

  def dao: DAO[Content, Table, Key]

  def find(key: Key): Action[AnyContent] =
    Action.async {
      dao.find(key).map(result => Ok(result.asJson)).recoverServerError
    }

  def insert: Action[Json] =
    Action.async(circe.json) { request =>
      val creationParamsCandidate = request.body.as[CreationParams]
      val result = creationParamsCandidate match {
        case Right(creationParams) =>
          dao
            .insert(constructor)(nextId)(creationParams)
            .map(acc => Ok(acc.asJson))
        case Left(decodingFailure) =>
          Future(BadRequest(Controller.mkError(request.body, "creation params", decodingFailure)))
      }
      result.recoverServerError
    }

  def replace: Action[Json] =
    Action.async(circe.json) { request =>
      val contentCandidate = request.body.as[Content]
      val result = contentCandidate match {
        case Right(value) =>
          dao.replace(value)(keyOf).map(acc => Ok(acc.asJson))
        case Left(decodingFailure) =>
          Future(BadRequest(Controller.mkError(request.body, "value", decodingFailure)))
      }
      result.recoverServerError
    }

  def delete: Action[Json] =
    Action.async(circe.json) { request =>
      val keyCandidate = request.body.as[Key]
      val result = keyCandidate match {
        case Right(key) =>
          dao
            .delete(key)
            .map(_ => Ok(s"Value with $key was deleted successfully."))
        case Left(decodingFailure) =>
          Future(BadRequest(Controller.mkError(request.body, "id", decodingFailure)))
      }
      result.recoverServerError
    }

  def getAll: Action[AnyContent] =
    Action.async {
      dao.all.map { values =>
        Ok(values.asJson)
      }.recoverServerError
    }

}

object Controller {

  private def mkError(body: Json, suffix: String, decodingFailure: DecodingFailure): String = {
    s"Could not parse $body as valid $suffix: $decodingFailure."
  }

  def apply[Content, Table <: RelationalProfile#Table[Content], Key, CreationParams, Id](
      _nextId: CreationParams => DBIO[Id],
      _constructor: (Id, CreationParams) => Content,
      _keyOf: Content => Key,
      _dao: DAO[Content, Table, Key]
  )(_controllerComponents: ControllerComponents)(implicit
      _executionContext: ExecutionContext,
      _encoderContent: Encoder[Content],
      _decoderContent: Decoder[Content],
      _creationParamsDecoder: Decoder[CreationParams],
      _keyDecoder: Decoder[Key]
  ): Controller[Content, Table, Key, CreationParams, Id] =
    new Controller[Content, Table, Key, CreationParams, Id] {
      override val nextId: CreationParams => DBIO[Id] = _nextId
      override val constructor: (Id, CreationParams) => Content = _constructor
      override val keyOf: Content => Key = _keyOf
      override val dao: DAO[Content, Table, Key] = _dao
      override protected val controllerComponents: ControllerComponents = _controllerComponents
      override protected val executionContext: ExecutionContext = _executionContext
      override protected val encoderContent: Encoder[Content] = _encoderContent
      override protected val decoderContent: Decoder[Content] = _decoderContent
      override protected val creationParamsDecoder: Decoder[CreationParams] = _creationParamsDecoder
      override protected val keyDecoder: Decoder[Key] = _keyDecoder
    }

}
