package db

import db.DAOCompanion.FindPredicate
import slick.jdbc.PostgresProfile.api._
import slick.lifted.{ Rep, TableQuery }
import slick.relational.RelationalProfile

import scala.concurrent.ExecutionContext

trait DAOCompanion[Content, Table <: RelationalProfile#Table[Content], Key] {

  def table: TableQuery[Table]

  def compare: FindPredicate[Table, Key]

  def findAction(key: Key): DBIO[Option[Content]] =
    findQuery(key).result.headOption

  def findPartialAction[Part](
      part: Part
  )(partCompare: FindPredicate[Table, Part]): DBIO[Seq[Content]] =
    findPartialQuery(partCompare)(part).result

  def findPartialQuery[Part](
      partCompare: FindPredicate[Table, Part]
  )(part: Part): Query[Table, Content, Seq] =
    table.filter(partCompare(_, part))

  def allAction: DBIO[Seq[Content]] =
    table.result

  def deleteAction(key: Key)(implicit ec: ExecutionContext): DBIO[Unit] =
    findQuery(key).delete.map(_ => ())

  def insertAction[CreationParams, MissingId](
      constructor: (MissingId, CreationParams) => Content
  )(
      nextMissingId: CreationParams => DBIO[MissingId]
  )(creationParams: CreationParams)(implicit ec: ExecutionContext): DBIO[Content] =
    nextMissingId(creationParams).flatMap { missingId =>
      val content = constructor(missingId, creationParams)
      table.returning(table) += content
    }

  def replaceAction(value: Content)(keyOf: Content => Key)(implicit ec: ExecutionContext): DBIO[Content] =
    findQuery(keyOf(value)).update(value).flatMap {
      case 1 => DBIO.successful(value)
      case n => DBIO.failed(new Throwable(s"Unexpected number of updates. Expected 1, but got $n"))
    }

  private def findQuery(key: Key): Query[Table, Content, Seq] =
    findPartialQuery(compare)(key)

}

object DAOCompanion {

  type FindPredicate[Table, Part] = (Table, Part) => Rep[Boolean]

  def apply[Content, Table <: RelationalProfile#Table[Content], Key](
      _table: TableQuery[Table],
      _compare: (Table, Key) => Rep[Boolean]
  ): DAOCompanion[Content, Table, Key] =
    new DAOCompanion[Content, Table, Key] {
      self =>
      override val table: TableQuery[Table] = _table
      override val compare: (Table, Key) => Rep[Boolean] = _compare
    }

}
