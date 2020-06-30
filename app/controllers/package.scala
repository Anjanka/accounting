import scala.concurrent.{ ExecutionContext, Future }
import play.api.mvc.ControllerHelpers.InternalServerError
import play.api.mvc.Result
package object controllers {

  object syntax {

    implicit class ServerErrorOps(val future: Future[Result]) extends AnyVal {

      def recoverServerError(implicit executionContext: ExecutionContext): Future[Result] =
        future.recover { case ex => InternalServerError(ex.getMessage) }

    }

  }

}
