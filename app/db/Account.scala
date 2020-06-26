package db

import io.circe.generic.JsonCodec
@JsonCodec
case class Account(id: Int, title: String, companyId: Int)
