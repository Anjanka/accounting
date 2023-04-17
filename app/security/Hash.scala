package security

import javax.crypto.SecretKeyFactory
import javax.crypto.spec.PBEKeySpec
import utils.string.StringUtil.syntax._

object Hash {

  private val hashAlgorithm: String = "PBKDF2WithHmacSHA256"
  private val signatureHashAlgorithm: String = "SHA-384"
  private val keyLength: Int = 512

  val defaultIterations: Int = 120000

  def fromPassword(password: String, salt: String, iterations: Int): String = {
    SecretKeyFactory
      .getInstance(hashAlgorithm)
      .generateSecret(new PBEKeySpec(password.toCharArray, salt.getBytes(), iterations.intValue, keyLength))
      .getEncoded
      .asBase64String
  }

  def verify(password: String, passwordParameters: PasswordParameters): Boolean =
    fromPassword(password, passwordParameters.salt, passwordParameters.iterations) == passwordParameters.hash

}
