package db

import base.Id
import javax.inject.Inject
import play.api.db.slick.{DatabaseConfigProvider, HasDatabaseConfigProvider}
import slick.jdbc.PostgresProfile
import slick.jdbc.PostgresProfile.api._

import scala.concurrent.{ExecutionContext, Future}

class CompanyDAO @Inject()(override protected val dbConfigProvider: DatabaseConfigProvider)
                          (implicit executionContext: ExecutionContext)
  extends HasDatabaseConfigProvider[PostgresProfile] {
  def findCompany(companyKey : Id.CompanyKey): Future[Option[Company]] = db.run(CompanyDAO.findCompanyAction(companyKey))

  def deleteCompany(companyKey : Id.CompanyKey): Future[Unit] = db.run(CompanyDAO.deleteCompanyAction(companyKey))

  def repsertCompany(company: Company): Future[Company] = db.run(CompanyDAO.repsertCompanyAction(company))

  def getAllCompanies: Future[Seq[Company]] = db.run(CompanyDAO.getAllCompaniesAction)
}

object CompanyDAO {

  def findCompanyAction(companyKey : Id.CompanyKey): DBIO[Option[Company]] = Tables.companyTable.filter(com => com.id === companyKey.id).result.headOption

  def deleteCompanyAction(companyKey : Id.CompanyKey)(implicit ec: ExecutionContext): DBIO[Unit] = Tables.companyTable.filter(com => com.id === companyKey.id).delete.map(_ => ())

  def repsertCompanyAction(company: Company)(implicit ec: ExecutionContext): DBIO[Company] = Tables.companyTable.returning(Tables.companyTable).insertOrUpdate(company).map {
    case Some(value) => value
    case None => company
  }

  def getAllCompaniesAction : DBIO[Seq[Company]] = Tables.companyTable.result

}
