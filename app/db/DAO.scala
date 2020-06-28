package db

import play.api.db.slick.{ DatabaseConfigProvider, HasDatabaseConfigProvider }
import slick.jdbc.PostgresProfile
import slick.lifted.Rep
import slick.relational.RelationalProfile

import scala.concurrent.{ ExecutionContext, Future }

trait DAO[Content, Table <: RelationalProfile#Table[Content], Key] extends HasDatabaseConfigProvider[PostgresProfile] {

  protected implicit def executionContext: ExecutionContext

  def daoCompanion: DAOCompanion[Content, Table, Key]

  def find(key: Key): Future[Option[Content]] = db.run(daoCompanion.findAction(key))

  def findPartial[Part](part: Part)(compare: (Table, Part) => Rep[Boolean]): Future[Seq[Content]] =
    db.run(daoCompanion.findPartialAction(part)(compare))

  def delete(key: Key): Future[Unit] = db.run(daoCompanion.deleteAction(key))

  def all: Future[Seq[Content]] = db.run(daoCompanion.allAction)

  def repsert(
      value: Content
  ): Future[Content] = db.run(daoCompanion.repsertAction(value))

}

object DAO {

  def apply[Content, Table <: RelationalProfile#Table[Content], Key](
      _daoCompanion: DAOCompanion[Content, Table, Key],
      _dbConfigProvider: DatabaseConfigProvider
  )(implicit _executionContext: ExecutionContext): DAO[Content, Table, Key] = {
    new DAO[Content, Table, Key] {
      override protected val executionContext: ExecutionContext = _executionContext
      override val daoCompanion: DAOCompanion[Content, Table, Key] = _daoCompanion
      override protected val dbConfigProvider: DatabaseConfigProvider = _dbConfigProvider
    }
  }

}
