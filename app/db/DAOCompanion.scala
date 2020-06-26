package db

import slick.jdbc.PostgresProfile.api._
import slick.lifted.{ Rep, TableQuery }
import slick.relational.RelationalProfile

import scala.concurrent.ExecutionContext

trait DAOCompanion[Table <: RelationalProfile#Table[_], Key] {

  def table: TableQuery[Table]

  def compare: (Table, Key) => Rep[Boolean]

  def findAction(key: Key): DBIO[Option[Table#TableElementType]] =
    findQuery(key).result.headOption

  def findPartialAction[Part](
      part: Part
  )(partCompare: (Table, Part) => Rep[Boolean]): DBIO[Seq[Table#TableElementType]] =
    findPartialQuery(partCompare)(part).result

  def findPartialQuery[Part](
      partCompare: (Table, Part) => Rep[Boolean]
  )(part: Part): Query[Table, Table#TableElementType, Seq] =
    table.filter(partCompare(_, part))

  def allAction: DBIO[Seq[Table#TableElementType]] =
    table.result

  def deleteAction(key: Key)(implicit ec: ExecutionContext): DBIO[Unit] =
    findQuery(key).delete.map(_ => ())

  def repsertAction(value: Table#TableElementType)(implicit ec: ExecutionContext): DBIO[Table#TableElementType] =
    table.returning(table).insertOrUpdate(value).map(_.getOrElse(value))

  private def findQuery(key: Key): Query[Table, Table#TableElementType, Seq] =
    findPartialQuery(compare)(key)

}

object DAOCompanion {

  def apply[Table <: RelationalProfile#Table[_], Key](
      _table: TableQuery[Table],
      _compare: (Table, Key) => Rep[Boolean]
  ): DAOCompanion[Table, Key] =
    new DAOCompanion[Table, Key] { self =>
      override val table: TableQuery[Table] = _table
      override val compare: (Table, Key) => Rep[Boolean] = _compare
    }

}
