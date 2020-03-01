package db

import java.util.Date


case class DBAccountingEntry(id: Int,
                             accountingYear: Int,
                             bookingDate: Date,
                             receiptNumber: String,
                             description: String,
                             credit: Int,
                             debit: Int,
                             amountWhole: Int,
                             amountChange: Int)
