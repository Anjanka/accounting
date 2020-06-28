package db.creation

import db.Company
import io.circe.generic.JsonCodec

@JsonCodec
case class CompanyCreationParams(name: String, address: String, taxNumber: String, revenueOffice: String)

object CompanyCreationParams {

  def create(id: Int, companyCreationParams: CompanyCreationParams): Company =
    Company(
      id = id,
      name = companyCreationParams.name,
      address = companyCreationParams.address,
      taxNumber = companyCreationParams.taxNumber,
      revenueOffice = companyCreationParams.revenueOffice
    )

}
