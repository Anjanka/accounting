package db

import play.api.db.slick.{DatabaseConfigProvider, HasDatabaseConfigProvider}
import slick.jdbc.PostgresProfile
import slick.lifted.Rep
import slick.relational.RelationalProfile

import scala.concurrent.{ExecutionContext, Future}

trait DAO[Table <: RelationalProfile#Table[_], Key] extends HasDatabaseConfigProvider[PostgresProfile] {

  protected implicit def executionContext: ExecutionContext

  def daoCompanion: DAOCompanion[Table, Key]

  def find(key: Key): Future[Option[Table#TableElementType]] = db.run(daoCompanion.findAction(key))

  def findPartial[Part](compare: (Table, Part) => Rep[Boolean])(part: Part): Future[Seq[Table#TableElementType]] =
    db.run(daoCompanion.findPartialAction(compare)(part))

  def delete(key: Key): Future[Unit] = db.run(daoCompanion.deleteAction(key))

  def all: Future[Seq[Table#TableElementType]] = db.run(daoCompanion.allAction)

  def repsert(value: Table#TableElementType): Future[Table#TableElementType] = db.run(daoCompanion.repsertAction(value))
}

object DAO {

  def apply[Table <: RelationalProfile#Table[_], Key](
      _daoCompanion: DAOCompanion[Table, Key],
      _dbConfigProvider: DatabaseConfigProvider
  )(implicit _executionContext: ExecutionContext): DAO[Table, Key] = {
    new DAO[Table, Key] {
      override protected val executionContext: ExecutionContext = _executionContext
      override val daoCompanion: DAOCompanion[Table, Key] = _daoCompanion
      override protected val dbConfigProvider: DatabaseConfigProvider = _dbConfigProvider
    }
  }

}
