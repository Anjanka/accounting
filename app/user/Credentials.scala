package user

import io.circe.generic.JsonCodec

@JsonCodec
case class Credentials(
    username: String,
    password: String
)
