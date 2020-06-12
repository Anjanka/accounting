package db

import io.circe.generic.JsonCodec

@JsonCodec
case class DBAccountingEntryTemplate(description: String,
                                     credit: Int,
                                     debit: Int,
                                     amountWhole: Int,
                                     amountChange: Int
                                    )
