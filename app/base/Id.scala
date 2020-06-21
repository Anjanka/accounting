package base



import io.circe.generic.JsonCodec

object Id {
  @JsonCodec
  case class AccountingEntryTemplateKey(companyID : Int, description: String)

  @JsonCodec
  case class AccountingEntryKey(companyID: Int, id: Int, accountingYear: Int)

  @JsonCodec
  case class AccountKey(companyID: Int, id: Int)
}
