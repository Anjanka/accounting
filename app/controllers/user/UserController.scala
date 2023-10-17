package controllers.user

import io.circe.syntax._
import play.api.libs.circe.Circe
import play.api.mvc.{ AbstractController, Action, ControllerComponents }
import security.jwt.{ JwtConfiguration, JwtExpiration, LoginContent }
import user.Credentials
import utils.jwt.JwtUtil

import javax.inject.Inject
import scala.util.chaining._

class UserController @Inject() (
    cc: ControllerComponents
) extends AbstractController(cc)
    with Circe {

  private val jwtConfiguration = JwtConfiguration.default

  private val userConfiguration = UserConfiguration.default

  def login: Action[Credentials] =
    Action(circe.tolerantJson[Credentials]) { request =>
      val credentials = request.body
      val jwtCandidate =
        if (UserConfiguration.validateCredentials(credentials, userConfiguration)) {
          val jwt = JwtUtil.createJwt(
            content = LoginContent(
              userId = userConfiguration.id
            ),
            privateKey = jwtConfiguration.signaturePrivateKey,
            expiration = JwtExpiration.Expiring(
              start = System.currentTimeMillis() / 1000,
              duration = jwtConfiguration.restrictedDurationInSeconds
            )
          )
          Some(jwt)
        } else None

      jwtCandidate
        .fold(
          BadRequest("Invalid credentials")
        )(
          _.pipe(_.asJson)
            .pipe(Ok(_))
        )
    }

}
