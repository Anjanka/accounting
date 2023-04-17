package controllers.user

import play.api.libs.circe.Circe
import play.api.mvc.{AbstractController, ControllerComponents}

import javax.inject.Inject
import scala.concurrent.ExecutionContext

class UserController @Inject() (
    cc: ControllerComponents,
    userConfiguration: UserConfiguration
)(implicit
    executionContext: ExecutionContext
) extends AbstractController(cc)
    with Circe
