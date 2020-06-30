package db

import base.Id.AccountingEntryTemplateKey
import io.circe.generic.JsonCodec

@JsonCodec
case class AccountingEntryTemplate(
    description: String,
    credit: Int,
    debit: Int,
    amountWhole: Int,
    amountChange: Int,
    companyId: Int
)

object AccountingEntryTemplate {

  def keyOf(accountingEntryTemplate: AccountingEntryTemplate): AccountingEntryTemplateKey =
    AccountingEntryTemplateKey(
      companyID = accountingEntryTemplate.companyId,
      description = accountingEntryTemplate.description
    )

}
