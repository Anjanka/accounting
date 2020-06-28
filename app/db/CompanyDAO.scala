package db

import base.Id.CompanyKey
import javax.inject.Inject
import play.api.db.slick.{ DatabaseConfigProvider, HasDatabaseConfigProvider }
import slick.jdbc.PostgresProfile

import scala.concurrent.ExecutionContext

class CompanyDAO @Inject() (override protected val dbConfigProvider: DatabaseConfigProvider)(implicit
    executionContext: ExecutionContext
) extends HasDatabaseConfigProvider[PostgresProfile] {
  val dao: DAO[Company, Tables.CompanyTable, CompanyKey] = DAO(CompanyDAO.daoCompanion, dbConfigProvider)
}

object CompanyDAO {

  import PostgresProfile.api._

  val daoCompanion: DAOCompanion[Company, Tables.CompanyTable, CompanyKey] = DAOCompanion(
    _table = Tables.companyTable,
    _compare = (comp, companyKey) => comp.id === companyKey.id
  )

  def nextId(implicit ec: ExecutionContext): DBIO[Int] =
    daoCompanion.allAction.map { companies =>
      if (companies.isEmpty) 1
      else companies.maxBy(_.id).id + 1
    }

}
