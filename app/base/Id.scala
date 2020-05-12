package base

import io.circe.generic.JsonCodec

@JsonCodec
case class Id[I](id: I)
