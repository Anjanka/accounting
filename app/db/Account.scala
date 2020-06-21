package db

import io.circe.generic.JsonCodec

@JsonCodec
case class Account(companyId: Int,
                   id: Int,
                   title: String)
