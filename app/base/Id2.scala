package base

import io.circe.generic.JsonCodec

@JsonCodec
case class Id2[I1, I2](id1: I1, id2: I2)
