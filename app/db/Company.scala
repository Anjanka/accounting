package db

import base.Id.CompanyKey
import io.circe.generic.JsonCodec

@JsonCodec
case class Company(
    id: Int,
    name: String,
    address: String,
    taxNumber: String,
    revenueOffice: String,
    postalCode: String,
    city: String,
    country: String
)

object Company { def keyOf(company: Company): CompanyKey = CompanyKey(id = company.id) }
