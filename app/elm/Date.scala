package elm

import io.circe.generic.JsonCodec

@JsonCodec
case class Date(year: Int,
                month: Int,
                day: Int)