package base

import java.sql.Date

import base.NominalAccountEntry.{Credit, Debit}

import Numeric.Implicits._

case class NominalAccount(accountId: Int, accountName: String, lastBookingDate: Date, entries: Seq[NominalAccountEntry]) {

  val debitBalance: MonetaryValue =
    entries
      .map(entry => entry.amount)
      .collect { case Debit(monetaryValue) => monetaryValue }
      .sum

  val creditBalance: MonetaryValue =
    entries
      .map(entry => entry.amount)
      .collect { case Credit(value) => value }
      .sum

  val openingBalance: MonetaryValue = {
      entries
        .filter(_.openingBalance)
        .map(entry => entry.amount)
        .collect { case Debit(monetaryValue) => monetaryValue }
        .sum
  }

  val revenue : MonetaryValue = {
    debitBalance - openingBalance
  }

  val balance: MonetaryValue = {
    (creditBalance - debitBalance).abs
  }


}
