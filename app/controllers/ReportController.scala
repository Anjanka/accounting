package controllers
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
    val dataContent = StreamConverters.fromInputStream(() => reportCreator.createPdf(TestMe.xml).newInputStream())
    Ok.chunked(
      dataContent
    )

  }


}
