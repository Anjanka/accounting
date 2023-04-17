package action

import play.api.mvc.{ Request, WrappedRequest }

case class UserRequest[A](
    request: Request[A]
) extends WrappedRequest[A](request)
