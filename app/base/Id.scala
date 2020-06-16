package base

import io.circe.generic.JsonCodec

object Id {
  @JsonCodec
  case class IdString(id: String)

  @JsonCodec
  case class IdInt(id: Int)
}
