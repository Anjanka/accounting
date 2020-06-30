package db.creation

import db.AccountingEntryTemplate
import io.circe.generic.JsonCodec

@JsonCodec
case class AccountingEntryTemplateCreationParams(
    description: String,
    credit: Int,
    debit: Int,
    amountWhole: Int,
    amountChange: Int,
    companyId: Int
)

object AccountingEntryTemplateCreationParams {

  def create(
      id: Int,
      accountingEntryTemplateCreationParams: AccountingEntryTemplateCreationParams
  ): AccountingEntryTemplate =
    AccountingEntryTemplate(
      description = accountingEntryTemplateCreationParams.description,
      credit = accountingEntryTemplateCreationParams.credit,
      debit = accountingEntryTemplateCreationParams.debit,
      amountWhole = accountingEntryTemplateCreationParams.amountWhole,
      amountChange = accountingEntryTemplateCreationParams.amountChange,
      companyId = accountingEntryTemplateCreationParams.companyId,
      id = id
    )

}
