package db

import io.circe.generic.JsonCodec
@JsonCodec
case class Company(id: Int, name: String, address: String, taxnumber: String, revenueoffice: String)
