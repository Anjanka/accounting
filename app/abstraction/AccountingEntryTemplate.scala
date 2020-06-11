package abstraction

import base.MonetaryValue

case class AccountingEntryTemplate(description: String,
                                   credit: Account, //SOLL
                                   debit: Account, //HABEN
                                   amount: MonetaryValue)
