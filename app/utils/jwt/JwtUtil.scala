package utils.jwt

import io.circe.syntax._
import io.circe.{ Decoder, Encoder }
import pdi.jwt.{ JwtAlgorithm, JwtCirce, JwtClaim, JwtHeader }
import pdi.jwt.algorithms.JwtAsymmetricAlgorithm
import security.jwt.JwtExpiration

object JwtUtil {

  private val signatureAlgorithm: JwtAsymmetricAlgorithm = JwtAlgorithm.RS256

  def validateJwt[A: Decoder](token: String, publicKey: String): Either[String, A] =
    JwtCirce
      .decode(token, publicKey, Seq(signatureAlgorithm))
      .toEither
      .left
      .map(_ => "Decoding of token failed")
      .flatMap { jwtClaim =>
        io.circe.parser
          .decode[A](jwtClaim.content)
          .left
          .map(_ => "Unexpected token content")
      }

  def createJwt[A: Encoder](content: A, privateKey: String, expiration: JwtExpiration): String =
    JwtCirce.encode(
      header = JwtHeader(algorithm = signatureAlgorithm),
      claim = JwtClaim(
        content = content.asJson.noSpaces,
        expiration = expiration.expirationAt,
        notBefore = expiration.notBefore
      ),
      key = privateKey
    )

}
