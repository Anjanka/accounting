package controllers

import db.AccountDAO
import io.circe.syntax._
import javax.inject._
import play.api.mvc._

import scala.concurrent.ExecutionContext

/**
 * This controller creates an `Action` to handle HTTP requests to the
 * application's home page.
 */
@Singleton
class HomeController @Inject()(val controllerComponents: ControllerComponents,
                               val accountDAO: AccountDAO)(implicit ec: ExecutionContext)
  extends BaseController {

  /**
   * Create an Action to render an HTML page.
   *
   * The configuration in the `routes` file means that this method
   * will be called when the application receives a `GET` request with
   * a path of `/`.
   */
  def index() = Action { implicit request: Request[AnyContent] =>
    Ok(views.html.index())
  }

  def getAccount(id: Int) = Action.async {
    accountDAO.findAccount(id).map {
      x =>
        Ok(x.asJson.noSpaces)
    }
  }
}
