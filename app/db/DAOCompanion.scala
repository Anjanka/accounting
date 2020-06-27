package db

import db.DAOCompanion.FindPredicate
import slick.jdbc.PostgresProfile.api._
import slick.lifted.{Rep, TableQuery}
import slick.relational.RelationalProfile

import scala.concurrent.ExecutionContext

trait DAOCompanion[Table <: RelationalProfile#Table[_], Key] {

  def table: TableQuery[Table]

  def compare: FindPredicate[Table, Key]

  def findAction(key: Key): DBIO[Option[Table#TableElementType]] =
    findQuery(key).result.headOption

  def findPartialAction[Part](
      part: Part
  )(partCompare: FindPredicate[Table, Part]): DBIO[Seq[Table#TableElementType]] =
    findPartialQuery(partCompare)(part).result

  def findPartialQuery[Part](
      partCompare: FindPredicate[Table, Part]
  )(part: Part): Query[Table, Table#TableElementType, Seq] =
    table.filter(partCompare(_, part))

  def allAction: DBIO[Seq[Table#TableElementType]] =
    table.result

  def deleteAction(key: Key)(implicit ec: ExecutionContext): DBIO[Unit] =
    findQuery(key).delete.map(_ => ())

  def repsertAction(
      value: Table#TableElementType,
      validate: Table#TableElementType => Boolean = _ => true
  )(implicit ec: ExecutionContext): DBIO[Table#TableElementType] =
    table.returning(table).insertOrUpdate(value).flatMap {
      case Some(element) if validate(element) => DBIO.successful(element)
      case Some(element) =>
        DBIO.failed(new Throwable(s"Inserted value $element doesn't match given value $value."))
      case None => DBIO.successful(value)
    }

  private def findQuery(key: Key): Query[Table, Table#TableElementType, Seq] =
    findPartialQuery(compare)(key)

}

object DAOCompanion {

  type FindPredicate[Table, Part] = (Table, Part) => Rep[Boolean]

  def apply[Table <: RelationalProfile#Table[_], Key](
      _table: TableQuery[Table],
      _compare: (Table, Key) => Rep[Boolean]
  ): DAOCompanion[Table, Key] =
    new DAOCompanion[Table, Key] { self =>
      override val table: TableQuery[Table] = _table
      override val compare: (Table, Key) => Rep[Boolean] = _compare
    }

}
