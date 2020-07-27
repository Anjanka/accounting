package controllers

import java.io.ByteArrayInputStream

import akka.stream.scaladsl.StreamConverters
import base.Id.CompanyKey
import db.{AccountingEntryDAO, CompanyDAO}
import javax.inject.Inject
import play.api.mvc.{Action, AnyContent, BaseController, ControllerComponents}
import report.{ReportCreator, TestMe}

import scala.concurrent.duration.Duration
import scala.concurrent.{Await, ExecutionContext}

class ReportController @Inject() (
    accountingEntryDAO: AccountingEntryDAO,
    companyDAO: CompanyDAO,
    val controllerComponents: ControllerComponents
)(implicit
    ec: ExecutionContext
) extends BaseController {

  def test: Action[AnyContent] =
    Action {
      val reportCreator = ReportCreator()
      // TODO: Use proper values here
      val allEntries = Await.result(accountingEntryDAO.dao.all, Duration.Inf)
      val accountingYear = 2020
      val company = Await.result(companyDAO.dao.find(CompanyKey(1)), Duration.Inf).get
      val dataContent = StreamConverters.fromInputStream(() =>
        new ByteArrayInputStream(reportCreator.createPdf(TestMe.mkReport(company, accountingYear, allEntries)).toByteArray)
      )
      Ok.streamed(
        dataContent,
        contentLength = None,
        inline = false,
        fileName = Some("test.pdf")
      ).withHeaders(("Content-Type", "pdf"))

    }

}