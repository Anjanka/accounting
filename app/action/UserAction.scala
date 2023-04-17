package action

import cats.data.EitherT
import controllers.user.UserConfiguration
import io.circe.syntax._
import play.api.libs.circe.Circe
import play.api.mvc._
import security.jwt.{ JwtConfiguration, LoginContent }
import utils.jwt.JwtUtil

import javax.inject.Inject
import scala.concurrent.{ ExecutionContext, Future }

class UserAction @Inject() (
    override val parse: PlayBodyParsers
)(implicit override val executionContext: ExecutionContext)
    extends ActionBuilder[UserRequest, AnyContent]
    with ActionRefiner[Request, UserRequest]
    with Circe {

  private val userConfiguration = UserConfiguration.default

  override protected def refine[A](request: Request[A]): Future[Either[Result, UserRequest[A]]] = {
    val transformer = for {
      token <- EitherT.fromOption[Future](
        request.headers.get(RequestHeaders.userToken),
        "No user token found in request"
      )
      loginContent <- EitherT.fromEither[Future](
        JwtUtil.validateJwt[LoginContent](token, JwtConfiguration.default.signaturePublicKey)
      )
      _ <- EitherT.cond[Future](loginContent.userId == userConfiguration.id, (), "Unexpected user id")
    } yield UserRequest(
      request = request
    )

    transformer
      .leftMap(error => Results.Unauthorized(error))
      .value
  }

  override val parser: BodyParser[AnyContent] = new BodyParsers.Default(parse)
}
