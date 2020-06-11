package db

import io.circe.generic.JsonCodec

@JsonCodec
case class DBAccount(id: Int,
                     title: String)
