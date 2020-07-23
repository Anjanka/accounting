package controllers

import java.io.ByteArrayInputStream

import akka.stream.scaladsl.StreamConverters
import db.AccountingEntryDAO
import javax.inject.Inject
import play.api.mvc.{Action, AnyContent, BaseController, ControllerComponents}
import report.{ReportCreator, TestMe}

import scala.concurrent.duration.Duration
import scala.concurrent.{Await, ExecutionContext}

class ReportController @Inject() (accountingEntryDAO: AccountingEntryDAO,
                                  val controllerComponents: ControllerComponents)(implicit
    ec: ExecutionContext
) extends BaseController {

  def test: Action[AnyContent] =
    Action {
      val reportCreator = ReportCreator()
      val allEntries = Await.result(accountingEntryDAO.dao.all, Duration.Inf)
      val dataContent = StreamConverters.fromInputStream(() =>
        new ByteArrayInputStream(reportCreator.createPdf(TestMe.mkReport(allEntries)).toByteArray)
      )
      Ok.streamed(
        dataContent,
        contentLength = None,
        inline = false,
        fileName = Some("test.pdf")
      ).withHeaders(("Content-Type", "pdf"))

    }

}
