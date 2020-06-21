package db

import io.circe.generic.JsonCodec

@JsonCodec
case class AccountingEntryTemplate(companyId: Int,
                                    description: String,
                                   credit: Int,
                                   debit: Int,
                                   amountWhole: Int,
                                   amountChange: Int
                                    )
