package base



import io.circe.generic.JsonCodec

object Id {
  @JsonCodec
  case class AccountingEntryTemplateKey(id: Int)

  @JsonCodec
  case class AccountingEntryKey(companyId: Int, id: Int, accountingYear: Int)

  @JsonCodec
  case class AccountKey(companyId: Int, id: Int)

  @JsonCodec
  case class CompanyKey(id: Int)
}
