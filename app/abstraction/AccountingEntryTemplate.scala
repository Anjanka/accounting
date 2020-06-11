package abstraction

import base.{Account, MonetaryValue}
import io.circe.generic.JsonCodec

@JsonCodec
case class AccountingEntryTemplate(description: String,
                                   credit: Account, //SOLL
                                   debit: Account, //HABEN
                                   amount: MonetaryValue)