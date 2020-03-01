package db


import java.sql.Date

import base.Account
import slick.lifted.{ProvenShape, Tag}
import slick.lifted.Shape._
import slick.jdbc.PostgresProfile.api._

object Tables {

  class AccountDB(tag: Tag) extends Table[Account](_tableTag = tag, _tableName = "account") {
    def id: Rep[Int] = column[Int]("id", O.PrimaryKey)

    def title: Rep[String] = column[String]("title")

    override def * : ProvenShape[Account] = (id, title) <> ( {
      case (i, t) => Account(i, t)
    }, Account.unapply)
  }

  val accountTable: TableQuery[AccountDB] = TableQuery[AccountDB]

  class DBAccountingEntryDB(tag: Tag) extends Table[DBAccountingEntry](_tableTag = tag, _tableName = "accounting_entry") {
    def id: Rep[Int] = column[Int]("id", O.PrimaryKey)

    def accountingYear: Rep[Int] = column[Int]("accounting_year", O.PrimaryKey)

    def bookingDate: Rep[Date] = column[Date]("booking_date")

    def receiptNumber: Rep[String] = column[String]("receipt_number")

    def description: Rep[String] = column[String]("description")

    def credit: Rep[Int] = column[Int]("credit")

    def debit: Rep[Int] = column[Int]("debit")

    def amountWhole: Rep[Int] = column[Int]("amount_whole")

    def amountChange: Rep[Int] = column[Int]("amount_change")

    override def * : ProvenShape[DBAccountingEntry] = (id, accountingYear, bookingDate, receiptNumber, description, credit, debit, amountWhole, amountChange) <> ((DBAccountingEntry.apply _).tupled, DBAccountingEntry.unapply)
  }

  val dbAccountingEntryTable: TableQuery[DBAccountingEntryDB] = TableQuery[DBAccountingEntryDB]
}
