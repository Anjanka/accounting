package abstraction

import java.sql.Date
import java.time.Year

import base.MonetaryValue

case class AccountingEntry(id: Int,
                           accountingYear: Year,
                           //Todo #7 switch to own Date type
                           bookingDate: Date,
                           receiptNumber: String,
                           description: String,
                           credit: Account, //SOLL
                           debit: Account, //HABEN
                           amount: MonetaryValue)
