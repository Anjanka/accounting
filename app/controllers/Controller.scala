package controllers

import controllers.syntax._
import db.DAO
import io.circe.syntax._
import io.circe.{ Decoder, DecodingFailure, Encoder, Json }
import play.api.libs.circe.Circe
import play.api.mvc._
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
    parseAndProcess("creation params", dao.insert(constructor)(nextId))((_, c) => Ok(c.asJson))

  def replace: Action[Json] =
    parseAndProcess("value", dao.replace(_: Content)(keyOf))((_, c) => Ok(c.asJson))

  def delete: Action[Json] =
    parseAndProcess("id", dao.delete)((key, _) => Ok(s"Value with $key was deleted successfully."))

  def findAll: Action[AnyContent] =
    Action.async {
      dao.all.map { values =>
        Ok(values.asJson)
      }.recoverServerError
    }

  private def parseAndProcess[A: Decoder, B](suffix: String, process: A => Future[B])(
      respond: (A, B) => Result
  ): Action[Json] =
    Action.async(circe.json) { request =>
      val aCandidate = request.body.as[A]
      val result = aCandidate match {
        case Right(a) =>
          process(a)
            .map(respond(a, _))
        case Left(decodingFailure) =>
          Future(BadRequest(Controller.mkError(request.body, suffix, decodingFailure)))
      }
      result.recoverServerError
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
