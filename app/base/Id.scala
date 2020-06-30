package base



import io.circe.generic.JsonCodec

object Id {
  @JsonCodec
  case class AccountingEntryTemplateKey(id: Int)

  @JsonCodec
  case class AccountingEntryKey(companyID: Int, id: Int, accountingYear: Int)

  @JsonCodec
  case class AccountKey(companyID: Int, id: Int)

  @JsonCodec
  case class CompanyKey(id: Int)
}
