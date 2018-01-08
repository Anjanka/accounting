package base

import java.util.Date


trait AEntry {

  //todo add comments
  def orderId: Int

  //Todo #7 switch to own Date type
  def date: Date

  def receiptNumber: Int
  def description: String
  def credit: Account
  def debit: Account
  def amount: MonetaryValue
}


