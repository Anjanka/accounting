package db.creation

import db.Company
import io.circe.generic.JsonCodec

@JsonCodec
case class CompanyCreationParams(
    name: String,
    address: String,
    postalCode: String,
    city: String,
    country: String,
    taxNumber: String,
    revenueOffice: String
)

object CompanyCreationParams {

  def create(id: Int, companyCreationParams: CompanyCreationParams): Company =
    Company(
      id = id,
      name = companyCreationParams.name,
      address = companyCreationParams.address,
      postalCode = companyCreationParams.postalCode,
      city = companyCreationParams.city,
      country = companyCreationParams.country,
      taxNumber = companyCreationParams.taxNumber,
      revenueOffice = companyCreationParams.revenueOffice
    )

}
