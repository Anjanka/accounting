package controllers
import java.io.ByteArrayInputStream

import akka.stream.scaladsl.StreamConverters
import javax.inject.Inject
import play.api.mvc.{Action, AnyContent, BaseController, ControllerComponents}
import report.{ReportCreator, TestMe}

import scala.concurrent.ExecutionContext

class ReportController @Inject() (val controllerComponents: ControllerComponents)(implicit
                                                                                  ec: ExecutionContext
) extends BaseController {

  def test: Action[AnyContent] = Action {
    val reportCreator = ReportCreator()
    val dataContent = StreamConverters.fromInputStream(() => new ByteArrayInputStream(reportCreator.createPdf(TestMe.xml).toByteArray))
    Ok.chunked(
      dataContent
    )

  }


}
