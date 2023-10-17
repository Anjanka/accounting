package controllers.user

import pureconfig.{ CamelCase, ConfigFieldMapping, ConfigSource }
import pureconfig.generic.ProductHint
import security.{ Hash, PasswordParameters }
import user.Credentials
import pureconfig.generic.auto._

import java.util.UUID

case class UserConfiguration(
    id: UUID,
    salt: String,
    hash: String
)

object UserConfiguration {

  implicit def hint[A]: ProductHint[A] = ProductHint[A](ConfigFieldMapping(CamelCase, CamelCase))

  val default: UserConfiguration = ConfigSource.default
    .at("userConfiguration")
    .loadOrThrow[UserConfiguration]

  def validateCredentials(
      credentials: Credentials,
      userConfiguration: UserConfiguration
  ): Boolean =
    Hash.verify(
      password = credentials.password,
      passwordParameters = PasswordParameters(
        hash = userConfiguration.hash,
        salt = userConfiguration.salt,
        iterations = Hash.defaultIterations
      )
    )

}
