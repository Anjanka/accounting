package security

case class PasswordParameters(
    hash: String,
    salt: String,
    iterations: Int
)
