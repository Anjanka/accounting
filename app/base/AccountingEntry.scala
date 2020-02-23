package base

import java.time.Year
import java.util.Date


trait AccountingEntry {

  //todo add comments
  def orderId: Int
  def accountingYear: Year

  //Todo #7 switch to own Date type
  def bookingDate: Date

  def receiptNumber: String
  def description: String
  def credit: Account //SOLL
  def debit: Account  //HABEN
  def amount: MonetaryValue
}


